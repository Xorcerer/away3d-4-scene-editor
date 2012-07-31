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

		public function FreeCameraController(view:View3D)
		{
			super(view);
			initCamera();
			_view.parent.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_view.parent.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			_view.parent.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_view.parent.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}


		private static const CAMERA_DEFAULT_HEIGHT:Number = 2000;
		private static const CAMERA_FIXED_ANGLE:Number = -30;

		private function initCamera():void
		{
			camera.y = CAMERA_DEFAULT_HEIGHT;
			camera.x = 0;
			camera.z = 0;
			camera.lookAt(new Vector3D());
			camera.pitch(CAMERA_FIXED_ANGLE);
			camera.lens.far += CAMERA_DEFAULT_HEIGHT * 2;
		}

		private function cameraMoveForward(step:Number):void
		{
			var v:Vector3D = camera.backVector.clone();
			v.y = 0;
			v.scaleBy(-step);
			camera.position = camera.position.add(v);

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
						camera.rotate(Vector3D.Y_AXIS, step);
					break;
				case Keyboard.RIGHT:
					if (e.shiftKey)
						camera.moveRight(step);
					else
						camera.rotate(Vector3D.Y_AXIS, -step);
					break;
			}
		}

		private static const MOUSE_WHEEL_MOVE_FACTOR:Number = 10;

		private function onMouseWheel(e:MouseEvent):void
		{
			camera.moveForward(e.delta * MOUSE_WHEEL_MOVE_FACTOR);
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
				var offset:Point = newPosition.subtract(_lastPosition);

				camera.x += - offset.x * MOUSE_DRAG_FACTOR * camera.y;
				camera.z += offset.y * MOUSE_DRAG_FACTOR * camera.y;

				_lastPosition = newPosition;
			}
		}
	}
}
