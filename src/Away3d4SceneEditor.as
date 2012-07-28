package
{

	import away3d.loaders.Loader3D;

	import controllers.FreeCameraController;

	import flash.display.Sprite;
	import flash.events.Event;

	import parsers.Blade3DXMLParser;

	import parsers.DDSParser;
	import parsers.Max3DSParser;
	import parsers.SceneLoader;

	[SWF(width=800, height=600, backgroundColor=0x0)]
	public class Away3d4SceneEditor extends Sprite
	{
		private var _sceneLoader:SceneLoader;

		public function Away3d4SceneEditor()
		{
			globalInit();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);

			_sceneLoader = new SceneLoader();
			addChild(_sceneLoader);

			stage.addEventListener(Event.RESIZE, onResize);
			_sceneLoader.load('yewai1');

			new FreeCameraController(_sceneLoader);
		}

		private static function globalInit():void
		{
			Loader3D.enableParser(DDSParser);
			Loader3D.enableParser(Max3DSParser);
			Loader3D.enableParser(Blade3DXMLParser);
		}

		private function onEnterFrame(e:Event):void
		{
			_sceneLoader.render();
		}

		private function onResize(e:Event):void
		{
			_sceneLoader.width = stage.stageWidth;
			_sceneLoader.height = stage.stageHeight;

		}
	}
}