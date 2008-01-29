package de.fork.css { 
	import de.fork.controls.csspropertyparsers.ScrollbarProperties;
	import de.fork.css.propertyparsers.Background;
	import de.fork.css.propertyparsers.Border;
	import de.fork.css.propertyparsers.DefaultParser;
	import de.fork.css.propertyparsers.DisplayPosition;
	import de.fork.css.propertyparsers.Filters;
	import de.fork.css.propertyparsers.Font;
	import de.fork.css.propertyparsers.Margin;
	import de.fork.css.propertyparsers.Padding;
	import de.fork.utils.StringUtil;
	public class CSSDeclaration
	{
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var m_inheritableProperties : Object = {};
		protected static var m_defaultValues : Object	= {};
		protected static var m_propertyToParserTable : Object	= {};
		
		protected static var g_defaultPropertiesRegistered : Boolean;	
		
		// this property only exist to reduce the display of errors, if there are missing parsers
		protected static var m_thrownErrors : Object	= {};
		
		public var m_properties : Object;
	
		protected var m_hasDefaultValues : Boolean;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSDeclaration()
		{
			if (!CSSDeclaration.g_defaultPropertiesRegistered)
			{
				CSSDeclaration.g_defaultPropertiesRegistered = 
					CSSDeclaration.registerDefaultProperties();
			}		
			
			m_properties = {};
		}
		
		public static function CSSDeclarationFromObject(obj:Object) : CSSDeclaration
		{
			var decl : CSSDeclaration = new CSSDeclaration();		
			for (var key:String in obj)
			{
				decl.setStyle(key, obj[key]);
			}		
			return decl;
		}
		
		public static function CSSDeclarationFromObjectDefinedInFile(
			obj:Object, file:String) : CSSDeclaration
		{
			var decl : CSSDeclaration = new CSSDeclaration();		
			for (var key:String in obj)
			{
				decl.setValueForKeyDefinedInFile(obj[key], key, file);
			}		
			return decl;		
		}	
	
		public static function registerPropertyCollection(cPropCol : Object /*CSSPropertyParser*/) : void
		{
			var i : Number = cPropCol.KNOWN_PROPERTIES.length;
			var prop : String;
			var defaultValues : Object;
			var key : String;
			
			while (i--)
			{
				prop = String(cPropCol.KNOWN_PROPERTIES[i]);
				m_propertyToParserTable[prop] = cPropCol;
				if (cPropCol.INHERITABLE_PROPERTIES && 
					cPropCol.INHERITABLE_PROPERTIES[prop])
					m_inheritableProperties[prop] = true;
			}
			
			defaultValues = cPropCol.defaultValues;
			if (defaultValues)
			{
				for (key in defaultValues)
					m_defaultValues[key] = defaultValues[key];
			}
		}
		
		// Alias for setPropertyForKey
		public function setStyle(key : String, value : String) : void
		{
			setValueForKeyDefinedInFile(value, key, null);
		}
		// Alias for getPropertyForKey
		public function getStyle(key : String) : CSSProperty
		{
			return m_properties[key];
		}
		public function hasStyle(key : String) : Boolean
		{
			return m_properties[key] != null;
		}
		
		public function setPropertyForKey(prop : CSSProperty, key : String) : void
		{
			m_properties[key] = prop;
		}
		
		public function properties() : Object
		{
			return m_properties;
		}
		
		public function getValueForKey(key : String) : CSSProperty
		{
			return m_properties[key];
		}
	
		// the cssdeclaration defined by argument will by default overwrite our properties
		public function mergeCSSDeclaration(
			otherDeclaration: CSSDeclaration, inheritableStylesOnly:Boolean = false) : void
		{
			var props : Object = otherDeclaration.m_properties;
			var key : String;
			var otherProp : CSSProperty;
			var ourProp : CSSProperty;
			
			for (key in props)
			{
				otherProp = props[key];
				
				// the other side has no property defined for the given key,
				// so we keep our own
				if (!otherProp)
					continue;
				
				ourProp = m_properties[key];
				
				// well, inheritable styles only is the deal
				if (inheritableStylesOnly == true && !m_inheritableProperties[key] && 
					!(ourProp && ourProp.inheritsValue()))
					continue;
				
				// we have no property defined for the given key,
				// so we use the other ones'
				if (!ourProp)
				{
					m_properties[key] = otherProp;
					continue;
				}
							
				// now we have two properties. so here goes the real merging
				if (ourProp.important() && !otherProp.important())// || 
	//				(!ourProp.inheritsValue() && inheritableStylesOnly))
					continue;
				
				m_properties[key] = otherProp;
			}
		}
		
		public function inheritCSSDeclaration(
			parentDeclaration:CSSDeclaration) : void
		{
			mergeCSSDeclaration(parentDeclaration, true);
		}
		
		public function addDefaultValues() : void
		{
			// init default values
			var key : String;
			var prop : CSSProperty;
			
			for (key in m_defaultValues)
			{
				if (m_properties[key])
				{
					continue;
				}
				m_properties[key] = CSSProperty(m_defaultValues[key]);		
			}
		}
		
		public function compare(otherDeclaration:CSSDeclaration) : Boolean
		{
			if (!otherDeclaration)
			{
				return false;
			}
			var ownProperties:Object = m_properties;
			var otherProperties:Object = otherDeclaration.m_properties;
			var key : String;
			for (key in ownProperties)
			{
				if (ownProperties[key] != otherProperties[key])
				{
					return false;
				}
			}
			//we have to compare in both direction as for .. in doesn't allow us 
			//to know if the other object has more properties
			for (key in otherProperties)
			{
				if (ownProperties[key] != otherProperties[key])
				{
					return false;
				}
			}
			return true;
		}
		
		public function clone() : CSSDeclaration
		{
			var decl : CSSDeclaration = new CSSDeclaration();
			
			for (var key:String in m_properties)
			{
				decl.m_properties[key] = m_properties[key];
			}
				
			return decl;
		}
		
		public function toObject() : Object
		{
			var obj : Object = {};
			
			for (var key:String in m_properties)
			{
				var value:Object = CSSProperty(m_properties[key]).valueOf();
				obj[key] = value;
			}
			
			return obj;
		}
		
		public function toTextFormatObject() : Object
		{
			var tfObject:Object = toObject();
			if (tfObject.color != null)
			{
				var colorStr:String = tfObject.color.rgb().toString(16);
				while(colorStr.length < 6)
				{
					colorStr = '0' + colorStr;
				}
				tfObject.color = '#' + colorStr;
			}
			return tfObject;
		}
		
		public function toString() : String
		{
			var str:String = "CSSDeclaration\n{\n";
			for (var key:String in m_properties)
			{
				str += "\t" + key + " : " + 
					CSSProperty(m_properties[key]).specifiedValue() + "\n";
			}
				
			return str + '}';
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		// internal handling of getting and setting properties
		protected function setValueForKeyDefinedInFile(val:String, key:String, file:String) : void
		{
			var res : Object;
	//		if (!file)
	//		{
				res = CSSPropertyCache.propertyForKeyValue(key, val+(file || ""));
	//		}
			if (!res)
			{
				var parser : Object = parserForProperty(key);
				var setFunc : String;
				
				
				if (parser == null)
				{
					setFunc = 'parseAnything';
					parser = DefaultParser;
				}
				else
				 	setFunc = "parse" + StringUtil.ucFirst(key);
				
				res = parser[setFunc](val, file);
				CSSPropertyCache.setPropertyForKeyValue(key, val+(file || ""), res);
			}
			
			if (res is CSSProperty)
				m_properties[key] = res;
			else if (res is CSSParsingResult)
			{
				var props : Object = res.properties();
				for (key in props)
					m_properties[key] = props[key];
			}
			else
			{
				var msg : String = 'c Parser for key "' + key + '" returned ';
				msg += res == null ? 'null. Perhaps you didn\'t define the ' +
				'parser method as static? Or you probably gave the parser method ' +
				'a wrong name. Or you even forgot to implement it. Double-check ' +
				'and retry!' : 'value of wrong type.';
				msg += 'Parsing property via DefaultParser (probably as String).';
				
				res = DefaultParser.parseAnything(val, file);
				m_properties[key] = res;
				
				trace(msg);
			}
		}	
		
		protected function parserForProperty(key : String) : Class
		{
			// get the name of the associated class
			var klass : Class = CSSDeclaration.m_propertyToParserTable[key];
			if (!klass)
			{
				if (!m_thrownErrors[key])
				{
					trace('n No parser registered for css property "' + key + '". Parsing property via DefaultParser (probably as string).');
					m_thrownErrors[key] = true;
				}
				return null;
			}		
			return klass;
		}
		
		protected static function registerDefaultProperties() : Boolean
		{
			CSSDeclaration.registerPropertyCollection(Background);
			CSSDeclaration.registerPropertyCollection(Border);
			CSSDeclaration.registerPropertyCollection(DisplayPosition);
			CSSDeclaration.registerPropertyCollection(Font);
			CSSDeclaration.registerPropertyCollection(Margin);
			CSSDeclaration.registerPropertyCollection(Padding);
			CSSDeclaration.registerPropertyCollection(ScrollbarProperties);
			CSSDeclaration.registerPropertyCollection(Filters);
			return true;
		}	
	}
}