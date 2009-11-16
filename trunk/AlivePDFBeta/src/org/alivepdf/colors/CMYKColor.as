package org.alivepdf.colors
{
	public final class CMYKColor implements IColor
	{
		public var cyan:Number;
		public var magenta:Number;
		public var yellow:Number;
		public var black:Number;
		
		public function CMYKColor ( cyan:Number, magenta:Number, yellow:Number, black:Number )	
		{
			this.cyan = cyan;
			this.magenta = magenta;
			this.yellow = yellow;
			this.black = black;	
		}
	}
}