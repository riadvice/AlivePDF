package org.alivepdf.links
{
	public final class Outline
	{
		public var level:int;
		public var pages:int;
		public var text:String;
		public var y:Number;
		public var parent:String;
		public var first:String;
		public var next:String;
		public var prev:String;
		public var last:String;
		public var redMultiplier:Number;
		public var greenMultiplier:Number;
		public var blueMultiplier:Number;
		
		public function Outline( text:String, level:int, pages:int, y:Number, redMultiplier:Number, greenMultiplier:Number, blueMultiplier:Number )
		{
			this.text = text;
			this.level = level;
			this.pages = pages;
			this.y = y;
			this.redMultiplier = redMultiplier;
			this.greenMultiplier = greenMultiplier;
			this.blueMultiplier = blueMultiplier;
		}
	}
}