package org.alivepdf.layout
{
	public final class Resize
	{	
		public var mode:String;
		public var position:String;
		
		public function Resize( mode:String, position:String )
		{
			this.mode = mode;
			this.position = position;	
		}
		
		public function toString ():String
		{
			return "[Resize mode="+mode+" position="+position+"]";	
		}	
	}
}