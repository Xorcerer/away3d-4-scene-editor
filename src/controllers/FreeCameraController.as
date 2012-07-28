/**
 * Created with IntelliJ IDEA.
 * User: logan
 * Date: 7/25/12
 * Time: 2:00 AM
 * To change this template use File | Settings | File Templates.
 */
package controllers
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;

	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;

	public class FreeCameraController extends CameraControllerBase
	{

		public function FreeCameraController(view:View3D)
		{
			super(view);

			_view.parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_view.parent.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}

		private function cameraMoveForword(step:Number):void
		{
			var v:Vector3D = camera.backVector.clone();
			v.y = 0;
			v.scaleBy(-step);
			camera.position = camera.position.add(v);

		}

		private function cameraYaw(step:Number):void
		{
			const y:Number = camera.y;
			camera.yaw(step);
			camera.y = y;

		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			const step:Number = 20;
			switch (e.keyCode)
			{
				case  Keyboard.UP:
					cameraMoveForword(step);
					break;
				case Keyboard.DOWN:
					cameraMoveForword(-step);
					break;
				case Keyboard.LEFT:
					if (e.shiftKey)
						camera.moveLeft(step);
					else
						cameraYaw(step / 2)
					break;
				case Keyboard.RIGHT:
					if (e.shiftKey)
						camera.moveRight(step);
					else
						cameraYaw(-step / 2);
					break;
			}
		}

		private function onMouseWheel(e:MouseEvent):void
		{
			camera.moveForward(e.delta * 10);
		}
	}
}
