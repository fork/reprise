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
	public class NumericListTransitionVO extends PropertyTransitionVO
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function NumericListTransitionVO()
		{
		}
		
		public override function setCurrentValueToRatio(ratio : Number) : *
		{
			var startValues : Array = startValue as Array;
			var endValues : Array = endValue as Array;
			var currentValues : Array = currentValue as Array;
			var i : int = startValues.length;
			while (i--)
			{
				currentValues[i] = startValue[i] + (endValue[i] - startValue[i]) * ratio;
			}
			
			return currentValue;
		}
	}
}