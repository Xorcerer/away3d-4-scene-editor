/**
 * Created with IntelliJ IDEA.
 * User: logan
 * Date: 7/25/12
 * Time: 12:52 AM
 * To change this template use File | Settings | File Templates.
 */
package parsers
{
	import controllers.ViewController;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	import utils.Log;
	import utils.Res;

	public class SceneLoader
	{
		private static const SCENES_DIR:String = 'scenes/';

		private var _sceneName:String;
		private var _viewController:ViewController;

		public function SceneLoader(viewController:ViewController, sceneName:String)
		{
			_viewController = viewController;
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
				_viewController.loadMesh(getMeshFilename(meshName), worldPosition);
			}
		}

		private function onIOError(e:IOErrorEvent):void
		{
			Log.e(e.toString());
		}
	}
}
