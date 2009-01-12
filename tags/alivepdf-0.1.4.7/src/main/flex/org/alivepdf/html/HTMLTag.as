package org.alivepdf.html
{
	public final class HTMLTag
	{
		public var tag:String;
		public var attr:XMLList;
		public var value:String;
		
		public function HTMLTag( tag:String, attributes:XMLList, value:String )
		{
			this.tag = tag;
			this.attr = attributes;
			this.value = value;
		}

	}
}