/**
 *	Avatar文件(.bla)加载器
 */
package utils
{
	import away3d.entities.Mesh;
	import away3d.events.ParserEvent;

	import bl.avatar.blAvatarStore;
	import bl.consts.blStrings;

	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import utils.LoaderHelper;

	public class BLALoader
	{
		public static var _useAvatarParser2 : Boolean = true;		// 是否使用binary的Avatar文件格式
		private var _avatar_url : String;
		private var _path : String;
		private var _avatarName : String;
		private var _targetMesh : Mesh;
		private var _callBack : Function;
		private var _meshLoadCount : int = 0;		// loading 计数
		private var _textureBmp : BitmapData;

		//改为静态成员。因为所有的职业和性别都可以共用该贴图了。
		private static var _clothTextureNames : Vector.<String> = new Vector.<String>;
		private static var _clothTextureMap : Dictionary = new Dictionary;			// 换装用贴图

		private var _avatarParser2 : AvatarParser2;
		private var _avatarMeshParser2 : Vector.<AvatarMeshParser2> = new Vector.<AvatarMeshParser2>;

		private var _extraBoneTagString : String;			// 外部骨骼绑定点文件
		private var _extraBoneTagBa : ByteArray;

		private var _extraSequncesStrings : Vector.<String> = new Vector.<String>;		// 外部动画文件
		private var _extraSequncesBa : Vector.<ByteArray> = new Vector.<ByteArray>;

		private var _extraMeshStrings : Vector.<String> = new Vector.<String>;			// 外部模型文件
		//拷贝所有的贴图数据
		public static function copyAllChothTexture() : Dictionary
		{
			var dic:Dictionary = new Dictionary();
			var key:String;
			for(key in _clothTextureMap){
				dic[key] = _clothTextureMap[key];
			}
			return dic;
		}

		public function BLALoader(avatar_url : String, avatarName : String)
		{
			this._avatar_url = avatar_url;
			_path = avatar_url.substr(0, avatar_url.lastIndexOf("/"));
			_avatarName = avatarName;
		}

		public function get textureBmp() : BitmapData {return _textureBmp;}
		public function startParse(mesh : Mesh, callBack : Function) : void
		{
			_targetMesh = mesh;
			this._callBack = callBack;

			loadAvatar();
		}

		private function loadAvatar() : void
		{
			// 加载贴图配置文件
			_meshLoadCount++;	// call onAvatarTextureConfig
			var texConfigUrl : String = _path + "/" + "texture.txt";
			LoaderHelper.loadFromUrl(texConfigUrl, onAvatarTextureConfig);

			// 加载外部骨骼描述文件
			_meshLoadCount++;	// call onAvatarBoneTagData
			var BoneTagUrl : String = _path + "/avatar" + blStrings.FILE_TYPE_AVATAR_TAG;
			LoaderHelper.loadFromUrl(BoneTagUrl, onAvatarBoneTagData2);
		}

		private function onAvatarBoneTagData2(tag : int, boneTag_ba : ByteArray) : void
		{
			_extraBoneTagBa = boneTag_ba;

			loadAvatarMeshConfig();

			onMeshLoaded(); // on call onAvatarBoneTagData2
		}

		private function onAvatarBoneTagData(tag : int, boneTag_str : String) : void
		{
			_extraBoneTagString = boneTag_str;

			loadAvatarMeshConfig();

			onMeshLoaded(); // on call onAvatarBoneTagData
		}

		private function loadAvatarMeshConfig() : void
		{
			// 加载外部模型描述文件
			_meshLoadCount++;	// call onAvatarMeshConfig
			var meshConfigUrl : String = _path + "/" + "mesh.txt";
			LoaderHelper.loadFromUrl(meshConfigUrl, onAvatarMeshConfig);
		}

		private function onAvatarMeshConfig(tag : int, meshConfig_str : String) : void
		{
			if(meshConfig_str)
			{
				// 加载外面描述的模型名
				var strArray : Array = meshConfig_str.split(/\s/);
				var filterStrArray : Array = strArray.filter(function(element:*, index:int, arr:Array):Boolean {
					return (element.length != 0 && element.charAt(0) != '#'); });

				var meshFileName : String;
				for(var i:int=0; i<filterStrArray.length; i++)
				{
					meshFileName = filterStrArray[i];
					_extraMeshStrings.push(meshFileName);
				}
			}

			// 加载外部动画描述文件
			_meshLoadCount++;	// call onAvatarAnimationConfig
			var aniConfigUrl : String = _path +"/" + "animation.txt";
			LoaderHelper.loadFromUrl(aniConfigUrl, onAvatarAnimationConfig);

			onMeshLoaded(); // on call onAvatarMeshConfig
		}

		private function loadAvatarData() : void
		{
			// 加载avatar文件
			_meshLoadCount++;	// call onAvatarDataReady2
			LoaderHelper.loadFromUrl(_avatar_url, onAvatarDataReady2);
		}

		private function onAvatarDataReady2(tag : int, avatar_ba : ByteArray) : void
		{
			if(!avatar_ba)
				throw new Error("no avatar.bla");
			// 拼接上外部的动画文件
			for(var si:int=0; si<_extraSequncesBa.length; si++)
			{
				avatar_ba.position = avatar_ba.length;
				avatar_ba.writeBytes(_extraSequncesBa[si]);
			}
			// 拼接上外部骨骼绑定点文件
			if(_extraBoneTagBa)
			{
				avatar_ba.position = avatar_ba.length;
				avatar_ba.writeBytes(_extraBoneTagBa);
			}

			// 解析avatar数据
			_avatarParser2 = new AvatarParser2(_avatar_url);
			_meshLoadCount++;	// call onAvatarDataParseReady2
			_avatarParser2.addEventListener(ParserEvent.PARSE_COMPLETE, onAvatarDataParseReady2);
			avatar_ba.position = 0;
			_avatarParser2.parseAsync(avatar_ba);			// 解析

			onMeshLoaded(); // on call onAvatarDataReady2
		}

		private function onAvatarDataParseReady2(evt : ParserEvent) : void
		{
			if( !_avatarParser2 || evt.message != _avatarParser2.url )
				return;

			_avatarParser2.removeEventListener(ParserEvent.PARSE_COMPLETE, onAvatarDataParseReady2);
			// 解析贴图
			_meshLoadCount++;	// call onTextureLoaded
//			var textureFullFileName :String = _path + "/" + _avatarParser2._textureFileName + blStrings.FILE_TYPE_TEXTURE;
			var textureFullFileName :String = _path + "/avatar" + blStrings.FILE_TYPE_TEXTURE;
			LoaderHelper.loadFromUrl(textureFullFileName, onTextureLoaded);
			// 解析mesh
			var mi:int;
			var meshName:String;
			// 合并外部模型名
			_avatarParser2._meshNames.length = 0;				// bla内模型名删除
			for(mi=0; mi<_extraMeshStrings.length; mi++)
			{
				if(_avatarParser2._meshNames.indexOf(_extraMeshStrings[mi]) == -1)
					_avatarParser2._meshNames.push(_extraMeshStrings[mi]);
			}
			// 加载模型
			_avatarMeshParser2.length = _avatarParser2._meshNames.length;
			for(mi=0; mi<_avatarParser2._meshNames.length; mi++)
			{
				meshName = _avatarParser2._meshNames[mi];
				meshName = _path + "/" + meshName + blStrings.FILE_TYPE_AVATAR_MESH;

				_meshLoadCount++;	// call onAvatarMeshReady
				LoaderHelper.loadFromUrl(meshName, onAvatarMeshReady2);
			}

			onMeshLoaded();	// on call onAvatarDataParseReady2
		}

		private function onAvatarMeshReady2(tag : int, mesh_ba : ByteArray) : void
		{
			var url:String = _path + "/" + _avatarParser2._meshNames[tag] + blStrings.FILE_TYPE_AVATAR_MESH;
			if(mesh_ba)
			{
				_avatarMeshParser2[tag] = new AvatarMeshParser2(url);
				_meshLoadCount++;	// call onMeshDataParseReady2
				_avatarMeshParser2[tag].addEventListener(ParserEvent.PARSE_COMPLETE, onMeshDataParseReady2);
				_avatarMeshParser2[tag].parseAsync(mesh_ba);
			}
			else
				throw new Error("load "+url+" failed");

			onMeshLoaded(); 	// call onAvatarMeshReady2
		}

		private function onMeshDataParseReady2(evt : ParserEvent) : void
		{
			// 解析mesh完毕
			var isThisParser:Boolean = false;
			for(var i:int=0; i<	_avatarMeshParser2.length; i++)
			{
				if( _avatarMeshParser2[i] && _avatarMeshParser2[i].url == evt.message )
				{
					isThisParser = true;
					_avatarMeshParser2[i].removeEventListener(ParserEvent.PARSE_COMPLETE, onMeshDataParseReady2);
					break;
				}
			}
			if(isThisParser)
				onMeshLoaded();		// on call onMeshDataParseReady
		}

		private function onTextureLoaded(tag : int, bm : BitmapData) : void
		{	// 贴图加载完毕
			if(bm)
				_textureBmp = bm;
			else
				_textureBmp = DefaultBitmapData.bitmapData;
			onMeshLoaded();		// on call onTextureLoaded
		}

		private function onMeshLoaded() : void {
			_meshLoadCount--;
			if( _meshLoadCount == 0 )
			{	// 全部加载完成
				var newAvatarStore : blAvatarStore = generateAvatarStore();		// 生成一个AvatarStore
				_callBack(newAvatarStore);

				// 释放资源
				_avatarParser2 = null;
				_avatarMeshParser2.length = 0;
			}
		}

		private function generateAvatarStore() : blAvatarStore
		{
			var newAvatarStore : blAvatarStore = new blAvatarStore(_avatarName);

			var pi:int;

			// 添加subGeometry
			for(pi=0; pi<_avatarMeshParser2.length; pi++)
			{
				newAvatarStore.addSubGeo(_avatarMeshParser2[pi].subGeometry, _avatarMeshParser2[pi].subGeometryName);
			}
			// 添加skeleton
			newAvatarStore.addSkeleton( _avatarParser2.skeleton );
			// 添加sequence
			for(pi=0; pi<_avatarParser2._sequences.length; pi++)
			{
				newAvatarStore.addSequence( _avatarParser2._sequences[pi] );
			}
			// 添加贴图
			newAvatarStore.setTexture(_textureBmp);
			// 添加骨骼绑定点
			newAvatarStore.addBoneTag( _avatarParser2._boneTagsName, _avatarParser2._boneTagParentIndex, _avatarParser2._boneTagMat );

			// 添加换装贴图
			newAvatarStore.setSubTextureMap(_clothTextureMap);
			// 子部件排序
			newAvatarStore.sortSubGeo();

			return newAvatarStore;
		}

		private function onAvatarTextureConfig(tag : int, texConfig_str : String) : void
		{
			if(texConfig_str)
			{
				// 加载所有Effect特效文件
				var strArray : Array = texConfig_str.split(/\s/);
				var texfileName : String;
				var list:Array;
				for(var i:int=0; i<strArray.length; i++)
				{
					texfileName = strArray[i];
					if(texfileName.length == 0)
						continue;
					if( texfileName.charAt(0) == '0')
						continue;

					_clothTextureNames.push(texfileName);
					list = _path.split("/");
					list.length -= 2;
//					texfileName = _path + "/" + texfileName + blStrings.FILE_TYPE_TEXTURE;// ".blt";
					texfileName = list.join("/") + "/equipment/equipment/" + texfileName + blStrings.FILE_TYPE_TEXTURE;// ".blt";

					_meshLoadCount++;	// call onClothTextureLoaded
					LoaderHelper.loadFromUrl(texfileName, onClothTextureLoaded);
				}

			}

			onMeshLoaded();		// on call onAvatarTextureConfig
		}

		private function onClothTextureLoaded(tag : int, bm : BitmapData) : void
		{
			if(bm)
			{
				_clothTextureMap[_clothTextureNames[tag]] = bm;
			}

			onMeshLoaded();		// on call onClothTextureLoaded
		}

		private var _extraSequanceCount:int = 0;
		private function onAvatarAnimationConfig(tag : int, aniConfig_str : String) : void
		{
			if(aniConfig_str)
			{
				// 加载所有动画
				var strArray : Array = aniConfig_str.split(/\s/);
				var filterStrArray : Array = strArray.filter(function(element:*, index:int, arr:Array):Boolean {
					return (element.length != 0 && element.charAt(0) != '#'); });

				var aniFileName : String;
				_extraSequanceCount += filterStrArray.length;
				for(var i:int=0; i<filterStrArray.length; i++)
				{
					aniFileName = filterStrArray[i];
					aniFileName = _path + "/" + aniFileName + blStrings.FILE_TYPE_AVATAR_SEQ;

					_meshLoadCount++;	// call onAnimationLoaded
					LoaderHelper.loadFromUrl(aniFileName, onAnimationLoaded2);

				}
			}
			else
			{	// 无外部动画文件
				loadAvatarData();
			}

			onMeshLoaded();		// on call onAvatarAnimationConfig
		}

		private function onAnimationLoaded2(tag : int, seqBa : ByteArray) : void
		{
			if(seqBa)
			{
				_extraSequncesBa.push(seqBa);
			}

			_extraSequanceCount--;
			if(_extraSequanceCount == 0)
			{	// 外部动画文件加载完毕
				loadAvatarData();
			}

			onMeshLoaded();		// on call onAnimationLoaded

		}

		private function onAnimationLoaded(tag : int, seqString : String) : void
		{
			if(seqString)
			{
				_extraSequncesStrings.push(seqString);
			}

			_extraSequanceCount--;
			if(_extraSequanceCount == 0)
			{	// 外部动画文件加载完毕
				loadAvatarData();
			}

			onMeshLoaded();		// on call onAnimationLoaded
		}
	}
}