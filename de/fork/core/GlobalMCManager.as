package de.fork.core
{ 
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public class GlobalMCManager
	{
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_lowLevelContainerDepth:Number = -17000;
		protected static var g_highLevelContainerDepth:Number = 10000;
		protected static var g_lowLevelContainerName:String = 'LOW_LEVEL_CONTAINER';
		protected static var g_highLevelContainerName:String = 'HIGH_LEVEL_CONTAINER';
		
		protected static var g_instance:GlobalMCManager;
		protected var m_lowLevelContainer:DisplayObjectContainer;
		protected var m_highLevelContainer:DisplayObjectContainer;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function instance(stage : DisplayObjectContainer = null) : GlobalMCManager
		{
			if (!g_instance)
			{
				g_instance = new GlobalMCManager(stage);
			}
			return g_instance;
		}
		
		public function addHighLevelMc(name:String = null) : Sprite
		{
			var clip : Sprite = new Sprite();
			if (name)
			{
				clip.name = name;
			}
			m_highLevelContainer.addChild(clip);
			return clip;
		}
		
		public function addLowLevelMc(name : String = null) : Sprite
		{
			var clip : Sprite = new Sprite();
			if (name)
			{
				clip.name = name;
			}
			m_lowLevelContainer.addChild(clip);
			return clip;
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function GlobalMCManager(stage : DisplayObjectContainer)
		{
			createLowLevelContainer(stage);
			createHighLevelContainer(stage);
		}
		
		protected function createLowLevelContainer(stage : DisplayObjectContainer) : void
		{
			m_lowLevelContainer = new DisplayObjectContainer();
			stage.addChildAt(m_lowLevelContainer, g_lowLevelContainerDepth);
		}
		
		protected function createHighLevelContainer(stage : DisplayObjectContainer) : void
		{
			m_highLevelContainer = new DisplayObjectContainer();
			stage.addChildAt(m_highLevelContainer, g_highLevelContainerDepth);
		}
	}
}