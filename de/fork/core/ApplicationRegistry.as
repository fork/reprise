package de.fork.core
{ 
	public class ApplicationRegistry
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_instance : ApplicationRegistry;
		protected var m_applications : Array;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function instance() : ApplicationRegistry
		{
			if (!g_instance)
			{
				g_instance = new ApplicationRegistry();
			}
			return g_instance;
		}
		
		public function registerApplication(app:Application) : void
		{
			m_applications[app.applicationURL()] = app;
		}
		
		public function applicationForURL(appURL:String) : Application
		{
			return Application(m_applications[appURL]);
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function ApplicationRegistry() 
		{
			m_applications = [];
		}	
	}
}