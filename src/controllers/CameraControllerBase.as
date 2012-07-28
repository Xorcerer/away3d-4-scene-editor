/**
 * Created with IntelliJ IDEA.
 * User: logan
 * Date: 7/29/12
 * Time: 4:30 AM
 * To change this template use File | Settings | File Templates.
 */
package controllers
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;

	public class CameraControllerBase
	{
		protected var _view:View3D;

		public function CameraControllerBase(view:View3D)
		{
			_view = view;
		}

		public function get camera():Camera3D
		{
			return _view.camera;
		}
	}
}
