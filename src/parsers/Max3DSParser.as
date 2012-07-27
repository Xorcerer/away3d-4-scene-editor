package parsers
{
	import away3d.loaders.parsers.Max3DSParser;

	import flash.net.URLRequest;

	/**
	 * A Max3DSParser with a configurable dependency texture url prefix.
	 */
	public class Max3DSParser extends away3d.loaders.parsers.Max3DSParser
	{
		private var _urlPrefixForTexture:String;

		public function Max3DSParser(urlPrefixForTexture:String = null)
		{
			_urlPrefixForTexture = urlPrefixForTexture;
		}

		override protected function addDependency(id:String, req:URLRequest, retrieveAsRawData:Boolean = false, data:* = null, suppressErrorEvents:Boolean = false):void
		{
			if (_urlPrefixForTexture &&
					(req.url.substr(0, 1) != '/' || req.url.substr(0, 5).toLowerCase() != 'http:')) // Not absolute.
			{
				req.url = (_urlPrefixForTexture + req.url).toLowerCase();
			}
			super.addDependency(id, req, retrieveAsRawData, data, suppressErrorEvents);
		}

	}
}
