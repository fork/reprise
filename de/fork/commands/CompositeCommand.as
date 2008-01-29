package de.fork.commands { 
	import de.fork.data.collection.IndexedArray;
	import de.fork.events.CommandEvent;
	
	import flash.events.Event;
	
	public class CompositeCommand
		extends AbstractAsynchronousCommand
	{
		
		/***************************************************************************
		*							protected properties							   *
		***************************************************************************/
		protected static var DEFAULT_MAX_PARALLEL_EXECUTION_COUNT : Number = 1;
		protected static var g_id : Number = 0;
		
		protected var m_maxParallelExecutionCount : Number;
		protected	var m_pendingCommands : IndexedArray;
		protected	var m_finishedCommands : IndexedArray;
		protected	var m_currentCommands : IndexedArray;
		protected	var m_isExecutingAsynchronously	: Boolean = false;
		protected	var m_abortOnFailure:Boolean = true;
		protected var m_failedCommands:Array;
		
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function CompositeCommand()
		{
			m_id = g_id++;
			m_maxParallelExecutionCount = DEFAULT_MAX_PARALLEL_EXECUTION_COUNT;
			clear();
		}
		
		public override function execute(...args):void
		{
			if (m_isExecuting)
			{
				return;
			}
			super.execute();
			m_isExecutingAsynchronously = containsAsynchronousCommands();
			executeNext();
		}
		
		public function addCommand(cmd:ICommand):void
		{
			m_pendingCommands.push(cmd);
		}
		
		public function removeCommand(cmd:ICommand):void
		{
			if (m_currentCommands.objectExists(cmd))
			{
				return;
			}
			m_pendingCommands.remove(cmd);
		}
		
	//	public function commandWithIndex(n:Number):ICommand
	//	{
	//		return ICommand(m_commands[n]);
	//	}
		
		public function abortOnFailure():Boolean
		{
			return m_abortOnFailure;
		}
	
		public function setAbortOnFailure(val:Boolean):void
		{
			m_abortOnFailure = val;
		}
		
		public function setMaxParallelExecutionCount(value : Number) : void
		{
			m_maxParallelExecutionCount = value;
			if (m_isExecuting)
			{
				while (m_currentCommands.length < m_maxParallelExecutionCount)
				{
					executeNext();
				}
			}
		}
		
		public function clear():void
		{
			m_pendingCommands = new IndexedArray();
			m_finishedCommands = new IndexedArray();
			m_currentCommands = new IndexedArray();
			m_failedCommands = [];
		}
		
		public override function cancel() : void
		{
			var i : Number = m_currentCommands.length;
			while (i--)
			{
				if (m_currentCommands[i] is IAsynchronousCommand)
				{
				var currentCommand : IAsynchronousCommand = 
					IAsynchronousCommand(m_currentCommands[i]);
				unregisterListenersForAsynchronousCommand(currentCommand);
				currentCommand.cancel();
				}
			}
			super.cancel();
		}
		
		
		
		/***************************************************************************
		*							protected methods								   *
		***************************************************************************/
		protected function command_complete(e:CommandEvent):void
		{
			var completedCommand:IAsynchronousCommand = 
				IAsynchronousCommand(e.target);
			unregisterListenersForAsynchronousCommand(completedCommand);
			
			if (!e.success)
			{
				if (m_abortOnFailure)
				{
					notifyComplete(false);
					return;
				}
				m_failedCommands.push(e.target);
			}
			m_currentCommands.remove(e.target);
			m_finishedCommands.push(e.target);
			executeNext();
		}
		
		protected function executeNext() : void
		{
			while (m_currentCommands.length < m_maxParallelExecutionCount)
			{
				if (m_pendingCommands.length == 0)
				{
					if (m_isExecutingAsynchronously && 
						m_currentCommands.length == 0)
					{
						notifyComplete(m_failedCommands.length < 1);
					}
					return;
				}
				var currentCommand : ICommand = ICommand(m_pendingCommands.shift());
				if (currentCommand is IAsynchronousCommand)
				{
					if (IAsynchronousCommand(currentCommand).isCancelled())
					{
						m_finishedCommands.push(currentCommand);
						executeNext();
						return;
					}
					registerListenersForAsynchronousCommand(
						IAsynchronousCommand(currentCommand));			
					m_currentCommands.push(currentCommand);
					currentCommand.execute();
				}
				else
				{
					currentCommand.execute();
					m_finishedCommands.push(currentCommand);
					executeNext();
				}
			}
		}
		
		protected function registerListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			cmd.addEventListener(Event.COMPLETE, 
				command_complete);
		}
		
		protected function unregisterListenersForAsynchronousCommand(
			cmd:IAsynchronousCommand):void
		{
			cmd.removeEventListener(Event.COMPLETE, 
				command_complete);
		}
		
		protected function containsAsynchronousCommands():Boolean
		{
			var i:Number = m_pendingCommands.length;
			while (i--)
			{
				if (m_pendingCommands[i] is IAsynchronousCommand)
				{
					return true;
				}
			}
			i = m_finishedCommands.length;
			while (i--)
			{
				if (m_finishedCommands[i] is IAsynchronousCommand)
				{
					return true;
				}
			}
			return false;
		}
	}
}