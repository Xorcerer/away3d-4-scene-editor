/**
 *	binary数据 
 */
package blade3d.Resource
{
	import blade3d.Loader.BlResourceLoaderManager;
	
	import flash.utils.ByteArray;

	public class BlBinaryResource extends BlResource
	{
		override public function get resType() : int {return BlResourceManager.TYPE_BYTEARRAY;}
		
		public function BlBinaryResource(url:String)
		{
			super(url);
		}
		
		override protected function _loadImp():void
		{
			BlResourceManager.instance().loaderManager.loadResource(_url, resType, OnBinaryData);
		}
		
		private function OnBinaryData(ba:ByteArray):void
		{
			
			
			_loadEnd();
		}
	}
}