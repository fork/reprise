package de.fork.events
{ 
	import de.fork.media.IMediaPlayer;
	import flash.events.Event;
	
	/**
	 * @author till
	 */
	public class MediaPlayerDisplayEvent extends Event
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const PLAY_CLICK : String = "playClickEvent";
		public static const PAUSE_CLICK : String = "pauseClickEvent";
		public static const STOP_CLICK : String = "stopClickEvent";
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function MediaPlayerDisplayEvent(type : String, bubbles : Boolean = false)
		{
			super(type, bubbles);
		}
	}
}