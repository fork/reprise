package de.fork.services.tracking { 
	/**
	 * @author Till Schneidereit
	 * 
	 * Code only implementation of the counterpixel system.
	 * 
	 * Usage:
	 * To be compatible with the old counterpixel component, the class uses
	 * _root.tld or _level0.tld to configure its domain. It's possible to
	 * override the result of this automatic configuration using 
	 * {@link CounterPixel#setDomain}
	 * 
	 * Additionally, you can use {@link CounterPixel#setBasePath} to define a path
	 * segment that gets prepended to each CounterPixel string.
	 * Example: If all your CounterPixels start with 
	 * "specials/nbc_superspecial/" you could use
	 * CounterPixel.getInstance().setBasePath("specials/nbc_superspecial/").
	 * 
	 * If you want to use CounterPixels for another brand than nivea, use
	 * {@link CounterPixel#setBrandName} to set the brand
	 * 
	 * If you enable debugging with {@link CounterPixel#setDebug}, the 
	 * CounterPixels are traced as well.
	 */
	import flash.system.System;
	public class CounterPixel implements ITrackingService
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var COUNTER_SCRIPT_PATH : String = "/cgi-bin/PageImp.exe?";
		
		protected static var g_instance : CounterPixel;
		
		protected var m_brand : String = "nivea";
		protected var m_domain : String;
		protected var m_debug : Boolean = false;
	
		protected var m_basePath : String = "";
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		/**
		 * @return singleton instance of CounterPixelWrapper
		 */
		public static function getInstance() : CounterPixel
		{
			if (!g_instance)
			{
				g_instance = new CounterPixel();
			}
			return g_instance;
		}
		
		public function track (trackingId : String) : void
		{
			callPixel(trackingId);
		}
		
		/**
		 * calls a counterpixel with the given name
		 */
		public function callPixel(pixel:String) : void
		{
			pixel = m_basePath + pixel;
			pixel = removeSlash(pixel);
			pixel = removeSpaces(pixel);
			pixel = parseVars(pixel);
			
			if(!pixel.length)
			{
				return;
			}
			
			var firstPart:String = String(pixel.split( "/" )[0]).toLowerCase();
			if(firstPart == m_brand.toLowerCase())
			{
				trace("\n******************************************************************************************************\nWARNING!\nThis Counterpixel semms to be wrong. Please make sure that \"Brand\" is not a part of \"Pixel\"!\n******************************************************************************************************\n:" + pixel);
			}
			
			var pixel1:String = "http://" + getHost(0) + COUNTER_SCRIPT_PATH + "/" + m_brand + "/" + m_domain + "/" + pixel;
			var pixel2:String = "http://" + getHost(1) + COUNTER_SCRIPT_PATH + "/" + m_brand + "/" + m_domain + "/" + pixel;
	
			if(_root._url.substr(0,7).toLowerCase() != "file://")
			{
				var loadVars1:LoadVars = new LoadVars();
				loadVars1.sendAndLoad(pixel1, loadVars1);
				var loadVars2:LoadVars = new LoadVars();
				loadVars2.sendAndLoad(pixel2, loadVars2);
			}
			
			if(m_debug)
			{
				trace("COUNTERPIXEL 1: " + pixel1);
				trace("COUNTERPIXEL 2: " + pixel2);
			}
		}
		
		/**
		 * starts and stops debugging of the counterpixels
		 */
		public function setDebug(debug:Boolean) : void
		{
			m_debug = debug;
		}
		/**
		 * starts and stops debugging of the counterpixels
		 */
		public function getDebug() : Boolean
		{
			return m_debug;
		}
		
		/**
		 * sets the brandname to use for the counterpixels
		 */
		public function setBrandName(brandName:String) : void
		{
			m_brand = brandName;
		}
		/**
		 * @return the brandname used for the counterpixels
		 */
		public function getBrandName() : String
		{
			return m_brand;
		}
		
		/**
		 * sets the domain to use for the counterpixels
		 */
		public function setDomain(domain:String) : void
		{
			m_domain = domain;
		}
		/**
		 * @return the domain used for the counterpixels
		 */
		public function getDomain() : String
		{
			return m_domain;
		}
		
		/**
		* setter for the basePath property
		*/
		public function setBasePath (value:String) : void
		{
			m_basePath = value;
		}
		/**
		* getter for the basePath property
		*/
		public function getBasePath() : String
		{
			return m_basePath;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function CounterPixel()
		{
			init();
		}
	    protected function init() : void
	    {
			System.security.allowDomain(getHost(0));
			System.security.allowDomain(getHost(1));
			
			m_domain = _root.tld;
			
			if((m_domain == undefined) || (m_domain == ""))
			{
				m_domain = _level0.tld;
				if((m_domain == undefined) || (m_domain == ""))
				{
					m_domain = "com";
				}
			}
		}
		
		
		protected function parseVars(s:String) : String
		{
			var tmp:String	= s;
			while( (tmp.indexOf('<') != -1) && (tmp.indexOf('>') != -1) )
			{
				var begin:Number = tmp.lastIndexOf( '<' );
				var end:Number = tmp.lastIndexOf( '>' );
				var varname:String = tmp.substr( begin + 1, end - begin - 1 );
				var x:String = _root[varname];
				if( x == undefined )
				{
					x	= "";
				}
				tmp = tmp.split("<" + varname + ">").join(x);
			}
			return tmp;
		}
		protected function removeSlash(s:String) : String
		{
			while( s.charAt(0) == "/" )
			{
				s = s.substr(1);
			}
			return s;
		}
		
		protected function removeSpaces(s:String) : String
		{
			while(s.charAt(0) == " ")
			{
				s = s.substr(1);
			}
			
			while(s.substr(s.length - 1) == " ")
			{
				s	= s.substr(0, s.length - 1);
			}
			return s;
		}
		protected function getHost(pixelNumber: Number) : String
		{
			var host:String = _root._HTTP_HOST.toLowerCase();
			if(_root._HTTP_HOST == undefined)
			{
				host	= "www.nivea.com";
			}
			
			var len:Number = host.length;
			if(host.substr(len - 4, 4) == ".biz")
			{
				host = host.substr(0, len - 4) + ".com";
			}
			
			if(host.indexOf(".") != -1)
			{
				var pixelStr:String = "counterpixel";
				if( pixelNumber > 0 )
				{
					pixelStr += pixelNumber.toString();
				}
				host = pixelStr + host.substr(host.indexOf("."), len);
			}
			
			return host;
		}
	}
}