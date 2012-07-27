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

	import parsers.DDSParser;

	import parsers.SceneLoader;

	import utils.Log;

	import utils.Res;

	public class Away3d4SceneEditor extends Sprite
	{
		private var _sceneLoader:SceneLoader;

		public function Away3d4SceneEditor()
		{
			globalInit();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			_sceneLoader = new SceneLoader('yewai1');
			_sceneLoader.backgroundColor = 0x666666;
			_sceneLoader.antiAlias = 4;

			// TODO: Added events to SceneLoader.
			addChild(_sceneLoader);

			_sceneLoader.load();
		}

		private static function globalInit():void
		{
			Parsers.enableAllBundled();
			Loader3D.enableParser(DDSParser);

			// FIXME: Cannot override default Max3DSParser.
			// Loader3D.enableParser(parsers.Max3DSParser);
		}

		private function onEnterFrame(ev:Event):void
		{
			_sceneLoader.camera.y = 3 * (stage.mouseY - stage.stageHeight / 2);
			if (_sceneLoader.scene.numChildren > 0)
				_sceneLoader.camera.lookAt(_sceneLoader.scene.getChildAt(0).position);

			_sceneLoader.render();
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