package reprise.commands
{ 
	import reprise.commands.IAsynchronousCommand;
	
	public interface IProgressCommand extends IAsynchronousCommand
	{
		function getProgress() : Number;
	}
}