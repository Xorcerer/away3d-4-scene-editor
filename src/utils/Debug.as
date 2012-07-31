/**
 * Created with IntelliJ IDEA.
 * User: logan
 * Date: 7/31/12
 * Time: 5:39 PM
 * To change this template use File | Settings | File Templates.
 */
package utils
{
	public class Debug
	{
		public static var assertEnable:Boolean = false;

		public static function asert(value:Boolean, error:String = ''):void
		{
			if(assertEnable && !value)
			{
				throw new Error("Assertion failed: " + error);
			}
		}

	}
}
