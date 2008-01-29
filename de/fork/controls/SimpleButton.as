package de.fork.controls { 
	/**
	 * @author Till Schneidereit
	 */
	import flash.display.MovieClip;
	import flash.events.Event;
	public class SimpleButton extends AbstractButton
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "SimpleButton";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function SimpleButton ()
		{
			m_elementType = className;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function createButtonDisplay() : void
		{
			m_buttonDisplay = this;
		}
	}
}