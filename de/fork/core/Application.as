package de.fork.core
{ 
	import de.fork.events.DisplayEvent;
	import de.fork.ui.DocumentView;
	import de.fork.ui.UIObject;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.utils.Timer;
	public class Application extends Sprite
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_baseView : DocumentView;
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
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function Application()
		{
			ApplicationRegistry.instance().registerApplication(this);
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
			m_baseView = new DocumentView();
			addChild(m_baseView);
			m_baseView.setParent(m_baseView);
		}
		
		/**
		 * creates a new UIComponent, replacing the current one, by calling the static 
		 * <code>create</code> method on the given class
		 * The class <b>has</b> to extend {@link de.fork.ui.UIComponent.UIComponent} and 
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
			m_currentView = m_baseView.addChildView(viewClass);
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