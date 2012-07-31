/**
 *	静态模型资源 
 */
package blade3d.Resource
{
	public class BlModelResource extends BlResource
	{
		override public function get resType() : int {return BlResourceManager.TYPE_MESH;}
		
		public function BlModelResource(url:String)
		{
			super(url);
		}
	}
}