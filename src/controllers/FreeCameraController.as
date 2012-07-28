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

	import flash.events.KeyboardEvent;

	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;

	import parsers.DDSParser;
	import parsers.Max3DSParser;

	import parsers.SceneLoader;

	import utils.Log;
	import utils.Res;

	public class FreeCameraController
	{
		private var _view:View3D;

		public function FreeCameraController(view:View3D)
		{
			_view = view;
			_view.parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			const step:Number = 20;
			switch (e.keyCode)
			{
				case  Keyboard.UP:
					if (e.shiftKey)
						_view.camera.moveForward(step);
					else
						_view.camera.moveUp(step);
					break;
				case Keyboard.DOWN:
					if (e.shiftKey)
						_view.camera.moveBackward(step);
					else
						_view.camera.moveDown(step);
					break;
				case Keyboard.LEFT:
					if (e.shiftKey)
						_view.camera.moveLeft(step);
					else
						_view.camera.yaw(step / 2);
					break;
				case Keyboard.RIGHT:
					if (e.shiftKey)
						_view.camera.moveRight(step);
					else
						_view.camera.yaw(-step / 2);
					break;
			}
		}
	}
}
