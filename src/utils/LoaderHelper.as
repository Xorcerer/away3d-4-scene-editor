/**
 * Created with IntelliJ IDEA.
 * User: logan
 * Date: 9/5/12
 * Time: 11:54 AM
 * To change this template use File | Settings | File Templates.
 */
package utils
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class LoaderHelper
	{
		public function LoaderHelper()
		{
		}

		public static function loadFromUrl(url:String, callback:Function):void
		{
			if (callback == null)
				return;

			var req:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader(req);
			loader.addEventListener(Event.COMPLETE, callback);
		}
	}
}
