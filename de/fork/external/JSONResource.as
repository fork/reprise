package de.fork.external
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