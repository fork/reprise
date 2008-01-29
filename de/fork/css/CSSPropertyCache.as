package de.fork.css { 
	/**
	 * @author Till Schneidereit
	 */
	public class CSSPropertyCache 
	{
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var g_propertyCache : Object = {};
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public static function propertyForKeyValue(
			key:String, value:String) : Object
		{
			var prop:Object = g_propertyCache[key+"="+value];
	//		if (!prop)
	//		{
	//			trace("no prop found for "+key+"="+value);
	//		}
			return g_propertyCache[key+"="+value];
		}
		public static function setPropertyForKeyValue(
			key:String, value:String, property:Object) : void
		{
			g_propertyCache[key+"="+value] = property;
		}
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function CSSPropertyCache()
		{
			
		}
		
	}
}