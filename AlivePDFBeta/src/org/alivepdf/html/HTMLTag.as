package org.alivepdf.html
{
	public final class HTMLTag
	{
		public var tag:String;
		public var attr:String;
		public var value:String;
		
		public function HTMLTag( tag:String, attr:String, value:String )
		{
			this.tag = tag;	
			this.attr = attr;	
			this.value = value;	
		}
	}
}