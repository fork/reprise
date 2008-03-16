package de.fork.ui
{ 
	import de.fork.core.UIRendererFactory;
	import de.fork.core.ccInternal;
	import de.fork.css.CSS;
	import de.fork.css.CSSDeclaration;
	import de.fork.css.CSSProperty;
	import de.fork.data.collection.HashMap;
	import de.fork.i18n.II18NService;
	import de.fork.services.tracking.ITrackingService;
	
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	use namespace ccInternal;
	public class DocumentView extends UIComponent
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "html";
		
		public var stageDimensionsChanged : Boolean;
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_styleSheet : CSS;
		protected var m_rendererFactory : UIRendererFactory;
	
		protected var m_elementsById : HashMap;
		protected var m_elementsByTagName : HashMap;
		
		protected var m_i18nService : II18NService;
		protected var m_trackingService : ITrackingService;
		
		protected var m_invalidChildren : Array;
		
		protected var m_widthIsRelative : Boolean;
		protected var m_heightIsRelative : Boolean;
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function DocumentView()
		{
			m_elementType = className;
			m_rendererFactory = new UIRendererFactory();
			m_elementsById = new HashMap();
		}
		
		public override function setParent(parent:UIObject) : UIObject
		{
			super.setParent(parent);
			m_rootElement = this;
			m_containingBlock = this;
			return this;
		}
		
		public function setI18NService(i18nService : II18NService) : void
		{
			m_i18nService = i18nService;
		}
		
		public function setTrackingService(
			trackingService : ITrackingService) : void
		{
			m_trackingService = trackingService;
		}
		
		/**
		 * sets the UIRendererFactory to use for this UIComponent structure.
		 */
		public function setUIRendererFactory(
			rendererFactory:UIRendererFactory) : UIComponent
		{
			m_rendererFactory = rendererFactory;
			return this;
		}
		/**
		 * returns the UIRendererFactory for this UIComponent structure
		 */
		public function uiRendererFactory() : UIRendererFactory
		{
			return m_rendererFactory;
		}
		
		/**
		 * initializes the UIComponent structure from the given xml structure, 
		 * creating child views as needed
		 */
		public function initFromXML(xml : XML) : DocumentView
		{
			parseXMLDefinition(xml);
			return this;
		}
		
		/**
		 * sets the styleSheet to use vor this UIComponent and its' children
		 */
		public function set styleSheet(stylesheet : CSS) : void
		{
			m_styleSheet = stylesheet;
			m_stylesInvalidated = true;
			initialize();
			invalidate();
		}
		/**
		 * returns the views' styleSheet
		 */
		public function get styleSheet() : CSS
		{
			return m_styleSheet;
		}
		
		public function registerElementID(id:String, element:UIComponent) : void
		{
			m_elementsById.setObjectForKey(element, id);
		}
		public function removeElementID(id:String) : void
		{
			m_elementsById.removeObjectForKey(id);
		}
		
		public function getElementById(id:String) : UIComponent
		{
			return UIComponent(m_elementsById.objectForKey(id));
		}
		
		public function getI18N(key : String) : String
		{
			if (!m_i18nService)
			{
				return key;
			}
			var result : String;
			if (m_i18nService.keyExists(key))
			{
				result = m_i18nService.getStringByKey(key);
				if (typeof result == "string")
				{
					result = result.split('\r\n').join('\n').split('\r').join('\n');
				}
			}
			if (result == null)
			{
				return key;
			}
			return result;
		}
		
		public function getI18NFlag(key : String) : Boolean
		{
			if (!m_i18nService)
			{
				return false;
			}
			if (m_i18nService.keyExists(key))
			{
				return m_i18nService.getBoolByKey(key) || false;
			}
			return false;
		}
		
		public function getI18NObject(key : String) : Object
		{
			if (!m_i18nService)
			{
				return null;
			}
			if (m_i18nService.keyExists(key))
			{
				return m_i18nService.getGenericContentByKey(key);
			}
			return null;
		}
		
		public function getTrack(trackingId : String) : void
		{
			m_trackingService.track(trackingId);
		}
		
		public function markChildAsInvalid(child : UIObject) : void
		{
			//TODO: check if child.toString() is ok to use
			m_invalidChildren.push(
				{element : child, path : child.toString()});
			stage.invalidate();
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize () : void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			m_rootElement = this;
			m_containingBlock = this;
			m_invalidChildren = [];
			stage.addEventListener(Event.RESIZE, stage_resize);
			super.initialize();
			stage.addEventListener(Event.RENDER, stage_render);
		}
		
		protected override function initDefaultStyles() : void
		{
			m_elementDefaultStyles.width = "100%";
			m_elementDefaultStyles.height = "100%";
			m_elementDefaultStyles.padding = "0";
			m_elementDefaultStyles.margin = "0";
			m_elementDefaultStyles.position = "absolute";
			m_elementDefaultStyles.fontFamily = "_sans";
			m_elementDefaultStyles.fontSize = "12px";
		}
		protected override function validateElement(
			forceValidation:Boolean = false, validateStyles:Boolean = false) : void
		{
			super.validateElement(forceValidation, validateStyles);
			stageDimensionsChanged = false;
		}
		protected override function resolveRelativeStyles(styles:CSSDeclaration) : void
		{
			var widthStyle : CSSProperty = m_complexStyles.getStyle('width');
			var heightStyle : CSSProperty = m_complexStyles.getStyle('height');
			if (widthStyle.isRelativeValue())
			{
				m_widthIsRelative = true;
				m_width = m_currentStyles.width = 
					Math.round(widthStyle.resolveRelativeValueTo(stage.stageWidth));
			}
			else
			{
				m_widthIsRelative = false;
				m_width = Number(widthStyle.valueOf());
			}
			if (heightStyle.isRelativeValue())
			{
				m_heightIsRelative = true;
				m_height = m_currentStyles.height = 
					Math.round(heightStyle.resolveRelativeValueTo(stage.stageHeight));
			}
			else
			{
				m_heightIsRelative = false;
				m_height = Number(heightStyle.valueOf());
			}
		}
		
		protected override function applyOutOfFlowChildPositions() : void
		{
			super.applyOutOfFlowChildPositions();
			y = m_marginTop;
			x = m_marginLeft;
		}
		
		protected function validateElements() : void
		{
			//TODO: verify this validation scheme
			var t1 : Number = getTimer();
			if (m_invalidChildren.length == 0)
			{
				return;
			}
			var lastValidatedPath : String;
			var sortedElements : Array = m_invalidChildren.sortOn(
				'path', Array.DESCENDING);
			m_invalidChildren = [];
			for(var i : Number = sortedElements.length; i--;)
			{
				var path : String = sortedElements[i].path;
				if (path.indexOf(lastValidatedPath) == 0)
				{
//					trace("d skip validation of: " + path);
					continue;
				}
//				trace("d validate " + path);
				lastValidatedPath = path;
				var element : UIObject = UIObject(sortedElements[i].element);
				element.validation_execute();
			}
			trace("validation took " + (getTimer() - t1) + "ms");
		}
		
		protected function stage_resize(event : Event) : void
		{
			if ((m_widthIsRelative && m_width != stage.stageWidth) || 
				(m_heightIsRelative && m_height != stage.stageHeight))
			{
				stageDimensionsChanged = true;
				m_stylesInvalidated = true;
				invalidate();
			}
		}
		
		protected function stage_render(event : Event) : void
		{
			validateElements();
		}
	}
}