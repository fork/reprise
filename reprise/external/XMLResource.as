package de.fork.external
{ 
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
			var xml:XML = new XML(m_data.split("\r\n").join("\n"));
			return xml;
		}
	}
}