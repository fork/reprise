package reprise.css
{ 
	public class CSSSegment
	{	
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_content : String;
		protected var m_URL : String;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSSegment() {}
		
		
		public function content() : String
		{
			return m_content;
		}
	
		public function setContent(val:String) : void
		{
			m_content = val;
		}
		
		public function url() : String
		{
			return m_URL;
		}
	
		public function setURL(val:String) : void
		{
			m_URL = val;
		}
		
		
		public function toString() : String
		{
			return '[CSSSegment] url: ' + m_URL + '\ncontent:\n' + m_content;
		}
	}
}