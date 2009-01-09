package org.alivepdf.colors

{
	
	public final class CMYKColor implements Color
	
	{
		
		public var cyan:Number;
		public var magenta:Number;
		public var yellow:Number;
		public var black:Number;
		
		public function CMYKColor ( pCyan:Number, pMagenta:Number, pYellow:Number, pBlack:Number )
		
		{
			
			cyan = pCyan;
			magenta = pMagenta;
			yellow = pYellow;
			black = pBlack;
			
		}
		
	}
	
}