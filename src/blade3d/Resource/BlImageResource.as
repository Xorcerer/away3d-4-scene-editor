/**
 *	贴图资源模型 
 */
package blade3d.Resource
{
	import flash.utils.ByteArray;

	public class BlImageResource extends BlResource
	{
		override public function get resType() : int {return BlResourceManager.TYPE_TEXTURE;}
		
		public function BlImageResource(url:String)
		{
			super(url);
		}
		
		override protected function _loadImp():void
		{
			BlResourceManager.instance().loaderManager.loadResource(_url, resType, OnImageData);
		}
		
		private function OnImageData(ba:ByteArray):void
		{
			
			
			_loadEnd();
		}
	}
}