package de.fork.commands { 
	import de.fork.events.CommandEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AbstractAsynchronousCommand extends EventDispatcher
		implements IAsynchronousCommand
	{
	
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		public var m_id : Number;
		protected var m_inited : Boolean;
		protected var m_isExecuting : Boolean;
		protected var m_isCancelled : Boolean;
		
		public var m_priority : Number = 0;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function execute(...args) : void
		{
			if (m_isExecuting)
				return;
			m_isExecuting = true;
			m_isCancelled = false;
		}
		
		public function isExecuting() : Boolean
		{
			return m_isExecuting;
		}
		
		public function cancel() : void
		{
			m_isExecuting = false;
			m_isCancelled = true;
			dispatchEvent(new CommandEvent(Event.CANCEL));
		}
		
		public function isCancelled() : Boolean
		{
			return m_isCancelled;
		}
		
		public function setPriority(value : Number) : void
		{
			m_priority = value;
		}
		public function priority() : Number
		{
			return m_priority;
		}
		public function setId(value : Number) : void
		{
			m_id = value;
		}
		public function id() : Number
		{
			return m_id;
		}
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		public function AbstractAsynchronousCommand()
		{
		}
		
		
		protected function notifyComplete(success:Boolean) : void
		{
			m_isExecuting = false;
			dispatchEvent(new CommandEvent(Event.COMPLETE, success));
		}	
	}
}