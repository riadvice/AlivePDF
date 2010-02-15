package org.alivepdf.links
{
	import flash.geom.Rectangle;

	public final class InternalLink implements ILink
	{
		public var page:int;
		public var y:Number;
		public var fit:Boolean;
		public var rectangle:Rectangle;
		
		public function InternalLink( page:int=1, y:Number=0, fit:Boolean=false, rectangle:Rectangle=null )
		{
			if ( page == 0 ) 
				throw new Error("Page number must be over 0 and below the total number of pages.");
			this.page = page;
			this.y = y;
			this.fit = fit;
			this.rectangle = rectangle;
		}
		
		public function toString ():String 
		{	
			return "[InternalLink page="+page+" y="+y+" fit="+fit+" rectangle="+rectangle+"]";	
		}
	}
}