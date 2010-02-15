package org.alivepdf.links
{
	public final class HTTPLink implements ILink
	{
		public var link:String;
		
		public function HTTPLink(link:String)
		{
			this.link = link;
		}
		
		public function toString ():String 
		{	
			return "[HTTPLink link="+link+"]";	
		}
	}
}