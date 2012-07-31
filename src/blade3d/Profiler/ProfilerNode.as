package blade3d.Profiler
{
	import flash.utils.getTimer;
	
	public class ProfilerNode
	{
		public var parent : ProfilerNode = null;
		public var children : Vector.<ProfilerNode> = new Vector.<ProfilerNode>;
		
		private var _name : String;
		private var _startTime : Number;
		private var _endTime : Number;
		private var _deltaTime : Number = 0.0;
		public var _reEntry : uint = 0;
		public static const _recordCount : int = 100;				// 记录采样数
		public var _averageTime : Number = 0;
		public var timeRecord : Vector.<Number> = new Vector.<Number>;
		
		public function ProfilerNode(name:String, parent:ProfilerNode) : void
		{
			_name = name;
			this.parent = parent
			Start();
		}
		
		public function Start() : void
		{
			_startTime = getTimer();
			Profiler._currentNodeName = name;
			_reEntry++;
		}
		
		public function End() : void
		{
			_endTime = getTimer();
			_deltaTime += _endTime - _startTime;
			_startTime = _endTime; 
			
			
//			timeRecord.push(_deltaTime);
//			if(timeRecord.length > _recordCount)
//				timeRecord.shift();
			
			if(Profiler._currentNodeName != name)
				throw new Error("Profile pair error");			// profiler的start和end不匹配
						
			if(parent)
				Profiler._currentNodeName = parent.name;
			else
				Profiler._currentNodeName = null;
		}
		
		public function nextFrame() : void
		{
			_reEntry = 0;
			_averageTime = _averageTime*0.9 + _deltaTime*0.1;
			
			timeRecord.push(_deltaTime);
			_deltaTime = 0;
			if(timeRecord.length > _recordCount)
				timeRecord.shift();
			
			for(var i:int=0; i<children.length; i++)
			{
				children[i].nextFrame();
			}
			
		}
		
		public function get name() : String
		{
			return 	_name;
		}
		
		public function get time() : Number
		{
			return _deltaTime;
		}
		
	}
}