/**
 * Created with IntelliJ IDEA.
 * User: logan
 * Date: 7/25/12
 * Time: 1:16 AM
 * To change this template use File | Settings | File Templates.
 */
package utils
{
	public class Log
	{
		public static function concatenate(args:Array):String
		{
			return args.join(' ');
		}

		public static function p(prefix:String, args:Array):void
		{
			trace(prefix + ': ', concatenate(args));
		}

		public static function d(... args):void
		{
			p('DEBUG', args);
		}

		public static function e(... args):void
		{
			p('Error', args);
		}
	}
}
