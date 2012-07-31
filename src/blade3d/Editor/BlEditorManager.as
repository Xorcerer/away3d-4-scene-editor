package blade3d.Editor
{
	import away3d.debug.Debug;
	
	import blade3d.BlManager;
	
	import flash.display.Sprite;
	
	import org.aswing.AsWingManager;

	public class BlEditorManager extends BlManager
	{
		static private var _instance : BlEditorManager;
		
		private var _rootSprite : Sprite;
		private var _resourceEditor : BlResourceEditor;
		
		public function BlEditorManager()
		{
			if(_instance)
				Debug.error("BlResourceManager error");
		}
		
		static public function instance() : BlEditorManager
		{
			if(!_instance)
				_instance = new BlEditorManager;
			return _instance;
		}
		
		public function init(rootSprite:Sprite, callBack:Function):Boolean
		{
			_rootSprite = rootSprite;
			_initCallBack = callBack;
			
			AsWingManager.setRoot(rootSprite);
			
			// 创建资源管理编辑界面
			_resourceEditor = new BlResourceEditor(_rootSprite, "Resource");
			
			
			_initCallBack(this);
			return true;
		}
	}
}