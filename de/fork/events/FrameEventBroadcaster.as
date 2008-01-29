package de.fork.events
{
	import de.fork.core.GlobalMCManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class FrameEventBroadcaster extends DisplayObject
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_instance : FrameEventBroadcaster;
		protected var m_dispatcherMC : Sprite;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function instance() : FrameEventBroadcaster
		{
			if (!g_instance)
			{
				g_instance = new FrameEventBroadcaster();
			}
			return g_instance;
		}
		
		public function FrameEventBroadcaster()
		{
			//TODO: check if we need this at all
			m_dispatcherMC = GlobalMCManager.instance().addLowLevelMc();
			m_dispatcherMC.addChild(this);
		}
	}
}