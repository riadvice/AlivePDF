package org.alivepdf.data
{
	import flash.utils.ByteArray;
	
	import org.alivepdf.colors.Color;
	
	public class Grid
	{
		private var _data:Array;
		private var _width:Number;
		private var _height:Number;
		private var _x:int;
		private var _y:int;
		private var _columns:Array;
		private var _borderColor:Color;
		private var _borderAlpha:Number;
		private var _joints:String;
		private var _backgroundColor:Color;
		private var _headerColor:Color;
		private var _cellColor:Color;
		private var _alternateRowColor:Boolean;
		
		public function Grid( data:Array, width:Number, height:Number, headerColor:Color, backgroundColor:Color, cellColor:Color, alternateRowColor:Boolean, borderColor:Color, borderAlpha:Number=1,joints:String="0 j")
		{
			_data = data;
			_width = width;
			_height = height;
			_borderColor = borderColor;
			_borderAlpha = borderAlpha;
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
		
		public function get columns ():Array
		{
			return _columns;
		}
		
		public function set columns ( columns:Array ):void
		{
			_columns = columns;
		}
		
		public function get width ():Number
		{
			return _width;	
		}
		
		public function get height ():Number
		{
			return _height;	
		}
		
		public function get x ():int
		{
			return _x;	
		}
		
		public function get y ():int
		{
			return _y;	
		}
		
		public function set x ( x:int ):void
		{
			_x = x;	
		}
		
		public function set y ( y:int ):void
		{
			_y = y;
		}
		
		public function get borderColor ():Color
		{
			return _borderColor;	
		}
		
		public function set borderColor ( color:Color ):void
		{
			_borderColor = color;	
		}
		
		public function get borderAlpha ():Number
		{
			return _borderAlpha;	
		}
		
		public function set borderAlpha ( alpha:Number ):void
		{
			_borderAlpha = alpha;	
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
		
		public function toString ():String 
        {
            return "[Grid cells="+_data.length+" alternateRowColor="+_alternateRowColor+" x="+x+" y="+y+"]";    
        } 
	}
}