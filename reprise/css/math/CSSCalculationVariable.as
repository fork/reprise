/**
 * @author till
 */
package de.fork.css.math
{
	public class CSSCalculationVariable 
		extends AbstractCSSCalculation 
	{
		/***************************************************************************
		*							private properties							   *
		***************************************************************************/
		private var m_selector : String;
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSCalculationVariable(selector : String)
		{
			m_selector = selector.substr(1, -2);
		}
		
		public override function resolve(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			return context.valueBySelector(m_selector);
		}
		
		public function toString() : String
		{
			return "CSSCalculationVariable, selector: " + m_selector;
		}
	}
}