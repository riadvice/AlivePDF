package org.alivepdf.layout
{
	public final class Mode
	{
		/**
		 * No resizing behavior involved.
		 */		
		public static const NONE:String = "None";
		/**
		 * Resizes the image so that it fits the page dimensions.
		 * This will never stretch your image.
		 */		
		public static const FIT_TO_PAGE:String = "FitToPage";
		/**
		 * Resizes the page to the image dimensions. White margins will be preserved.
		 * Use PDF.setMargins() to modify them.
		 */		
		public static const RESIZE_PAGE:String = "ResizePage";		
	}
}