package de.fork.commands
{	
	import flash.events.IEventDispatcher; 
	
	public interface ICommand extends IEventDispatcher
	{
		function execute(...rest) : void;
		function setId(value : Number) : void;
		function id() : Number;
		function setPriority(value : Number) : void;
		function priority() : Number;
	}
}