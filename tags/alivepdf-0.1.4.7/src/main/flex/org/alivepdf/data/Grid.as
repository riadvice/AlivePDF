package org.alivepdf.data
{
	import flash.utils.ByteArray;
	import org.alivepdf.colors.IColor;
	
	public class Grid
	{
		private var _data:Array;
		private var _width:int;
		private var _height:int;
		private var _cellsWidth:Array;
		private var _borderColor:IColor;
		private var _joints:String;
		private var _backgroundColor:IColor;
		private var _headerColor:IColor;
		private var _cellColor:IColor;
		private var _alternateRowColor:Boolean;
		
		public function Grid( data:Array, width:int, height:int, cellsWidth:Array, headerColor:IColor, backgroundColor:IColor, cellColor:IColor, alternateRowColor:Boolean, borderColor:IColor, joints:String="0 j")
		{
			_data = data;
			_width = width;
			_height = height;
			_cellsWidth = cellsWidth;
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
		
		public function get width ():int
		{
			return _width;	
		}
		
		public function get height ():int
		{
			return _height;	
		}
		
		public function get borderColor ():IColor
		{
			return _borderColor;	
		}
		
		public function get joints ():String
		{
			return _joints;	
		}
		
		public function get backgroundColor ():IColor
		{
			return _backgroundColor;	
		}
		
		public function get headerColor ():IColor
		{
			return _headerColor;	
		}
		
		public function get cellColor ():IColor
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