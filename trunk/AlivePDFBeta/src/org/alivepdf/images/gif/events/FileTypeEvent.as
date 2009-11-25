package org.alivepdf.images.gif.events
{	
	import flash.events.Event;
	
	public class FileTypeEvent extends Event 
	{
		public static const INVALID:String = "invalid";
		
		public function FileTypeEvent ( pType:String )	
		{
			super ( pType, false, false );	
		}
		
		public override function clone():Event
		{
			return new FileTypeEvent ( type );	
		}
	}
}