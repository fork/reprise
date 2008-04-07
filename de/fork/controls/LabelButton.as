package de.fork.controls
{ 
	/**
	 * @author Marco
	 */
	public class LabelButton extends AbstractButton
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "LabelButton";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var m_labelDisplay : Label;
		protected var m_label : String = '';
	
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function LabelButton()
		{
			
		}
		
		/**
		 * sets the labelto display
		 */
		public function setLabel(label:String) : void
		{
			if (!m_labelDisplay)
			{
				m_label = label;
				return;
			}
			m_labelDisplay.setLabel(label);
			invalidate();
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function createChildren() : void
		{
			m_labelDisplay = Label(addComponent('label', null, Label));
			m_labelDisplay.label = m_label;
			m_label = '';
		}
		protected override function createButtonDisplay() : void
		{
			m_buttonDisplay = this;
		}
		/**
		 * calculates the horizontal space taken by this elements' content
		 */
		protected override function calculateContentWidth() : Number
		{
			if (m_currentStyles.display == 'inline')
			{
				return m_labelDisplay.width;
			}
			return super.calculateContentWidth();
		}
	}
}