package de.fork.events { 
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	/**
	 * @author Till Schneidereit
	 */
	public class EventBroadcaster extends EventDispatcher
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected static var g_instance : EventBroadcaster;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function instance() : EventBroadcaster
		{
			if ( g_instance == null )
			{
				g_instance = new EventBroadcaster();
			}
			return g_instance;
		}
		
		public function broadcastEvent(event:Event) : void
		{		
			dispatchEvent(event);
		} 
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		public function EventBroadcaster()
		{
		}
	}
}