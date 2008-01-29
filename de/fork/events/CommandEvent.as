package de.fork.events { 
	import de.fork.commands.ICommand;	
	
	import flash.events.Event;
	
	public class CommandEvent extends Event
	{
		public var success : Boolean;
			
		public function CommandEvent(type:String, didSucceed:Boolean = false)
		{
			super(type);
			success = didSucceed;
		}
	}
}