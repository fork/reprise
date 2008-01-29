package de.fork.events
{ 
	import de.fork.media.IMediaPlayer;
	import flash.events.Event;
	
	/**
	 * @author till
	 */
	public class MediaEvent extends Event
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var PLAYBACK_START : String = "playbackStart";
		public static var PLAYBACK_FINISH : String = "playbackFinish";
		public static var BUFFERING : String = "buffering";
		public static var VIDEO_INITIALIZE : String = "videoInitialize";
		public static var CUE_POINT : String = "cuePoint";
		
		public var metaData : Object;
		public var cuePoint : Object;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function MediaEvent(type : String, bubbles : Boolean = false)
		{
			super(type, bubbles);
		}
	}
}