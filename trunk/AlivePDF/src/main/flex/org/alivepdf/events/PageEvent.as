package org.alivepdf.events
{
	import flash.events.Event;
	import org.alivepdf.pages.Page;

	public final class PageEvent extends Event
	{
				
		public var page:Page;
		
		public static const ADDED:String = "added";
		
		public function PageEvent ( type:String, page:Page )
		
		{
			
			super(type, false, false);
			
			this.page = page;
			
		}
		
	}
}