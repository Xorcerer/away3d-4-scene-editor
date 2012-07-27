/**
 * Created with IntelliJ IDEA.
 * User: logan
 * Date: 7/25/12
 * Time: 12:52 AM
 * To change this template use File | Settings | File Templates.
 */
package parsers
{
	import away3d.containers.View3D;
	import away3d.events.LoaderEvent;
	import away3d.loaders.Loader3D;

	import controllers.ViewController;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import utils.Log;
	import utils.Res;

	public class SceneLoader extends View3D
	{
		private static const SCENES_DIR:String = 'scenes/';

		private var _sceneName:String;

		public function SceneLoader(sceneName:String)
		{
			_sceneName = sceneName;
		}

		public function load():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError)
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.load(new URLRequest(Res.getPath(sceneFilename)));
		}

		private function get sceneFilename():String
		{
			return SCENES_DIR + _sceneName + '/map.xml';
		}

		private function getMeshFilename(name:String):String
		{
			return SCENES_DIR + _sceneName + '/' + name + '.3ds';
		}

		private function onComplete(e:Event):void
		{
			XML.ignoreComments = true;
			XML.ignoreWhitespace = true;
			var sceneXML:XML = new XML(e.target.data);

			var meshNodes:XMLList = sceneXML.child('mesh');
			for(var i:uint = 0; i < meshNodes.length(); ++i)
			{
				var node:XML = meshNodes[i];
				var meshName:String = node.@name;
				var worldPosition:Vector3D = new Vector3D(node.pos.@x, node.pos.@y, node.pos.@z);
				loadMesh(getMeshFilename(meshName), worldPosition);
			}
		}

		public function loadMesh(name:String, worldPosition:Vector3D):void
		{
			var loader:Loader3D = new Loader3D();
			loader.position = worldPosition;
			loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			loader.addEventListener(LoaderEvent.LOAD_ERROR, onLoadError);
			loader.load(new URLRequest(Res.getPath(name)), null,  null, new Max3DSParser());
		}

		private function onIOError(e:IOErrorEvent):void
		{
			Log.e(e.toString());
		}

		private function onResourceComplete(e:LoaderEvent):void
		{
			scene.addChild(e.currentTarget as Loader3D);
		}

		private function onLoadError(e:LoaderEvent):void
		{
			Log.e(e.message);
		}
	}
}
