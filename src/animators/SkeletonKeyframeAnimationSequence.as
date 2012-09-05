/**
 *	记录骨骼中每个骨头关键帧的动画序列 
 */
package animators
{
	import away3d.animators.data.*;
	import away3d.animators.nodes.AnimationClipNodeBase;
	import away3d.arcane;
	import away3d.core.math.Quaternion;

	import flash.geom.Vector3D;

	use namespace arcane;
	
	public class SkeletonKeyframeAnimationSequence extends AnimationClipNodeBase
	{
		private var _startFrame : int;		// 开始帧
		private var _endFrame :int			// 结束帧
		private var _frameRate : Number = 33.3333;		// 每帧的持续时间(ms)(3dmax默认每秒30帧)
		private var _boneKeyframes : Vector.<BoneKeyframes>;
		private var _boneNum : uint;
		private var _retJointPose : JointPose = new JointPose;		// 计算某帧骨头位置的返回值用
		
		public function SkeletonKeyframeAnimationSequence(name : String, boneNum : uint) : void
		{
			super(name);
			
			_startFrame = 99999999;
			_endFrame = -99999999;
			_boneNum = boneNum;
			
			_boneKeyframes = new Vector.<BoneKeyframes>(_boneNum, true);;
		}
		
		public function addBoneKeyframe(boneIndex:int, keyframe:int, pos:Vector3D, quat:Quaternion) : void
		{
			// 添加某骨头的关键帧
			if(_startFrame > keyframe) _startFrame = keyframe;
			if(_endFrame < keyframe) _endFrame = keyframe;
			
			if(boneIndex >= _boneNum)
				throw new Error("boneIndex > boneNum");
			
			if(!_boneKeyframes[boneIndex])
				_boneKeyframes[boneIndex] = new BoneKeyframes;
			
			var keyframes : Vector.<Keyframe> = _boneKeyframes[boneIndex].keyframes;
			
			var newKeyframe : Keyframe = new Keyframe;
			newKeyframe.frame = keyframe;
			newKeyframe.pos = pos;
			newKeyframe.quat = quat;
			
			var insertPos : int;
			for(insertPos=0; insertPos<keyframes.length;insertPos++)
			{
				if( keyframe < keyframes[insertPos].frame )
					break;
			}
			keyframes.splice(insertPos,0, newKeyframe);		
		}
		
		public function get boneNum() : uint
		{
			return _boneNum;
		}
		
		public override function get duration() : uint
		{
			return (_endFrame - _startFrame) * _frameRate;
		}
		// 获得该骨头相对于父骨头的位置
		public function getBonePose(boneIndex:int, time:Number) : JointPose
		{
			var beforeI : int = 0;
			var remainTime : Number;
			var keyframes : Vector.<Keyframe> = _boneKeyframes[boneIndex].keyframes;
			
			if( looping )		// loop?
			{
				remainTime = (time % 1) * duration + (_startFrame * _frameRate); 
				
				for(beforeI=0; beforeI<keyframes.length; beforeI++)
				{
					if( remainTime <= (keyframes[beforeI].frame * _frameRate) )
						break;
				}
				
			}
			else
			{
				if( time > 1)
					beforeI = keyframes.length;
				else
				{
					remainTime = time * duration + (_startFrame * _frameRate)
					for(beforeI=0; beforeI<keyframes.length; beforeI++)
					{
						if( remainTime <= (keyframes[beforeI].frame * _frameRate) )
							break;
					}					
				}
			}
			
//			Debug.bltrace("beforeI="+beforeI);
			if(beforeI==0)
			{				
				_retJointPose.translation.copyFrom(keyframes[0].pos);
				_retJointPose.orientation.copyFrom(keyframes[0].quat);
			}
			else if(beforeI == keyframes.length)
			{
				_retJointPose.translation.copyFrom(keyframes[beforeI-1].pos);
				_retJointPose.orientation.copyFrom(keyframes[beforeI-1].quat);
			}
			else
			{
				var weight : Number = (remainTime - (keyframes[beforeI-1].frame * _frameRate)) /
					( (keyframes[beforeI].frame * _frameRate) - (keyframes[beforeI-1].frame * _frameRate) );
				
				var p1 : Vector3D = keyframes[beforeI-1].pos;
				var q1 : Quaternion = keyframes[beforeI-1].quat;
				var p2 : Vector3D = keyframes[beforeI].pos;
				var q2 : Quaternion = keyframes[beforeI].quat;
				
				_retJointPose.orientation.slerp(q1, q2, weight );		// 高质量的quaternion插值
//				_retJointPose.orientation.lerp(q1, q2, weight );
				
				_retJointPose.translation.x = p1.x + weight*(p2.x - p1.x);
				_retJointPose.translation.y = p1.y + weight*(p2.y - p1.y);
				_retJointPose.translation.z = p1.z + weight*(p2.z - p1.z);
			}
			
			return _retJointPose;		
		}
		
	}
	
	
}

import away3d.core.math.Quaternion;

import flash.geom.Vector3D;

class Keyframe
{
	public var frame : int;
	public var pos : Vector3D;
	public var quat : Quaternion;
}

class BoneKeyframes
{
	public var keyframes : Vector.<Keyframe> = new Vector.<Keyframe>;
}


