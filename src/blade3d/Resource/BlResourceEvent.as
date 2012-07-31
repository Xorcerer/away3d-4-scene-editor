/**
 *	资源事件 
 */
package blade3d.Resource
{
	import flash.events.Event;
	
	public class BlResourceEvent extends Event
	{
		// 资源列表加载
		public static const RESOURCE_LIST : String = "resourceList";
		
		// 资源加载完毕
		public static const RESOURCE_COMPLETE : String = "resourceComplete";
		
		
		public var res:BlResource;
		
		public function BlResourceEvent(type:String, res:BlResource)
		{
			super(type);
			this.res = res;
		}
	}
}