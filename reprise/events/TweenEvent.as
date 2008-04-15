package reprise.events
{
	import flash.events.Event;
	 
	public class TweenEvent extends Event
	{
		public static const START : String = 'start';
		public static const TICK : String = 'tick';
		
		public var success : Boolean;	
		
	
		public function TweenEvent(type : String, didSucceed:Boolean)
		{
			super(type);
			success = didSucceed;
		}	
	}
}