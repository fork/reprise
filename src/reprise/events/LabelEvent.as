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