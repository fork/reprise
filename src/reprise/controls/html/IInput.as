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

package reprise.controls.html
{

	import reprise.commands.IAsynchronousCommand;
	import reprise.data.IValidator;

	
	public interface IInput extends IValidator, IAsynchronousCommand
	{
		function setValidator(validator:IValidator):void;
		function validator():IValidator;
		function setRequired(value : Boolean):void
		function required():Boolean;
		function markAsValid():void;
		function markAsInvalid():void;
		function setName(aName:String):void;
		function setFieldName(aName:String):void;
		function fieldName():String;
		function setData(theData:*):void;
		function data():*;
	}
}