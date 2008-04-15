package reprise.css
{ 
	import reprise.external.FileResource;
	
	public class CSSImport extends FileResource
	{
		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		protected	var m_owner : CSS;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CSSImport(owner:CSS, url:String = null)
		{
			m_owner = owner;
			setURL(url);
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function notifyComplete(success:Boolean) : void
		{
			if (success)
			{
				m_owner.resolveImport(this);
			}
			super.notifyComplete(success);
		}	
	}
}