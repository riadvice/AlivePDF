package org.alivepdf.annotations
{
	public class Annotation
	{
		protected var _type:String;
		protected var _text:String;
		protected var _x:int;
		protected var _y:int;
		protected var _width:int;
		protected var _height:int;
		
		public function Annotation( type:String, text:String, x:int=0, y:int=0, width:int=100, height:int=100 )
		{
			_type = type;
			_text = text;
			_x = x;
			_y = y;
			_width = width;
			_height = height;
		}

		public function get text():String
		{
			return _text;
		}

		public function get width():int
		{
			return _width;
		}
		
		public function get height():int
		{
			return _height;
		}

		public function get y():int
		{
			return _y;
		}

		public function get x():int
		{
			return _x;
		}

		public function get type():String
		{
			return _type;
		}
	}
}