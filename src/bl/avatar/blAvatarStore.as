/**
 *	维护Avatar系统中换装部件的类
 * 	通过载入一套模型和动画文件,而生成一套Avatar换装用的SubMesh
 * 	并可以通过不同SubMesh的组合,生成不同外形的角色mesh对象
 */
package bl.avatar
{
	import animators.SkeletonKeyframeAnimationSequence;

	import away3d.animators.data.Skeleton;
	import away3d.core.base.SkinnedSubGeometry;
	import away3d.debug.Debug;

	import flash.display.BitmapData;
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;

	public class blAvatarStore
	{
		private var _AvatarName : String;			// Avatar名字
		
		private var _mesh_str_list : Vector.<String>;
		private var _meshload_count : uint = 0;
		private var _meshCount : uint = 0;
		
		private var _avatarLoadCount : int = 0;
		private var _callBack : Function;
		
		private var _meshPool : Vector.<blAvatarMesh> = new Vector.<blAvatarMesh>;	
		public static var allocateAvatarMeshCount : int = 0;
		// 模型
		private var _load_mesh : blAvatarMesh;		// load用mesh,此mesh不做渲染用
		private var _skeleton : Skeleton;					// 骨骼
		// 贴图
		private var _tex_url : String;			// 贴图url
		private var _tex_bmp : BitmapData;		// 贴图 
		// 动画
		private var _SequenceArray : Vector.<SkeletonKeyframeAnimationSequence>;		// 动画数据
		
		// 换装部件
		private var _subGeoMap : Dictionary = new Dictionary;		// <subGeoName部件名, SkinnedSubGeometry>
		private var _subGeoNum : uint = 0;
		private var _subGeoNames : Vector.<String> = new Vector.<String>;		// 子模型的名字
		
		// 换装贴图
		private var _subTextureMap : Dictionary = new Dictionary;		// <贴图名， 贴图>
		private var _subTextureNum : uint = 0;
		
		
		// 骨骼绑定点数据
		public var _boneTagsName : Vector.<String>;
		public var _boneTagParentIndex : Vector.<int>;
		public var _boneTagMat : Vector.<Matrix3D>
		
		public function blAvatarStore(avatarName : String)
		{
			_AvatarName = avatarName;
			_SequenceArray = new Vector.<SkeletonKeyframeAnimationSequence>;
		}
		
		public function get name() : String {return _AvatarName;}
		
		public function getPoolCount() : int
		{
			return _meshPool.length;
		}
		
		public function getSubGeoMap() : Dictionary
		{
			return _subGeoMap;		// 获取换装部件列表
		}
		
		public function getSubGeoNames() : Vector.<String> 
		{
			return _subGeoNames;
		}
		
		public function getSubGeoCount() : uint 
		{
			return _subGeoNum;
		}
		
		public function getSequence() : Vector.<SkeletonKeyframeAnimationSequence> 
		{
			return _SequenceArray;
		}
		
		public function getSequenceCount() : uint 
		{
			return _SequenceArray.length;
		}
		
		public function createAvatarMesh(isUnion : Boolean = true) : blAvatarMesh 
		{
			var newAvatarMesh : blAvatarMesh;
			if( _meshPool.length > 0 )
			{
				newAvatarMesh = _meshPool.pop();
			}
			else
			{
				newAvatarMesh = allocateAvatarMesh(isUnion);
			}
			return newAvatarMesh;
		}
		/**
		 *	创建一个新的AvatarMesh实例
		 * 	isUnion = true 在创建是组装好一个完整的avatar 
		 */		
		private function allocateAvatarMesh(isUnion : Boolean = true) : blAvatarMesh 
		{
			// 创建Mesh
			var newAvatarMesh : blAvatarMesh = new blAvatarMesh(this, null);
			// 创建骨骼
			var newAnimation : SkeletonAnimation = new SkeletonAnimation(_skeleton);
			newAvatarMesh.geometry.animation = newAnimation;
			// 模型组装
			if(isUnion)
				newAvatarMesh.assembleMesh();		// 组合部件
			
			// 创建动画模块
			var animator : SmoothSkeletonAnimator = new SmoothSkeletonAnimator(SkeletonAnimationState(newAvatarMesh.animationState));
			newAvatarMesh.animator = animator;
			
			// 添加动画
			if(_SequenceArray)
			{
				var ai:int = 0;
				for(ai=0; ai<_SequenceArray.length; ai++)
				{
					animator.addKeyframeSequence( _SequenceArray[ai] );
				}
			}
			// 添加材质(一定要最后添加,否则material中不会有animate shader
			newAvatarMesh.resetTexture();
			
			// 创建骨骼挂接点
			addBoneTagToAvatar(newAvatarMesh, animator);
			
			
			allocateAvatarMeshCount++;
			return newAvatarMesh;
		}
		
		public function freeMeshPool(freeCount : int) : void
		{
			for(var i:int=0; i<freeCount; i++)
			{
				if(_meshPool.length<=0)
					break;
				
				var freeOne : blAvatarMesh = _meshPool.pop();
				// 释放AvatarMesh
				freeOne.dispose(true);
				allocateAvatarMeshCount--;
			}
		}
		
		private function addBoneTagToAvatar(avatar : blAvatarMesh, animator : SmoothSkeletonAnimator) : void
		{
			var boneTagMap : Dictionary = new Dictionary;
			// 创建骨骼挂接点
			var boneTag : BoneTag;
			var ti:int;
			for(ti=0; ti<_boneTagsName.length; ti++)
			{
				boneTag = animator.addBoneTagByIndex(_boneTagParentIndex[ti]);
				boneTag.name = _boneTagsName[ti];
				boneTag.transform = _boneTagMat[ti];
				boneTagMap[boneTag.name] = boneTag;
			}
			avatar.setBoneTagMaps(boneTagMap);
			
		}
		// 对子部件进行按名排序
		public function sortSubGeo() : void
		{
			var subGeoList:Array = [];
			for each(var geo:String in _subGeoNames)
			{
				subGeoList.push(geo);
			}
			subGeoList.sort();
			
			_subGeoNames.length = 0;
			
			for(var i:int=0; i<subGeoList.length; i++)
			{
				_subGeoNames.push(subGeoList[i]);
			}
		}
		
		public function addSubGeo(subGeo : SkinnedSubGeometry, subGeoName : String) : void 
		{
			_subGeoMap[subGeoName] = subGeo;
			_subGeoNames.push(subGeoName);
			_subGeoNum++;
		}
		
		public function addSkeleton(skel : Skeleton) : void 
		{
			_skeleton = skel;
		}
		
		public function addSequence(seq : SkeletonKeyframeAnimationSequence): void
		{
			_SequenceArray.push(seq);
		}
		
		public function setTexture(tex : BitmapData):void
		{
			_tex_bmp = tex;
		}
		
		public function getTexture() : BitmapData
		{
			return _tex_bmp;
		}
		
		public function setSubTextureMap(subTextureMap : Dictionary) : void
		{
			_subTextureMap = subTextureMap;
			
			_subTextureNum = 0;
			for(var subTextureName:String in _subTextureMap)
			{
//				Debug.bltrace(subTextureName);
				_subTextureNum++;
			}
		}
		
		public function getSubTextureMap() : Dictionary
		{
			return _subTextureMap;
		}
		
		public function getSubTexture(subTextureName : String) : BitmapData
		{
			return _subTextureMap[subTextureName];
		}
		
		public function addBoneTag(boneTagNames:Vector.<String>, boneTagParentIndex:Vector.<int>, boneTagMat:Vector.<Matrix3D>) : void
		{
			_boneTagsName = boneTagNames;
			_boneTagParentIndex = boneTagParentIndex;
			_boneTagMat = boneTagMat;
		}
		// 回收该store对应的mesh
		public function recycle(avatarMesh : blAvatarMesh) : void
		{
			avatarMesh.detachParent();
			if(avatarMesh.avatarStore != this)
			{
				Debug.bltrace("recycle avatarmesh error");
				return;
			}
			_meshPool.push(avatarMesh);
		}
		
	
	}
}