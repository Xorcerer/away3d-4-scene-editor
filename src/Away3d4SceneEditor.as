package
{

	import away3d.containers.View3D;
	import away3d.events.LoaderEvent;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.Parsers;

	import controllers.ViewController;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;

	import parsers.SceneLoader;

	import utils.Log;

	import utils.Res;

	public class Away3d4SceneEditor extends Sprite
	{
		private var _view:View3D;
		private var _viewController:ViewController;

		public function Away3d4SceneEditor()
		{
			Parsers.enableAllBundled();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			_view = new View3D();
			_view.backgroundColor = 0x666666;
			_view.antiAlias = 4;
			addChild(_view);

			_viewController = new ViewController(_view);
			_viewController.loadScene('yewai1');
		}

		private function onEnterFrame(ev:Event):void
		{
			_view.camera.y = 3 * (stage.mouseY - stage.stageHeight / 2);
			if (_view.scene.numChildren > 0)
				_view.camera.lookAt(_view.scene.getChildAt(0).position);

			_view.render();
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.F)
			{}
			else if (e.keyCode == Keyboard.B)
			{}
		}
	}
}