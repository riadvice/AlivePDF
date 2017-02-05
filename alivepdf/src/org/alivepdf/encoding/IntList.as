package org.alivepdf.encoding
{
	public final class IntList
	{
		public var data:int;
		public var next:IntList;
		
		public function IntList(dt:int, nx:IntList)
		{
			data = dt;
			next = nx;
		}
		
		public static function create(arr:Array):IntList
		{
			var i:int = arr.length;
			var itm:IntList = new IntList(arr[--i], null);
			while (--i > -1) {
				itm = new IntList(arr[i], itm);
			}
			return itm;
		}
	}
}
