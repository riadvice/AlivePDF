package org.alivepdf.codabar
{
	import flash.utils.Dictionary;

	public class CodaBar
	{	
		protected var _barChar:Dictionary = new Dictionary (true);
		protected var _x:Number;
		protected var _y:Number;
		protected var _code:String;
		protected var _start:String;
		protected var _end:String;
		protected var _baseWidth:Number;
		protected var _height:Number;
		
		public function CodaBar( x:int, y:int, code:String, start:String='A', end:String='A', baseWidth:Number=0.35, height:Number=16 )
		{
			_x = x;
			_y = y;
			_code = code;
			_start = start;
			_end = end;
			_baseWidth = baseWidth;
			_height = height;
			
			barChar['0'] = new Array (6.5, 10.4, 6.5, 10.4, 6.5, 24.3, 17.9);
			barChar['1'] = new Array (6.5, 10.4, 6.5, 10.4, 17.9, 24.3, 6.5);
			barChar['2'] = new Array (6.5, 10.0, 6.5, 24.4, 6.5, 10.0, 18.6);
			barChar['3'] = new Array (17.9, 24.3, 6.5, 10.4, 6.5, 10.4, 6.5);
			barChar['4'] = new Array (6.5, 10.4, 17.9, 10.4, 6.5, 24.3, 6.5);
			barChar['5'] = new Array (17.9, 10.4, 6.5, 10.4, 6.5, 24.3, 6.5);
			barChar['6'] = new Array (6.5, 24.3, 6.5, 10.4, 6.5, 10.4, 17.9);
			barChar['7'] = new Array (6.5, 24.3, 6.5, 10.4, 17.9, 10.4, 6.5);
			barChar['8'] = new Array (6.5, 24.3, 17.9, 10.4, 6.5, 10.4, 6.5);
			barChar['9'] = new Array (18.6, 10.0, 6.5, 24.4, 6.5, 10.0, 6.5);
			barChar['$'] = new Array (6.5, 10.0, 18.6, 24.4, 6.5, 10.0, 6.5);
			barChar['-'] = new Array (6.5, 10.0, 6.5, 24.4, 18.6, 10.0, 6.5);
			barChar[':'] = new Array (16.7, 9.3, 6.5, 9.3, 16.7, 9.3, 14.7);
			barChar['/'] = new Array (14.7, 9.3, 16.7, 9.3, 6.5, 9.3, 16.7);
			barChar['.'] = new Array (13.6, 10.1, 14.9, 10.1, 17.2, 10.1, 6.5);
			barChar['+'] = new Array (6.5, 10.1, 17.2, 10.1, 14.9, 10.1, 13.6);
			barChar['A'] = new Array (6.5, 8.0, 19.6, 19.4, 6.5, 16.1, 6.5);
			barChar['T'] = new Array (6.5, 8.0, 19.6, 19.4, 6.5, 16.1, 6.5);
			barChar['B'] = new Array (6.5, 16.1, 6.5, 19.4, 6.5, 8.0, 19.6);
			barChar['N'] = new Array (6.5, 16.1, 6.5, 19.4, 6.5, 8.0, 19.6);
			barChar['C'] = new Array (6.5, 8.0, 6.5, 19.4, 6.5, 16.1, 19.6);
			barChar['*'] = new Array (6.5, 8.0, 6.5, 19.4, 6.5, 16.1, 19.6);
			barChar['D'] = new Array (6.5, 8.0, 6.5, 19.4, 19.6, 16.1, 6.5);
			barChar['E'] = new Array (6.5, 8.0, 6.5, 19.4, 19.6, 16.1, 6.5);
		}

		public function get barChar():Dictionary
		{
			return _barChar;
		}

		public function set barChar(value:Dictionary):void
		{
			_barChar = value;
		}

		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			_height = value;
		}

		public function get baseWidth():Number
		{
			return _baseWidth;
		}

		public function set baseWidth(value:Number):void
		{
			_baseWidth = value;
		}

		public function get end():String
		{
			return _end;
		}

		public function set end(value:String):void
		{
			_end = value;
		}

		public function get start():String
		{
			return _start;
		}

		public function set start(value:String):void
		{
			_start = value;
		}

		public function get code():String
		{
			return _code;
		}

		public function set code(value:String):void
		{
			_code = value;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			_y = value;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			_x = value;
		}
	}
}