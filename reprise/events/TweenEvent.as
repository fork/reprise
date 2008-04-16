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
	import flash.events.Event;
	 
	public class TweenEvent extends Event
	{
		public static const START : String = 'start';
		public static const TICK : String = 'tick';
		
		public var success : Boolean;	
		
	
		public function TweenEvent(type : String, didSucceed:Boolean)
		{
			super(type);
			success = didSucceed;
		}	
	}
}