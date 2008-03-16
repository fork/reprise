/**
 * @author till
 */
package de.fork.css.math
{
	public class CSSCalculationRelativeValue 
		extends AbstractCSSCalculation 
	{
		/***************************************************************************
		*							private properties							   *
		***************************************************************************/
		private var m_value : Number;
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSCalculationRelativeValue(valueString : String)
		{
			//TODO: check if we have to use parseFloat or parseInt
			m_value = parseFloat(valueString) / 100;
		}
		
		public override function resolve(reference : Number) : Number
		{
			return reference * m_value;
		}
		
		public function toString() : String
		{
			return "relative value: " + (m_value * 100) + "%";
		}
	}
}