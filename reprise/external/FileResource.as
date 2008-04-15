package de.fork.external 
{	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class FileResource extends AbstractResource
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		protected var m_loader : URLLoader;
		protected var m_data : String;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function FileResource(url:String = null)
		{
			super(url);
		}
		
		public function data() : String
		{
			return m_data;
		}
		
		public override function content() : *
		{
			return m_loader.data;
		}
		
		public override function getBytesLoaded() : Number
		{
			return m_loader.bytesLoaded;
		}
		
		public override function getBytesTotal() : Number
		{
			return m_loader.bytesTotal;
		}
		
		
		
		/***************************************************************************
		*							protected methods							   *
		***************************************************************************/
		protected override function doLoad() : void
		{
			m_loader = new URLLoader();
			m_loader.addEventListener(
				HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			m_loader.addEventListener(Event.COMPLETE, loader_complete);
			m_loader.load(new URLRequest(urlByAppendingTimestamp()));
			//TODO: add error handling
		}
		
		protected override function doCancel() : void
		{
			m_loader.removeEventListener(
				HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			m_loader.removeEventListener(Event.COMPLETE, loader_complete);
			m_loader.load(null);
			m_loader = null;
		}	
		
		// LoadVars event	
		protected function loader_complete(event : Event) : void
		{
			m_data = m_loader.data;
			onData(true);
		}
	}
}