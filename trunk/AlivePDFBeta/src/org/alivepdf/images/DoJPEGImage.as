package org.alivepdf.images
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public final class DoJPEGImage extends JPEGImage
	{
		private var bitmap:BitmapData;
		
		public function DoJPEGImage( buffer:BitmapData, imageStream:ByteArray, id:int)
		{
			bitmap = buffer;
			super(imageStream, ColorSpace.DEVICE_RGB, id);
		}
		
		protected override function parse():void
		{
			width = bitmap.width;
			height = bitmap.height;
		}
	}
}