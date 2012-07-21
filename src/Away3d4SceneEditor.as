package
{

	import away3d.containers.View3D
	import away3d.events.LoaderEvent
	import away3d.loaders.Loader3D
	import away3d.loaders.parsers.Parsers

	import flash.display.Sprite
	import flash.events.Event
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest
	import flash.ui.Keyboard;

	public class Away3d4SceneEditor extends Sprite
	{
		private var _view:View3D
		private var _loader:Loader3D

		public function Away3d4SceneEditor()
		{
			_view = new View3D()
			_view.backgroundColor = 0x666666
			_view.antiAlias = 4
			addChild(_view)
			addEventListener(Event.ENTER_FRAME, onEnterFrame)

			Parsers.enableAllBundled()

			_loader = new Loader3D()
			_loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete)
			_loader.addEventListener(LoaderEvent.LOAD_ERROR, onLoadError)
			_loader.load(new URLRequest('../res/box.3ds'))
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown)
		}

		private function onEnterFrame(ev:Event):void
		{
			_view.camera.y = 3 * (stage.mouseY - stage.stageHeight / 2)
			if (_loader)
			{
				_loader.rotationY = stage.mouseX - stage.stageWidth / 2
				_view.camera.lookAt(_loader.position)
			}

			_view.render()
		}

		private function onLoadError(ev:LoaderEvent):void
		{
			trace(ev.message)
			_loader.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete)
			_loader.removeEventListener(LoaderEvent.LOAD_ERROR, onLoadError)
			_loader = null
		}

		private function onResourceComplete(ev:LoaderEvent):void
		{
			_loader.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete)
			_loader.removeEventListener(LoaderEvent.LOAD_ERROR, onLoadError)
			_view.scene.addChild(_loader)
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.F)
				_loader.scale(1.1)
			else if (e.keyCode == Keyboard.B)
				_loader.scale(0.9)
		}
	}
}