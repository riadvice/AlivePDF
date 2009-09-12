package org.alivepdf.fonts.parsing
{
	public final class MetricInfo
	{
		private var _leftSideBearing:int;
		private var _advanceWidth:int;
		
		public function MetricInfo( advanceWidth:Number, leftSideBearing:Number )
		{
			_advanceWidth = advanceWidth;
			_leftSideBearing = leftSideBearing;	
		}
		
		public function get advanceWidth():Number
		{
			return _advanceWidth;		
		}
		
		public function get leftSideBearing():Number
		{	
			return _leftSideBearing;	
		}
	}
}