package org.alivepdf.drawing

{
	
	public final class DashedLine 
	
	{
		
		private var _aPattern:Array;
		private var _sPattern:String;
		
		public function DashedLine ( pDashedPattern:Array )
		
		{
			
			_aPattern = pDashedPattern;
			_sPattern = "[";
			
			var lng:int = _aPattern.length;
			
			for (var i:int = 0; i< lng; i++) (i < lng-1) ? _sPattern += _aPattern[i] + " " : _sPattern += _aPattern[i];
			
			_sPattern += "] 0 d"
			
		}
		
		public function get pattern ():String 
		
		{
			
			return _sPattern;
			
		}
		
	}
	
}