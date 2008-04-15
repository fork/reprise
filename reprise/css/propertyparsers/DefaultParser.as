package reprise.css.propertyparsers { 
	import reprise.css.CSSProperty;
	import reprise.css.CSSPropertyParser;
	
	
	public class DefaultParser extends CSSPropertyParser
	{
		
		
		public static function get defaultValues() : Object
		{
			return null;
		}
		
		public static function parseAnything(val:String, file:String) : CSSProperty
		{
			return strToStringProperty(val, file);
		}	
	}
}