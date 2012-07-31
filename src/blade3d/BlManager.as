/**
 *	管理器基类 
 */
package blade3d
{
	import flash.events.EventDispatcher;

	public class BlManager extends EventDispatcher
	{
		protected var _initCallBack : Function;
		
		public function BlManager()
		{
		}
	}
}