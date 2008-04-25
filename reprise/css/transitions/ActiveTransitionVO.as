////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.css.transitions
{
	import reprise.css.CSSProperty;
	
	public class ActiveTransitionVO
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public var property : String;
		public var duration : CSSProperty;
		public var delay : CSSProperty;
		public var easing : Function;
		
		public var endValue : CSSProperty;
		public var currentValue : CSSProperty;
		
		public var startTime : int;
		
		public var hasCompleted : Boolean;
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_startValue : CSSProperty;
		
		public function ActiveTransitionVO()
		{
		}
		
		public function set startValue(value : CSSProperty) : void
		{
			m_startValue = value;
			currentValue = value.clone();
		}
		public function get startValue() : CSSProperty
		{
			return m_startValue;
		}
		
		public function updateValues(endValue : CSSProperty, 
			duration : CSSProperty, delay : CSSProperty, 
			startTime : int, context : Object) : void
		{
			setValueForTimeInContext(startTime, context);
			var current : Number = currentValue.specifiedValue();
			this.startValue = this.endValue;
			this.endValue = endValue;
			this.duration = duration;
			this.delay = delay;
			this.startTime = startTime;
			
			var durationValue : int = duration.valueOf() as int;
			var stepAmount : int;
			var stepTimeOffset : int = 0;
			var lastStepValue : Number; 
			setValueForTimeInContext(startTime, context);
			var stepValue : Number = currentValue.specifiedValue();
			var shelter : int = 1000;
			if (startValue.valueOf() < current && endValue.valueOf() > current 
				||
				startValue.valueOf() > current && endValue.valueOf() < current)
			{
				stepAmount = 10;
			}
			else
			{
				stepAmount = -10;
			}
			do
			{
				lastStepValue = stepValue;
				stepTimeOffset += stepAmount;
				setValueForTimeInContext(startTime + stepTimeOffset, context);
				stepValue = currentValue.specifiedValue();
			}
			while (Math.max(current, stepValue) - Math.min(current, stepValue) 
				<=
				Math.max(current, lastStepValue) - 
				Math.min(current, lastStepValue) && shelter--);
			
			this.startTime -= stepTimeOffset + stepAmount;
		}
		
		public function setValueForTimeInContext(time : int, context : Object) : void
		{
			var durationValue : int = duration.valueOf() as int;
			var currentTime : int = time - startTime;
			if (durationValue <= currentTime)
			{
				hasCompleted = true;
				currentValue = endValue;
				return;
			}
			var end : Number = endValue.valueOf() as Number;
			var start : Number = startValue.valueOf() as Number;
			var value : Number = easing(currentTime, start, end - start, durationValue);
			value = Math.round(value);
			currentValue.setSpecifiedValue(value);
		}
	}
}