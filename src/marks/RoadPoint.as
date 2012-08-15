package marks
{
	import utils.*;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.primitives.SphereGeometry;

	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class RoadPoint extends Mesh
	{
		private static const SPHERE:SphereGeometry = new SphereGeometry(50);
		private static const DARK_RED:uint = 0x441100;
		private static const MATERIAL:MaterialBase = new ColorMaterial(DARK_RED);
		private static const DEFAULT_HEIGHT:Number = 100;

		public function RoadPoint(position:Point, name:String = null)
		{
			super(SPHERE, MATERIAL);

			this.name = name ? name : position.toString();
			this.position = new Vector3D(position.x, DEFAULT_HEIGHT, position.y);

			mouseEnabled = true;
			addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown3d)
		}

		private function onMouseDown3d(e:MouseEvent3D):void
		{
			Log.d(name, 'Clicked.')
		}
	}
}
