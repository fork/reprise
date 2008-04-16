////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2007 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.external
{ 
	import com.cinqetdemi.JSON;
	
	public class JSONResource extends FileResource
	{
		public function JSONResource(url:String)
		{
			super(url);
		}
		
		public override function content() : *
		{
			return JSON.parse(m_data);
		}
	}
}