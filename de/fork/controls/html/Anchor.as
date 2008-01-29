package de.fork.controls.html { 
	import de.fork.controls.AbstractButton;
	import de.fork.utils.GfxUtil;
	import de.fork.events.HTMLEvent;
	
	
	public class Anchor extends AbstractButton
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "a";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_elementType : String = className;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Anchor() {}	
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function createButtonDisplay() : void {}
	
		
		protected function buttonDisplay_click() : void
		{
			var event : HTMLEvent = new HTMLEvent(HTMLEvent.ANCHOR_CLICK, this);
			dispatchEvent(event);
		}
	}
}