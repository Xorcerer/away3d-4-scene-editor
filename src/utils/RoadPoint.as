package utils
{
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.SphereGeometry;

	import flash.geom.Point;
	import flash.geom.Vector3D;

	public class RoadPoint extends Mesh
	{

		public static const SPHERE:SphereGeometry = new SphereGeometry(50);
		private static const DARK_RED:uint = 0x441100;

		private static const DEFAULT_HEIGHT:Number = 100;

		public function RoadPoint(position:Point, name:String = '')
		{
			super(SPHERE, new ColorMaterial(DARK_RED));

			this.name = name;
			this.position = new Vector3D(position.x, DEFAULT_HEIGHT, position.y);
		}
	}
}
