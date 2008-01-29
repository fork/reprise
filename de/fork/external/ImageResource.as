package de.fork.external { 
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	public class ImageResource extends AbstractResource
	{
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_loader : Loader;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ImageResource(url:String = null)
		{
			super(url);
		}
		
		public override function content() : *
		{
			return m_loader.content;
		}		
		
		public function bitmap(backgroundColor:Number = NaN) : BitmapData
		{
			var transparent : Boolean = false;
			if (isNaN(backgroundColor))
			{
				transparent = true;
				backgroundColor = 0;
			}
			var bmp : BitmapData = new BitmapData(m_loader.width, m_loader.height, 
				transparent, backgroundColor);
			bmp.draw(m_loader);
			return bmp;
		}
		
		public override function getBytesLoaded() : Number
		{
			return m_loader.loaderInfo.bytesLoaded;
		}
		
		public override function getBytesTotal() : Number
		{
			return m_loader.loaderInfo.bytesTotal;
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/	
		protected override function doLoad() : void
		{
			m_loader = new Loader();
			m_loader.addEventListener(Event.COMPLETE, loader_complete);
			m_loader.addEventListener(Event.COMPLETE, loader_complete);
			m_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
			m_loader.addEventListener(Event.INIT, loader_init);
			m_loader.addEventListener(IOErrorEvent.IO_ERROR, loader_error);
			m_loader.load(m_request);
			
			//TODO: find a way to support attaching assets here
//			if (m_url.indexOf('attach://') == 0)
//			{
//				var symbolId : String = m_url.split('//')[1];
//				m_container = m_container.attachMovie(
//					symbolId, symbolId, m_container.getNextHighestDepth());
//				m_httpStatus = new HTTPStatus(200, m_url);
//				onData(true);
//				return;			
//			}
		}
		
		protected override function doCancel() : void
		{
			m_loader.unload();
		}
		
		//Loader events
		protected function loader_complete(event : Event) : void
		{
			m_httpStatus = new HTTPStatus(200, m_url);
		}
		
		protected function loader_init(event : Event) : void
		{
			onData(true);
		}
		
		protected function loader_error(event : IOErrorEvent) : void
		{
			//TODO: find a way to support timeouts
//			else if (errorCode == 'LoadNeverCompleted')
//			{
//				notifyComplete(false, ResourceEvent.ERROR_TIMEOUT);
//				return;
//			}
			
			onData(false);
		}
	}
}