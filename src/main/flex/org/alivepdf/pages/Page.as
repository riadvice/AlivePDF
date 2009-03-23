package org.alivepdf.pages
{
	import org.alivepdf.events.PagingEvent;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	
	public final class Page
	{
		private var _width:Number;
		private var _height:Number;
		private var _fwPt:Number;
		private var _fhPt:Number;
		private var _wPt:Number;
		private var _hPt:Number;
		private var _fw:Number;
		private var _fh:Number;
		private var _w:Number;
		private var _h:Number;
		private var _rotation:Number;
		private var _page:int;
		private var _pageTransition:String;
		private var _content:String;
		private var _annots:String;
		private var _orientation:String;
		private var _size:Size;
		private var _format:Array;
		private var _k:Number;
		private var _unit:String;
	
		public function Page ( pOrientation:String, unit:String="Mm", size:Object=null, pRotation:Number=0 )
		{	
			_orientation = pOrientation;
			
			_rotation = pRotation;
						
			this._unit = setUnit( unit );

			_size = Size.getSize( size ).clone();
			
			if ( _size != null )
				 _format = _size.dimensions;
				 
			else throw new RangeError ("Incorrect dimensions.");
			
			_fwPt = _format[0];
			_fhPt = _format[1];
						
			_fw = _fwPt/_k;
			_fh = _fhPt/_k;

			if ( this._orientation == Orientation.PORTRAIT )
			{

				wPt = _fwPt;
				hPt = _fhPt;
				w = _fw;
				h = _fh;
				_width = wPt;
				_height = hPt;

			} else if ( this._orientation == Orientation.LANDSCAPE )
			{
					
				wPt = _fhPt;
				hPt = _fwPt;
				w = _fh;
				h = _fw;
				_width = wPt;
				_height = hPt;

			} else throw new RangeError ('Incorrect orientation: ' + pOrientation);
			
			_page = 0;
	
			_annots = new String();
	
			_content = new String();
	
			transitions = new String();
		}
		
		/**
		 * 
		 * @return Page
		 * @example
		 * This example shows how to clone a page :
		 * <div class="listing">
		 * <pre>
		 *
		 * var clonedPage = existingPage.clone();
		 * myPDF.addPage ( clonedPage );
		 * </pre>
		 * </div>
		 */		
		public function clone ( ):Page 
		{
			var page:Page = new Page ( orientation, _unit, size, rotation );
			
			page.content = content;
			page.transitions = transitions;
			
			return page;	
		}
		
		public function get orientation ( ):String 
		{
			return _orientation;	
		}
		
		public function setUnit ( unit:String ):String
		{	
			if ( unit == Unit.POINT ) _k = 1;
			else if ( unit == Unit.MM ) _k = 72/25.4;
			else if ( unit == Unit.CM ) _k = 72/2.54;
			else if ( unit == Unit.INCHES ) _k = 72;
			else throw new RangeError ('Incorrect unit: ' + unit);
			
			return unit;	
		}
	
		public function rotate ( pRotation:Number ):void
		{
	
			if ( pRotation % 90 )
				throw new RangeError ("Rotation must be a multiple of 90");
	
			_rotation = pRotation;
		}
		
		private function paging ( evt:PagingEvent ):void
		{
			_page = evt.page;	
		}
		
		/**
		 * Lets you resize the Page dimensions
		 *  
		 * @param width
		 * @param height
		 * 
		 */		
		public function resize ( width:Number, height:Number ):void 
		{
			width = _fwPt = wPt = width;
			height = _fhPt = hPt = height;	
		}
	
		public function addTransition ( style:String='R', duration:Number=1, dimension:String='H', motionDirection:String='I', transitionDirection:int=0 ):void
		{
			transitions = '/Trans << /Type /Trans /D '+duration+' /S /'+style+' /Dm /'+dimension+' /M /'+motionDirection+' /Di /'+transitionDirection+' >>';
		}
		
		public function set width ( pWidth:Number ):void 
		{
			_format[0] = _width = pWidth;
		}
		
		public function get width ( ):Number 
		{
			return _width;	
		}
		
		public function set height ( pHeight:Number ):void 
		{	
			_format[1] = _height = pHeight;
		}
		
		public function get height ( ):Number 
		{
			return _height;	
		}
		
		public function set wPt ( pwPt:Number ):void 
		{
			_wPt = pwPt;
		}
		
		public function get wPt ( ):Number 
		{
			return _wPt;	
		}
		
		public function set hPt ( phPt:Number ):void 
		{
			_hPt = phPt;
		}
		
		public function get hPt ( ):Number 
		{
			return _hPt;	
		}
		
		public function set w ( pW:Number ):void 
		{
			_w = pW;
		}
		
		public function get w ( ):Number 
		{
			return _w;	
		}
		
		public function set h ( pH:Number ):void 
		{
			_h = pH;
		}
		
		public function get h ( ):Number 
		{
			return _h;	
		}
		
		public function get size ():Size
		{
			return _size;	
		}
		
		public function set size ( size:Size ):void 
		{
			_size = size;	
		}
		
		public function set rotation ( pRotation:Number ):void 
		{
			_rotation = pRotation;
		}
		
		public function get rotation ( ):Number 
		{
			return _rotation;	
		}
		
		public function get page ( ):int 
		{
			return _page;	
		}
		
		public function set content ( pContent:String ):void 
		{
			_content = pContent;	
		}
		
		public function get content ( ):String 
		{
			return _content;	
		}
		
		public function get transitions ( ):String 
		{
			return _pageTransition;	
		}
		
		public function set transitions ( pTransition:String ):void 
		{
			_pageTransition = pTransition;	
		}
		
		public function get annotations ( ):String 
		{
			return _annots;	
		}
		
		public function set annotations ( pAnnotation:String ):void 
		{	
			_annots = pAnnotation;	
		}
		
		public function toString ( ):String 
		{
			return "[Page orientation="+_orientation+" page="+page+" width="+(w>>0)+" height="+(h>>0)+"]";	
		}
	}
}