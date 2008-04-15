/**
 * @author till
 */
package de.fork.css.math
{
	public class AbstractCSSCalculation 
	{
		public function resolve(
			reference : Number, context : ICSSCalculationContext = null) : Number
		{
			//TODO: check if returned 0 is the better strategy
			return NaN;
		}
	}
}