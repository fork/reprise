package de.fork.easing
{ 
	/**
	 * @author °°*Joachim Fraatz
	 */
	public class Custom 
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function easeInHexOutBack (
			t:Number, b:Number, c:Number, d:Number, s:Number):Number
		{
			if (s == undefined) s = 1.70158; 
			if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
			return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
		}
	}
}