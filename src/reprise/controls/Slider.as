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

package reprise.controls
{
	
	import reprise.ui.UIComponent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	
	public class Slider extends UIComponent
	{
		
		//*****************************************************************************************
		//*                                  Protected Properties                                 *
		//*****************************************************************************************
		protected var m_thumb:UIComponent;
		protected var m_statusBar:UIComponent;
		protected var m_track:UIComponent;
		
		protected var m_minValue:Number = 0;
		protected var m_maxValue:Number = 100;
		protected var m_value:Number = 0;
		protected var m_isContinuous:Boolean = true;
		
		protected var m_dragStartThumbPosition:Number;
		protected var m_dragStartMousePosition:Number;
		protected var m_isDragging:Boolean;
		protected var m_frameListenerActive:Boolean = false;
		
		protected var m_allowsTickMarkValuesOnly:Boolean = false;
		protected var m_numTickMarks:int = 2;
		protected var m_animatesChange:Boolean = false;
		protected var m_animationFriction:Number = .35;
		
		
		
		//*****************************************************************************************
		//*                                     Public Methods                                    *
		//*****************************************************************************************
		public function Slider() {}
		
		
		public function setValue(value:Number):void
		{
			value = Math.min(value, m_maxValue);
			value = Math.max(value, m_minValue);
			m_value = m_allowsTickMarkValuesOnly ? closestTickMarkValueToValue(value) : value;
			if (!m_isDragging)
			{
				applyValue();
			}
		}
		
		public function value():Number
		{
			return m_value;
		}
		
		public function setMaxValue(maxValue:Number):void
		{
			m_maxValue = maxValue;
			setValue(m_value);
		}
		
		public function maxValue():Number
		{
			return m_maxValue;
		}
		
		public function setMinValue(minValue:Number):void
		{
			m_minValue = minValue;
			setValue(m_value);
		}
		
		public function minValue():Number
		{
			return m_minValue;
		}
		
		/** 
		* Sets whether the slider sends its events continuously to its listeners 
		* during mouse tracking.
		*/
		public function setContinuous(bFlag:Boolean):void
		{
			m_isContinuous = bFlag;
		}
		
		public function isContinuous():Boolean
		{
			return m_isContinuous;
		}
		
		public function setAllowsTickMarkValuesOnly(bFlag:Boolean):void
		{
			m_allowsTickMarkValuesOnly = bFlag;
		}
		
		public function allowsTickMarkValuesOnly():Boolean
		{
			return m_allowsTickMarkValuesOnly;
		}
		
		public function setNumberOfTickMarks(num:int):void
		{
			m_numTickMarks = num;
		}
		
		public function numberOfTickMarks():int
		{
			return m_numTickMarks;
		}
		
		public function tickMarkValueAtIndex(index:int):Number
		{
			return (m_maxValue - m_minValue) / (m_numTickMarks - 1) * index;
		}
		
		public function closestTickMarkValueToValue(val:Number):Number
		{
			var diff:Number = (m_maxValue - m_minValue) / (m_numTickMarks - 1);
			var index:int = Math.floor(val / diff);
			if (val % diff > diff / 2) index++;
			return index * diff;
		}
		
		public function setAnimatesChange(bFlag:Boolean):void
		{
			m_animatesChange = bFlag;
		}
		
		protected function animatesChange():Boolean
		{
			return m_animatesChange;
		}
		
		
		
		//*****************************************************************************************
		//*                                   Protected Methods                                   *
		//*****************************************************************************************
		override protected function createChildren():void
		{
			createTrack();
			createStatusBar();
			createThumb();
			addListeners();
		}
		
		override protected function beforeFirstDraw():void
		{
			applyValue();
		}
		
		protected function createTrack():void
		{
			m_track = addComponent('track');
		}
		
		protected function createStatusBar():void
		{
			m_statusBar = addComponent('status_bar');
		}
		
		protected function createThumb():void
		{
			m_thumb = addComponent('thumb');
			m_thumb.setStyle('position', 'absolute');
		}
		
		protected function addListeners():void
		{
			m_thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_click);
			m_track.addEventListener(MouseEvent.MOUSE_DOWN, track_mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		protected function applyValue():void
		{
			var pos:Number = valueToPosition(m_value, m_minValue, m_maxValue);
			if (m_animatesChange && (!m_isDragging || m_allowsTickMarkValuesOnly))
			{
				var diff:Number = (pos - m_thumb.left) * m_animationFriction;
				if (Math.abs(diff) > 0.05)
				{
					pos = m_thumb.left + diff;
					addFrameListener();
				}
				else 
				{
					removeFrameListener();
				}
			}
			m_thumb.left = m_statusBar.width = pos;
		}
		
		protected function valueToPosition(value:Number, dataMin:Number, dataMax:Number):Number
		{
			var pos:Number = (width - m_thumb.width) / 100 * ((value - dataMin) / 
				((dataMax - dataMin) / 100));
			pos = Math.max(0, pos);
			pos = Math.min(width - m_thumb.width, pos);
			return Math.round(pos);
		}
		
		protected function positionToValue(pos:Number):Number
		{
			pos = Math.max(0, pos);
			pos = Math.min(width - m_thumb.width, pos);
			return pos / ((width - m_thumb.width) / 100) * 
				((m_maxValue - m_minValue) / 100) + m_minValue;
		}
		
		protected function applyCurrentDragValue():void
		{
			setValue(positionToValue(m_dragStartThumbPosition + 
				(m_track.mouseX - m_dragStartMousePosition)));
			applyValue();
		}
		
		protected function addFrameListener():void
		{
			if (m_frameListenerActive) return;

			addEventListener(Event.ENTER_FRAME, self_enterFrame);
			m_frameListenerActive = true;
		}
		
		protected function removeFrameListener():void
		{
			if (!m_frameListenerActive) return;
			var animationActive:Boolean = m_thumb.left != valueToPosition(m_value, m_minValue, 
				m_maxValue);
			if (animationActive || m_isDragging) return;
			removeEventListener(Event.ENTER_FRAME, self_enterFrame);
			m_frameListenerActive = false;
		}
		
		
		
		//*****************************************************************************************
		//*                                         Events                                        *
		//*****************************************************************************************
		protected function thumb_click(e:MouseEvent):void
		{
			m_dragStartThumbPosition = m_thumb.left;
			m_dragStartMousePosition = m_track.mouseX;
			m_isDragging = true;
			addFrameListener();
		}
		
		protected function stage_mouseUp(e:MouseEvent):void
		{
			if (!m_isDragging)
			{
				return;
			}
			m_isDragging = false;
			removeFrameListener();
			applyCurrentDragValue();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function track_mouseDown(e:MouseEvent):void
		{
			setValue(positionToValue(mouseX - m_thumb.width / 2));
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function self_enterFrame(e:Event):void
		{
			// if we're not being dragged, there's animation to be done
			if (!m_isDragging)
			{
				applyValue();
				return;
			}
			if (m_isContinuous)
			{
				dispatchEvent(new Event(Event.CHANGE));
			}
			applyCurrentDragValue();
		}
	}
}