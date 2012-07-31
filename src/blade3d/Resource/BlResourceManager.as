/**
 *	资源管理器
 * 	负责加载和维护所有的资源 
 */
package blade3d.Resource
{
	import away3d.debug.Debug;
	
	import blade3d.BlManager;
	import blade3d.Loader.BlResourceLoaderManager;
	
	import flash.utils.Dictionary;

	// 资源事件
//	[Event(name="resourceComplete", type="blade3d.events.ResourceEvent")]
	
	public class BlResourceManager extends BlManager
	{
		// 资源类型
		static public var TYPE_NONE : int = 0;
		static public var TYPE_BYTEARRAY : int = 1;			// binary数据
		static public var TYPE_STRING : int = 2;				// 文本字符串
		static public var TYPE_TEXTURE : int = 3;				// 贴图
		static public var TYPE_MESH : int = 4;				// 模型
		// 资源路径
		public var root_url:String = "../res/";
		
		// 资源列表
		private var _ResourceMap : Dictionary = null;		// 资源列表
		private var _firstLoadCount : int = 0;
		
		static private var _instance : BlResourceManager;
		
		private var _loaderManager : BlResourceLoaderManager;
		public function get loaderManager() : BlResourceLoaderManager {return _loaderManager;}
		
		public function BlResourceManager()
		{
			if(_instance)
				Debug.error("BlResourceManager error");
		}
		
		static public function instance() : BlResourceManager
		{
			if(!_instance)
				_instance = new BlResourceManager();
			return _instance;
		}
		
		public function get ResourceMap() : Dictionary {return _ResourceMap;}
		
		public function init(callBack:Function):Boolean
		{
			_initCallBack = callBack;
			_loaderManager = new BlResourceLoaderManager;
			// 读取资源文件列表
			loadResource(root_url + "filelist.txt", TYPE_STRING, onLoadFileList);
			
			return true;
		}
		
		public function findResource(url:String):BlResource
		{
			return _ResourceMap[url];
		}
		
		public function loadString(url:String, callBack : Function):void
		{
			loadResource(url, TYPE_STRING, callBack);
		}
		
		private function loadResource(url:String, type:int, callback:Function):void
		{
			_loaderManager.loadResource(url, type, callback);
		}
		
		private function onLoadFileList(str:String):void
		{
			Debug.assert(!_ResourceMap);
			_ResourceMap = new Dictionary;
			
			// 创建资源列表
			var strArray : Array = str.split(/\s/);
			var filterStrArray : Array = strArray.filter(
				function(element:*, index:int, arr:Array):Boolean 
				{
					return (element.length != 0 && element.charAt(0) != '#'); 
				}
			);
			
			// 创建资源对象
			var allFileName : String;
			var fileName : String;
			var extName : String;
			var pathName : String;
			for(var i:int=0; i<filterStrArray.length; i++)
			{
				// 解析文件名
				allFileName = filterStrArray[i];
				var pPos:int = allFileName.lastIndexOf('.');
				extName = allFileName.substr(pPos);
				fileName = allFileName.substr(0, pPos);
				var slashPos:int = fileName.lastIndexOf('/') + 1;
				pathName = fileName.substr(0, slashPos);
				fileName = fileName.substr(slashPos);
				
				// 创建资源对象
				var newResource:BlResource;
//				if(extName == ".3ds")
//				{	// 静态模型
//					newResource = new BlModelResource(allFileName);
//				}
				if(extName == ".dds" || extName == ".png" || extName == ".bmp" || extName == ".jpeg" || extName == ".jpg" || extName == "gif")
				{	// 贴图
					
				}
//				else if(extName = ".txt")
//				{	// 文本
//					
//				}
				else
				{	// 2进制数据
					newResource = new BlBinaryResource(allFileName);
				}
				
				// 设置资源加载类型 
				newResource.loadType = BlResource.LOAD_TYPE_DELAY;
					
				// 记录资源
				_ResourceMap[allFileName] = newResource;
			}
			
			// 加载资源列表中，必须加载的资源
			_firstLoadCount++;
			for each(var res:BlResource in _ResourceMap)
			{
				if(res.loadType == BlResource.LOAD_TYPE_MUST)
				{
					_firstLoadCount++;
					res.load();
				}
			}
			
			onResourceLoaded(null);
			dispatchEvent(new BlResourceEvent(BlResourceEvent.RESOURCE_LIST, null));
		}
		
		public function onResourceLoaded(res:BlResource):void
		{
			_firstLoadCount--;
			if(_firstLoadCount==0)
			{
				_initCallBack(this);
			}
			
			if(res)
			{
				Debug.trace("load res:"+res.url);
				dispatchEvent(new BlResourceEvent(BlResourceEvent.RESOURCE_COMPLETE, res));
			}
		}
	}
}