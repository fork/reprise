package de.fork.external
{ 
	import flash.net.URLLoader;
	import flash.xml.XMLDocument;
	public class XMLResource extends FileResource
	{
		/***************************************************************************
		*							protected properties						   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function XMLResource(url:String) 
		{
			super(url);
		}
		
		public override function content() : *
		{
			var xml:XMLDocument = new XMLDocument();
			xml.ignoreWhite = true;
			xml.parseXML(m_data.split("\r\n").join("\n"));
			return xml;
		}
	}
}