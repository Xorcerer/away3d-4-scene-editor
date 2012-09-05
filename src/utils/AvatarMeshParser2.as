/**
 *	Avatar模型文件的解析器2  
 */
package utils
{
	import away3d.arcane;
	import away3d.core.base.SkinnedSubGeometry;
	import away3d.core.math.Quaternion;
	import away3d.debug.Debug;
	import away3d.loaders.parsers.*;

	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	use namespace arcane;
	
	public class AvatarMeshParser2 extends ParserBase
	{
		// chunk id
		private const BLM_VERTEX:int = 0x0800
		private const BLM_INDEX:int = 0x0900
			
		// 解析用
		private var _byteData : ByteArray;
		private var _startedParsing : Boolean = false;
		private var _tmpChunk : ChunkBlm = new ChunkBlm;
		
		// mesh数据
		private var _subGeoName : String;		
		private var _vertices : Vector.<Number>;
		private var _uvs : Vector.<Number>;
		private var _boneWeights : Vector.<Number>;
		private var _boneIndices : Vector.<Number>;
		private var _indices : Vector.<uint>;
		private var _subGeom : SkinnedSubGeometry;
		
		public var url:String = null;
		public function get subGeometry() : SkinnedSubGeometry {return _subGeom;}
		public function get subGeometryName() : String {return _subGeoName;}
		
		public function AvatarMeshParser2(url:String)
		{
			
			super(ParserDataFormat.BINARY);
			this.url = url;
			_subGeoName = this.url.substr(this.url.lastIndexOf("/")+1);
			_subGeoName = _subGeoName.substr(0, _subGeoName.lastIndexOf("."));
		}
		
	
		protected override function proceedParsing() : Boolean
		{
			if(!_startedParsing)
			{
				// 开始解析
				_byteData = getByteData();
				_startedParsing = true;
				_byteData.position = 0;
				_byteData.endian = Endian.LITTLE_ENDIAN;
				
				// 解析文件头
				var version:int = _byteData.readUnsignedInt();
				var vertexNum:int = _byteData.readUnsignedInt();
				var faceCount:int = _byteData.readUnsignedInt();
				var indexCount:int = _byteData.readUnsignedInt();
				
				
				_vertices = new Vector.<Number>(vertexNum*3, true);
				_uvs = new Vector.<Number>(vertexNum*2, true);
				_boneIndices = new Vector.<Number>(vertexNum * 4, true);	// 最多4个权重
				_boneWeights = new Vector.<Number>(vertexNum * 4, true);
				
				_indices = new Vector.<uint>(indexCount, true);
			}
			
			while (hasTime())
			{
				// 读Chunk	
				readChunk(_byteData);
				var chunkId : int = _tmpChunk.id;
				var count : int = _tmpChunk.count;
				// 读Chunk内容				
				switch(chunkId)
				{
					case BLM_VERTEX:
						readChunk_BLM_VERTEX(count);
						break;
					case BLM_INDEX:
						readChunk_BLM_INDEX(count);
						break;
					default:
						break;
				}
				
				
				if (_byteData.position == _byteData.length)
				{	// blm文件解析完成, 创建AvatarMesh					
					generateMesh();
					
					return ParserBase.PARSING_DONE;		
				}
			}
			return ParserBase.MORE_TO_PARSE;
		}
		
		private function generateMesh() : void
		{
			_subGeom = new SkinnedSubGeometry(4);
			_subGeom.updateVertexData(_vertices);
			_subGeom.updateUVData(_uvs);
			_subGeom.updateIndexData(_indices);
			_subGeom.updateJointIndexData(_boneIndices);
			_subGeom.updateJointWeightsData(_boneWeights);
		}
		
		private function readChunk_BLM_VERTEX(count:int) : void
		{
			// 读取顶点
			for(var vertexIndex:int=0;vertexIndex<count;vertexIndex++)
			{
				_vertices[vertexIndex*3] = _byteData.readFloat();			// 顶点
				_vertices[vertexIndex*3+1] = _byteData.readFloat();
				_vertices[vertexIndex*3+2] = _byteData.readFloat();
				
				_uvs[vertexIndex*2] = _byteData.readFloat();				// uv
				_uvs[vertexIndex*2+1] = _byteData.readFloat();
				
				var i:int;
				var boneCount:int = _byteData.readUnsignedByte();
				
				for(i=0; i<boneCount; i++)
				{
					var boneIndex:int = _byteData.readShort();								// bone index
					_boneIndices[vertexIndex*4+i] = boneIndex*3;					// 一个骨头占用3个vector
					var boneWeight:Number = _byteData.readFloat();							// bone weight
					_boneWeights[vertexIndex*4+i] = boneWeight;
				}
				
			}
		}
		
		private function readChunk_BLM_INDEX(count:int) : void
		{
			for(var indexI:int=0;indexI<count;indexI++)
			{
				_indices[indexI*3] = _byteData.readUnsignedInt();
				_indices[indexI*3+1] = _byteData.readUnsignedInt();
				_indices[indexI*3+2] = _byteData.readUnsignedInt();
			}
		}
		
		private function readQuaternion() : Quaternion
		{
			var quat : Quaternion = new Quaternion();
			quat.x = _byteData.readFloat();
			quat.y = _byteData.readFloat();
			quat.z = _byteData.readFloat();
			
			// quat supposed to be unit length
			var t : Number = 1 - quat.x * quat.x - quat.y * quat.y - quat.z * quat.z;
			quat.w = t < 0 ? 0 : -Math.sqrt(t);
			
			return quat;
		}
		
		private function readVector3D() : Vector3D
		{
			var vec : Vector3D = new Vector3D();
			vec.x = _byteData.readFloat();
			vec.y = _byteData.readFloat();
			vec.z = _byteData.readFloat();
			return vec;
		}
		
		private function readChunk(ba:ByteArray) : ChunkBlm
		{
			_tmpChunk.id = ba.readUnsignedShort();
			_tmpChunk.count = ba.readUnsignedInt();
			return _tmpChunk;
		}
		
		private function readString(ba:ByteArray) : String
		{
			var strLen:int = ba.readUnsignedShort();
			var str:String = ba.readUTFBytes(strLen);
			ba.readByte();		// '\0'
			return str;			
		}
		
	}
}

class ChunkBlm
{	
	public var id:int;
	public var count:int;	
}