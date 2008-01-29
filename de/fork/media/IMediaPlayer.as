package de.fork.media
{ 
	import flash.events.IEventDispatcher;
	
	public interface IMediaPlayer extends IEventDispatcher
	{
		function load(source : String) : void;
		function play(offset : Number) : void;
		function pause() : void;
		function resume() : void;
		function stop() : void;
	
		function isPlaying() : Boolean;
	
		function setVolume(volume : Number) : void;
		function getVolume() : Number;
	
		function getBytesLoaded() : Number;
		function getBytesTotal() : Number;
	
		function getDuration() : Number;
		function getDurationLoaded() : Number;
		function getPosition() : Number;
		function getLoadingTimeLeft() : Number;
	
		function getPercentLoaded() : Number;
	
		function destroy() : void;
	}
	
	
	
	
}