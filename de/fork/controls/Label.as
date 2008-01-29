package de.fork.controls { 
	import de.fork.core.ccInternal;
	import de.fork.css.CSS;
	import de.fork.css.CSSDeclaration;
	import de.fork.events.LabelEvent;
	import de.fork.ui.UIComponent;
	import de.fork.utils.StringUtil;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	use namespace ccInternal;
	
	public class Label extends UIComponent
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "Label";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var AS_LINK_PREFIX : String = 
			"asfunction:parent.UIComponent.textLink_click,";
		
		protected var m_labelDisplay : TextField;
		protected var m_textSetExternally : Boolean;
		protected var m_selectable : Boolean;
		
		protected var m_textLinkHrefs : Array;
		
		protected var m_internalTextStylesheet : StyleSheet;
		protected var m_internalStyleIndex : Number;
	
		protected var m_xmlDefinition : XMLNode;
	
		protected var m_htmlMode : Boolean;
	
		protected var m_labelXml : XMLNode;
		
		protected var m_textAlignment : String;
		protected var m_containsImages : Boolean;	
		protected var m_overflowIsInvalid : Boolean;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Label ()
		{
			m_elementType = className;
		}
		
		/**
		 * sets the label to display
		 */
		public function setLabel(label:String) : void
		{
			m_labelXml = (new XMLDocument("<p>" + label + "</p>")).firstChild;
			m_textSetExternally = true;
			invalidate();
		}
		public function getLabel() : String
		{
			var labelStr:String = m_labelXml.toString();
			return labelStr.substring(
				labelStr.indexOf(">") + 1, labelStr.lastIndexOf("<"));
		}
		
		/**
		 * sets whether the label should be displayed with html formatting or not
		 */
		public function set html(value:Boolean) : void
		{
			if (m_htmlMode != value)
			{
				m_htmlMode = value;
				invalidate();
			}
		}
		/**
		 * sets whether the label should be displayed with html formatting or not
		 */
		public function get html() : Boolean
		{
			return m_htmlMode;
		}
		
		public function set enabled(value:Boolean) : void
		{
			m_instanceStyles.selectable = value ? 'true' : 'false';
			m_labelDisplay.selectable = enabled;
		}
		
		public function get enabled () : Boolean
		{
			return m_selectable;
		}
		
		public function get textWidth() : Number
		{
			return m_labelDisplay.textWidth;
		}
		
		public function get textHeight() : Number
		{
			return m_labelDisplay.textHeight;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize () : void
		{
			super.initialize();
			
			m_textLinkHrefs = [];
		}
		protected override function createChildren() : void
		{
			m_labelDisplay = new TextField();
			m_labelDisplay = m_contentDisplay.addChild(m_labelDisplay) as TextField;
			m_labelDisplay.name = 'labelDisplay';
			m_labelDisplay.x = -2;
			m_labelDisplay.y = -2;
			m_labelDisplay.width = 20;
			m_labelDisplay.height = 20;
		}
		protected override function initDefaultStyles() : void
		{
			m_elementDefaultStyles.selectable = 'true';
			m_elementDefaultStyles.display = 'inline';
			m_elementDefaultStyles.wordWrap = 'wrap';
			m_elementDefaultStyles.multiline = 'true';
		}
		
		protected override function calculateStyles() : void
		{
			super.calculateStyles();
			if (m_stylesInvalidated)
			{
				m_selectable = m_currentStyles.selectable;
				var fmt : TextFormat = new TextFormat();
				if (m_currentStyles.tabStops)
				{
					var tabStops : Array = 
						m_currentStyles.tabStops.split(", ").join(",").split(",");
					fmt.tabStops = tabStops;
				}
				else
				{
					fmt.tabStops = null;
				}
			}
		}
		
		protected override function parseChildNodes(firstChild : XMLNode) : void
		{
			var labelXml:XMLDocument = new XMLDocument();
			for(var node : XMLNode = firstChild;
				node != null; node = node.nextSibling)
			{
				labelXml.appendChild(node.cloneNode(true));
			}
			m_labelXml = labelXml;
		}
		
		protected override function measure() : void
		{
			//TODO: find a way to make measuring work if the TextField contains IMGs
			m_intrinsicWidth = m_labelDisplay.textWidth;
			m_intrinsicHeight = m_labelDisplay.height - 4;
		}
		
		protected function renderLabel() : void
		{
			if (m_stylesInvalidated)
			{
				if (m_selectorPathChanged)
				{
					m_labelDisplay.selectable = m_selectable;
					
					m_labelDisplay.embedFonts = m_currentStyles.embedFonts;
					m_labelDisplay.antiAliasType = m_currentStyles.antiAliasType || 
						AntiAliasType.NORMAL;
					m_labelDisplay.wordWrap = m_currentStyles.wordWrap == 'wrap';
					m_labelDisplay.multiline = m_currentStyles.multiline;
				}
			}
			if (m_stylesInvalidated || m_textSetExternally)
			{
				m_labelDisplay.x = -2;
				if (m_currentStyles.width)
				{
					m_labelDisplay.width = m_currentStyles.width + 6;
				}
				else
				{
					m_labelDisplay.autoSize = 'left';
				}
				
				m_internalTextStylesheet = new StyleSheet();
				m_labelDisplay.styleSheet = m_internalTextStylesheet;
				m_internalStyleIndex = 0;
				m_xmlDefinition = m_labelXml.cloneNode(true);
				m_textAlignment = null;
				m_containsImages = false;
				cleanNode(m_xmlDefinition, m_selectorPath, 
					m_rootElement.styleSheet);
				var text:String = m_xmlDefinition.toString();
				if (m_currentStyles.fixLineEndings)
				{
					text = text.split('\r\n').join('\n').split('\r').join('\n');
				}
				m_labelDisplay.htmlText = text.substr(0, text.length - 3);
				if (m_labelDisplay.wordWrap)
				{
					m_labelDisplay.autoSize = 'left';
					var enforceUpdate : Number = m_labelDisplay.height;
				}
				else
				{
					m_labelDisplay.height = m_labelDisplay.textHeight + 8;
				}
				m_labelDisplay.autoSize = 'none';
				
				//shrink the TextField to the smallest width possible
				if (m_textAlignment != 'mixed' && !m_containsImages)
				{
					if (m_labelDisplay.textWidth < m_labelDisplay.width - 8)
					{
						m_labelDisplay.width = m_labelDisplay.textWidth + 8;
						if (m_textAlignment == 'right')
						{
							m_labelDisplay.x = 
								m_currentStyles.width - m_labelDisplay.width + 2;
						}
						else if (m_textAlignment == 'center')
						{
							m_labelDisplay.x = Math.round(
								m_currentStyles.width / 2 - 
								m_labelDisplay.width / 2);
						}
					}
				}
				
				m_textSetExternally = false;
				m_overflowIsInvalid = true;
			}
		}
		
		protected override function applyInFlowChildPositions() : void
		{
			renderLabel();
		}
		
		/**
		 * we're guaranteed not to have any child elements, so we can ignore this
		 */
		protected override function applyOutOfFlowChildPositions() : void
		{
		}
		
		/**
		 * cleanes the given node to prepare it for display in a TextField
		 */
		protected function cleanNode(node:XMLNode, selectorPath:String, 
			stylesheet:CSS, transform:String = null) : void
		{
			if (node.nodeType == 3 || node.nodeName == "br")
			{
				if (transform)
				{
					node.nodeValue = transformText(node.nodeValue, transform);
				}
				//nothing to clean in text nodes and <br>-nodes
				return;
			}
			
			//bring all style definitions into a form the player can understand
			var nodeStyle:CSSDeclaration;
			if (node == m_xmlDefinition)
			{
				nodeStyle = m_complexStyles.clone();
				if (nodeStyle.getStyle('transform'))
				{
					transform = nodeStyle.getStyle('transform').valueOf() as String;
				}
			}
			else
			{
				var classesStr:String = node.attributes["class"];
				if (!classesStr)
				{
					classesStr = "";
				}
				else
				{
					classesStr = "@." + classesStr.split(" ").join("@.") + "@";
				}
				var id:String = node.attributes.id;
				if (!id)
				{
					id = "";
				}
				else
				{
					id = "@#" + id + "@";
				}
				selectorPath += " @" + node.nodeName + "@" + classesStr + id;
				nodeStyle = stylesheet.getStyleForEscapedSelectorPath(selectorPath);
			}
			//the player doesn't understand the "style" attribute, so we need to
			//copy all information into a class
			var stylesStr:String = node.attributes.style;
			var stylesStyle:Object;
			if (stylesStr)
			{
				var styleParser:StyleSheet = new StyleSheet();
				styleParser.parseCSS("stylesClass {" + stylesStr + "}");
				stylesStyle = styleParser.getStyle("stylesClass");
				nodeStyle.mergeCSSDeclaration(
					CSSDeclaration.CSSDeclarationFromObject(stylesStyle));
				delete node.attributes.style;
			}
			
			if (nodeStyle)
			{
				var convertedNodeStyle:Object = nodeStyle.toTextFormatObject();
				if (convertedNodeStyle.textTransform != null)
				{
					transform = convertedNodeStyle.textTransform;
				}
				if (m_internalStyleIndex == 0)
				{
					delete convertedNodeStyle.marginLeft;
					delete convertedNodeStyle.marginRight;
				}
				var styleName:String = "style_" + m_internalStyleIndex++;
				m_internalTextStylesheet.setStyle(
					"." + styleName, convertedNodeStyle);
				node.attributes["class"] = styleName;
				delete node.attributes.id;
				
				/* check if the label has mixed textAlign properties.
				 * If it does its TextField can't be shrinked horizontally 
				 */
				if (m_textAlignment != 'mixed')
				{
					var textAlign:String = convertedNodeStyle.textAlign;
					if (!textAlign)
					{
						textAlign = 'left';
					}
					if (!m_textAlignment)
					{
						m_textAlignment = textAlign;
					}
					else if (m_textAlignment != textAlign)
					{
						m_textAlignment = 'mixed';
					}
				}
			}
			
			switch (node.nodeName)
			{
				case "br":
					//remove all redundant whitespace around "<br />"-tags
					if (node.previousSibling.nodeType == 3)
					{
						node.previousSibling.nodeValue = StringUtil.rTrim(
							node.previousSibling.nodeValue);
					}
					if (node.nextSibling.nodeType == 3)
					{
						node.nextSibling.nodeValue = StringUtil.lTrim(
							node.nextSibling.nodeValue);
					}
					break;
				case "a":
					//extract all links and redirect them to an ActionScript method
					var href:String = node.attributes.href;
					if (href)
					{
						var target:String = node.attributes.target;
						if (target)
						{
							href += "|"+target;
							delete node.attributes.target;
						}
						node.attributes.href = 
							AS_LINK_PREFIX + m_textLinkHrefs.length;
						m_textLinkHrefs.push(href);
					}
					break;
				case "p":
				case "span":
					//do nothing these tags are fine
					break;
				case "img":
				{
					//we can't shrink the TextField later on, because the player 
					//doesn't include images in its calculation of textWidth and 
					//textHeight. Therefore, we flag that now and don't try to 
					//reduce the size
					m_containsImages = true;
					break;
				}
				default:
					//replace unknown tags by <span> tag. This enables styling 
					//the node using the "class"-attribute, which is not possible 
					//on tags unknown to the player
					node.nodeName = "span";
			}
			
			for (var child:XMLNode = node.firstChild; 
				child != null; child = child.nextSibling)
			{
				cleanNode(child, selectorPath, stylesheet, transform);
			}
		}
		/**
		 * event handler, invoked on click of one of 
		 * the links inside of the displayed text
		 */
		protected function textLink_click(linkIndexStr:String) : void
		{
			var linkIndex:Number = parseInt(linkIndexStr);
			var hrefArr:Array = String(m_textLinkHrefs[linkIndex]).split("|");
			var href:String = hrefArr[0];
			var target:String = hrefArr[1];
			
			var event : LabelEvent = new LabelEvent(LabelEvent.LINK_CLICK, this);
			event.url = href;
			event.linkTarget = target;
			dispatchEvent(event);
			if (!event.isDefaultPrevented())
			{
				var request:URLRequest = new URLRequest(event.url);
				navigateToURL(request, event.linkTarget || '_self');
				
			}
		}
		protected function transformText(text:String, transform:String) : String
		{
			switch (transform)
			{
				case 'uppercase':
				{
					text = text.toUpperCase();
					break;
				}
				case 'lowercase':
				{
					text = text.toLowerCase();
					break;
				}
			}
			return text;
		}
		
		protected override function applyOverflowProperty() : void
		{
			if (!m_overflowIsInvalid)
			{
				return;
			}
			m_overflowIsInvalid = false;
			var overflow : * = m_currentStyles.overflow;
			
			if (m_currentStyles.overflow == null || 
				overflow == 'visible' || overflow == 'hidden')
			{
				super.applyOverflowProperty();
				return;
			}
			
			var availableWidth:Number = m_currentStyles.width;
			var availableHeight:Number = Math.max(calculateContentHeight(), 
				m_currentStyles.height);
			var scrollbarWidth : Number = 
				m_currentStyles.scrollbarWidth || DEFAULT_SCROLLBAR_WIDTH;
			
			if (overflow == 'scroll' || overflow == 'scroll-vertical')
			{
				if (!m_vScrollbar)
				{
					m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
				}
				availableWidth -= scrollbarWidth;
				m_vScrollbar.setVisibility(true);
			}
			if (overflow == 'scroll' || overflow == 'scroll-horizontal')
			{
				if (!m_hScrollbar)
				{
					m_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
				}
				availableHeight -= scrollbarWidth;
				m_hScrollbar.setVisibility(true);
			}
			if (overflow == 0) //'auto' gets resolved to '0'
			{
				if (m_labelDisplay.textHeight > availableHeight)
				{
					if (!m_vScrollbar)
					{
						m_vScrollbar = createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
					}
					availableWidth -= scrollbarWidth;
					m_vScrollbar.setVisibility(true);
					m_labelDisplay.width = availableWidth + 3;
				}
				else if (m_vScrollbar)
				{
					m_vScrollbar.setVisibility(false);
				}
				
				if (!m_labelDisplay.wordWrap && 
					m_labelDisplay.textWidth > m_labelDisplay.width - 3)
				{
					if (!m_hScrollbar)
					{
						m_hScrollbar = createScrollbar(Scrollbar.ORIENTATION_HORIZONTAL);
					}
					availableHeight -= scrollbarWidth;
					m_hScrollbar.setVisibility(true);
					
					if ((!m_vScrollbar || !m_vScrollbar.getVisibility()) && 
						m_labelDisplay.textHeight > availableHeight)
					{
						if (!m_vScrollbar)
						{
							m_vScrollbar = 
								createScrollbar(Scrollbar.ORIENTATION_VERTICAL);
						}
						availableWidth -= scrollbarWidth;
						m_vScrollbar.setVisibility(true);
					}
				}
				else if (m_hScrollbar)
				{
					m_hScrollbar.setVisibility(false);
				}
			}
			if (!(m_vScrollbar && m_vScrollbar.getVisibility()) && 
				!(m_hScrollbar && m_hScrollbar.getVisibility()))
			{
				return;
			}
			
			m_labelDisplay.width = availableWidth + 6;
			m_labelDisplay.height = availableHeight + 6;
			
			availableHeight += m_paddingTop + m_paddingBottom;
			availableWidth += m_paddingLeft + m_paddingRight;
			
			m_vScrollbar.outerHeight = availableHeight;
			m_vScrollbar.top = m_borderTopWidth;
			m_vScrollbar.left = availableWidth + m_borderLeftWidth;
			m_vScrollbar.delayValidation();
			
			if (m_hScrollbar)
			{
				m_hScrollbar.outerHeight = availableWidth;
				m_hScrollbar.top = availableHeight + scrollbarWidth;
				m_hScrollbar.left = m_borderLeftWidth;
				m_hScrollbar.delayValidation();
			}
		}
	
		protected override function createScrollbar(orientation : String, 
			skipListenerRegistration : Boolean = true) : Scrollbar
		{
			var scrollbar : Scrollbar = super.createScrollbar(orientation, true);
			scrollbar.setScrollTarget(m_labelDisplay, orientation);
			return scrollbar;
		}
	}
}