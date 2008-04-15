package reprise.css { 
	import reprise.utils.StringUtil;
	
	
	public class CSSPropertyParser
	{
		
		/**
		* fill these in subclasses
		**/
		public static var KNOWN_PROPERTIES : Array = null;
		public static var INHERITABLE_PROPERTIES : Object = null;
		
			
		
		
		public function CSSPropertyParser() {}
		
		
		
		
		/**
		* don't touch this. no need to call this directly
		**/
		protected static function strToProperty(val:String, file:String = null) : Object
		{
			var prop : CSSProperty = new CSSProperty();
			var obj : Object = CSSParsingHelper.removeImportantFlagFromString(val);
			val = obj.result;
			prop.setImportant(obj.important);
			prop.setCSSFile(file);
			
			if (CSSParsingHelper.valueShouldInherit(val))
			{
				prop.setInheritsValue(true);
			}
				
			return {property : prop, filteredString : val};
		}
		
		protected static function strToNumericProperty(
			val:String, file:String = null) : Object
		{		
			var obj : Object = strToProperty(val, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
	
			if (prop.inheritsValue())
			{
				return obj;
			}
			
			if (val.indexOf('calc(') > -1)
			{
				prop.setIsCalculation(true);
			}
			else
			{
				prop.setUnit(CSSParsingHelper.extractUnitFromString(val));
			}
			
			return {property : prop, filteredString : val};
		}
		
		
		
		
		/**
		* convert string into properties, by declaring the type of the value
		**/
		protected static function strToFloatProperty(val:String, file:String = null) : CSSProperty
		{		
			var obj : Object = strToNumericProperty(val, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
			
			if (val == 'auto' || prop.isCalculation())
			{
				prop.setSpecifiedValue(val);
				return prop;
			}
			prop.setSpecifiedValue(parseFloat(val));
			return prop;
		}
		
		protected static function strToIntProperty(val:String, file:String = null) : CSSProperty
		{
			var obj : Object = strToNumericProperty(val, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
			
			if (val == 'auto' || prop.isCalculation())
			{
				prop.setSpecifiedValue(val);
				return prop;
			}
			prop.setSpecifiedValue(parseInt(val));
			return prop;		
		}
		
		protected static function strToStringProperty(val:String, file:String = null) : CSSProperty
		{
			var obj : Object = strToProperty(val, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
				
			prop.setSpecifiedValue(val);
			return prop;
		}
		
		protected static function strToColorProperty(val:String, file:String = null) : CSSProperty
		{
			var obj : Object = strToProperty(val, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
				
			prop.setSpecifiedValue(CSSParsingHelper.parseColor(val));
			return prop;
		}
		
		protected static function strToURLProperty(val:String, file:String = null) : CSSProperty
		{
			var obj : Object = strToProperty(val, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
				
			prop.setSpecifiedValue(CSSParsingHelper.parseURL(val, file));
			return prop;
		}
		
		protected static function strToBoolProperty(val:String, 
			trueFlags:Array = null, file:String = null) : CSSProperty
		{
			var obj : Object = strToProperty(val, file);
			var prop : CSSProperty = obj.property;
			val = obj.filteredString;
			
			if (prop.inheritsValue())
			{
				return prop;
			}
			
			if (trueFlags == null)
			{
				trueFlags = ['true', '1'];
			}
			
			var isTrue : Boolean = false;
			var i : Number = trueFlags.length;
			while (i--)
			{
				if (val.indexOf(trueFlags[i]) != -1)
				{
					isTrue = true;
					break;
				}
			}		
			prop.setSpecifiedValue(isTrue);
			return prop;		
		}
		
		protected static function strToRectParsingResult(val:String, file:String, name:String) : CSSParsingResult
		{
			var obj : Object = strToProperty(val, file);
			var prop : CSSProperty = obj.property;
			val = StringUtil.trim(obj.filteredString);
			
			var res : CSSParsingResult = new CSSParsingResult();
		
			if (prop.inheritsValue())
			{
				res.addPropertyForKey(prop, name + 'Top');
				res.addPropertyForKey(prop, name + 'Right');
				res.addPropertyForKey(prop, name + 'Bottom');
				res.addPropertyForKey(prop, name + 'Left');
			}
			
			if (val.length == 0)
			{
				return null;
			}
			
			var parts : Array = val.split(' ');
			var important : Boolean = prop.important();
					
			var rectTop : CSSProperty;
			var rectRight : CSSProperty;
			var rectBottom : CSSProperty;
			var rectLeft : CSSProperty;
	
			switch (parts.length)
			{
				case 1:
					rectTop = rectRight = rectBottom = 
						rectLeft = strToIntProperty(parts[0], file);
					break;
					
				case 2:
					rectTop = rectBottom = strToIntProperty(parts[0], file);
					rectRight = rectLeft = strToIntProperty(parts[1], file);								
					break;
					
				case 3:
					rectTop = strToIntProperty(parts[0], file);
					rectRight = rectLeft = strToIntProperty(parts[1], file);
					rectBottom = strToIntProperty(parts[2], file);
					break;
					
				case 4:
					rectTop = strToIntProperty(parts[0], file);
					rectRight = strToIntProperty(parts[1], file);
					rectBottom = strToIntProperty(parts[2], file);
					rectLeft = strToIntProperty(parts[3], file);
					break;
					
				default:
					trace('w Wrong number of parameters for CSSProperty rect with name"' + name + '"');
					return res;
			}
			rectTop.setImportant(important);
			rectRight.setImportant(important);
			rectBottom.setImportant(important);
			rectLeft.setImportant(important);
	
			res.addPropertyForKey(rectTop, name + 'Top');
			res.addPropertyForKey(rectRight, name + 'Right');
			res.addPropertyForKey(rectBottom, name + 'Bottom');
			res.addPropertyForKey(rectLeft, name + 'Left');		
			return res;
		}
	}
}