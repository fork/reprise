package reprise.controls.csspropertyparsers
{ 
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	/**
	 * @author Till Schneidereit
	 */
	public class ScrollbarProperties extends CSSPropertyParser
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var KNOWN_PROPERTIES : Array = 
		[
			'autoHide',
			'scaleScrollThumb',
			'lineScrollSize',
			'pageScrollSize'
		];
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function parseAutoHide(
			val : String, file : String = null) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseScaleScrollThumb(
			val : String, file : String = null) : CSSProperty
		{
			return strToBoolProperty(val, null, file);
		}
		
		public static function parseLineScrollSize(
			val : String, file : String = null) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
		public static function parsePageScrollSize(
			val : String, file : String = null) : CSSProperty
		{
			return strToIntProperty(val, file);
		}
	}
}