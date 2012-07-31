/**
 *	引擎 
 */
package blade3d
{
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.debug.Debug;
	
	import blade3d.Editor.BlEditorManager;
	import blade3d.Resource.BlResourceManager;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FocusEvent;

	public class BlEngine
	{
		static private var _sprite:Sprite; 
		static private var _mainView:View3D;
		static private var _initCount:int = 0;
		static private var _initEndCallBack:Function;
		
		public function BlEngine()
		{
		}
		
		static public function init(sprite:Sprite, mainView:View3D, initEndCallBack:Function=null):void
		{
			_sprite = sprite;
			_mainView = mainView;
			_initEndCallBack = initEndCallBack;
			
			_sprite.stage.scaleMode = StageScaleMode.NO_SCALE;
			_sprite.stage.align = StageAlign.TOP_LEFT;
//			_sprite.stage.stageFocusRect = true;
			
			// 初始化编辑管理器
			_initCount++;
			if(!BlEditorManager.instance().init(_sprite, onInitManagerCallBack))
				Debug.error("BlEditorManager init failed");
			
			// 初始化资源管理器
			_initCount++;
			if(!BlResourceManager.instance().init(onInitManagerCallBack))
				Debug.error("BlResourceManager init failed");
			
			_sprite.addEventListener(Event.RESIZE, onResize);
			onResize();
			
			
			_sprite.addChild(new AwayStats(_mainView));
		}
		
		static private function onInitManagerCallBack(manager:Object) : void
		{
			Debug.trace(manager+" init end");
			_initCount--;
			if(_initCount==0)
			{
				_initEndCallBack();
			}
		}
		
		static public function render():void
		{
			
		}
		
		static private function onResize(event:Event = null):void
		{
			_mainView.width = _sprite.stage.stageWidth;
			_mainView.height = _sprite.stage.stageHeight;
			//			_signatureBitmap.y = stage.stageHeight - _signature.height;
		}
	}
}