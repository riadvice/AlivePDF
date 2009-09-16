package org.alivepdf.colors
{
	public final class SpotColor implements IColor
	{
		protected static var idRef:int;
		public var i:int;
		public var n:int;
		public var name:String;
		public var color:CMYKColor;
		
		public function SpotColor( name:String, color:CMYKColor )
		{
			i = SpotColor.idRef++;
			this.name = name;
			this.color = color;
		}
	}
}