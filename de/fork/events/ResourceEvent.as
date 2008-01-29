package de.fork.events
{ 
	import de.fork.external.HTTPStatus;
	
	import flash.events.Event;
	
	public class ResourceEvent extends CommandEvent
	{		
		/***************************************************************************
		*							public properties							   *
		***************************************************************************/
		public static const PROGRESS : String = 'resourceProgress';
		
		public static const ERROR_TIMEOUT : Number = 1;
		public static const ERROR_HTTP : Number = 2;
		public static const ERROR_UNKNOWN : Number = 3;
		public static const ERROR_NO_ERROR : Number = 4; //for the sake of completeness
		public static const USER_CANCELLED : Number = 5;
			
		public var httpStatus : HTTPStatus;
		public var reason : Number;
		
		
		/***************************************************************************
		*							public methods								   *
		***************************************************************************/
		public function ResourceEvent(type:String, didSucceed:Boolean = false, 
			reason:Number = -1, status:HTTPStatus = null)
		{
			super(type);
			if (type == COMPLETE && !didSucceed && reason == -1)
			{
				trace("ResourceEvent with negative success called " + 
					"without specifying a reason!");
			}
			success = didSucceed;
			httpStatus = status;
		}
		
		public override function clone() : Event
		{
			return new ResourceEvent(type, success, reason, httpStatus.clone());
		}
	}
}