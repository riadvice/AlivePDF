package org.alivepdf.annotations
{
	public class TextAnnotation extends Annotation
	{
		protected var _open:Boolean;
		
		public function TextAnnotation(type:String, text:String="A text note!", x:int=0, y:int=0, width:int=100, height:int=100, open:Boolean=false)
		{
			super(type, text, x, y, width, height);
			_open = open;
		}
		
		public function get open():Boolean
		{
			return _open;
		}

		public function set open(value:Boolean):void
		{
			_open = value;
		}
	}
}