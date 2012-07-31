/**
 *	资源加载器 
 */
package blade3d.Loader
{
	import away3d.debug.Debug;
	import away3d.errors.AbstractMethodError;
	
	import blade3d.Resource.BlResource;
	import blade3d.Resource.BlResourceManager;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class BlResourceLoader extends URLLoader
	{
		private var _manager : BlResourceLoaderManager;
		
		public var url:String = "";
		//public var resType:int = BlResourceManager.TYPE_NONE;		// 资源的类型
		protected var _callBacks : Array = new Array();
		
		private var _request : URLRequest = null;
		private var _resouce : BlResource = null;
		
		
		public function BlResourceLoader(manager : BlResourceLoaderManager)
		{
			_manager = manager;
			super();
		}
		
		public function get resType():int {return BlResourceManager.TYPE_NONE;}
		
		public function addCallBack(callback : Function):void
		{
			if(callback == null)
				return;
			
			_callBacks.push(callback);
		}
		
		private function reset():void
		{
			url = "";
			_callBacks.length = 0;
			
			_request = null;
			
			close();
		}
		
		public function isLoading():Boolean {return _request == null;}
		
		public function startLoad():void
		{
			if(resType == BlResourceManager.TYPE_NONE || url == null || url.length==0)
				throw new Error("Resource Loader error!"); 
			_request = new URLRequest(BlResourceManager.instance().root_url + url);
			
			addEventListener(Event.COMPLETE, onLoadComplete);
			addEventListener(IOErrorEvent.IO_ERROR, onError);
			addEventListener(ProgressEvent.PROGRESS, onProgress);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
			load(_request);
		}
		
		private function onProgress(evt : ProgressEvent) : void
		{
			
		}
		
		private function onLoadComplete(evt : Event) : void
		{
			Finish(0);
		}
		
		private function onError(evt : IOErrorEvent) : void
		{
			Debug.warning("load error:"+evt.text);
			Finish(-1);
		}
		
		private function onSecurityError(evt : SecurityErrorEvent) : void
		{
			Debug.warning("load error:"+evt.text);
			Finish(-2);
		}
		
		private function Finish(error:int) : void
		{
			// remove listener
			removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			removeEventListener(ProgressEvent.PROGRESS, onProgress);
			removeEventListener(IOErrorEvent.IO_ERROR, onError);
			removeEventListener(Event.COMPLETE, onLoadComplete);
			
			// tell manager
			_manager.onLoaderComplete(this);
			
			// callback data
			callBack();
			
			// reset
			reset();
		}
		
		protected function callBack():void
		{
			throw new AbstractMethodError();
		}

	}
}