/**
* This class lets you play animated GIF files in the flash player
* @author Thibault Imbert (bytearray.org)
*/

package org.alivepdf.images.gif.events
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class GIFPlayerEvent extends Event	
	{
		public var rect:Rectangle;	
		public static const COMPLETE:String = "complete";
		
		public function GIFPlayerEvent ( pType:String, pRect:Rectangle )
		{
			super ( pType, false, false );
			
			rect = pRect;	
		}
	}
}