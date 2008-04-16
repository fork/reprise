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

package reprise.ui.renderers { 
	import reprise.commands.FrameCommandExecutor;
	import reprise.utils.Delegate;
	
	
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