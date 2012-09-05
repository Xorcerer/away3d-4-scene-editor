/**
 *	Avatar的字节流解析器 
 */
package utils
{
	import animators.SkeletonKeyframeAnimationSequence;

	import away3d.animators.data.Skeleton;
	import away3d.core.math.Quaternion;
	import away3d.loaders.parsers.*;

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class AvatarParser2 extends ParserBase
	{
		
		// chunk id
		private const BLA_MESH:int = 0x0100;
		private const BLA_HIERARCHY:int = 0x0200;
		private const BLA_BONES:int = 0x0300;
		private const BLA_BONETAGS:int = 0x0400;
		private const BLQ_ANIMATION:int = 0x0500
		private const BLQ_BONE:int = 0x0600
		private const BLQ_TIME:int = 0x0700

		
		// 解析用
		private var _byteData : ByteArray;
		private var _startedParsing : Boolean = false;
		private var _tmpChunk : ChunkBla = new ChunkBla;
		// 数据
		public var _meshNames : Vector.<String>;		// 部件名
		public var _textureFileName : String;			// 贴图名
		
		// 动画相关
		public var _sequences : Vector.<SkeletonKeyframeAnimationSequence> = new Vector.<SkeletonKeyframeAnimationSequence>;
		
		private var _numBones : int;
		private var _bindPoses : Vector.<Matrix3D>;
		private var _skeleton : Skeleton;
		private var _animation : SkeletonAnimation;
		
		// 骨骼绑定点相关
		public var _boneTagsName : Vector.<String> = new Vector.<String>;
		public var _boneTagParentIndex : Vector.<int> = new Vector.<int>;
		public var _boneTagMat : Vector.<Matrix3D> = new Vector.<Matrix3D>;
		public var url:String = null;

		public function get skeleton() : Skeleton {return _skeleton;}
		
		public function AvatarParser2(url:String)
		{
			super(ParserDataFormat.BINARY);
			this.url = url;
						
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
				if(version!=2)
					throw new Error("avatar version error " + _url) ;
				_numBones = _byteData.readUnsignedInt();
				_bindPoses = new Vector.<Matrix3D>(_numBones, true);				
				_textureFileName = readString(_byteData);			// 贴图
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
					case BLA_MESH:
						readChunk_BLA_MESH(count);
						break;
					case BLA_HIERARCHY:
						readChunk_BLA_HIERARCHY(count);
						break;
					case BLA_BONES:
						readChunk_BLA_BONES(count);
						break;
					case BLA_BONETAGS:
						readChunk_BLA_BONETAGS(count);
						break;
					case BLQ_ANIMATION:
						readChunk_BLQ_ANIMATION(count);
						break;					
					default:
						throw new Error("avatar parse error");
						break;
				}
				
				
				if (_byteData.position == _byteData.length)
				{	// bla文件解析完成, 创建AvatarMesh					
					_animation = new SkeletonAnimation(_skeleton);
					
					return ParserBase.PARSING_DONE;		
				}
			}
			return ParserBase.MORE_TO_PARSE;
		}
		
		private function readChunk_BLQ_ANIMATION(count:int) : void
		{
			var keyFrame:int;
			var keyFramePos : Vector3D;
			var keyFrameQuat : Quaternion;
			var sequence : SkeletonKeyframeAnimationSequence;
			
			var aniName:String = readString(_byteData);
			
			sequence = new SkeletonKeyframeAnimationSequence(aniName, count);
			
			// 读取每个骨头的动画数据
			for(var boneI:int=0; boneI<count; boneI++)
			{
				readChunk(_byteData);
				var chunkId : int = _tmpChunk.id;
				var keyCount : int = _tmpChunk.count;
				
				if(chunkId == BLQ_BONE)
				{
					for(var timeI:int=0; timeI<keyCount; timeI++)
					{
						keyFrame = _byteData.readInt();
						keyFramePos = readVector3D();			// pos
						keyFrameQuat = readQuaternion();		// quat
						
						sequence.addBoneKeyframe(boneI, keyFrame, keyFramePos, keyFrameQuat);			// 3dmax 默认一帧30ms
					}			
					
				}
				else
					throw new Error("blq animation error");
			}
			
			_sequences.push(sequence);
		}
		
		private function readChunk_BLA_MESH(count:int) : void
		{
			_meshNames = new Vector.<String>;
			
			var meshName : String;
			for(var i:int=0; i<count; i++)
			{
				meshName = readString(_byteData);
				_meshNames.push(meshName);
			}
		}
		
		private function readChunk_BLA_HIERARCHY(count:int) : void
		{
			var boneName : String;
			var bone : SkeletonJoint;			
			var parentIndex : int;
			
			_skeleton = new Skeleton();
			
			for(var i:int=0; i<count; i++)
			{
				boneName = readString(_byteData);
				parentIndex = _byteData.readShort();
				
				bone = new SkeletonJoint();
				bone.name = boneName;
				bone.parentIndex = parentIndex;
				
				_skeleton.joints[i] = bone;
			}
		}
		
		private function readChunk_BLA_BONES(count:int) : void
		{
			var boneIndex : int;
			var bonePos : Vector3D;
			var boneQuat : Quaternion;
			
			for(var i:int=0; i<count; i++)
			{
				boneIndex = i;
				bonePos = readVector3D();
				boneQuat = readQuaternion();
				
				_bindPoses[boneIndex] = boneQuat.toMatrix3D();
				_bindPoses[boneIndex].appendTranslation(bonePos.x, bonePos.y, bonePos.z);
				var inv : Matrix3D = _bindPoses[boneIndex].clone();
				inv.invert();
				
				_skeleton.joints[boneIndex].inverseBindPose = inv.rawData;		// 骨头变换矩阵的逆
			}
		}
		
		private function readChunk_BLA_BONETAGS(count:int) : void
		{
			var boneTagName : String;
			var parentBoneIndex : int;
			var boneTagPos : Vector3D;
			var boneTagQuat : Quaternion;
			var bonePose : Matrix3D;
			
			for(var i:int=0; i<count; i++)
			{
				boneTagName = readString(_byteData);
				parentBoneIndex = _byteData.readShort();
				
				boneTagPos = readVector3D();
				boneTagQuat = readQuaternion();
				
				bonePose = boneTagQuat.toMatrix3D();
				bonePose.appendTranslation(boneTagPos.x, boneTagPos.y, boneTagPos.z);
				
				_boneTagsName.push(boneTagName);
				_boneTagParentIndex.push(parentBoneIndex);
				_boneTagMat.push( bonePose );
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
	
		private function readChunk(ba:ByteArray) : ChunkBla
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

class ChunkBla
{	
	public var id:int;
	public var count:int;	
}
