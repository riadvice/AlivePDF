package org.alivepdf.events
{
	import flash.events.Event;

	public final class PagingEvent extends Event
	{
		public var page:int;
		
		public static const ADDED:String = "paging";
		
		public function PagingEvent ( type:String, page:int )	
		{
			super(type, false, false);	
			this.page = page;
		}
		
		public override function clone():Event
		{
			return new PagingEvent ( type, page );	
		}
	}
}