package blade3d.Loader
{
	import blade3d.Resource.BlResourceManager;
	
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;

	public class BlBinaryLoader extends BlResourceLoader
	{
		public function BlBinaryLoader(manager:BlResourceLoaderManager)
		{
			super(manager);
			dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		override public function get resType():int {return BlResourceManager.TYPE_BYTEARRAY;}
		
		override protected function callBack():void
		{
			var ba:ByteArray = data as ByteArray;
			
			// callback
			for(var i:int = 0; i < _callBacks.length; i++)
			{
				_callBacks[i](ba);
			}
		}
	}
}