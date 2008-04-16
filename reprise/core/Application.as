////////////////////////////////////////////////////////////////////////////////
//
//  Fork unstable media GmbH
//  Copyright 2006-2008 Fork unstable media GmbH
//  All Rights Reserved.
//
//  NOTICE: Fork unstable media permits you to use, modify, and distribute this
//  file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package reprise.core
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.Timer;
	
	import reprise.css.CSS;
	import reprise.events.DisplayEvent;
	import reprise.external.IResource;
	import reprise.external.ResourceLoader;
	import reprise.ui.DocumentView;
	import reprise.ui.UIObject;
	public class Application extends Sprite
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static const CSS_URL : String = 'style/main.css';
		
		protected var m_rootElement : DocumentView;
		protected var m_currentView : UIObject;
		protected var m_lastView : UIObject;
		protected var m_stageCheckTimer : Timer;
		
		protected var m_resourceLoader : ResourceLoader;
		protected var m_css : CSS;
		
		
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
			initResourceLoading();
		}
		
		protected function initResourceLoading() : void
		{
			m_resourceLoader = new ResourceLoader();
			m_resourceLoader.addEventListener(Event.COMPLETE, resource_complete);
			loadDefaultResources();
			loadResources();
			m_resourceLoader.execute();
		}
		protected function loadDefaultResources() : void
		{
			var cssURL : String = stage.loaderInfo.parameters.css_url || 
				(hasOwnProperty('cssURL') && this['cssURL'] !== undefined) || 
				'flash/style.css';
			if (cssURL)
			{
				m_css = addResource(new CSS(cssURL)) as CSS;
			}
		}
		protected function loadResources() : void
		{
		}
		
		protected function addResource(resource : IResource) : IResource
		{
			m_resourceLoader.addResource(resource);
			return resource;
		}
		protected function resource_complete(event : Event) : void
		{
			m_resourceLoader.removeEventListener(Event.COMPLETE, resource_complete);
			initApplication();
		}
		
		protected function initApplication() : void
		{
			createRootElement();
			m_rootElement.styleSheet = m_css;
			startApplication();
		}
		protected function createRootElement() : void
		{
			m_rootElement = new DocumentView();
			addChild(m_rootElement);
			m_rootElement.setParent(m_rootElement);
		}
		
		protected function startApplication() : void
		{
		}
		
		/**
		 * creates a new UIComponent, replacing the current one.
		 * The class <strong>has</strong> to extend {@link reprise.ui.UIComponent}.
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