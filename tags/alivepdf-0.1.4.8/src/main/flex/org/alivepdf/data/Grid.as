package org.alivepdf.data
{
	import flash.utils.ByteArray;
	
	import org.alivepdf.colors.Color;
	
	public class Grid
	{
		private var _data:Array;
		private var _width:int;
		private var _aligns:Array;
		private var _height:int;
		private var _cellsWidth:Array;
		private var _borderColor:Color;
		private var _joints:String;
		private var _backgroundColor:Color;
		private var _headerColor:Color;
		private var _cellColor:Color;
		private var _alternateRowColor:Boolean;
		
		public function Grid( data:Array, width:int, height:int, cellsWidth:Array, aligns:Array, headerColor:Color, backgroundColor:Color, cellColor:Color, alternateRowColor:Boolean, borderColor:Color, joints:String="0 j")
		{
			_data = data;
			_width = width;
			_height = height;
			_cellsWidth = cellsWidth;
			_aligns = aligns;
			_borderColor = borderColor;
			_joints = joints;
			_backgroundColor = backgroundColor;
			_headerColor = headerColor;
			_cellColor = cellColor;
			_alternateRowColor = alternateRowColor;	
		}
		
		public function export ():ByteArray
		{
			return new ByteArray();	
		}
		
		public function get cellsWidth ():Array
		{
			return _cellsWidth;
		}
		
		public function get aligns ():Array
		{
			return _aligns;
		}
		
		public function get width ():int
		{
			return _width;	
		}
		
		public function get height ():int
		{
			return _height;	
		}
		
		public function get borderColor ():Color
		{
			return _borderColor;	
		}
		
		public function get joints ():String
		{
			return _joints;	
		}
		
		public function get backgroundColor ():Color
		{
			return _backgroundColor;	
		}
		
		public function get headerColor ():Color
		{
			return _headerColor;	
		}
		
		public function get cellColor ():Color
		{
			return _cellColor;	
		}
		
		public function get alternateRowColor ():Boolean
		{	
			return _alternateRowColor;	
		}
		
		public function get dataProvider ():Array
		{
			return _data;	
		}
	}
}