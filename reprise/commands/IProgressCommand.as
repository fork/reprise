package de.fork.commands
{ 
	import de.fork.commands.IAsynchronousCommand;
	
	public interface IProgressCommand extends IAsynchronousCommand
	{
		function getProgress() : Number;
	}
}