/**
 *	资源对象基类 
 */
package blade3d.Resource
{
	import away3d.errors.AbstractMethodError;

	public class BlResource
	{
		// 加载类型
		static public var LOAD_TYPE_DELAY : int = 0;		// 需要时再加载
		static public var LOAD_TYPE_AUTO : int = 1;		// 逐步自动再加载
		static public var LOAD_TYPE_MUST : int = 2;		// 必须加载好再卡似乎
		
		// 资源状态
		static public var LOAD_UNLOAD : int = 0;			// 未加载
		static public var LOAD_LOADING : int = 1;			// 加载中
		static public var LOAD_LOADED : int = 2;			// 已加载
		
		protected var _url:String;			// 资源的url
		
		protected var loadState:int = LOAD_UNLOAD;		// 资源状态
		
		public var loadType:int;			// 加载类型
		
		public function get resType() : int {return BlResourceManager.TYPE_NONE;}
		public function get url() : String {return _url;} 
		public function get isLoaded() : Boolean {return loadState != LOAD_UNLOAD;}
		
		public function BlResource(url:String)
		{
			_url = url;
		}
		// 加载该资源
		public function load():void
		{
			if(loadState != LOAD_UNLOAD)
				return;
			
			loadState = LOAD_LOADING;
			
			_loadImp();		// 开始加载
		}
		
		protected function _loadImp():void
		{
			throw new AbstractMethodError();
		}
		
		protected function _loadEnd():void
		{
			loadState = LOAD_LOADED;
			BlResourceManager.instance().onResourceLoaded(this);
		}
	}
}