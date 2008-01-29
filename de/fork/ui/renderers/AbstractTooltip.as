package de.fork.ui.renderers { 
	import de.fork.controls.Label;
	import de.fork.core.ccInternal;
	import de.fork.events.DisplayEvent;
	import de.fork.ui.UIObject;
	
	import flash.geom.Point;
	
	use namespace ccInternal;
	
	public class AbstractTooltip extends Label
	{
			
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "AbstractTooltip";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_target : UIObject;
		protected var m_dataSupplyTarget : Object;
			
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/	
		public function AbstractTooltip()
		{
			m_elementType = className;
		}
	
		
		public function setData(data : Object) : void
		{
			m_tooltipData = data;
			setLabel(String(data));
		}
		
		public function data() : Object
		{
			return m_tooltipData;
		}
		
		public function updatePosition() : void
		{
			setPosition(m_target.stage.mouseX, m_target.stage.mouseY);
		}
		
		public override function setPosition(x : Number, y : Number) : void
		{
			var newPos : Point = new Point(x, y);
			newPos = parent.localToGlobal(newPos);
			newPos.y = Math.max(-m_marginTop, newPos.y + m_marginTop);
			newPos.y = Math.min(stage.stageHeight - outerHeight - m_marginTop, newPos.y);
			newPos.x = Math.max(-m_marginLeft, newPos.x + m_marginLeft);
			newPos.x = Math.min(stage.stageWidth - outerWidth - m_marginLeft, newPos.x);
			newPos = parent.globalToLocal(newPos);
			left = newPos.x;
			top = newPos.y;
		}
		
		public function setTarget(target : UIObject) : void
		{
			if (m_target != null)
			{
				removeEventListenersFromTargets();
			}
			
			m_target = target;
			addEventListenersToTargets();
		}
		
		public function target() : Object
		{
			return m_target;
		}
		
		public override function remove() : void
		{
			removeEventListenersFromTargets();
			super.remove();
		}
		
		public function setDataSupplyTarget(target:Object) : void
		{
			m_dataSupplyTarget = target;
		}
		
		public function dataSupplyTarget() : Object
		{
			return m_dataSupplyTarget;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initDefaultStyles() : void
		{
			super.initDefaultStyles();
			m_instanceStyles.position = 'absolute';
			m_elementDefaultStyles.left = 0;
			m_elementDefaultStyles.top = 0;
		}
		
		protected function target_remove(event : DisplayEvent) : void
		{
			dispatchEvent(new DisplayEvent(DisplayEvent.REMOVE));
		}
		
		protected function target_visibleChanged(e : DisplayEvent) : void
		{
			if (e.target.getVisibility())
				return;
			dispatchEvent(new DisplayEvent(DisplayEvent.REMOVE));
		}
		
		protected function target_tooltipDataChanged(e : DisplayEvent) : void
		{
			if (m_dataSupplyTarget.tooltipData() == null)
			{
				dispatchEvent(new DisplayEvent(DisplayEvent.REMOVE));
				return;
			}
			
			if (m_dataSupplyTarget.tooltipData() != m_tooltipData)
			{
				setData(m_dataSupplyTarget.tooltipData());
			}
		}
		
		protected function removeEventListenersFromTargets() : void
		{
			var parent : Object = m_target;
			while (true && parent != null)
			{
				parent.removeEventListener(this);
				if (parent == m_dataSupplyTarget)
				{
					break;
				}
				parent = parent['m_parentElement'];
			}
		}
		
		protected function addEventListenersToTargets() : void
		{
			var parent : Object = m_target;
			while (true && parent != null)
			{
				parent.addEventListener(DisplayEvent.REMOVE,
				 target_remove);
				parent.addEventListener(DisplayEvent.VISIBLE_CHANGED,
				 target_visibleChanged);
				if (parent == m_dataSupplyTarget)
				{
					break;
				}
				parent = parent['m_parentElement'];			
			}
			m_dataSupplyTarget.addEventListener(
				DisplayEvent.TOOLTIPDATA_CHANGED, target_tooltipDataChanged);
		}
	}
}