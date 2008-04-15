package reprise.core
{ 
	import reprise.events.DisplayEvent;
	import reprise.ui.DocumentView;
	import reprise.ui.UIObject;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.Timer;
	public class Application extends Sprite
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_rootElement : DocumentView;
		protected var m_currentView : UIObject;
		protected var m_lastView : UIObject;
		protected var m_stageCheckTimer : Timer;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function applicationURL() : String
		{
			return loaderInfo.url;
		}
		
		public function rootElement() : DocumentView
		{
			return m_rootElement;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function Application()
		{
			ApplicationRegistry.instance().registerApplication(this);
			if (stage)
			{
				initialize();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, self_addedToStage, false, 0, true);
			}
		}
		protected function self_addedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, self_addedToStage);
			initialize();
		}
		
		protected function initialize() : void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			GlobalMCManager.instance(this);
			createBaseView();
		}
		protected function createBaseView() : void
		{
			m_rootElement = new DocumentView();
			addChild(m_rootElement);
			m_rootElement.setParent(m_rootElement);
		}
		
		/**
		 * creates a new UIComponent, replacing the current one, by calling the static 
		 * <code>create</code> method on the given class
		 * The class <b>has</b> to extend {@link reprise.ui.UIComponent.UIComponent} and 
		 * implement a static create method returning an instance of the class.
		 * (Unfortunately, there's no way to enforce any of this in AS.)
		 */
		protected function showView(viewClass:Class, delayShow:Boolean) : UIObject
		{
			if (m_currentView)
			{
				m_lastView = m_currentView;
				m_currentView = null;
				m_lastView.addEventListener(DisplayEvent.HIDE_COMPLETE, 
				 lastView_hide);
				m_lastView.hide();
			}
			m_currentView = m_rootElement.addChildView(viewClass);
			if (!m_lastView && !delayShow)
			{
				m_currentView.show();
			}
			else {
				m_currentView.setVisibility(false);
			}
			return m_currentView;
		}
	
		protected function lastView_hide() : void
		{
			m_lastView.remove();
			m_lastView = null;
			if (m_currentView)
			{
				m_currentView.show();
			}
		}
	}
}