package de.fork.controls
{
	import de.fork.controls.Label;
	import de.fork.controls.LabelButton;
	import de.fork.events.MouseEvent;
	import de.fork.controls.IDataInput;
	import de.fork.data.validators.IDataValidator;
	
	/**
	 * @author marco
	 */
	class Checkbox extends LabelButton implements IDataInput
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "Checkbox";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_required : Boolean;
		protected var m_validator : IDataValidator;
	
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function Checkbox()
		{
		}
		public function get checked () : Boolean
		{
			return selected;	
		}
		
		public function getLabelDisplay() : Label
		{
			return m_labelDisplay;
		}
		
			
		public function getValue() : Object
		{
			return {checked:selected};
		}
		
		public function isValid() : Boolean
		{
			if(m_required && !selected)
			{
				return false;
			}
			return true;
		}
		
		public function setRequired(required : Boolean) : void
		{
			m_required = required;
		}
	
		public function required() : Boolean
		{
			return m_required;
		}
	
		public function setValidator(validator : IDataValidator) : void
		{
			m_validator = validator;
		}
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function initialize () : void
		{
			super.initialize();
			isToggleButton = true;
			m_labelDisplay.html = true;
		}
		
		protected function buttonDisplay_click(event:MouseEvent) : void
		{
			super.buttonDisplay_click(event);
			if(selected)
			{
				selected = false;	
			}
			else
			{
				selected = true;	
			}	
		}
		
		public function validator() : IDataValidator
		{
			return m_validator;	
		}
	}
}