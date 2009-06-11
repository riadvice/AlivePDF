package org.alivepdf.encoding
{
	public class IntBlock
	{
		public var data:int;
		public var next:IntBlock;
		public var down:IntBlock;
		
		public function IntBlock(dt:int, nx:IntBlock, dn:IntBlock)
		{
			data = dt;
			next = nx;
			down = dn;
		}
		
		public static function create8_8(arr:Array):IntBlock
		{
			if(arr.length != 64) throw new Error("Need an 8*8 array!");

			var i:int = arr.length;
			var item:IntBlock = null;
			var c7:IntBlock = item = new IntBlock(arr[--i], item, null);
			var c6:IntBlock = item = new IntBlock(arr[--i], item, null);
			var c5:IntBlock = item = new IntBlock(arr[--i], item, null);
			var c4:IntBlock = item = new IntBlock(arr[--i], item, null);
			var c3:IntBlock = item = new IntBlock(arr[--i], item, null);
			var c2:IntBlock = item = new IntBlock(arr[--i], item, null);
			var c1:IntBlock = item = new IntBlock(arr[--i], item, null);
			var c0:IntBlock = item = new IntBlock(arr[--i], item, null);
			while(i != 0) {
				c7 = item = new IntBlock(arr[--i], item, c7);
				c6 = item = new IntBlock(arr[--i], item, c6);
				c5 = item = new IntBlock(arr[--i], item, c5);
				c4 = item = new IntBlock(arr[--i], item, c4);
				c3 = item = new IntBlock(arr[--i], item, c3);
				c2 = item = new IntBlock(arr[--i], item, c2);
				c1 = item = new IntBlock(arr[--i], item, c1);
				c0 = item = new IntBlock(arr[--i], item, c0);
			}
			return item;
		}
	}
}
