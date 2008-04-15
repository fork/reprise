package reprise.tweens
{
	import reprise.utils.ColorUtil;
	
	
	public class ColorTweenPropertyVO extends TweenedPropertyVO
	{
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ColorTweenPropertyVO(
			scope:Object, property:String, startValue:Number, 
			targetValue:Number, tweenFunction:Function, roundResults:Boolean, 
			propertyIsMethod:Boolean, extraParams:Array)
		{
			super(scope, property, startValue, targetValue, tweenFunction, 
				roundResults, propertyIsMethod, extraParams);
		}
			
		
		/***************************************************************************
		*							private methods								   *
		***************************************************************************/
		private function tweenedValue(duration:Number, time:Number) : Number
		{
			var args : Array = [time, 0, 100, duration].concat(extraParams);
			var percent : Number = tweenFunction.apply(null, args);
			
			var startColorRGB : Object = ColorUtil.number2rgbObject(startValue);
			var endColorRGB : Object = ColorUtil.number2rgbObject(targetValue);
			var currentColorRGB : Object = {};
			
			currentColorRGB.r = startColorRGB.r + 
				(endColorRGB.r - startColorRGB.r) / 100 * percent;
			currentColorRGB.g = startColorRGB.g + 
				(endColorRGB.g - startColorRGB.g) / 100 * percent;
			currentColorRGB.b = startColorRGB.b + 
				(endColorRGB.b - startColorRGB.b) / 100 * percent;
			
			return ColorUtil.rgbObject2Number(currentColorRGB);
		}
	}
}