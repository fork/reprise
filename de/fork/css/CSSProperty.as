package de.fork.css { 
	// @see http://www.w3.org/TR/REC-CSS2/cascade.html
	public class CSSProperty
	{
		
			
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var UNIT_PIXEL : String = 'px';
		public static var UNIT_EM : String = 'em';
		public static var UNIT_PERCENT : String = '%';
		
		public static var IMPORTANT_FLAG : String = '!important';
		public static var INHERIT_FLAG : String = 'inherit';
		public static var AUTO_FLAG : String = 'auto';
		
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_id : Number = 0;
		
		protected var m_important : Boolean = false;
		protected var m_isRelativeValue : Boolean = false;
		protected var m_inheritsValue : Boolean = false;
	                                    
		protected var m_specifiedValue : Object = null;
		protected var m_computedValue : Object = null;
	//	protected var m_actualValue : Object = null;
		
		protected var m_unit : String = null;
		
		protected var m_cssFile : String;
	
		protected var m_id : Number;
		
		
	
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSProperty()
		{
			m_id = g_id++;
		}
		
			
		public function important() : Boolean
		{
			return m_important;
		}
	
		public function setImportant(val:Boolean) : void
		{
			m_important = val;
		}
		
		public function unit() : String
		{
			return m_unit;
		}
		
		public function setUnit(unitStr:String) : void
		{
			if (unitStr == UNIT_PIXEL)
				m_isRelativeValue = false;
			else if (unitStr == UNIT_EM)
				m_isRelativeValue = true;
			else if (unitStr == UNIT_PERCENT)
				m_isRelativeValue = true;
			
			m_unit = unitStr;
		}
		
		public function isRelativeValue() : Boolean
		{
			return m_isRelativeValue;
		}
		
		public function setIsRelativeValue( bFlag : Boolean ) : void
		{
			m_isRelativeValue = bFlag;
		}
		
		public function setInheritsValue( bFlag : Boolean ) : void
		{
			m_inheritsValue = bFlag;
		}
		
		public function inheritsValue() : Boolean
		{
			return m_inheritsValue;
		}	
		
		public function specifiedValue() : Object
		{
			return m_specifiedValue;
		}
	
		public function setSpecifiedValue(val:Object) : void
		{
			m_specifiedValue = val;
			if (val == 'auto')
			{
				m_computedValue = 0;
			}
		}
		
	//	public function computedValue() : Object
	//	{
	//		return m_computedValue;
	//	}
	//
	//	public function setComputedValue( val : Object ) : void
	//	{
	//		m_computedValue = val;
	//	}
	//	
	//	public function actualValue() : Object
	//	{
	//		return m_actualValue;
	//	}
	//
	//	public function setActualValue( val : Object ) : void
	//	{
	//		m_actualValue = val;
	//	}
		
		public function setCSSFile(cssFile : String) : void
		{
			m_cssFile = cssFile;
		}
		
		public function cssFile() : String
		{
			return m_cssFile;
		}
		
		public function toString() : String
		{
			var str:String = "property {\n";
			str += "\tspecified Value : " + m_specifiedValue + "\n";
			str += "\tcomputed Value : " + m_computedValue + "\n";
	//		str += "\tactual Value : " + m_actualValue + "\n";
			str += "\tunit : " + m_unit + "\n";
			str += "\timportant : " + m_important + "\n";
			return str;
		}	
		
		public function valueOf() : Object
		{
	//		if (m_actualValue != null)
	//		{
	//			return m_actualValue;
	//		}
			if (m_computedValue != null)
			{
				return m_computedValue;
			}
			return m_specifiedValue;
		}	
		
		public function clone() : CSSProperty
		{
			var prop : CSSProperty = new CSSProperty();
			prop.m_important = m_important;
			prop.m_unit = m_unit;
			prop.m_specifiedValue = m_specifiedValue;
			prop.m_inheritsValue = m_inheritsValue;
	//		prop.m_actualValue = m_actualValue;
			prop.m_isRelativeValue = m_isRelativeValue;
			prop.m_computedValue = m_computedValue;
			prop.m_cssFile = m_cssFile;
			return prop;
		}
	}
	
}