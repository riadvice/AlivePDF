package org.alivepdf.images.gif.events
{
	import flash.events.Event;;
	
	public class TimeoutEvent extends Event	
	{
		public static const TIME_OUT:String = "timeout";
		
		public function TimeoutEvent ( pType:String )	
		{
			super ( pType, false, false );	
		}
		
		public override function clone():Event
		{
			return new TimeoutEvent ( type );	
		}
	}
}