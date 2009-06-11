package org.alivepdf.events
{
	import flash.events.Event;
	import org.alivepdf.pages.Page;

	public final class PagingEvent extends Event
	{
				
		public var page:int;
		
		public static const ADDED:String = "paging";
		
		public function PagingEvent ( type:String, page:int )
		
		{
			
			super(type, false, false);
			
			this.page = page;
			
		}
		
	}
}