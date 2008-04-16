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

package reprise.controls { 
	import reprise.core.ccInternal;
	import reprise.events.DisplayEvent;
	import reprise.events.MouseEventConstants;
	import reprise.ui.UIComponent;
	import reprise.utils.ProxyFunction;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	use namespace ccInternal;
	
	public class Scrollbar extends UIComponent
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var ORIENTATION_VERTICAL : String = 'vertical';
		public static var ORIENTATION_HORIZONTAL : String = 'horizontal';
		
		public static var className : String = "Scrollbar";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_linkageID : String = "Scrollbar";
		
		protected static var SCROLL_DIR_UP : Number = -1;
		protected static var SCROLL_DIR_DOWN : Number = 1;
		
		
		protected var m_scrollUpBtn : SimpleButton;
		protected var m_scrollDownBtn : SimpleButton;
		protected var m_scrollThumb : SimpleButton;
		protected var m_scrollTrack : SimpleButton;
		
		protected var m_scrollDirection : Number;
		protected var m_scrollIntervalID : Number;
		
		protected var m_target : TextField;
		protected var m_textScrollOrientation : String;
		
		protected var m_minPos : Number;
		protected var m_maxPos : Number;
		
		protected var m_thumbMinPos : Number;
		protected var m_thumbMaxPos : Number;
		
		protected var m_scrollPosition : Number;
	
		protected var m_mouseWheelListener : Object;
		
		protected var m_mouseWheelHitAreaX : Number;
		protected var m_mouseWheelHitAreaY : Number;
		protected var m_mouseWheelHitAreaWidth : Number;
		protected var m_mouseWheelHitAreaHeight : Number;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Scrollbar()
		{
		}


		public function delayValidation() : void
		{
			setTimeout(forceRedraw, 1);
		}
		
		/**
		 * sets a TextField instance as the Scrollbar's m_target
		 */
		public function setScrollTarget(target:TextField, orientation:String) : void
		{
			m_target = target;
			m_textScrollOrientation = orientation;
			if (m_target)
			{
				if (orientation == ORIENTATION_VERTICAL)
				{
					pageScrollSize = m_target.bottomScrollV - m_target.scrollV;
				}
				else
				{
					pageScrollSize = m_target.width - 4;
				}
				addEventListener(Event.ENTER_FRAME, checkTargetScrollPos);
				checkTargetScrollPos();
			}
			else
			{
				removeEventListener(Event.ENTER_FRAME, checkTargetScrollPos);
			}
		}
		
		/**
		 * sets the Scrollbar's scrollV properties
		 */
		public function setScrollProperties(
			pageSize:Number, minPos:Number, maxPos:Number) : void
		{
			pageScrollSize = pageSize;
			if (maxPos < minPos)
			{
				maxPos = minPos;
			}
			m_minPos = minPos;
			m_maxPos = maxPos;
			invalidate();
		}
		
		/**
		 * setter for the scrollPosition property
		 */
		public function set scrollPosition(position:Number) : void
		{
			if (m_target)
			{
				m_target.scrollV = position;
			}
			updateScrollPosition(position);
		}
		/**
		 * getter for the scrollPosition property
		 */
		public function get scrollPosition() : Number
		{
			return m_scrollPosition;
		}
		
		/**
		 * sets whether the scrollBar should automatically 
		 * hide itself if there's no need to scrollV
		 */
		public function set autoHide(hide:Boolean) : void
		{
			m_currentStyles.autoHide = hide;
			m_instanceStyles.setStyle('autoHide', hide.toString());
		}
		/**
		 * returns the current state of the autoHide property
		 */
		public function get autoHide() : Boolean
		{
			return m_currentStyles.autoHide;
		}
		
		public function set pageScrollSize(value:Number) : void
		{
			m_currentStyles.pageScrollSize = value;
			m_instanceStyles.setStyle('pageScrollSize', value.toString());
		}
		public function get pageScrollSize() : Number
		{
			return m_currentStyles.pageScrollSize;
		}
		public function set lineScrollSize(value:Number) : void
		{
			m_currentStyles.lineScrollSize = value;
			m_instanceStyles.setStyle('lineScrollSize', value.toString());
		}
		public function get lineScrollSize() : Number
		{
			return m_currentStyles.lineScrollSize;
		}
		
		/**
		 * getter for the scaleScrollThumb property
		 */
		public function get scaleScrollThumb() : Boolean
		{
			return Boolean(m_currentStyles.scaleScrollThumb);
		}
		/**
		 * getter for the scaleScrollThumb property
		 */
		public function set scaleScrollThumb(scaleScrollThumb:Boolean) : void
		{
			m_instanceStyles.setStyle('scaleScrollThumb', scaleScrollThumb.toString());
		}
		
		/**
		 * sets the area in which the scrollbar should react on mouseWheel events
		 * 
		 * Coordinates are relative to the Scrollbars' parent
		 */
		public function setMouseWheelArea(
			x:Number, y:Number, width:Number, height:Number) : void
		{
			m_mouseWheelHitAreaX = x;
			m_mouseWheelHitAreaY = y;
			m_mouseWheelHitAreaWidth = width;
			m_mouseWheelHitAreaHeight = height;
		}
		
		/**
		 * clean up
		 */
		public override function remove() : void
		{
			clearInterval(m_scrollIntervalID);
			super.remove();
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize() : void
		{
			super.initialize();
			
			m_scrollPosition = 0;
			m_minPos = 0;
			m_maxPos = 0;
			
			
			//init mouseWheel support
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel_turn);
		}
		protected override function initDefaultStyles() : void
		{
			m_elementDefaultStyles.setStyle('lineScrollSize', '1');
			m_elementDefaultStyles.setStyle('pageScrollSize', '5');
			m_elementDefaultStyles.setStyle('outerWidth', '16px');
			m_elementDefaultStyles.setStyle('outerHeight', '50px');
		}
		
		protected override function createChildren() : void
		{
			m_scrollUpBtn = SimpleButton(addChild(new SimpleButton()));
			m_scrollUpBtn.cssClasses = "scrollUpBtn";
			m_scrollTrack = SimpleButton(addChild(new SimpleButton()));
			m_scrollTrack.cssClasses = "scrollTrack";
			m_scrollDownBtn = SimpleButton(addChild(new SimpleButton()));
			m_scrollDownBtn.cssClasses = "scrollDownBtn";
			m_scrollThumb = SimpleButton(addChild(new SimpleButton()));
			m_scrollThumb.cssClasses = "scrollThumb";
			
			//init button delegates
			m_scrollUpBtn.addEventListener(MouseEvent.MOUSE_DOWN,  scrollUp_press);
			m_scrollUpBtn.addEventListener(MouseEvent.MOUSE_UP, scrollBtn_up);
			m_scrollUpBtn.addEventListener(
				MouseEventConstants.MOUSE_UP_OUTSIDE, scrollBtn_up);
			
			m_scrollDownBtn.addEventListener(MouseEvent.MOUSE_DOWN, scrollDown_press);
			m_scrollDownBtn.addEventListener(MouseEvent.MOUSE_UP, scrollBtn_up);
			m_scrollDownBtn.addEventListener(
				MouseEventConstants.MOUSE_UP_OUTSIDE, scrollBtn_up);
			
			m_scrollThumb.addEventListener(MouseEvent.MOUSE_DOWN, scrollThumb_press);
			m_scrollThumb.addEventListener(MouseEvent.MOUSE_UP, scrollThumb_up);
			m_scrollThumb.addEventListener(
				MouseEventConstants.MOUSE_UP_OUTSIDE, scrollThumb_up);
			
			m_scrollTrack.addEventListener(MouseEvent.MOUSE_DOWN, scrollTrack_press);
			m_scrollTrack.addEventListener(MouseEvent.MOUSE_UP, scrollBtn_up);
			m_scrollTrack.addEventListener(
				MouseEventConstants.MOUSE_UP_OUTSIDE, scrollBtn_up);
		}
		
		protected override function validateAfterChildren() : void
		{
			top = top;
			left = left;
			if (m_currentStyles.autoHide && m_maxPos == m_minPos)
			{
				setVisibility(false);
				//TODO: check if we can disable positioning entirely here
				super.validateAfterChildren();
				return;
			}
			
			var specHeight:Number = m_currentStyles.height;
			var trackHeight:Number = 
				specHeight - m_scrollUpBtn.outerHeight - m_scrollDownBtn.outerHeight;
			m_scrollTrack.setStyle('outerHeight', trackHeight + 'px');
			m_scrollTrack.forceRedraw();
			applyInFlowChildPositions();
				
			super.validateAfterChildren();
			
			if (m_maxPos == m_minPos)
			{
				if (m_scrollThumb.enabled)
				{
					m_scrollThumb.enabled = false;
					m_scrollUpBtn.enabled = false;
					m_scrollDownBtn.enabled = false;
					m_scrollTrack.enabled = false;
				}
			}
			else
			{
				if (!m_scrollThumb.enabled)
				{
					m_scrollThumb.enabled = true;
					m_scrollUpBtn.enabled = true;
					m_scrollDownBtn.enabled = true;
					m_scrollTrack.enabled = true;
				}
			
				var scrollTrackBox:Rectangle = m_scrollTrack.actualBox();
				m_thumbMinPos = scrollTrackBox.top;
				if (m_currentStyles.scaleScrollThumb)
				{
					m_scrollThumb.setStyle('height', 'auto');
					m_scrollThumb.outerHeight = Math.ceil(
						m_scrollTrack.outerHeight * pageScrollSize / 
						(pageScrollSize + m_maxPos - m_minPos));
					m_scrollThumb.forceRedraw();
				}
				m_thumbMaxPos = scrollTrackBox.bottom - m_scrollThumb.outerHeight;
			}
			updateScrollPosition(m_scrollPosition);
		}
		
		
		
		protected function scrollUp_press(event : MouseEvent) : void
		{
			startScrollUp(lineScrollSize);
		}
		
		protected function scrollDown_press(event : MouseEvent) : void
		{
			startScrollDown(lineScrollSize);
		}
		
		protected function scrollThumb_press(event : MouseEvent) : void
		{
			m_scrollIntervalID = setInterval(thumbScrub, 50, event.localY);
		}
		protected function scrollThumb_up(event : MouseEvent) : void
		{
			clearInterval(m_scrollIntervalID);
		}
		
		protected function scrollTrack_press(event : MouseEvent) : void
		{
			if (mouseY >= m_scrollThumb.top)
			{
				startScrollDown(pageScrollSize);
			}
			else
			{
				startScrollUp(pageScrollSize);
			}
		}
		
		protected function scrollBtn_up(event : MouseEvent) : void
		{
			stopScroll();
		}
		
		/**
		 * periodically checks if the m_target's scrollV property has 
		 * changed and updates the scrollbar's visuals accordingly
		 */
		protected function checkTargetScrollPos(...rest) : void
		{
			if (m_textScrollOrientation == ORIENTATION_VERTICAL)
			{
				if (m_target.maxScrollV != m_maxPos || 
					m_target.scrollV != m_scrollPosition)
				{
					setScrollProperties(m_target.bottomScrollV - m_target.scrollV, 
						1, m_target.maxScrollV);
					m_scrollPosition = m_target.scrollV;
				}
			}
			else
			{
				if (m_target.maxScrollH != m_maxPos || 
					m_target.scrollH != m_scrollPosition)
				{
					m_scrollPosition = m_target.scrollH;
					setScrollProperties(m_target.width - 4, 0, 
						m_target.maxScrollH);
				}
			}
		}
		
		
		protected function startScrollUp(scrollSize:Number) : void
		{
			startScroll(scrollSize, SCROLL_DIR_UP);
		}
		protected function startScrollDown(scrollSize:Number) : void
		{
			startScroll(scrollSize, SCROLL_DIR_DOWN);
		}
		
		protected function startScroll(scrollSize:Number, direction:Number) : void
		{
			m_scrollDirection = direction;
			scrollV(scrollSize);
			clearInterval(m_scrollIntervalID);
			m_scrollIntervalID = setInterval(
				ProxyFunction.create(this, callScroll), 200, scrollSize);
		}
		protected function stopScroll() : void
		{
			clearInterval(m_scrollIntervalID);
		}
		protected function scrollV(scrollSize:Number) : void
		{
			if (scrollSize == pageScrollSize)
			{
				if (m_scrollDirection == SCROLL_DIR_DOWN && 
					mouseY < m_scrollThumb.bottom)
				{
					return;
				}
				else if (m_scrollDirection == SCROLL_DIR_UP && 
					mouseY >= m_scrollThumb.top)
				{
					return;
				}
			}
			
			updateScrollPosition(
				m_scrollPosition + m_scrollDirection * scrollSize, true);
			dispatchEvent(new DisplayEvent(Event.CHANGE));
		}
		
		/**
		 * updates the scrollPosition in accordance with the thumbs current position
		 */
		protected function thumbScrub(offset:Number) : void
		{
			var pos:Number = mouseY - offset;
			if (pos < m_thumbMinPos)
			{
				pos = m_thumbMinPos;
			}
			else if (pos > m_thumbMaxPos)
			{
				pos = m_thumbMaxPos;
			}
			
			var oldPosition : Number = m_scrollPosition;
			updateScrollPosition(Math.round((pos - m_thumbMinPos) * 
				m_maxPos /(m_thumbMaxPos - m_thumbMinPos)), true);
			if (m_scrollPosition != oldPosition)
			{
				dispatchEvent(new DisplayEvent(Event.CHANGE));
			}
		}
		
		protected function callScroll(scrollSize:Number) : void
		{
			scrollV(scrollSize);
			clearInterval(m_scrollIntervalID);
			m_scrollIntervalID = 
				setInterval(ProxyFunction.create(this, scrollV), 50, scrollSize);
		}
		
		/**
		 * updates graphics to reflect the new scrollPosition
		 */
		protected function updateScrollPosition(
			position:Number, updateTextFieldTarget:Boolean = false) : void
		{
			if (position < m_minPos)
			{
				position = m_minPos;
			}
			else if (position > m_maxPos)
			{
				position = m_maxPos;
			}
			m_scrollPosition = position;
			if (m_maxPos <= m_minPos)
			{
				m_scrollThumb.top = m_thumbMinPos;
			}
			else
			{
				m_scrollThumb.top = m_thumbMinPos + 
					Math.round((m_thumbMaxPos - m_thumbMinPos) * 
					(position - m_minPos) /(m_maxPos - m_minPos));
			}
			if (updateTextFieldTarget && m_target)
			{
				if (m_textScrollOrientation == ORIENTATION_VERTICAL)
				{
					m_target.scrollV = m_scrollPosition;
				}
				else
				{
					m_target.scrollH = m_scrollPosition;
				}
			}
		}
		
		/**
		 * event handler, invoked on turn of the mouseWheel
		 * 
		 * updates the scrollPosition
		 */
		protected function mouseWheel_turn(event : MouseEvent) : void
		{
			var xMouse:Number = parent.mouseX;
			var yMouse:Number = parent.mouseY;
			
			if ((m_target &&(xMouse >= x && xMouse <= x + outerWidth) && 
				(yMouse >= y && yMouse <= y + outerHeight)) ||
				((xMouse >= m_mouseWheelHitAreaX && 
				xMouse <= m_mouseWheelHitAreaX + m_mouseWheelHitAreaWidth) && 
				(yMouse >= m_mouseWheelHitAreaY && 
				yMouse <= m_mouseWheelHitAreaY + m_mouseWheelHitAreaHeight)))
			{
				var position:Number = 
					scrollPosition - lineScrollSize * event.delta;
				updateScrollPosition(position, true);
				dispatchEvent(new DisplayEvent(Event.CHANGE));
			}
		}
	}
}