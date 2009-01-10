package org.alivepdf.events
{
	
	import flash.events.Event;

	public final class ProcessingEvent extends Event
	
	{
		
		public var duration:Number;
		
		public static const COMPLETE:String = "complete";
		public static const PAGE_TREE:String = "pageTree";
		public static const RESOURCES:String = "resources";
		public static const STARTED:String = "started";
		
		public function ProcessingEvent ( type:String, duration:Number=0 )
		
		{
		
			super(type, false, false);
			
			this.duration = duration;
		
		}
		
	}
}