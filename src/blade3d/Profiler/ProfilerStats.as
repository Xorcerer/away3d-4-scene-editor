package blade3d.Profiler
{
	import away3d.containers.View3D;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	
	public class ProfilerStats extends Sprite
	{
		private var _dia_bmp : BitmapData;
		private var _diagram : Sprite;
		private var _profile_graph : Shape;
		private var _functionNames : Vector.<TextField> = new Vector.<TextField>;
		
		private var frameTimeRecords : Vector.<Number> = new Vector.<Number>;
		private var _lastFrameTime : Number;
		private var _scaleText : TextField;
		
		private var _functionInfoDirty : Boolean = true;
		private var _lastFunctionInfoTime : uint = 0;
		
		// 位置
		private static const _WIDTH : Number = 200;
		private static const _HEIGHT : Number = 250;
		private static const _PROF_COUNT : int = 5;
		private var _gridHeightY : Number = 0;
		private var _stepX : Number = 0;
		private var _scale : Number = 1;
		private var _lineCount : int = 0;
		
		// 拖动
		private var _drag_dx : Number;
		private var _drag_dy : Number;
		private var _dragging : Boolean = false;
		
		//
		private var _drawNode : ProfilerNode;
		static public var instance : ProfilerStats = null;
		
		public function ProfilerStats(view3d : View3D = null)
		{
			super();
			_init();
			
			instance = this;
		}
		
		private function _init() : void
		{
			_initDiagrams();
			_functionInfoDirty = true;
						
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, _onRemovedFromStage);
		}
		
		private function _onAddedToStage(ev : Event) : void
		{
		}
		
		private function _onRemovedFromStage(ev : Event) : void
		{
		}
		
		private function _initDiagrams() : void
		{
			_dia_bmp = new BitmapData(_WIDTH, _HEIGHT, true, 100);
			_diagram = new Sprite;
			_diagram.graphics.beginBitmapFill(_dia_bmp);
			_diagram.graphics.drawRect(0, 0, _dia_bmp.width, _dia_bmp.height);
			_diagram.graphics.endFill();
			_diagram.y = 0;
			addChild(_diagram);	
			_diagram.graphics.lineStyle(1, 0xffffff, 0.3);
			
			_gridHeightY = _HEIGHT/_PROF_COUNT; 
			_stepX = _WIDTH/ProfilerNode._recordCount;
			
			
			_profile_graph = new Shape;
			_profile_graph.y = 0;
			addChildAt(_profile_graph, 0);
			

			for(var i:int=0; i<=_PROF_COUNT; i++)
			{
				_diagram.graphics.moveTo(0, 0+i*_gridHeightY);
				_diagram.graphics.lineTo(_WIDTH, +i*_gridHeightY);
			}
			
			var function_btn : Sprite;
			var _swhw_tf : TextField;
			
			for(i=0; i<_PROF_COUNT; i++)
			{
				function_btn = new Sprite;
				function_btn.x = 7 + i * 15;
				function_btn.y = 7;
				function_btn.graphics.beginFill(0, 0);
				function_btn.graphics.lineStyle(1, 0xefefef, 1, true);
				function_btn.graphics.drawRect(-4, -4, 8, 8);
				function_btn.graphics.moveTo(-3, 2);
				function_btn.graphics.lineTo(i-3, 2);
				function_btn.buttonMode = true;
				_diagram.addChild(function_btn);
				if(i==0)
					function_btn.addEventListener(MouseEvent.CLICK, _onInFunctionBtnClick1);
				else if(i==1)
					function_btn.addEventListener(MouseEvent.CLICK, _onInFunctionBtnClick2);
				else if(i==2)
					function_btn.addEventListener(MouseEvent.CLICK, _onInFunctionBtnClick3);
				else if(i==3)
					function_btn.addEventListener(MouseEvent.CLICK, _onInFunctionBtnClick4);
				else if(i==4)
					function_btn.addEventListener(MouseEvent.CLICK, _onInFunctionBtnClick5);
			
				var funcNameText : TextField = new TextField;
				funcNameText.defaultTextFormat = new TextFormat('_sans', 9, 0xffffff, true);;
				funcNameText.autoSize = TextFieldAutoSize.LEFT;
				funcNameText.x = 2;
				funcNameText.y = i*_gridHeightY + _gridHeightY/2;
				funcNameText.selectable = false;
				funcNameText.mouseEnabled = false;
				_diagram.addChild(funcNameText);
				_functionNames.push(funcNameText);
				funcNameText.text = "";
			}
			
			for(i=0;i<2;i++)
			{
				function_btn = new Sprite;
				function_btn.x = 107 + i * 15;
				function_btn.y = 7;
				function_btn.graphics.beginFill(0, 0);
				function_btn.graphics.lineStyle(1, 0xefefef, 1, true);
				function_btn.graphics.drawRect(-4, -4, 8, 8);
				function_btn.graphics.moveTo(-3, 2);
				function_btn.graphics.lineTo(i-3, 2);
				function_btn.buttonMode = true;
				_diagram.addChild(function_btn);
				if(i==0)
					function_btn.addEventListener(MouseEvent.CLICK, _onOutFunctionBtnClick);
				else if(i==1)
					function_btn.addEventListener(MouseEvent.CLICK, _onProfileToggleClick);
				else if(i==2)
					function_btn.addEventListener(MouseEvent.CLICK, _onReflashText);
			}
			
			for(i=0;i<2;i++)
			{
				function_btn = new Sprite;
				function_btn.x = 150 + i * 15;
				function_btn.y = 7;
				function_btn.graphics.beginFill(0, 0);
				function_btn.graphics.lineStyle(1, 0xefefef, 1, true);
				function_btn.graphics.drawRect(-4, -4, 8, 8);
				function_btn.graphics.moveTo(-3, 2);
				function_btn.graphics.lineTo(i-3, 2);
				function_btn.buttonMode = true;
				_diagram.addChild(function_btn);
				if(i==0)
					function_btn.addEventListener(MouseEvent.CLICK, _onAddScaleClick);
				else if(i==1)
					function_btn.addEventListener(MouseEvent.CLICK, _onSubScaleClick);
			}
			
			_scaleText = new TextField;
			_scaleText.defaultTextFormat = new TextFormat('_sans', 9, 0xffffff, true);;
			_scaleText.autoSize = TextFieldAutoSize.LEFT;
			_scaleText.x = 170;
			_scaleText.y = 0;
			_scaleText.selectable = false;
			_scaleText.mouseEnabled = false;
			_diagram.addChild(_scaleText);
			_scaleText.text = "x" + _scale.toFixed(2).toString();
			
			// 支持拖动
			_diagram.addEventListener(MouseEvent.MOUSE_DOWN, _onDiagramMouseDown);
		}
		
		public function redraw(curTime : int, deltaTime : int) : void
		{
			frameTimeRecords.push(deltaTime);
			if(frameTimeRecords.length > 100)
				frameTimeRecords.shift();
			
			
			// main plate
			this.graphics.clear();
			this.graphics.beginFill(0, 0.6);
			this.graphics.drawRect(0, 0, _WIDTH, _HEIGHT);
			
			// 绘制性能曲线
			var g : Graphics;
			g = _profile_graph.graphics;
			g.clear();
			g.lineStyle(.5, 0xff00cc, 1, true, LineScaleMode.NONE);
			
			var lineCount : int = 0;
			if(!_drawNode)
			{	
				var y:int = 0;
				var yh : Number;
				var node : ProfilerNode;
				for(var key : Object in Profiler._rootNodeMap)
				{
					if(y >= _PROF_COUNT-1)
						continue;
					
					node = Profiler._rootNodeMap[key];
					g.moveTo(0, _gridHeightY*(y+1));
					for(var i:int=0; i<node.timeRecord.length; i++)
					{
						yh = node.timeRecord[i] * _scale;
						if(yh > _gridHeightY) yh = _gridHeightY;
						g.lineTo(i*_stepX, _gridHeightY*(y+1) - yh);
					}
					y++;
				}
											
				g.moveTo(0, _gridHeightY*(y+1));
				for(i=0; i<frameTimeRecords.length; i++)
				{
					yh = frameTimeRecords[i] * _scale;
					if(yh > _gridHeightY) yh = _gridHeightY;
					g.lineTo(i*_stepX, _gridHeightY*(y+1) - yh);
				}
				y++;
				lineCount = y;
				
			}
			else
			{
//				var info : String = "";				
				for(var ni:int=0; ni<_drawNode.children.length; ni++)
				{
					node = _drawNode.children[ni];
					g.moveTo(0, _gridHeightY*(ni+1));
					for(i=0; i<node.timeRecord.length; i++)
					{
						yh = node.timeRecord[i] * _scale;
						if(yh > _gridHeightY) yh = _gridHeightY;
						g.lineTo(i*_stepX, _gridHeightY*(ni+1) - yh);
					}
//					info += node.name + "=" + node.time + " " + node._reEntry;
				}
				//Debug.bltrace( info );
				lineCount = ni;
			}
			
			if(lineCount != _lineCount)
			{
				_functionInfoDirty = true;
				_lineCount = lineCount;
			}
			
			// 每间隔一段时间更新函数信息
			if(curTime - _lastFunctionInfoTime > 3000)
				_functionInfoDirty = true;
			
			if(_functionInfoDirty)
			{
				reDrawFunctionInfo();
				_lastFunctionInfoTime = curTime;
				_functionInfoDirty = false;
			}
		}
		
		private function reDrawFunctionInfo() : void
		{
			var ni : int;
			if(_drawNode)
			{
				for(ni=0; ni<_drawNode.children.length && ni<_PROF_COUNT; ni++)
				{
					_functionNames[ni].text = 
						_drawNode.children[ni].name + " " +_drawNode.children[ni]._averageTime.toFixed(1) + " " + _drawNode.children[ni]._reEntry;					
				}
				
				for( ;ni < _PROF_COUNT; ni++)
				{
					_functionNames[ni].text = "";
				}
			}
			else
			{
				for(ni=0 ;ni < _PROF_COUNT; ni++)
				{
					_functionNames[ni].text = "";
				}
				
				ni = 0;
				var node : ProfilerNode;
				for(var key : Object in Profiler._rootNodeMap)
				{
					node = Profiler._rootNodeMap[key];
					if(ni < _PROF_COUNT)
						_functionNames[ni].text = node.name + " " + node._averageTime.toFixed(1) + " " + node._reEntry;
					ni++;
				}
				if(ni < _PROF_COUNT)
					_functionNames[ni].text = "frameTime";
			}
		}
		
		private function _onInFunctionBtnClick1(ev : MouseEvent) : void
		{
			if(!_drawNode)
				_drawNode = Profiler.getRootNode(0);
			else if(_drawNode.children.length > 0)
				_drawNode = _drawNode.children[0];
			_functionInfoDirty = true;
		}
		
		private function _onInFunctionBtnClick2(ev : MouseEvent) : void
		{
			if(!_drawNode)
				_drawNode = Profiler.getRootNode(1);
			else if(_drawNode.children.length > 1)
				_drawNode = _drawNode.children[1];
			_functionInfoDirty = true;
		}
		
		private function _onInFunctionBtnClick3(ev : MouseEvent) : void
		{
			if(!_drawNode)
				_drawNode = Profiler.getRootNode(2);
			else if(_drawNode.children.length > 2)
				_drawNode = _drawNode.children[2];
			_functionInfoDirty = true;
		}
		
		private function _onInFunctionBtnClick4(ev : MouseEvent) : void
		{
			if(!_drawNode)
				_drawNode = Profiler.getRootNode(3);
			else if(_drawNode.children.length > 3)
				_drawNode = _drawNode.children[3];
			_functionInfoDirty = true;
		}
		
		private function _onInFunctionBtnClick5(ev : MouseEvent) : void
		{
			if(!_drawNode)
				_drawNode = Profiler.getRootNode(4);
			else if(_drawNode.children.length > 4)
				_drawNode = _drawNode.children[4];
			_functionInfoDirty = true;
		}
		
		private function _onOutFunctionBtnClick(ev : MouseEvent) : void
		{
			if(_drawNode)
				_drawNode = _drawNode.parent;
			_functionInfoDirty = true;
		}
		
		private function _onProfileToggleClick(ev : MouseEvent) : void
		{
			Profiler.isProfiler = !Profiler.isProfiler;
		}
		
		private function _onReflashText(ev : MouseEvent) : void
		{
			_functionInfoDirty = true;
		}
		
		private function _onAddScaleClick(ev : MouseEvent) : void
		{
			_scale = _scale*2;
			_scaleText.text = "x" + _scale.toFixed(2).toString();
		}
		
		private function _onSubScaleClick(ev : MouseEvent) : void
		{
			_scale = _scale/2;
			_scaleText.text = "x" + _scale.toFixed(2).toString();
		}
		
		private function _onDiagramMouseDown(ev : MouseEvent) : void
		{
			_drag_dx = this.mouseX;
			_drag_dy = this.mouseY;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, _onMouseUpOrLeave);
			stage.addEventListener(Event.MOUSE_LEAVE, _onMouseUpOrLeave);
		}
		
		private function _onMouseMove(ev : MouseEvent) : void
		{
			_dragging = true;
			this.x = stage.mouseX - _drag_dx;
			this.y = stage.mouseY - _drag_dy;
		}
		
		private function _onMouseUpOrLeave(ev : Event) : void
		{
			_endDrag();
		}
		
		private function _endDrag() : void
		{
			if (this.x < -_WIDTH)
				this.x = -(_WIDTH-20);
			else if (this.x > stage.stageWidth)
				this.x = stage.stageWidth - 20;
			
			if (this.y < 0)
				this.y = 0;
			else if (this.y > stage.stageHeight)
				this.y = stage.stageHeight - 15;
			
			// Round x/y position to make sure it's on
			// whole pixels to avoid weird anti-aliasing
			this.x = Math.round(this.x);
			this.y = Math.round(this.y);
			
			
			_dragging = false; 
			stage.removeEventListener(Event.MOUSE_LEAVE, _onMouseUpOrLeave);
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onMouseUpOrLeave);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onMouseMove);
		}
		
	}	
}