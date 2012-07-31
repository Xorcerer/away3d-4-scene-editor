package editor
{
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.partition.Partition3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;
	
	import blade3d.BlEngine;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import org.aswing.AsWingManager;
	import org.aswing.BorderLayout;
	import org.aswing.Insets;
	import org.aswing.JButton;
	import org.aswing.JPanel;
	import org.aswing.JWindow;
	import org.aswing.SoftBox;
	import org.aswing.SolidBackground;
	import org.aswing.UIManager;
	import org.aswing.border.EmptyBorder;
	import org.aswing.event.AWEvent;

	[SWF(width="700", height="500", backgroundColor="#ffffff", frameRate="60", quality="LOW")]
	public class ModelViewer extends Sprite
	{ 
		
		[Embed(source="/../floor_diffuse.jpg")]
		public static var TestTexture:Class;
		
		private var _view:View3D;
		private var _camController:HoverController;
		
		private var _move:Boolean = false;		
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		private var _light:DirectionalLight;
		private var _lightPicker:StaticLightPicker;
		
		private var _mesh:Mesh;
//		private var _bmpMat:TextureMaterial= new BitmapMaterial();
		private var _testMaterial:TextureMaterial;
		private var _ground:Mesh;
		private var _meshFile:FileReference;
		
		private var _openBtn:JButton;			// 打开
		
		public function ModelViewer() 
		{
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void
		{
			_meshFile = new FileReference;
			
			InitEngine();
			InitUI();
						
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
		private function InitEngine():void
		{
			_view = new View3D();
			addChild(_view);
			
			//     this
			//   /      \
			// view3D   aswing
			BlEngine.init(this, _view, InitModel);
			
			
//			_view.scene.partition = new Partition3D(null);
			
			_view.camera.lens.far = 2100;
			
			_camController = new HoverController(_view.camera, null, 45, 20, 1000, 10);
			
			_view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_view.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		private function InitUI():void
		{
			
//			var window:JWindow;
//			window = new JWindow(this);
//			window.setBackgroundDecorator(new SolidBackground(UIManager.getColor("window")));
//			
//			window.setBorder(new EmptyBorder(null, new Insets(4, 4, 4, 4)));
//			window.setX(100);
//			window.setSizeWH(100, 200);
//			window.show();
//			
//			var pane:SoftBox = SoftBox.createVerticalBox(0);
//			window.setContentPane(pane);
//			
//			_openBtn = new JButton("open mesh");
//			pane.append(_openBtn);
//			pane.append(new JButton("open texture"));
//			
//			_openBtn.addActionListener(onBtn);
		}
		
		private function InitModel():void
		{
			_light = new DirectionalLight(-1, -1, 1);
			_lightPicker = new StaticLightPicker([_light]);
			_view.scene.addChild(_light);
			
			_testMaterial = new TextureMaterial(Cast.bitmapTexture(TestTexture));
			_testMaterial.shadowMethod = new FilteredShadowMapMethod(_light);
			_testMaterial.lightPicker = _lightPicker;
			_testMaterial.specular = 0;
			
			_ground = new Mesh(new PlaneGeometry(1000, 1000), _testMaterial);
			_view.scene.addChild(_ground);
		}
		
		private function onBtn(e:AWEvent):void
		{
			if(e.target == _openBtn)
			{
				_meshFile.browse([new FileFilter(".3ds", "*.3ds;")]);	
				_meshFile.addEventListener(Event.SELECT, function(event : Event) :void
					{
						_meshFile.load();		// 加载模型文件
					}
				);	
				_meshFile.addEventListener(Event.COMPLETE, onMeshFileLoaded);
			}
		}
		
		private function onMeshFileLoaded(event : Event) : void 
		{
			var packageData : ByteArray = _meshFile.data;
			if(_mesh)
			{
				_mesh.dispose();
			}
			
//			_mesh = new Mesh(_bmpMat);
//			_view.scene.addChild(_mesh);
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			_lastPanAngle = _camController.panAngle;
			_lastTiltAngle = _camController.tiltAngle;
			_lastMouseX = stage.mouseX;
			_lastMouseY = stage.mouseY;
			_move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			_move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onStageMouseLeave(event:Event):void
		{
			_move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onEnterFrame(e:Event):void
		{
			BlEngine.render();
			_view.render();
			
			if(_move)
			{
				_camController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle;
				_camController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle;
			}
			
		}
		
		
	}
};