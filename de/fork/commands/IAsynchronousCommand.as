package de.fork.commands
{ 
	import de.fork.commands.ICommand;
	
	public interface IAsynchronousCommand extends ICommand
	{
		function cancel() : void;
		function isCancelled() : Boolean;
	}
}