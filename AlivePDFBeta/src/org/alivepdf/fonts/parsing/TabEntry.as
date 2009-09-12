package org.alivepdf.fonts.parsing
{
	public final class TabEntry
	{
		public var checksum:Number;
		public var offset:Number;
		public var length:Number;
		public var tag:Array;
		
		public function TabEntry()
		{	
			tag = new Array(4);	
		}
	}
}