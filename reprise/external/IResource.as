package de.fork.external
{ 
	import de.fork.commands.IProgressCommand;
	
	
	public interface IResource extends IProgressCommand
	{
		function load( url : String = null) : void;
		function didFinishLoading() : Boolean;	
		function setURL( src : String ) : void;
		function url() : String;
		function content() : *;
		function setTimeout( timeout : Number ) : void;
		function timeout() : Number;
		function setForceReload( bFlag : Boolean ) : void;
		function forceReload() : Boolean;
		function setRetryTimes( times : Number ) : void;
		function retryTimes() : Number;
		function getBytesLoaded() : Number;
		function getBytesTotal() : Number;
	}
}