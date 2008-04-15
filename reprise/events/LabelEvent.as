package de.fork.events
{
	import flash.events.Event;
	 
	/**
	 * @author Till
	 */
	public class LabelEvent extends Event
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const LINK_CLICK : String = "linkClick";
		
		public var url : String;
		public var linkTarget : String;
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function LabelEvent(type:String, target:Object)
		{
			super(type, target);
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		
	}
}