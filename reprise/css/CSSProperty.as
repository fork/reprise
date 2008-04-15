package de.fork.css
{
	import de.fork.css.math.AbstractCSSCalculation;
	import de.fork.css.math.CSSCalculationGroup;
	import de.fork.css.math.CSSCalculationPercentage;
	import de.fork.css.math.ICSSCalculationContext;
	 
	// @see http://www.w3.org/TR/REC-CSS2/cascade.html
	public class CSSProperty
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const UNIT_PIXEL : String = 'px';
		public static const UNIT_EM : String = 'em';
		public static const UNIT_PERCENT : String = '%';
		
		public static const IMPORTANT_FLAG : String = '!important';
		public static const INHERIT_FLAG : String = 'inherit';
		public static const AUTO_FLAG : String = 'auto';
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_id : Number = 0;
		
		protected var m_important : Boolean = false;
		protected var m_isRelativeValue : Boolean = false;
		protected var m_inheritsValue : Boolean = false;
	                                    
		protected var m_specifiedValue : Object = null;
		protected var m_computedValue : Object = null;
		
		protected var m_isCalculation : Boolean;
		protected var m_calculation : AbstractCSSCalculation;
		protected var m_calculationResultsCache : Object;
		
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
			{
				m_isRelativeValue = false;
			}
			else if (unitStr == UNIT_EM || unitStr == UNIT_PERCENT)
			{
				setIsRelativeValue(true);
			}
			
			m_unit = unitStr;
		}
		
		public function isRelativeValue() : Boolean
		{
			return m_isRelativeValue;
		}
		
		public function setIsRelativeValue( bFlag : Boolean ) : void
		{
			m_isRelativeValue = bFlag;
			m_calculationResultsCache = {};
			if (m_specifiedValue)
			{
				setSpecifiedValue(m_specifiedValue);
			}
		}
		
		public function isCalculation() : Boolean
		{
			return m_isCalculation;
		}
	
		public function setIsCalculation(value : Boolean) : void
		{
			m_isCalculation = value;
			if (value)
			{
				m_calculationResultsCache = {};
				m_isRelativeValue = true;
				if (m_specifiedValue)
				{
					preprocessCalculation(m_specifiedValue);
				}
			}
		}
		
		public function setInheritsValue( bFlag : Boolean ) : void
		{
			m_inheritsValue = bFlag;
		}
		
		public function inheritsValue() : Boolean
		{
			return m_inheritsValue;
		}
		
		public function isAuto() : Boolean
		{
			return m_specifiedValue == 'auto';
		}
		
		public function specifiedValue() : Object
		{
			return m_specifiedValue;
		}
	
		public function setSpecifiedValue(value : Object) : void
		{
			m_specifiedValue = value;
			if (value == 'auto')
			{
				m_computedValue = 0;
			}
			else if (m_isRelativeValue)
			{
				if (m_isCalculation)
				{
					preprocessCalculation(value);
				}
				else
				{
					m_calculation = new CSSCalculationPercentage(value.toString());
				}
			}
		}
		
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
			str += "\tunit : " + m_unit + "\n";
			str += "\timportant : " + m_important + "\n";
			return str;
		}	
		
		public function valueOf() : Object
		{
			if (m_computedValue != null)
			{
				return m_computedValue;
			}
			return m_specifiedValue;
		}
		
		public function resolveRelativeValueTo(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			if (m_calculationResultsCache[reference])
			{
				return m_calculationResultsCache[reference];
			}
			return m_calculationResultsCache[reference] = 
				resolveCalculation(reference, context);
		}
		
		public function clone() : CSSProperty
		{
			var prop : CSSProperty = new CSSProperty();
			prop.m_important = m_important;
			prop.m_unit = m_unit;
			prop.m_specifiedValue = m_specifiedValue;
			prop.m_inheritsValue = m_inheritsValue;
			prop.m_isRelativeValue = m_isRelativeValue;
			prop.m_computedValue = m_computedValue;
			prop.m_cssFile = m_cssFile;
			return prop;
		}
	
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function preprocessCalculation(val : Object) : void
		{
			var expression : String = val.substring(5, val.length - 1);
			m_calculation = CSSCalculationGroup.
				PrepareCalculation(String(expression));
		}
		
		protected function resolveCalculation(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			return m_calculation.resolve(reference, context);
		}
	}
	
}