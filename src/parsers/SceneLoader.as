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

	import flash.net.URLRequest;

	import utils.Log;
	import utils.Res;

	public class SceneLoader extends View3D
	{
		private static const SCENES_DIR:String = 'scenes/';

		public function SceneLoader()
		{
			backgroundColor = 0x0;
			antiAlias = 4;
		}

		public function load(sceneName:String):void
		{
			var loader:Loader3D = new Loader3D();
			addListeners(loader);

			loader.load(new URLRequest(Res.getPath(getSceneFilename(sceneName))));
		}

		private static function getSceneFilename(sceneName:String):String
		{
			return SCENES_DIR + sceneName + '/map.xml';
		}

		private function addListeners(loader:Loader3D):void
		{
			loader.addEventListener(LoaderEvent.LOAD_ERROR, onLoadError);
			loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
		}

		private function removeListeners(loader:Loader3D):void
		{
			loader.removeEventListener(LoaderEvent.LOAD_ERROR, onLoadError);
			loader.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
		}

		private function onResourceComplete(e:LoaderEvent):void
		{
			var loader:Loader3D = e.currentTarget as Loader3D;
			removeListeners(loader);
			scene.addChild(loader);
		}

		private function onLoadError(e:LoaderEvent):void
		{
			removeListeners(e.currentTarget as Loader3D);
			Log.e(e.message);
		}
	}
}
