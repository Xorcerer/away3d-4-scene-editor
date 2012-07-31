/**
 *	资源加载管理器 
 */
package blade3d.Loader
{
	import away3d.debug.Debug;
	
	import blade3d.Resource.BlResourceManager;
	
	import flash.utils.Dictionary;

	public class BlResourceLoaderManager
	{
//		private var _loaderPool : Vector.<BlResourceLoader> = new Vector.<BlResourceLoader>;			// 加载完毕的闲置加载器
		private var _loadingPool : Dictionary = new Dictionary;		// 正在加载中的加载器
		
		public var loadingCount : int = 0;
		
		public function BlResourceLoaderManager()
		{
		}
				
		public function loadResource(url:String, resType:int, callback:Function):void
		{
			var loader : BlResourceLoader;
			if(_loadingPool[url])
			{
				loader = _loadingPool[url];
				loader.addCallBack(callback);
			}
			else
			{
				loader = getFreeLoader(resType);
				loader.addCallBack(callback);
				_loadingPool[url] = loader;
			}
			
			loader.url = url;
			
			loader.startLoad();
		}
		
		private function getFreeLoader(resType:int) : BlResourceLoader
		{
			var loader : BlResourceLoader;
			switch(resType)
			{
				case BlResourceManager.TYPE_STRING:
				{
					loader = new BlStringLoader(this);
					break;
				}
				case BlResourceManager.TYPE_BYTEARRAY:
				{
					loader = new BlBinaryLoader(this);
					break;
				}
				default:
				{
					throw new Error("resType error");
					break;
				}
			}
			
			loadingCount++;
			return loader;
		}
		
		private function recycleLoader(loader : BlResourceLoader):void
		{
			
		}
		
		public function onLoaderComplete(loader : BlResourceLoader):void
		{
			// free loader
			Debug.assert(_loadingPool[loader.url]);
			delete _loadingPool[loader.url];
			loadingCount--;
			
			recycleLoader(loader);
		}
	}
}