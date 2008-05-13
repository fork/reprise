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

package reprise.css.transitions
{
	public class TransitionVOFactory
	{
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_propertyHandlerClasses : Object = {};
		
	
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function TransitionVOFactory()
		{
		}
		
		public static function registerProperty(
			name : String, transitionClass : Class) : void
		{
			g_propertyHandlerClasses[name] = transitionClass;
		}
		
		public static function transitionForPropertyName(
			name : String) : PropertyTransitionVO
		{
			var transitionClass : Class = 
				g_propertyHandlerClasses [name] || NumericTransitionVO;
			return PropertyTransitionVO(new transitionClass());
		}
	}
}