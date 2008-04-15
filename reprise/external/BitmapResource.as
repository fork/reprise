package reprise.external { 
	import reprise.commands.TimeCommandExecutor;
	
	import flash.display.BitmapData;
	
	
	public class BitmapResource extends AbstractResource
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_cacheBitmap : Boolean;
		protected var m_cloneBitmap : Boolean;
		protected var m_bytesLoaded : Number;
		protected var m_bytesTotal : Number;
		protected var m_applicationURL : String;
		protected var m_data : BitmapData;
		
		protected var m_containingImageResource : ImageResource;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function BitmapResource(url:String = null, 
			cacheBitmap:Boolean = true, cloneBitmap:Boolean = true)
		{
			m_url = url;
		}
		
		public override function execute(...rest) : void
		{
			if (m_applicationURL == null)
			{
				throw new Error('You didn\'t specify an ApplicationURL ' + 
					'for your BitmapResource! (' + m_url + ')');
			}
			super.execute();
			// we rely on the events dispatched by ImageResource
			TimeCommandExecutor.instance().removeCommand(m_controlDelegate);
		}
		
		public function setApplicationURL(appURL:String) : void
		{
			m_applicationURL = appURL;
		}
		
		public function applicationURL() : String
		{
			return m_applicationURL;
		}
		
		public override function getBytesLoaded() : Number
		{
			return m_bytesLoaded;
		}
		
		public override function getBytesTotal() : Number
		{
			return m_bytesTotal;
		}	
		
		public override function content() : *
		{
			return m_data;
		}	
		
		public function setCacheBitmap(bFlag:Boolean) : void
		{
			m_cacheBitmap = bFlag;
		}
		
		public function cacheBitmap() : Boolean
		{
			return m_cacheBitmap;
		}
		
		public function setCloneBitmap(bFlag:Boolean) : void
		{
			m_cloneBitmap = bFlag;
		}
		
		public function cloneBitmap() : Boolean
		{
			return m_cloneBitmap;
		}
		
		
		
		/**
		* Do not call these directly
		* following methods are meant to be used by BitmapResourceCache only
		**/
		public function setContent(bitmap:BitmapData, httpStatus:HTTPStatus = null) : void
		{
			m_data = bitmap;
			m_httpStatus = httpStatus;
			onData(bitmap != null);
		}
		
		public function setBytesLoaded(bytesLoaded:Number) : void
		{
			m_bytesLoaded = bytesLoaded;
		}
		
		public function setBytesTotal(bytesTotal:Number) : void
		{
			m_bytesTotal = bytesTotal;
		}
		
		public function updateProgress() : void
		{
			checkProgress();		
		}
		
		/**
		 * Used to propagate priority changes from a BitmapResource to the 
		 * ImageResource that does the actual loading.
		 * 
		 * TODO: find a better way to do this.
		 */
		public function setContainingImageResource(
			imageResource : ImageResource) : void
		{
			m_containingImageResource = imageResource;
		}
		
		public override function setPriority(value : Number) : void
		{
			super.setPriority(value);
			m_containingImageResource.setPriority(value);
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function doLoad() : void
		{
			var cache : BitmapResourceCache = BitmapResourceCache.instance();
			cache.loadBitmapResource(this);
		}
		protected override function doCancel() : void
		{
			// BitmapResourceCacheItem takes care of cancelling
		}
	}
}