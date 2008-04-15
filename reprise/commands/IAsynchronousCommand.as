package reprise.commands
{ 
	import reprise.commands.ICommand;
	
	public interface IAsynchronousCommand extends ICommand
	{
		function cancel() : void;
		function isCancelled() : Boolean;
	}
}