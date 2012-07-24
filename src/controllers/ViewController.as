/**
 * Created with IntelliJ IDEA.
 * User: logan
 * Date: 7/25/12
 * Time: 2:00 AM
 * To change this template use File | Settings | File Templates.
 */
package controllers
{
	import away3d.containers.View3D;
	import away3d.events.LoaderEvent;
	import away3d.loaders.Loader3D;

	import flash.geom.Vector3D;
	import flash.net.URLRequest;

	import parsers.SceneLoader;

	import utils.Log;
	import utils.Res;

	public class ViewController
	{
		private var _view:View3D;

		public function ViewController(view:View3D)
		{
			_view = view;
		}

		public function loadScene(name:String):void
		{
			var sceneLoader:SceneLoader = new SceneLoader(this, name);
			sceneLoader.load();
		}

		public function loadMesh(name:String, worldPosition:Vector3D):void
		{
			var loader:Loader3D = new Loader3D();
			loader.position = worldPosition;
			loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			loader.addEventListener(LoaderEvent.LOAD_ERROR, onLoadError);
			loader.load(new URLRequest(Res.getPath(name)));
		}

		private function onResourceComplete(e:LoaderEvent):void
		{
			_view.scene.addChild(e.currentTarget as Loader3D);
		}

		private function onLoadError(e:LoaderEvent):void
		{
			Log.e(e.message);
		}
	}
}
