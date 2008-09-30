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

package reprise.ui
{
	import reprise.controls.Scrollbar;
	import reprise.core.UIRendererFactory;
	import reprise.core.reprise;
	import reprise.css.CSSDeclaration;
	import reprise.css.CSSParsingHelper;
	import reprise.css.CSSProperty;
	import reprise.css.ComputedStyles;
	import reprise.css.math.ICSSCalculationContext;
	import reprise.css.propertyparsers.Filters;
	import reprise.css.transitions.CSSTransitionsManager;
	import reprise.ui.layoutmanagers.CSSBoxModelLayoutManager;
	import reprise.ui.renderers.ICSSRenderer;
	import reprise.utils.GfxUtil;
	import reprise.utils.StringUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	use namespace reprise;

	public class UIComponent extends UIObject implements ICSSCalculationContext
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static const WIDTH_RELATIVE_PROPERTIES : Array = 
		[
			['marginTop', false],
			['marginBottom', false],
			['marginLeft', false],
			['marginRight', false],
			['paddingTop', false],
			['paddingBottom', false],
			['paddingLeft', false],
			['paddingRight', false],
			['left', true],
			['right', true]
		];
		protected static const EDGE_NAMES : Array = 
		[
			'Top',
			'Right',
			'Bottom',
			'Left'
		];
		protected static const HEIGHT_RELATIVE_PROPERTIES : Array = 
		[
			['top', true],
			['bottom', true],
			['height', true]
		];
		protected static const OWN_WIDTH_RELATIVE_PROPERTIES:Array = 
		[
			['borderTopLeftRadius', false],
			['borderTopRightRadius', false],
			['borderBottomLeftRadius', false],
			['borderBottomRightRadius', false]
		];
		
		protected static const DEFAULT_SCROLLBAR_WIDTH : int = 16;
		
		
		//attribute properties
		protected var m_xmlDefinition : XML;
		protected var m_nodeAttributes : Object;
		protected var m_cssClasses : String = "";
		protected var m_cssId : String = "";
		protected var m_selectorPath : String;
		
		//style properties
		protected var m_currentStyles : ComputedStyles;
		protected var m_complexStyles : CSSDeclaration;
		protected var m_instanceStyles : CSSDeclaration;
		protected var m_elementDefaultStyles : CSSDeclaration;
		
		protected var m_autoFlags : Object = {};
		protected var m_positionInFlow : int = 1;
		protected var m_positioningType : String;
		
		//validation properties
		protected var m_stylesInvalidated : Boolean;
		protected var m_dimensionsChanged : Boolean;
		protected var m_specifiedDimensionsChanged : Boolean;
		protected var m_selectorPathChanged : Boolean;
		
		//dimensions and position
		protected var m_contentBoxWidth : Number = 0;
		protected var m_contentBoxHeight : Number = 0;
		protected var m_borderBoxHeight : Number = 0;
		protected var m_borderBoxWidth : Number = 0;
		protected var m_paddingBoxHeight : Number = 0;
		protected var m_paddingBoxWidth : Number = 0;
		
		protected var m_intrinsicWidth : Number = -1;
		protected var m_intrinsicHeight : Number = -1;
		
		protected var m_positionOffset : Point;
		
		//managers and renderers
		protected var m_layoutManager : CSSBoxModelLayoutManager;
		protected var m_borderRenderer : ICSSRenderer;
		protected var m_backgroundRenderer : ICSSRenderer;
		
		//displays
		protected var m_containingBlock : UIComponent;
		
		protected var m_upperContentDisplay : Sprite;
		protected var m_lowerContentDisplay : Sprite;
		protected var m_backgroundDisplay : Sprite;
		protected var m_bordersDisplay : Sprite;
		protected var m_upperContentMask : Sprite;
		protected var m_lowerContentMask : Sprite;
		
		protected var m_vScrollbar : Scrollbar;
		protected var m_hScrollbar : Scrollbar;
		
		protected var m_dropShadowFilter : DropShadowFilter;
		
		
		/***************************************************************************
		*							private properties							   *
		***************************************************************************/
		private var m_explicitContainingBlock : UIComponent;
		private var m_cssPseudoClasses : String = "";
		private var m_pseudoClassesBackup : String;
		private var m_specifiedStyles : CSSDeclaration;
		private var m_transitionsManager : CSSTransitionsManager;
		private var m_skipNextValidation : Boolean;
		private var m_scrollbarsDisplay : Sprite;
		private var m_oldInFlowStatus : int = -1;
		private var m_oldOuterBoxDimension : Point;

		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/ 
		public function UIComponent()
		{
		}
		
		/**
		 * Convenience method that eases the process to add a child element.
		 * 
		 * @param classes The css classes the component should have.
		 * @param id The css id the component should have.
		 * @param componentClass The ActionScript class to instantiate. If this is 
		 * omitted, an instance of UIComponent will be created.
		 * @param index The index at which the element should be added. If this is 
		 * omitted, the element will be created at the next available index.
		 */
		public function addComponent(classes : String = null, id : String = null, 
			componentClass : Class = null, index : int = -1) : UIComponent
		{
			if (!componentClass)
			{
				componentClass = UIComponent;
			}
			var component : UIComponent;
			if (index == -1)
			{
				component = UIComponent(addChild(new componentClass()));
			}
			else
			{
				component = UIComponent(addChildAt(new componentClass(), index));
			}
			if (id)
			{
				component.cssId = id;
			}
			if (classes)
			{
				component.cssClasses = classes;
			}
			return component;
		}
		
		/**
		 * initializes the UIComponent structure from the given xml structure, 
		 * creating child views as needed
		 * TODO: check if this method should call parseXMLDefinition to fully initialize 
		 * using the xml data (including attributes)
		 */
		public function setInnerXML(xml:XML) : UIComponent
		{
			m_xmlDefinition.setChildren(xml.children());
			parseXMLContent(xml);
			return this;
		}
		
		/**
		 * initializes the UIComponent structure from the given xml structure, 
		 * creating child views as needed
		 */
		public function overrideContainingBlock(
			containingBlock : UIComponent) : void
		{
			m_explicitContainingBlock = containingBlock;
		}
		
		public function get containingBlock() : UIComponent
		{
			return m_containingBlock;
		}

		
		public override function set width(value : Number) : void
		{
			setStyle('width', value + "px");
		}
		public override function get width() : Number
		{
			return m_contentBoxWidth;
		}
		
		public function get outerWidth() : Number
		{
			return m_borderBoxWidth;
		}
		
		public function get intrinsicWidth() : Number
		{
			return m_intrinsicWidth;
		}
		
		public override function set height(value:Number) : void
		{
			setStyle('height', value + "px");
		}
		public override function get height() : Number
		{
			return m_contentBoxHeight;
		}
		
		public function get outerHeight() : Number
		{
			return m_borderBoxHeight;
		}
		
		public function get intrinsicHeight() : Number
		{
			return m_intrinsicHeight;
		}
		
		public override function get top() : Number
		{
			if (!isNaN(m_currentStyles.top))
			{
				return m_currentStyles.top;
			}
			if (!isNaN(m_currentStyles.bottom))
			{
				return m_containingBlock.calculateContentHeight() - 
					m_currentStyles.bottom - m_borderBoxHeight;
			}
			return 0;
		}
		public override function set top(value:Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.top = value;
			m_instanceStyles.setStyle('top', value + "px");
			m_autoFlags.top = false;
			if (!m_positionInFlow)
			{
				var absolutePosition:Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.y -= y;
				y = value + m_currentStyles.marginTop - absolutePosition.y;
			}
		}
		public override function get left() : Number
		{
			if (!isNaN(m_currentStyles.left))
			{
				return m_currentStyles.left;
			}
			if (!isNaN(m_currentStyles.right))
			{
				return m_containingBlock.calculateContentWidth() - 
					m_currentStyles.right - m_borderBoxWidth;
			}
			return 0;
		}
		public override function set left(value:Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.left = value;
			m_instanceStyles.setStyle('left', value + "px");
			m_autoFlags.left = false;
			if (!m_positionInFlow)
			{
				var absolutePosition:Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.x -= x;
				x = value + m_currentStyles.marginLeft - absolutePosition.x;
			}
		}
		
		public override function get right() : Number
		{
			if (!isNaN(m_currentStyles.left))
			{
				return m_currentStyles.left + m_borderBoxWidth;
			}
			if (!isNaN(m_currentStyles.right))
			{
				return m_currentStyles.right;
			}
			return 0 + m_borderBoxWidth;
		}
		public function set right(value:Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.right = value;
			m_instanceStyles.setStyle('right', value + "px");
			m_autoFlags.right = false;
			if (!m_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.x -= x;
				x = m_containingBlock.calculateContentWidth() - m_borderBoxWidth - 
					m_currentStyles.right - m_currentStyles.marginRight - absolutePosition.x;
			}
		}
		
		public override function get bottom() : Number
		{
			if (!isNaN(m_currentStyles.top))
			{
				return m_currentStyles.top + m_borderBoxHeight;
			}
			if (!isNaN(m_currentStyles.bottom))
			{
				return m_currentStyles.bottom;
			}
			return 0 + m_borderBoxHeight;
		}
		public function set bottom(value:Number) : void
		{
			if (isNaN(value))
			{
				value = 0;
			}
			m_currentStyles.bottom = value;
			m_instanceStyles.setStyle('bottom', value + "px");
			m_autoFlags.bottom = false;
			if (!m_positionInFlow)
			{
				var absolutePosition : Point = 
					getPositionRelativeToContext(m_containingBlock);
				absolutePosition.y -= y;
				y = m_containingBlock.calculateContentHeight() - m_borderBoxHeight - 
					m_currentStyles.bottom - m_currentStyles.marginBottom - absolutePosition.y;
			}
		}
		
		//TODO: check if these should be removed in favor of styles.margin*
		public function get marginTop() : Number
		{
			return m_currentStyles.marginTop;
		}
		public function get marginRight() : Number
		{
			return m_currentStyles.marginRight;
		}
		public function get marginBottom() : Number
		{
			return m_currentStyles.marginBottom;
		}
		public function get marginLeft() : Number
		{
			return m_currentStyles.marginLeft;
		}
		
		public function get attributes() : Object
		{
			return m_nodeAttributes;
		}
		
		/**
		 * returns a Rectangle object that contains the current position and 
		 * dimensions of the UIComponent relative to its parentElement
		 */
		public function actualBox() : Rectangle
		{
			return new Rectangle(
				x, y, m_borderBoxWidth, m_borderBoxHeight);
		}
		
		public function get contentBoxWidth() : Number
		{
			return m_contentBoxWidth;
		}
		public function get contentBoxHeight() : Number
		{
			return m_contentBoxHeight;
		}
		public function get paddingBoxWidth() : Number
		{
			return m_paddingBoxWidth;
		}
		public function get paddingBoxHeight() : Number
		{
			return m_paddingBoxHeight;
		}
		public function get borderBoxWidth() : Number
		{
			return m_borderBoxWidth;
		}
		public function get borderBoxHeight() : Number
		{
			return m_borderBoxHeight;
		}

		/**
		 * Returns the width that is available to child elements.
		 */
		public function innerWidth() : Number
		{
			if (m_vScrollbar && m_vScrollbar.getVisibility())
			{
				return m_currentStyles.width - m_vScrollbar.outerWidth;
			}
			return m_currentStyles.width;
		}
		
		/**
		 * Returns the height that is available to child elements.
		 */
		public function innerHeight() : Number
		{
			if (m_hScrollbar && m_hScrollbar.getVisibility())
			{
				return m_currentStyles.height - m_hScrollbar.outerWidth;
			}
			return m_currentStyles.height;
		}
		
		public function get style() : ComputedStyles
		{
			return m_currentStyles;
		}
		public function get autoFlags() : Object
		{
			return m_autoFlags;
		}
		public function get positionInFlow() : int
		{
			return m_positionInFlow;
		}

		/**
		 * sets the CSS id and invalidates styling
		 */
		public function set cssId(id:String) : void
		{
			if (m_cssId)
			{
				m_rootElement.removeElementID(m_cssId);
			}
			m_rootElement.registerElementID(id, this);
			m_cssId = id;
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * returns the CSS id of this element
		 */
		public function get cssId() : String
		{
			return m_cssId;
		}
		/**
		 * sets the CSS classes and invalidates styling
		 */
		public function set cssClasses(classes:String) : void
		{
			m_cssClasses = classes;
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * returns the CSS classes of this element
		 */
		public function get cssClasses() : String
		{
			return m_cssClasses;
		}
		/**
		 * sets the CSS pseudo classes and invalidates styling
		 */
		public function set cssPseudoClasses(classes:String) : void
		{
			m_cssPseudoClasses = classes;
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * returns the CSS pseudo classes of this element
		 */
		public function get cssPseudoClasses() : String
		{
			return m_cssPseudoClasses;
		}
		
		public function hasClass(className : String) : Boolean
		{
			return StringUtil.delimitedStringContainsSubstring(
				m_cssClasses, className, ' ');
		}
		
		public function setStyle(name : String, value : String = null) : void
		{
			m_instanceStyles.setStyle(name, value);
			invalidate();
			m_stylesInvalidated = true;
		}
		
		public override function tooltipDelay() : Number
		{
			return m_currentStyles.tooltipDelay || 0;
		}
		public override function setTooltipDelay(delay : Number) : void
		{
			// we don't need no invalidation
			m_instanceStyles.setStyle('tooltipDelay', delay.toString());
			m_currentStyles.tooltipDelay = delay;
		}
		public override function tooltipRenderer() : String
		{
			return m_tooltipRenderer;
		}
		public override function setTooltipRenderer(renderer : String) : void
		{
			// we don't need no invalidation
			m_instanceStyles.setStyle('tooltipRenderer', renderer);
			m_currentStyles.tooltipRenderer = renderer;
		}
		
		public override function setFocus(value : Boolean, method : String) : void
		{
			if (value)
			{
				addPseudoClass('focus');
			}
			else
			{
				removePseudoClass('focus');
			}
		}
		
		/**
		 * replaces all CSS pseudo classes with the :error class, but saves the 
		 * other classes for a switch back later on.
		 */
		public function setErrorMark() : void
		{
			if (m_pseudoClassesBackup == null)
			{
				m_pseudoClassesBackup = m_cssPseudoClasses;
				cssPseudoClasses = " :error";
			}
		}
		/**
		 * removes the CSS error marking and reactivates the old pseudo classes.
		 */
		public function removeErrorMark() : void
		{
			if (m_pseudoClassesBackup != null)
			{
				cssPseudoClasses = m_pseudoClassesBackup;
				m_pseudoClassesBackup = null;
			}
		}
		/**
		 * adds a pseudo class if it's not already in the list of pseudo classes.
		 */
		public function addPseudoClass(name:String) : void
		{
			if (m_pseudoClassesBackup)
			{
				if (StringUtil.delimitedStringContainsSubstring(
					m_pseudoClassesBackup, ':' + name, ' '))
				{
					return;
				}
				m_pseudoClassesBackup += " :" + name;
				if (m_pseudoClassesBackup.charAt(0) == ' ')
				{
					m_pseudoClassesBackup = m_pseudoClassesBackup.substr(1);
				}
			}
			else
			{
				if (StringUtil.delimitedStringContainsSubstring(
					m_cssPseudoClasses, ':' + name, ' '))
				{
					return;
				}
				m_cssPseudoClasses += " :" + name;
				if (m_cssPseudoClasses.charAt(0) == ' ')
				{
					m_cssPseudoClasses = m_cssPseudoClasses.substr(1);
				}
			}
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * removes a pseudo class from the list.
		 */
		public function removePseudoClass(name:String) : void
		{
			if (m_pseudoClassesBackup)
			{
				if (!StringUtil.delimitedStringContainsSubstring(
					m_pseudoClassesBackup, ':' + name, ' '))
				{
					return;
				}
				m_pseudoClassesBackup = 
					StringUtil.removeSubstringFromDelimitedString(
					m_pseudoClassesBackup, ':' + name, ' ');
			}
			else
			{
				if (!StringUtil.delimitedStringContainsSubstring(
					m_cssPseudoClasses, ':' + name, ' '))
				{
					return;
				}
				m_cssPseudoClasses = StringUtil.removeSubstringFromDelimitedString(
					m_cssPseudoClasses, ':' + name, ' ');
			}
			m_stylesInvalidated = true;
			invalidate();
		}
		
		/**
		 * adds a CSS class if it's not already in the list of CSS classes.
		 */
		public function addCSSClass(name : String) : void
		{
			if (StringUtil.delimitedStringContainsSubstring(
				m_cssClasses, name, ' '))
			{
				return;
			}
			m_cssClasses += ' ' + name;
			if (m_cssClasses.charAt(0) == ' ')
			{
				m_cssClasses = m_cssClasses.substr(1);
			}
			m_stylesInvalidated = true;
			invalidate();
		}
		/**
		 * removes a CSS class from the list.
		 */
		public function removeCSSClass(name : String) : void
		{
			if (!StringUtil.delimitedStringContainsSubstring(
				m_cssClasses, name, ' '))
			{
				return;
			}
			m_cssClasses = StringUtil.
				removeSubstringFromDelimitedString(m_cssClasses, name, ' ');
			m_stylesInvalidated = true;
			invalidate();
		}
		
		/**
		 * sets the views visibility without executing any transitions that might 
		 * be defined in the views' <code>hide</code> and <code>show</code> methods
		 */
		public override function setVisibility(visible : Boolean) : void
		{
			var visibilityProperty:String = (visible ? 'visible' : 'hidden');
			m_instanceStyles.setStyle('visibility', visibilityProperty);
			m_currentStyles.visibility = visibilityProperty;
			super.setVisibility(visible);
		}
		
		public function isDisplayed() : Boolean
		{
			return !(m_currentStyles.display && m_currentStyles.display == 'none');
		}
		
		/**
		* setter for the alpha property
		*/
		public override function set alpha(value:Number) : void
		{
			opacity = value;
		}
		/**
		* getter for the alpha property
		*/
		public override function get alpha() : Number
		{
			return opacity;
		}
		/**
		* setter for the opacity property
		*/
		public function set opacity(value:Number) : void
		{
			super.alpha = value;
			m_currentStyles.opacity = value;
			m_instanceStyles.setStyle('opacity', value.toString());
		}
		/**
		* getter for the opacity property
		*/
		public function get opacity() : Number
		{
			if (m_currentStyles.opacity != null)
			{
				return m_currentStyles.opacity;
			}
			return 1;
		}
	
		/**
		* setter for the rotation property
		*/
		public override function set rotation(value : Number) : void
		{
			super.rotation = value;
			m_currentStyles.rotation = value;
			m_instanceStyles.setStyle('rotation', value.toString());
		}
		/**
		* getter for the rotation property
		*/
		public override function get rotation() : Number
		{
			return m_currentStyles.rotation || 0;
		}
		
		/**
		 * removes the UIComponent from its' parents' display list
		 */
		public override function remove(...args) : void
		{
			if (m_cssId)
			{
				m_rootElement.removeElementID(m_cssId);
			}
			super.remove();
		}
		
		
		public function getElementsByClassName(className:String) : Array
		{
			var elements:Array = [];
			
			var len : int = m_children.length;
			for (var i : int = 0; i < len; i++)
			{
				var child : DisplayObject = m_children[i];
				if (!(child is UIComponent))
				{
					continue;
				}
				var childView : UIComponent = child as UIComponent;
				if (childView.hasClass(className))
				{
					elements.push(childView);
				}
				var subElements : Array = childView.getElementsByClassName(className);
				if (subElements.length)
				{
					elements = elements.concat(subElements);
				}
			}		
			return elements;		
		}
		
		public function getElementsBySelector(selector : String) : Array
		{
			var matches : Array = [];
			var selectorParts : Array;
			var element : UIComponent;
			var candidates : Array = [];
			//find last ID in the selector and discard everything before that
			var lastIDIndex : int = selector.lastIndexOf('#');
			if (lastIDIndex != -1)
			{
				//find element for ID and make it the root candidate
				selector = selector.substr(lastIDIndex + 1);
				selectorParts = selector.split(' ');
				var id : String = selectorParts.shift();
				//discard every other information in the ID selector
				id = ((id.split('.')[0] as String).split('[')[0] as String).split(':')[0];
				element = m_rootElement.getElementById(id);
				if (!element)
				{
					//if there's no element for the ID, there's nothing to return
					return matches;
				}
				candidates.push(element);
			}
			else
			{
				//no ID found, make current element the root candidate
				candidates.push(this);
				selectorParts = selector.split(' ');
			}
			
			while (candidates.length && selectorParts.length)
			{
				var index : int;
				var currentSelectorPart : String = selectorParts.shift();
				//extract index suffix from path
				var fragments : Array = currentSelectorPart.split('[');
				var currentPath : String = fragments[0];
				if (fragments[1])
				{
					index = parseInt(fragments[1]);
				}
				
				var oldCandidates : Array = candidates;
				candidates = [];
				var children : Array;
				
				//split into tag and classes
				var classes : Array = currentPath.split('.');
				var className : String;
				var tag : String = classes.shift();
				//find first
				if (tag.length)
				{
					while (oldCandidates.length)
					{
						element = oldCandidates.shift();
						children = element.getElementsByTagName(tag);
						if (children.length)
						{
							candidates = candidates.concat(children);
						}
					}
				}
				else
				{
					className = classes.shift();
					while (oldCandidates.length)
					{
						element = oldCandidates.shift();
						children = element.getElementsByClassName(className);
						if (children.length)
						{
							candidates = candidates.concat(children);
						}
					}
				}
				
			}
			
			matches = candidates;
			return matches;
		}
		public function getElementBySelector(selector : String) : UIComponent
		{
			return getElementsBySelector(selector)[0];
		}
		
		public function get selectorPath() : String
		{
			return m_selectorPath;
		}
		
		public function get cssTag() : String
		{
			return m_elementType;
		}
		
		public function valueBySelectorProperty(
			selector : String, property : String, ...rest : Array) : *
		{
			var target : UIComponent;
			
			//If there's no selector, this element is the target
			if (!selector)
			{
				target = this;
			}
			else
			{
				target = getElementBySelector(selector);
			}
			
			var targetProperty : *;
			try
			{
				targetProperty = target[property];
			}
			catch (error : Error)
			{
				if (target.m_currentStyles[property])
				{
					return target.m_currentStyles[property];
				}
				throw error;
			}
			if (targetProperty is Function)
			{
				targetProperty = (targetProperty as Function).apply(target, rest);
			}
			
			return targetProperty;
		}
		
		public function setAttributeId(value : String) : void
		{
			cssId = value;
		}
		public function setAttributeClass(value : String) : void
		{
			cssClasses = value;
		}
		public function setAttributeStyle(value : String) : void
		{
			m_instanceStyles = 
				CSSParsingHelper.parseDeclarationString(value, applicationURL());
		}
		public function setAttributeTooltip(value : String) : void
		{
			setTooltipData(value);
		}
		public function setAttributeTitle(value : String) : void
		{
			if (!m_tooltipData)
			{
				setTooltipData(value);
			}
		}
		
		/**
		 * Returns true if this element has any currently running CSS transitions
		 */
		public function hasActiveTransitions() : Boolean
		{
			return m_transitionsManager.isActive();
		}
		
		/**
		 * Returns true if this element has a currently running CSS transition for the 
		 * given style
		 */
		public function hasActiveTransitionForStyle(style : String) : Boolean
		{
			return m_transitionsManager.hasActiveTransitionForStyle(style);
		}

		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize() : void
		{
			if (!m_class.basicStyles)
			{
				m_class.basicStyles = new CSSDeclaration();
				m_class.basicStyles.addDefaultValues();
				m_elementDefaultStyles = m_class.basicStyles;
				initDefaultStyles();
			}
			else
			{
				m_elementDefaultStyles = m_class.basicStyles;
			}
			m_instanceStyles = new CSSDeclaration();
			m_transitionsManager = new CSSTransitionsManager(this);
			m_layoutManager = new CSSBoxModelLayoutManager();
			m_currentStyles = new ComputedStyles();
			m_stylesInvalidated = true;
			super.initialize();
		}
		
		/**
		 * creates all clips needed to display the UIObjects' content
		 */
		protected override function createDisplayClips() : void
		{
			super.createDisplayClips();
			
			// create container for elements with z-index < 0
			m_lowerContentDisplay = new Sprite();
			m_contentDisplay.addChild(m_lowerContentDisplay);
			m_lowerContentDisplay.name = 'lower_content_display';
			
			// create container for elements with z-index >= 0
			m_upperContentDisplay = new Sprite();
			m_contentDisplay.addChild(m_upperContentDisplay);
			m_upperContentDisplay.name = 'upper_content_display';
		}
		
		/**
		 * Resets the elements styles.
		 * 
		 * Mostly used in debugging to enable style reloading.
		 */
		protected function resetStyles() : void
		{
			m_complexStyles = null;
			m_specifiedStyles = null;
			for each (var child : UIComponent in m_children)
			{
				child.resetStyles();
			}
			m_stylesInvalidated = true;
			invalidate();
		}
		
		/**
		 * Executes element validation, refreshing and applying all style properties and 
		 * redrawing the element.
		 * 
		 * Components shouldn't need to override this method, since it only starts the 
		 * validation cycle and doesn't really implement functionality that's worth 
		 * overriding.
		 */
		protected override function validateElement(
			forceValidation:Boolean = false, validateStyles:Boolean = false) : void
		{
			m_rootElement.increaseValidatedElementsCount();
			if (m_skipNextValidation)
			{
				m_skipNextValidation = false;
				return;
			}
			if (validateStyles)
			{
				m_stylesInvalidated = true;
			}
			super.validateElement(forceValidation);
		}
		
		/**
		 * Hook method, executed before the UIComponents' children get validated.
		 * 
		 * Stores values for some settings for later comparison and executes style 
		 * validation. If that results in changed settings, it applies those.
		 */
		protected override function validateBeforeChildren() : void
		{
			m_oldOuterBoxDimension = new Point(
				m_borderBoxWidth + m_currentStyles.marginLeft + m_currentStyles.marginRight, 
				m_borderBoxHeight + m_currentStyles.marginTop + m_currentStyles.marginBottom);
			m_oldInFlowStatus = m_positionInFlow;
			
			var oldWidth : Number = m_currentStyles.width;
			var oldHeight : Number = m_currentStyles.height;
			
			if (!m_stylesInvalidated && m_transitionsManager.isActive())
			{
				m_stylesInvalidated = true;
			}
			if (m_stylesInvalidated)
			{
				calculateStyles();
				
				if (!isDisplayed())
				{
					visible = false;
					return;
				}
				
				if (m_stylesInvalidated)
				{
					visible = m_visible;
					
					if (m_currentStyles.overflowY == 'scroll')
					{
						if (!m_vScrollbar)
						{
							m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
						}
						else
						{
							m_vScrollbar.setVisibility(true);
						}
					}
					
					if (m_currentStyles.overflowX == 'scroll')
					{
						if (!m_hScrollbar)
						{
							m_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
						}
						else
						{
							m_hScrollbar.setVisibility(true);
						}
					}
					applyStyles();
					if (m_currentStyles.width != oldWidth || 
						m_currentStyles.height != oldHeight)
					{
						m_specifiedDimensionsChanged = true;
						resolveSpecifiedDimensions();
					}
				}
				else
				{
					m_stylesInvalidated = false;
				}
			}
		}
		/**
		 * Hook method, executed after the UIObjects' children get validated
		 */
		protected override function validateAfterChildren() : void
		{
			if (!isDisplayed())
			{
				return;
			}
			
			applyInFlowChildPositions();
			
			var autoFlag:String = CSSProperty.AUTO_FLAG;
			
			var oldIntrinsicHeight : Number = m_intrinsicHeight;
			var oldIntrinsicWidth : Number = m_intrinsicWidth;
			
			measure();
			
			if (m_autoFlags.width || m_autoFlags.height)
			{
				if (m_autoFlags.width && 
					(m_currentStyles.display == 'inline' ||
					(!m_positionInFlow && (m_autoFlags.left || m_autoFlags.right))))
				{
					m_contentBoxWidth = m_intrinsicWidth;
				}
				if (m_intrinsicHeight != -1 && m_autoFlags.height)
				{
					m_contentBoxHeight = m_intrinsicHeight;
				}
			}
			
			m_paddingBoxHeight = m_contentBoxHeight + 
				m_currentStyles.paddingTop + m_currentStyles.paddingBottom;
			m_borderBoxHeight = m_paddingBoxHeight + 
				m_currentStyles.borderTopWidth + m_currentStyles.borderBottomWidth;
			m_paddingBoxWidth = m_contentBoxWidth + 
				m_currentStyles.paddingLeft + m_currentStyles.paddingRight;
			m_borderBoxWidth = m_paddingBoxWidth + 
				m_currentStyles.borderLeftWidth + m_currentStyles.borderRightWidth;
			
			m_dimensionsChanged = !m_oldOuterBoxDimension.equals(new Point(
				m_borderBoxWidth + 
				m_currentStyles.marginLeft + m_currentStyles.marginRight, 
				m_borderBoxHeight + 
				m_currentStyles.marginTop + m_currentStyles.marginBottom));
			
			var parentReflowNeeded:Boolean = false;
			
			if (m_dimensionsChanged || m_stylesInvalidated)
			{
				applyBackgroundAndBorders();
				applyOverflowProperty();
				if ((m_currentStyles.float || m_positionInFlow) && m_dimensionsChanged)
				{
					parentReflowNeeded = true;
	//				trace("f reason for parentReflow: dims of in-flow changed");
				}
			}
			else if (m_intrinsicHeight != oldIntrinsicHeight || 
				m_intrinsicWidth != oldIntrinsicWidth)
			{
				applyOverflowProperty();
			}
			
			if (!(m_parentElement is UIComponent && m_parentElement != this && 
				UIComponent(m_parentElement).m_isValidating))
			{
				if ((m_oldInFlowStatus == -1 || m_dimensionsChanged) && 
					!m_positionInFlow)
				{
					//The element is positioned absolutely or fixed.
					//check if at least one of the vertical and one of the 
					//horizontal dimensions is specified. If not, we need to 
					//let the parent do the positioning
					if ((m_autoFlags.top && m_autoFlags.bottom) || 
						(m_autoFlags.left && m_autoFlags.right))
					{
						parentReflowNeeded = true;
	//					trace("f reason for reflow: All positions in " +
	//						"absolute positioned element are auto");
					}
				}
				else if (m_oldInFlowStatus != m_positionInFlow)
				{
					parentReflowNeeded = true;
	//				trace("f reason for parentReflow: flowPos changed");
				}
				if (m_parentElement && m_parentElement != this)
				{
					if (parentReflowNeeded)
					{
	//					trace("w parentreflow needed in " + 
	//						m_elementType + "#"+m_cssId + "."+m_cssClasses);
						//TODO: change this use parent.validateAfterChildren
						m_skipNextValidation = true;
						m_parentElement.forceRedraw();
						return;
					}
					else
					{
	//					trace("w no parentreflow needed in " + 
	//						m_elementType + "#"+m_cssId + "."+m_cssClasses);
						UIComponent(m_parentElement).applyOutOfFlowChildPositions();
					}
				}
				else
				{
					applyOutOfFlowChildPositions();
				}
			}
			m_layoutManager.applyDepthSorting(
				m_lowerContentDisplay, m_upperContentDisplay);
		}
		protected override function finishValidation() : void
		{
			super.finishValidation();
			
			m_dimensionsChanged = false;
			m_specifiedDimensionsChanged = false;
			
			m_stylesInvalidated = false;
		}

		protected override function validateChildren() : void
		{
			if (!isDisplayed())
			{
				return;
			}
			super.validateChildren();
		}
		protected override function validateChild(child:UIObject) : void
		{
			if (child is UIComponent)
			{
				UIComponent(child).validateElement(
					true, m_stylesInvalidated || m_selectorPathChanged);
			}
			else
			{
				super.validateChild(child);
			}
		}
		
		protected function initDefaultStyles() : void
		{
		}
		
		protected function refreshSelectorPath() : void
		{
			var oldPath:String = m_selectorPath;
			var path : String;
			if (m_parentElement)
			{
				path = (m_parentElement as UIComponent).selectorPath + " ";
			}
			else 
			{
				path = "";
			}
			path += "@" + m_elementType + "@";
			if (m_cssId)
			{
				path += "@#" + m_cssId + "@";
			}
			if (m_cssClasses)
			{
				path += "@." + m_cssClasses.split(' ').join('@.') + "@";
			}
			if (m_cssPseudoClasses.length)
			{
				path += m_cssPseudoClasses.split(" :").join("@:") + "@";
			}
			if (m_isFirstChild)
			{
				path += "@:first-child@";
			}
			if (m_isLastChild)
			{
				path += "@:last-child@";
			}
			if (path != oldPath)
			{
				m_selectorPath = path;
				m_selectorPathChanged = true;
				return;
			}
			m_selectorPathChanged = false;
		}
	
		/**
		 * parses all styles associated with this element and its classes and creates a 
		 * combined style object.
		 * CalculateStyles also invokes processing of transitions and resolution of 
		 * relative values.
		 */
		protected function calculateStyles() : void
		{
			refreshSelectorPath();
			
			var styles:CSSDeclaration = m_elementDefaultStyles.clone();
			var oldStyles:CSSDeclaration = m_specifiedStyles;
			
			if (m_parentElement != this && m_parentElement is UIComponent)
			{
				styles.inheritCSSDeclaration(
					UIComponent(m_parentElement).m_complexStyles);
			}
			
			if (m_rootElement.styleSheet)
			{
				styles.mergeCSSDeclaration(m_rootElement.styleSheet.
					getStyleForEscapedSelectorPath(m_selectorPath));
			}
			
			styles.mergeCSSDeclaration(m_instanceStyles);
			
			//check if styles or other relevant factors have changed and stop validation 
			//if not.
			if (!(m_containingBlock && m_containingBlock.m_specifiedDimensionsChanged) && 
				styles.compare(oldStyles) && !m_transitionsManager.isActive() && 
				!(this == m_rootElement && DocumentView(this).stageDimensionsChanged))
			{
				m_stylesInvalidated = false;
				return;
			}
			
			m_specifiedStyles = styles;
			styles = m_transitionsManager.processTransitions(oldStyles, styles);
			m_complexStyles = styles;
			m_currentStyles = styles.toComputedStyles();
			
			if (m_transitionsManager.isActive())
			{
				m_stylesInvalidated = true;
				invalidate();
			}
			
			resolvePositioningProperties();
			resolveContainingBlock();
			resolveRelativeStyles(styles);
		}
		
		/**
		 * Applies a wide array of style settings.
		 * When implementing components, this method should be overridden to implement 
		 * additional settings derived from stylesheets.
		 */
		protected function applyStyles() : void
		{	
			m_positionOffset = new Point(0, 0);
			if (m_positioningType == 'relative')
			{
				m_positionOffset.x = m_currentStyles.left;
				m_positionOffset.y = m_currentStyles.top;
			}
			
			
			if (m_currentStyles.tabIndex != null)
			{
				m_tabIndex = m_currentStyles.tabIndex;
			}
			
			m_tooltipRenderer = m_currentStyles.tooltipRenderer;
			m_tooltipDelay = m_currentStyles.tooltipDelay;
			
			m_contentDisplay.blendMode = m_currentStyles.blendMode || 'normal';
			
			if (m_dropShadowFilter != null)
			{
				removeFilter(m_dropShadowFilter);
			}
			if (m_currentStyles.textShadowColor != null)
			{
				m_dropShadowFilter = Filters.dropShadowFilterFromStyleObjectForName(
					m_currentStyles, 'text');
				addFilter(m_dropShadowFilter);
			}
			
			if (m_currentStyles.visibility == 'hidden' && m_visible)
			{
				m_visible = visible = false;
			}
			else if (m_currentStyles.visibility != 'hidden' && !m_visible)
			{
				m_visible = visible = true;
			}
			
			if (m_currentStyles.cursor == 'pointer')
			{
				if (!buttonMode)
				{
					buttonMode = true;
					useHandCursor = true;
				}
			}
			else if (buttonMode)
			{
				buttonMode = false;
				useHandCursor = false;
			}
			
			super.rotation = m_currentStyles.rotation || 0;
			if (m_currentStyles.opacity == null)
			{
				super.alpha = 1;
			}
			else
			{
				super.alpha = m_currentStyles.opacity;
			}
		}
		
		protected function resolvePositioningProperties() : void
		{
			if (!m_currentStyles.float || m_currentStyles.float == 'none')
			{
				m_currentStyles.float = null;
			}
			
			var positioning:String = m_positioningType = 
				m_currentStyles.position || 'static';
			
			if (!m_currentStyles.float && 
				(positioning == 'static' || positioning == 'relative'))
			{
				m_positionInFlow = 1;
			}
			else
			{
				m_positionInFlow = 0;
			}
		}
		
		/**
		 * resolves the element that acts as the containing block for this element.
		 * 
		 * The containing block is defined as follows:
		 * - if an explicit containg block is provided using 
		 * overrideContainingBlock, the override is used
		 * - if the elements' position is 'static' or 'relative', its 
		 * containing block is its parentElement
		 * - if the elements' position is 'absolute', its containing block
		 * is the next ancestor with a position other than 'static'
		 * - if the elements' position is 'static', its containing block
		 * is the viewPort
		 */
		protected function resolveContainingBlock() : void
		{
			 if (m_explicitContainingBlock)
			 {
				m_containingBlock = m_explicitContainingBlock;
			}
			else
			{
				var parentComponent:UIComponent = UIComponent(m_parentElement);
				if (m_positioningType == 'fixed')
				{
					m_containingBlock = m_rootElement;
				}
				else if (m_positioningType == 'absolute')
				{
					var inspectedBlock:UIComponent = parentComponent;
					while (inspectedBlock && 
						inspectedBlock.m_positioningType == 'static')
					{
						inspectedBlock = inspectedBlock.m_containingBlock;
					}
					m_containingBlock = inspectedBlock;
				}
				else
				{
					m_containingBlock = parentComponent;
				}
			}
		}
		
		protected function resolveRelativeStyles(styles:CSSDeclaration, 
			parentW:Number = -1, parentH:Number = -1) : void
		{
			var borderBoxSizing : Boolean = 
				m_currentStyles.boxSizing && m_currentStyles.boxSizing == 'border-box';
			
			if (parentW == -1)
			{
				parentW = m_containingBlock.innerWidth();
			}
			if (parentH == -1)
			{
				parentH = m_containingBlock.innerHeight();
			}
			
			resolvePropsToValue(styles, WIDTH_RELATIVE_PROPERTIES, parentW);
			
			//calculate border widths. width resolution relies on correct border widths, 
			//so we have to do this here.
			for each (var borderName : String in EDGE_NAMES)
			{
				var style : String = 
					m_currentStyles['border' + borderName + 'Style'] || 'none';
				var width : Number;
				if (style == 'none')
				{
					m_currentStyles['border' + borderName + 'Width'] = 0;
				}
				else
				{
					m_currentStyles['border' + borderName + 'Width'] ||= 0;
				}
			}
			
			
			var wProp : CSSProperty = styles.getStyle('width');
			if (wProp.specifiedValue() == 'auto')
			{
				m_autoFlags.width = true;
				if (!m_positionInFlow)
				{
					m_contentBoxWidth = m_currentStyles.width = parentW - 
						m_currentStyles.left - m_currentStyles.right - 
						m_currentStyles.marginLeft - m_currentStyles.marginRight - 
						m_currentStyles.paddingLeft - m_currentStyles.paddingRight - 
						m_currentStyles.borderLeftWidth - m_currentStyles.borderRightWidth;
				}
				else
				{
					m_contentBoxWidth = m_currentStyles.width = parentW - 
						m_currentStyles.marginLeft - m_currentStyles.marginRight - 
						m_currentStyles.paddingLeft - m_currentStyles.paddingRight - 
						m_currentStyles.borderLeftWidth - m_currentStyles.borderRightWidth;
				}
			}
			else
			{
				m_autoFlags.width = false;
				if (wProp.isRelativeValue())
				{
					var relevantWidth : Number = parentW;
					if (m_positioningType == 'absolute')
					{
						relevantWidth += 
							m_containingBlock.m_currentStyles.paddingLeft + 
							m_containingBlock.m_currentStyles.paddingRight;
					}
					m_currentStyles.width = 
						wProp.resolveRelativeValueTo(relevantWidth, this);
				}
				if (borderBoxSizing)
				{
					m_currentStyles.width -= 
						m_currentStyles.borderLeftWidth + m_currentStyles.paddingLeft + 
						m_currentStyles.borderRightWidth + m_currentStyles.paddingRight;
					if (m_currentStyles.width < 0)
					{
						m_currentStyles.width = 0;
					}
				}
				m_contentBoxWidth = m_currentStyles.width || 0;
			}
			
			resolvePropsToValue(styles, HEIGHT_RELATIVE_PROPERTIES, parentH);
			m_contentBoxHeight = m_currentStyles.height;
			
			if (borderBoxSizing && !m_autoFlags.height)
			{
				m_contentBoxHeight -= 
					m_currentStyles.borderTopWidth + m_currentStyles.paddingTop + 
					m_currentStyles.borderBottomWidth + m_currentStyles.paddingBottom;
				if (m_contentBoxHeight < 0)
				{
					m_contentBoxHeight = 0;
				}
				m_currentStyles.height = m_contentBoxHeight;
			}
			//TODO: verify that we should really resolve the border-radii this way
			resolvePropsToValue(styles, OWN_WIDTH_RELATIVE_PROPERTIES, 
				m_contentBoxWidth + m_currentStyles.borderTopWidth);
		}
		
		protected function resolvePropsToValue(styles : CSSDeclaration, 
			props : Array, baseValue : Number) : void
		{
			for (var i : int = props.length; i--;)
			{
				var propName:String = props[i][0];
				var cssProperty:CSSProperty = styles.getStyle(propName);
				if (cssProperty)
				{
					if (cssProperty.isRelativeValue())
					{
						m_currentStyles[propName] = Math.round(
							cssProperty.resolveRelativeValueTo(baseValue, this));
					}
					m_autoFlags[propName] = cssProperty.isAuto();
				}
				else 
				{
					m_autoFlags[propName] = props[i][1];
					m_currentStyles[propName] = 0;
				}
			}
		}
		
		/**
		 * calculates the vertical space taken by this elements' content
		 */
		protected function calculateContentHeight() : Number
		{
			return m_contentBoxHeight;
		}
	
		/**
		 * calculates the horizontal space taken by this elements' content
		 */
		protected function calculateContentWidth() : Number
		{
			return m_contentBoxWidth;
		}
		
		/**
		 * applies position and dimensions based on css definitions and other 
		 * relevant factors.
		 */
		protected function resolveSpecifiedDimensions() : void
		{
			//apply final relative position/paddings/borderWidths to displays
			m_contentDisplay.y = m_positionOffset.y + 
				m_currentStyles.borderTopWidth;
			m_contentDisplay.x = m_positionOffset.x + 
				m_currentStyles.borderLeftWidth;
		}
	
		protected function applyInFlowChildPositions() : void
		{
			m_layoutManager.applyFlowPositions(this, m_children);
			m_intrinsicWidth = m_currentStyles.intrinsicWidth;
			m_intrinsicHeight = m_currentStyles.intrinsicHeight;
		}
		
		protected function applyOutOfFlowChildPositions() : void
		{
			m_layoutManager.applyAbsolutePositions(this, m_children);
			for each (var child : UIComponent in m_children)
			{
				if (!child || !child.isDisplayed())
				{
					//only deal with children that derive from UIComponent
					continue;
				}
				child.applyOutOfFlowChildPositions();
			}
			super.calculateKeyLoop();
		}
		
		/**
		 * this override prevents key loop calculation from happening before all 
		 * relevant data is gathered. Specifically, element positions aren't finalized 
		 * before applyOutOfFlowChildPositions is invoked recursively from the outermost 
		 * invalid element. Because of this relationship, we invoke the super 
		 * implementation from applyOutOfFlowChildPositions.
		 */
		protected override function calculateKeyLoop() : void
		{
			
		}
	
	
		/**
		 * parses the elements' xmlDefinition as set through innerHTML
		 */
		protected function parseXMLDefinition(xmlDefinition : XML) : void
		{
			m_xmlDefinition = xmlDefinition;
			parseXMLAttributes(xmlDefinition);
			parseXMLContent(xmlDefinition);
			
			m_stylesInvalidated = true;
			invalidate();
		}
		
		protected function parseXMLAttributes(node : XML) : void
		{
			if (node.nodeKind() == 'text')
			{
				//TODO: check if this can happen at all. Shouldn't a text node be 
				//rendered by the label component anyway?
				//this element is a textNode and is therefore guaranteed to have no
				//styles attached. It should completely use its parents' styles.
				//m_domPath = m_parentElement.domPath;
				m_elementType = "p";
			}
			else 
			{
				var attributes : Object = {};
				for each (var attribute : XML in node.@*)
				{
					if (attribute.nodeKind() != 'text')
					{
						var attributeName : String = attribute.localName();
						var attributeValue : String = attribute.toString();
						attributes[attributeName] = attributeValue;
						assignValueFromAttribute(attributeName, attributeValue);
					}
				}
				m_nodeAttributes = attributes;
				m_elementType = node.localName();
			}
		}
		
		/**
		 * Tries invoking a setter named after the schema 'setAttribute[attribute name]'. 
		 * If that fails, the method invokes setValueForKey to try to assign the value 
		 * by other means.
		 */
		private function assignValueFromAttribute(
			attribute : String, value : String) : void
		{
			var usedValue : * = resolveBindings(value);
			try
			{
				var attributeSetterName : String = 'setAttribute' + 
					attribute.charAt(0).toUpperCase() + attribute.substr(1);
				this[attributeSetterName](usedValue);
			}
			catch (error: Error)
			{
				try
				{
					setValueForKey(attribute, usedValue);
				}
				catch (error : Error)
				{
				}
			}
		}
		protected function resolveBindings(text : String) : *
		{
			var result : * = text;
			var valueParts : Array = text.split(/(?<!\\){|(?<!\\)}/);
			if (valueParts.length > 1)
			{
				for (var i : int = 1; i < valueParts.length; i += 2)
				{
					var bindingParts : Array = valueParts[i].split(/\s*,\s*/);
					var selectorPath : String = '';
					if (bindingParts.length == 2)
					{
						selectorPath = bindingParts.shift();
					}
					var propertyParts : Array = bindingParts[0].split(/\s*:\s*/);
					valueParts[i] = valueBySelectorProperty.
						apply(this, [selectorPath].concat(propertyParts));
				}
				if (valueParts.length > 3 || valueParts[0] != '' || valueParts[2] != '')
				{
					result = valueParts.join('');
				}
				else
				{
					result = valueParts[1];
				}
			}
			return result;
		}
	
		/**
		 * parses and displays the elements' childNodes
		 */
		protected function parseXMLContent(node : XML) : void
		{
			for each (var childNode:XML in node.children())
			{
				preprocessTextNode(childNode);
				var child:UIComponent = 
					m_rootElement.uiRendererFactory().rendererByNode(childNode);
				if (child)
				{
					addChild(child);
					child.parseXMLDefinition(childNode);
				}
				else
				{
					trace ("f No handler found for node: " + childNode.toXMLString());
				}
			}
		}
		
		protected function preprocessTextNode(node : XML) : void
		{
			var textNodeTags : String = UIRendererFactory.TEXTNODE_TAGS;
			if (textNodeTags.indexOf(node.localName() + ",") != -1)
			{
				var nodesToCombine : XMLList = new XMLList(node);
				var parentNode : XML = node.parent() as XML;
				var siblings : XMLList = parentNode ? parentNode.* : null;
				if (!siblings)
				{
					return;
				}
				//TODO: find a cleaner way to combine text nodes
				for (var i : int = node.childIndex() + 1; 
					i < XMLList(parentNode.*).length();)
				{
					var sibling : XML = XMLList(parentNode.*)[i];
					if (textNodeTags.indexOf(sibling.localName() + ',') == -1)
					{
						break;
					}
					nodesToCombine += sibling;
					delete parentNode.*[i];
				}
				var xmlParser : XML = <p/>;
				xmlParser.setChildren(nodesToCombine);
				siblings[node.childIndex()] = xmlParser;
			}
		}
	
		
		/**
		 * draws the background rect and borders according to the styles 
		 * specified for this element.
		 */
		protected function applyBackgroundAndBorders() : void
		{
			if (m_currentStyles.backgroundColor || m_currentStyles.backgroundImage || 
				(m_currentStyles.backgroundGradientColors && 
				m_currentStyles.backgroundGradientType))
			{
				var backgroundRendererId:String = 
					m_currentStyles.backgroundRenderer || "";
				if (!m_backgroundRenderer || 
					m_backgroundRenderer.id() != backgroundRendererId)
				{
					if (m_backgroundDisplay)
					{
						m_backgroundRenderer.destroy();
						removeChild(m_backgroundDisplay);
					}
					m_backgroundDisplay = new Sprite();
					m_backgroundDisplay.name = "background_" + backgroundRendererId;
					m_contentDisplay.addChildAt(m_backgroundDisplay, 0);
					m_backgroundRenderer = m_rootElement.uiRendererFactory().
						backgroundRendererById(backgroundRendererId);
					m_backgroundRenderer.setDisplay(m_backgroundDisplay);
				}
				m_backgroundDisplay.visible = true;
				
				m_backgroundDisplay.x = 0 - m_currentStyles.borderLeftWidth;
				m_backgroundDisplay.y = 0 - m_currentStyles.borderTopWidth;
				m_backgroundRenderer.setSize(m_borderBoxWidth, m_borderBoxHeight);
				m_backgroundRenderer.setStyles(m_currentStyles);
				m_backgroundRenderer.setComplexStyles(m_complexStyles);
				m_backgroundRenderer.draw();
				//TODO: move into renderer
				m_backgroundDisplay.blendMode = 
					m_currentStyles.backgroundBlendMode || 'normal';
			}
			else
			{
				if (m_backgroundDisplay)
				{
					m_backgroundDisplay.visible = false;
				}
			}
			
			if (m_currentStyles.borderTopStyle || m_currentStyles.borderRightStyle || 
				m_currentStyles.borderBottomStyle || m_currentStyles.borderLeftStyle)
			{
				var borderRendererId:String = m_currentStyles.borderRenderer || "";
				if (!m_borderRenderer || m_borderRenderer.id() != borderRendererId)
				{
					if (m_bordersDisplay)
					{
						m_borderRenderer.destroy();
						removeChild(m_bordersDisplay);
					}
					m_bordersDisplay = new Sprite();
					m_bordersDisplay.name = "border_" + borderRendererId;
					m_contentDisplay.addChildAt(m_bordersDisplay, 
						m_contentDisplay.getChildIndex(m_upperContentDisplay));
					m_borderRenderer = m_rootElement.uiRendererFactory().
						borderRendererById(borderRendererId);
					m_borderRenderer.setDisplay(m_bordersDisplay);
				}
				m_bordersDisplay.visible = true;
				
				m_bordersDisplay.x = 0 - m_currentStyles.borderLeftWidth;
				m_bordersDisplay.y = 0 - m_currentStyles.borderTopWidth;
				
				m_borderRenderer.setSize(m_borderBoxWidth, m_borderBoxHeight);
				m_borderRenderer.setStyles(m_currentStyles);
				m_borderRenderer.setComplexStyles(m_complexStyles);
				m_borderRenderer.draw();
			}
			else
			{
				if (m_bordersDisplay)
				{
					m_bordersDisplay.visible = false;
				}
			}
		}
		protected function applyOverflowProperty() : void
		{
			var maskNeeded:Boolean = false;
			var scrollersNeeded:Boolean = false;
			
			var ofx:* = m_currentStyles.overflowX;
			var ofy:* = m_currentStyles.overflowY;
			
			if (ofx == 'visible' || ofx == null || ofx == 'hidden')
			{
				if (m_hScrollbar) m_hScrollbar.setVisibility(false);
				if (ofx == 'hidden') maskNeeded = true;
			}
			else
			{
				maskNeeded = scrollersNeeded = true;
			}
			
			if (ofy == 'visible' || ofy == null || ofy == 'hidden')
			{
				if (m_vScrollbar) m_vScrollbar.setVisibility(false);
				if (ofy == 'hidden') maskNeeded = true;
			}
			else
			{
				maskNeeded = scrollersNeeded = true;
			}
			
			if (scrollersNeeded) 
			{
				applyScrollbars();
			}
			
			if (maskNeeded)
			{
				applyMask();
			}
			else
			{
				m_upperContentDisplay.mask = null;
				m_lowerContentDisplay.mask = null;
			}
		}
		
		protected function applyMask() : void
		{
			var maskW:Number = (m_currentStyles.overflowX == 'visible' || 
				m_currentStyles.overflowX == null) 
				? m_borderBoxWidth
				: innerWidth() + m_currentStyles.paddingLeft + m_currentStyles.paddingRight;
			var maskH:Number = (m_currentStyles.overflowY == 'visible' || 
				m_currentStyles.overflowY == null)
				? m_borderBoxHeight
				: innerHeight() + m_currentStyles.paddingTop + m_currentStyles.paddingBottom;
			
			if (!m_lowerContentMask)
			{
				m_upperContentMask = new Sprite();
				m_lowerContentMask = new Sprite();
				m_upperContentMask.name = 'upperMask';
				m_lowerContentMask.name = 'lowerMask';
				addChild(m_upperContentMask);
				addChild(m_lowerContentMask);
				m_upperContentMask.visible = false;
				m_lowerContentMask.visible = false;
			}
			
			m_upperContentMask.x = m_lowerContentMask.x = 
				m_currentStyles.borderLeftWidth;
			m_upperContentMask.y = m_lowerContentMask.y = 
				m_currentStyles.borderTopWidth;
			var radii : Array = [];
			var order : Array = 
				['borderTopLeftRadius', 'borderTopRightRadius', 
				'borderBottomRightRadius', 'borderBottomLeftRadius'];
			
			var i : Number;
			var radiusItem : Number;
			for (i = 0; i < order.length; i++)
			{
				radii.push(m_currentStyles[order[i]] || 0);
			}
			m_upperContentMask.graphics.clear();
			m_lowerContentMask.graphics.clear();
			m_upperContentMask.graphics.beginFill(0x00ff00, 50);
			m_lowerContentMask.graphics.beginFill(0x00ff00, 50);
			GfxUtil.drawRoundRect(m_upperContentMask, 0, 0, 
				maskW, maskH, radii);
			GfxUtil.drawRoundRect(m_lowerContentMask, 0, 0, 
				maskW, maskH, radii);
			m_upperContentDisplay.mask = m_upperContentMask;
			m_lowerContentDisplay.mask = m_lowerContentMask;
		}
		
		protected function applyScrollbars() : void
		{
			//TODO: ask Marc 'say what???'
			function childWidth():Number
			{
				var widestChildWidth:Number = 0;
				var childCount:Number = m_children.length;
				while (childCount--)
				{
					var child:UIComponent = m_children[childCount] as UIComponent;
					var childX:Number = child.m_currentStyles.position == 'absolute' ? 
						child.x : 0;
					widestChildWidth = Math.max(childX + child.m_borderBoxWidth + 
						child.m_currentStyles.marginRight - m_currentStyles.paddingLeft, 
						widestChildWidth);
				}
				return widestChildWidth;
			}
			
			var vScrollerNeeded:Boolean, hScrollerNeeded:Boolean = false;
			
			if (m_currentStyles.overflowY == 0 && 
				m_intrinsicHeight > m_currentStyles.height)
			{
				if (!m_vScrollbar)
				{
					m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
					addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel_turn);
				}
				m_vScrollbar.setVisibility(true);
				if (m_currentStyles.overflowX == 'scroll' || 
					m_currentStyles.overflowX == 0)
				{
					validateChildren();
					applyInFlowChildPositions();
					m_intrinsicWidth = childWidth();
				}
				vScrollerNeeded = true;
			}
			
			if (m_currentStyles.overflowY == 'scroll')
			{
				vScrollerNeeded == true;
			}
			
			if (m_currentStyles.overflowX == 0 && 
				m_intrinsicWidth > m_currentStyles.width)
			{
				if (!m_hScrollbar)
				{
					m_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
				}
				m_hScrollbar.setVisibility(true);
				if (vScrollerNeeded)
				{
					var oldIntrinsicWidth:Number = m_intrinsicWidth;
					validateChildren();
					applyInFlowChildPositions();
					applyOutOfFlowChildPositions();
					m_intrinsicWidth = oldIntrinsicWidth;
				}
				hScrollerNeeded = true;
			}

			if (m_currentStyles.overflowX == 'scroll')
			{
				hScrollerNeeded == true;
			}

			if (vScrollerNeeded)
			{
				m_vScrollbar.setScrollProperties(innerHeight(), 0, 
					m_intrinsicHeight - innerHeight());
				m_vScrollbar.top = 0;
				m_vScrollbar.height = innerHeight() + 
					m_currentStyles.paddingTop + m_currentStyles.paddingBottom;
				m_vScrollbar.left = m_currentStyles.width - m_vScrollbar.outerWidth + 
					m_currentStyles.paddingLeft + m_currentStyles.paddingRight;
				m_vScrollbar.validateElement(true, true);
			}
			else
			{
				if (m_vScrollbar)
				{
					m_vScrollbar.setVisibility(false);
				}
			}
			
			if (hScrollerNeeded)
			{
				m_hScrollbar.setScrollProperties(innerWidth(), 0, 
					m_intrinsicWidth - innerWidth());
				m_hScrollbar.top = m_currentStyles.height + 
					m_currentStyles.paddingTop + m_currentStyles.paddingRight;
				m_hScrollbar.height = innerWidth() + 
					m_currentStyles.paddingLeft + m_currentStyles.paddingRight;
				m_hScrollbar.validateElement(true, true);
			}
			else
			{
				if (m_hScrollbar)
				{
					m_hScrollbar.setVisibility(false);
				}
			}
		}
		
		protected function createScrollbar(
			orientation:String, skipListenerRegistration : Boolean = false) : Scrollbar
		{
			if (!m_scrollbarsDisplay)
			{
				m_scrollbarsDisplay = new Sprite();
				m_scrollbarsDisplay.name = 'scrollbars_display';
				addChild(m_scrollbarsDisplay);
			}
			var scrollbar:Scrollbar = new Scrollbar();
			scrollbar.setParent(this);
			scrollbar.overrideContainingBlock(this);
			m_scrollbarsDisplay.addChild(scrollbar);
			scrollbar.cssClasses = orientation + "Scrollbar";
			scrollbar.setStyle('position', 'absolute');
			scrollbar.setStyle('autoHide', 'false');
			//TODO: remove scrollbarWidth property
			scrollbar.setStyle('width', 
				(m_currentStyles.scrollbarWidth || DEFAULT_SCROLLBAR_WIDTH) + 'px');
			if (orientation == Scrollbar.ORIENTATION_HORIZONTAL)
			{
				scrollbar.rotation = -90;
			}
			if (!skipListenerRegistration)
			{
				scrollbar.addEventListener(Event.CHANGE, 
					this[orientation + 'Scrollbar_change']);
			}
			scrollbar.addEventListener(MouseEvent.CLICK, scrollbar_click);
			scrollbar.validateElement(true, true);
			return scrollbar;
		}
		
		protected function scrollbar_click(event : Event) : void
		{
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
		protected function verticalScrollbar_change(event : Event) : void
		{
			m_upperContentDisplay.y = m_lowerContentDisplay.y = 
				-m_vScrollbar.scrollPosition;
		}
		
		protected function horizontalScrollbar_change(event : Event) : void
		{
			m_upperContentDisplay.x = m_lowerContentDisplay.x = 
				-m_hScrollbar.scrollPosition;
		}
		
		protected function mouseWheel_turn(event : MouseEvent) : void
		{
			if (event.shiftKey && m_hScrollbar)
			{
				m_hScrollbar.scrollPosition -= m_hScrollbar.lineScrollSize * event.delta;
				m_upperContentDisplay.x = m_lowerContentDisplay.x = -m_hScrollbar.scrollPosition;
			}
			else if ((!event.shiftKey && m_vScrollbar) || 
				(event.shiftKey && (!m_hScrollbar || !m_hScrollbar.getVisibility())))
			{
				m_vScrollbar.scrollPosition -= m_vScrollbar.lineScrollSize * event.delta;
				m_upperContentDisplay.y = m_lowerContentDisplay.y = -m_vScrollbar.scrollPosition;
			}
		}
		
		protected function i18n(key : String) : String
		{
			return m_rootElement.getI18N(key);
		}
		protected function i18nFlag(key : String) : Boolean
		{
			return m_rootElement.getI18NFlag(key);
		}
		protected function i18nObject(key : String) : Object
		{
			return m_rootElement.getI18NObject(key);
		}
		protected function track(trackingId : String) : void
		{
			m_rootElement.getTrack(trackingId);
		}
		
		/**
		 * Hook method. Measures the intrinsic dimensions of the component.
		 * The default implementation calculates the intrinsic height based
		 * on the bottom of the last child that's positioned in-flow and the 
		 * intrinsic width based on the style defined value.
		 * This value is then applied to the height property as the calculated value.
		 */
		protected function measure() : void
		{
		}
		
		protected override function unregisterChildView(child:UIObject) : void
		{
			log(child, child.parent);
			if (child is UIComponent)
			{
				if (m_children.indexOf(child) != -1)
				{
					child.parent.removeChild(child);
					m_children.splice(m_children.indexOf(child), 1);
					invalidate();
				}
			}
			else
			{
				super.unregisterChildView(child);
			}
		}
		
		internal function valueForKey(key : String) : *
		{
			return this[key];
		}
		internal function setValueForKey(key : String, value : *) : void
		{
			//try to assign to a setter method by prepending 'set'
			try
			{
				var setterName : String = 
					'set' + key.charAt(0).toUpperCase() + key.substr(1);
				this[setterName](value);
			}
			catch (error : Error)
			{
				//failed, try to assign to a property
				this[key] = value;
			}
		}
	}
}