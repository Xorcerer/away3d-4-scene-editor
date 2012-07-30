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

	import flash.display.Stage;

	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.media.Camera;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;

	public class FreeCameraController extends CameraControllerBase
	{
		public var _lastPosition:Point = null;

		private static const CAMERA_DEFAULT_HEIGHT:Number = 2000;

		private static const CAMERA_FIXED_ANGLE:Number = -30;

		public function FreeCameraController(view:View3D)
		{
			super(view);

			camera.y = CAMERA_DEFAULT_HEIGHT;
			camera.x = 0;
			camera.z = 0;
			camera.lookAt(new Vector3D());
			camera.pitch(CAMERA_FIXED_ANGLE);
			camera.lens.far += CAMERA_DEFAULT_HEIGHT * 2;

			_view.parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_view.parent.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			_view.parent.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_view.parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}

		private function cameraMoveForward(step:Number):void
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
					cameraMoveForward(step);
					break;
				case Keyboard.DOWN:
					cameraMoveForward(-step);
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

		private function onMouseDown(e:MouseEvent):void
		{
			var newPosition:Point = new Point(e.localX, e.localY);
			_lastPosition = newPosition;
		}

		private const MOUSE_DRAG_FACTOR:Number = 0.1;
		private function onMouseMove(e:MouseEvent):void
		{
			if (e.buttonDown)
			{
				var newPosition:Point = new Point(e.localX, e.localY);
				var diff:Point = newPosition.subtract(_lastPosition);
				camera.x += - diff.x * MOUSE_DRAG_FACTOR * camera.y;
				camera.z += diff.y * MOUSE_DRAG_FACTOR * camera.y;
				_lastPosition = newPosition;
			}
		}
	}
}
