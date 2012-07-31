package blade3d.Loader
{
	import blade3d.Resource.BlResourceManager;
	
	import flash.net.URLLoaderDataFormat;

	public class BlStringLoader extends BlResourceLoader
	{
		public function BlStringLoader(manager:BlResourceLoaderManager)
		{
			super(manager);
			dataFormat = URLLoaderDataFormat.TEXT;
		}
		
		override public function get resType():int {return BlResourceManager.TYPE_STRING;}
		
		override protected function callBack():void
		{
			var str:String = data as String;
			
			// callback
			for(var i:int = 0; i < _callBacks.length; i++)
			{
				_callBacks[i](str);
			}
		}
	}
}