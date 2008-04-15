package de.fork.i18n
{
	/**
	 * @author till
	 */
	public interface II18NService
	{
		function getStringByKey(key : String) : String;
		function getBoolByKey(key : String) : Boolean;
		function getGenericContentByKey(key : String) : Object;
		function keyExists(key : String) : Boolean;
	}
}