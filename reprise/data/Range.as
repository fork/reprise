package de.fork.data
{ 
	public class Range
	{
		
		public var location : int;
		public var length : int;
		
		
		public function Range(loc : int, len : int)
		{
			location = loc;
			length = len;
		}
		
		public function clone() : Range
		{
			return new Range(location, length);
		}
	}
}