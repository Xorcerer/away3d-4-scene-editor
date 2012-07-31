package blade3d.Profiler
{
	//import away3d.debug.ProfileNode;
	
	public class Profiler
	{
		public static var _rootNodeMap : Object = new Object;
		private static var _rootCount : int = 0;
		private static var _currentProfileNode : ProfilerNode = null;
		public static var isProfiler : Boolean = true;		// 是否启用
		public static var _currentNodeName :String;
		
		private static var _allProfilerNode : Vector.<ProfilerNode> = new Vector.<ProfilerNode>;

		
		public static function start(name:String) : void
		{
			if(!isProfiler)
				return;
		
			//Debug.bltrace("Start " + name);
			if(_currentProfileNode)
			{
				var i:int = 0;
				while(i<_currentProfileNode.children.length)
				{
					if(_currentProfileNode.children[i].name == name)
						break;
					i++;	
				}
				
				if(i < _currentProfileNode.children.length)
				{
					_currentProfileNode = _currentProfileNode.children[i];
					_currentProfileNode.Start();
				}
				else
				{
					var newProfilerNode : ProfilerNode = new ProfilerNode(name, _currentProfileNode);
					_allProfilerNode.push(newProfilerNode);
					_currentProfileNode.children.push(newProfilerNode);
					_currentProfileNode = newProfilerNode;
				}
				
			}
			else
			{
				if( _rootNodeMap.hasOwnProperty(name) )
				{
					_currentProfileNode = _rootNodeMap[name];
					_currentProfileNode.Start();
				}				
				else
				{
					_currentProfileNode	= new ProfilerNode(name, null);
					_allProfilerNode.push(_currentProfileNode);
					_rootNodeMap[name] = _currentProfileNode;
					_rootCount++;
				}
			}
		}
		
		public static function end(name:String) : void
		{
			if(!isProfiler)
				return;
			
			//Debug.bltrace("end " + name + " cur " + Profiler._currentNodeName);
			if(_currentProfileNode)
			{
				if(Profiler._currentNodeName != name)
					throw new Error("Profile pair error");			// profiler的start和end不匹配
				
				_currentProfileNode.End();
				_currentProfileNode = _currentProfileNode.parent;
			}
		}
		
		public static function nextFrame() : void
		{
			if(!isProfiler)
				return;
			
			for each(var node:ProfilerNode in _rootNodeMap)
			{
				node.nextFrame();
			}
		}
		
		public static function getFirstRootNode() : ProfilerNode
		{
			return _allProfilerNode[0];
		}
		
		public static function get rootCount() : int
		{
			return _rootCount;
		}
		
		public static function getRootNode(index : int) : ProfilerNode
		{
			var resNode : ProfilerNode = null;
			var count:int = 0;
			for(var key:Object in _rootNodeMap)
			{
				if(index == count)
					resNode = _rootNodeMap[key];
				count++;
			}
			return resNode;
		}

	}	
}
