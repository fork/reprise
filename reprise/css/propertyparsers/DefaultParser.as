package de.fork.css.propertyparsers { 
	import de.fork.css.CSSProperty;
	import de.fork.css.CSSPropertyParser;
	
	
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