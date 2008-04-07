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
			m_labelDisplay.setLabel(label);
			invalidate();
		}
		
		/**
		 * sets whether the label should be displayed with html formatting or not
		 */
		public function set html(value:Boolean) : void
		{
			m_labelDisplay.html = value;
			invalidate();
		}
		/**
		 * sets whether the label should be displayed with html formatting or not
		 */
		public function get html() : Boolean
		{
			return m_labelDisplay.html;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function createChildren() : void
		{
			m_labelDisplay = Label(addComponent('label', null, Label));
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