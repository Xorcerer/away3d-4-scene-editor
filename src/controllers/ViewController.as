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

	import parsers.DDSParser;
	import parsers.Max3DSParser;

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
			var sceneLoader:SceneLoader = new SceneLoader(name);
			sceneLoader.load();
		}
	}
}
