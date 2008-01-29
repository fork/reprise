package de.fork.ui.renderers { 
	import de.fork.commands.FrameCommandExecutor;
	import de.fork.utils.Delegate;
	
	
	public class DefaultTooltipRenderer extends AbstractTooltip
	{
			
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static var className : String = "DefaultTooltipRenderer";
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected var fadeIn : Delegate;
		protected var fadeOut : Delegate;
		protected var isFadingIn : Boolean;
		protected var isFadingOut : Boolean;
		protected var isVisible : Boolean;
			
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/	
		public function DefaultTooltipRenderer()
		{
			m_elementType = className;
		}
	
		
		public override function show() : void
		{
			if (isFadingIn || (isVisible && !isFadingOut))
				return;
			setVisibility(true);
			isFadingOut = false;
			isFadingIn = true;
			FrameCommandExecutor.instance().removeCommand(fadeOut);
			FrameCommandExecutor.instance().addCommand(fadeIn);
		}
		
		public override function hide() : void
		{
			if (isFadingOut || (!isVisible && !isFadingIn))
				return;
			isFadingIn = false;
			isFadingOut = true;
			FrameCommandExecutor.instance().removeCommand(fadeIn);
			FrameCommandExecutor.instance().addCommand(fadeOut);
		}
		
		public override function updatePosition() : void
		{
			setPosition(stage.mouseX, stage.mouseY + 18);
		}
	
	
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected override function initialize() : void
		{
			super.initialize();
			fadeIn = new Delegate(this, doShow);
			fadeOut = new Delegate(this, doHide);
			isFadingIn = false;
			isFadingOut = false;
			isVisible = false;
			alpha = 0;
		}
		
		protected function doShow() : void
		{
			alpha += 10;
			if (alpha >= 100)
			{
				FrameCommandExecutor.instance().removeCommand(fadeIn);
				isFadingIn = false;
				isVisible = true;
				show_complete();
			}
		}
		
		protected function doHide() : void
		{
			alpha -= 10;		
			if (alpha <= 0)
			{
				FrameCommandExecutor.instance().removeCommand(fadeOut);
				isFadingOut = false;
				isVisible = false;
				hide_complete();
			}
		}	
	}
}