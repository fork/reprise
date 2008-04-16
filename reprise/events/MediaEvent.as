////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.events
{ 
	import reprise.media.IMediaPlayer;
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