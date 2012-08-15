/**
 *    纯as3的dds解析器
 */
package parsers
{
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.IAsset;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.parsers.ParserBase;
	import away3d.materials.DefaultMaterialBase;

	import flash.geom.Point;

	import flash.geom.Vector3D;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	import utils.Log;
	import marks.RoadPoint;

	use namespace arcane;

	public class Blade3DXMLParser extends ParserBase
	{
		public static function supportsType(extension:String):Boolean
		{
			return extension.toLowerCase() == 'xml';
		}

		public static function supportsData(data:*):Boolean
		{
			// TODO:
			return false;
		}

		private var _mesh:Mesh = new Mesh(new Geometry());
		private var _subMeshPositions:Dictionary = new Dictionary();
		private var _xmlLoaded:Boolean = false;

		public function Blade3DXMLParser()
		{
			super(URLLoaderDataFormat.TEXT);
		}

		private var _meshNodes:XMLList;

		private var _indexOfMeshNodes:int = 0;

		protected override function proceedParsing() : Boolean
		{
			if (_meshNodes && _indexOfMeshNodes >= _meshNodes.length())
			{
				finalizeAsset(_mesh);
				return PARSING_DONE;
			}

			if (!_xmlLoaded)
			{
				XML.ignoreComments = true;
				XML.ignoreWhitespace = true;
				var sceneXML:XML = new XML(_data);

				_meshNodes = sceneXML.child('mesh');
				_xmlLoaded = true;

				var roadPoints:XMLList = sceneXML.child('trigger');
				for (var i:int = 0; i < roadPoints.length(); ++i)
				{
					var point:XML = roadPoints[i];
					var rp:RoadPoint = new RoadPoint(new Point(point.@x, point.@z), point.@name);
					_mesh.addChild(rp);
				}
			}

			while (_indexOfMeshNodes < _meshNodes.length())
			{
				var node:XML = _meshNodes[_indexOfMeshNodes];
				var meshName:String = node.@name;
				var worldPosition:Vector3D = new Vector3D(node.pos.@x, node.pos.@y, node.pos.@z);

				var key:String = 'node-' + _indexOfMeshNodes + '-' + meshName;
				_subMeshPositions[key] = worldPosition;
				addDependency(key, new URLRequest(meshName + '.3ds'));

				++_indexOfMeshNodes;
				if (!hasTime())
					return MORE_TO_PARSE;
			}

			pauseAndRetrieveDependencies();

			return MORE_TO_PARSE;
		}

		private static const LEAF_ALPHA_THRESHOLD:Number = 2.0 / 255;

		arcane override function resolveDependency(resourceDependency:ResourceDependency):void
		{
			resourceDependency.assets.forEach(function (asset:IAsset, index:int, array:Vector.<IAsset>):void
			{
				if (asset.assetType == AssetType.MESH && _subMeshPositions[resourceDependency.id])
				{
					var subMesh:Mesh = asset as Mesh;
					subMesh.position = _subMeshPositions[resourceDependency.id];
					_mesh.addChild(subMesh);

					delete _subMeshPositions[resourceDependency.id];
				}
				else if (asset.assetType == AssetType.MATERIAL)
				{
					var mat:DefaultMaterialBase = asset as DefaultMaterialBase;
					if (mat)
						mat.alphaThreshold = LEAF_ALPHA_THRESHOLD;
				}
			});

		}
	}
}