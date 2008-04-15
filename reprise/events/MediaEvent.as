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
		public static const PLAYBACK_START : String = "playbackStart";
		public static const PLAYBACK_PAUSE : String = "playbackPause";
		public static const PLAYBACK_FINISH : String = "playbackFinish";
		public static const BUFFERING : String = "buffering";
		public static const VIDEO_INITIALIZE : String = "videoInitialize";
		public static const CUE_POINT : String = "cuePoint";
		
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