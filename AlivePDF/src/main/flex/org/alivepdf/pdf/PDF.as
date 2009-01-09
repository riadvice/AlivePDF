/*
_________________            __________________________
___    |__  /__(_)__   _________  __ \__  __ \__  ____/
__  /| |_  /__  /__ | / /  _ \_  /_/ /_  / / /_  /_    
_  ___ |  / _  / __ |/ //  __/  ____/_  /_/ /_  __/
/_/  |_/_/  /_/  _____/ \___//_/     /_____/ /_/  
     
Copyright (c) 2008 Thibault Imbert

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/**
* This library lets you generate PDF files with the Flash Player
* AlivePDF is based on the FPDF PHP library (http://www.fpdf.org/)
* @author Thibault Imbert
* @version 0.1.4.6 Current Release
* @url alivepdf.bytearray.org
*/

package org.alivepdf.pdf
{

	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.alivepdf.colors.CMYKColor;
	import org.alivepdf.colors.Color;
	import org.alivepdf.colors.GrayColor;
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.display.Display;
	import org.alivepdf.display.PageMode;
	import org.alivepdf.drawing.Caps;
	import org.alivepdf.drawing.DashedLine;
	import org.alivepdf.drawing.WindingRule;
	import org.alivepdf.encoding.Base64;
	import org.alivepdf.encoding.JPEGEncoder;
	import org.alivepdf.encoding.PNGEncoder;
	import org.alivepdf.events.PageEvent;
	import org.alivepdf.events.ProcessingEvent;
	import org.alivepdf.fonts.CoreFonts;
	import org.alivepdf.images.GIFImage;
	import org.alivepdf.images.ImageFormat;
	import org.alivepdf.images.JPEGImage;
	import org.alivepdf.images.PDFImage;
	import org.alivepdf.images.PNGImage;
	import org.alivepdf.images.ResizeMode;
	import org.alivepdf.layout.Layout;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.metrics.FontMetrics;
	import org.alivepdf.pages.Page;
	import org.alivepdf.saving.Method;
	import org.alivepdf.tools.sprintf;

	/**
	 * Dispatched when a page has been added to the PDF. The addPage() method generate this event
	 *
	 * @eventType org.alivepdf.events.PageEvent.ADDED
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( PageEvent.ADDED, pageAdded );
	 * </pre>
	 * </div>
 	 */
	[Event(name='added', type='org.alivepdf.events.PageEvent')]
	
	/**
	 * Dispatched when PDF has been generated and available. The save() method generate this event
	 *
	 * @eventType org.alivepdf.events.ProcessingEvent.COMPLETE
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( ProcessingEvent.COMPLETE, generationComplete );
	 * </pre>
	 * </div>
 	 */
	[Event(name='complete', type='org.alivepdf.events.ProcessingEvent')]
	
	/**
	 * Dispatched when the PDF page tree has been generated. The save() method generate this event
	 *
	 * @eventType org.alivepdf.events.ProcessingEvent.PAGE_TREE
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( ProcessingEvent.PAGE_TREE, pageTreeAdded );
	 * </pre>
	 * </div>
 	 */
	[Event(name='pageTree', type='org.alivepdf.events.ProcessingEvent')]
	
	/**
	 * Dispatched when the required resources (fonts, images, etc.) haven been written into the PDF. The save() method generate this event
	 *
	 * @eventType org.alivepdf.events.ProcessingEvent.RESOURCES
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( ProcessingEvent.RESOURCES, resourcesAdded );
	 * </pre>
	 * </div>
 	 */
	[Event(name='resources', type='org.alivepdf.events.ProcessingEvent')]
	
	/**
	 * Dispatched when the PDF generation has been initiated. The save() method generate this event
	 *
	 * @eventType org.alivepdf.events.ProcessingEvent.STARTED
	 *
	 * * @example
	 * This example shows how to listen for such an event :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener ( ProcessingEvent.STARTED, generationStarted );
	 * </pre>
	 * </div>
 	 */
	[Event(name='started', type='org.alivepdf.events.ProcessingEvent')]

	/**
	* The PDF class represents a PDF document.
	*/
	public final class PDF implements IEventDispatcher
	{

		private static const PDF_VERSION:String = '1.3';
		private static const ALIVEPDF_VERSION:String = '0.1.4.6';
		
		private static const JPG_HEADER:int = 0xFFD8;
		private static const PNG_HEADER:int = 0x8950;
		private static const GIF_HEADER:String = "GIF";

        //current page number
		private var nbPages:int;
		//current object number
		private var n:int;      
		//array of object offsets            
		private var offsets:Array;
		//current document state        
		private var state:int;
		//compression flag        
		private var compress:Boolean;
		//default orientation        
		private var defaultOrientation:String;
		//default format  
		private var defaultSize:Size;
		//default rotation  
		private var defaultRotation:int;
		//default unit  
		private var defaultUnit:String;
		//current orientation
		private var currentOrientation:String;
		//array indicating orientation changes 
		private var orientationChanges:Array;
		//scale factor (number of points in user unit)
		private var k:Number;
		//left margin             
		private var lMargin:Number;
		//top margin           
		private var tMargin:Number;
		//right margin       
		private var rMargin:Number;
		//page break margin          
		private var bMargin:Number;
		//cell margin      
		private var cMargin:Number;            
		private var currentX:Number;
		private var currentY:Number;
		//last cell printed
		private var lasth:Number;
		//line width in user unit        
		private var lineWidth:Number;
		//array of standard font names       
		private var standardFonts:Object;
		//array of used fonts        
		private var fonts:Object;
		//array of font files          
		private var fontFiles:Array;
		//array of encoding differences         
		private var diffs:Array;
		//array of internal links            
		private var links:Array;
		//current font family              
		private var fontFamily:String;
		//current font style         
		private var fontStyle:String;
		//underlining flag        
		private var underline:Boolean;
		//current font size in points        
		private var fontSizePt:Number;
		//commands for drawing color        
		private var strokeStyle:String;
		//winding number rule
		private var windingRule:String;
		//commands for filling color        
		private var fillColor:String;   
		//commands for text color       
		private var addTextColor:String;
		//indicates whether fill and text colors are different        
		private var colorFlag:Boolean;
		//word spacing       
		private var ws:Number;
		//automatic page breaking      
		private var autoPageBreak:Boolean;
		//threshold used to trigger page breaks
		private var pageBreakTrigger:Number;
		//flag set when processing footer
		private var inFooter:Boolean;
		//zoom display mode       
		private var zoomMode:*;
		//layout display mode         
		private var layoutMode:String;         
		private var pageMode:String;
		//document infos
		private var documentTitle:String;            
		private var documentSubject:String;       
		private var documentAuthor:String;      
		private var documentKeywords:String;    
		private var documentCreator:String;
		//alias for total number of pages        
		private var aliasNbPages:String;
		//PDF version number      
		private var pdfVersion:String;
		private var buffer:ByteArray;
		private var streamDictionary:Dictionary;
		private var compressedPages:ByteArray;
		private var encryptRef:int;
		private var image:PDFImage;
		private var fontSize:Number;
		private var name:String;
		private var type:String;
		private var desc:String;
		private var up:Number;
		private var ut:Number;
		private var cw:Object;
		private var enc:Number;
		private var diff:Number;
		private var d:Number;
		private var nb:int;
		private var originalsize:Number;
		private var size1:Number;
		private var size2:Number;
		private var fontkey:String;
		private var file:String;
		private var currentFont:Object;
		private var b2:String;
		private var pageLinks:Array;
		private var mtd:*
		private var filter:String;
		private var inited:Boolean;
		private var filled:Boolean
		private var dispatcher:EventDispatcher;
		private var arrayPages:Array;
		private var arrayNotes:Array;
		private var extgstates:Array;
		private var currentPage:Page;
		private var outlines:Array;
		private var rotationMatrix:Matrix;
		private var outlineRoot:int;
		private var angle:Number;
		private var textRendering:int;
		private var autoPagination:Boolean;
		private var viewerPreferences:String;
		private var drawingRule:String;
		private var reference:String;
		private var references:String;

		/**
		* The PDF class represents a PDF document.
		*
		* @author Thibault Imbert
		*
		* @example
		* This example shows how to create a valid PDF document :
		* <div class="listing">
		* <pre>
		*
		* var myPDF:PDF = new PDF ( Orientation.PORTRAIT, Unit.MM, Size.A4 );
		* </pre>
		* </div>
		*/

		public function PDF ( orientation:String='Portrait', unit:String='Mm', pageSize:Object=null, rotation:int=0 )
		{
			
			var format:Array;
			var size:Size;
			
			n = 2;
			angle = 0;
			state = 0;
			lasth = 0;
			fontSizePt = 12;
			ws = 0;
			
			size = ( pageSize != null ) ? Size.getSize(pageSize).clone() : Size.A4.clone();
			
			if ( size == null  ) throw new RangeError ('Unknown page format : ' + pageSize +', please use a org.alivepdf.layout.' + 
									  					  'Size object or any of those strings : A3, A4, A5, Letter, Legal, Tabloid');

			dispatcher = new EventDispatcher ( this );

			viewerPreferences = new String();
			outlines = new Array();
			arrayPages = new Array();
			arrayNotes = new Array();
			extgstates = new Array();
			orientationChanges = new Array();
			nbPages = arrayPages.length;
			buffer = new ByteArray();
			offsets = new Array();
			fonts = new Object();
			pageLinks = new Array();
			fontFiles = new Array();
			diffs = new Array();
			streamDictionary = new Dictionary();
			rotationMatrix = new Matrix();
			links = new Array();
			inFooter = false;
			fontFamily = new String();
			fontStyle = new String();
			underline = false;
			strokeStyle = new String ('0 G');
			fillColor = new String ('0 g');
			addTextColor = new String ('0 g');
			colorFlag = false;
			inited = true;
			references = new String();
			compressedPages = new ByteArray();

			//Standard fonts
			standardFonts = new CoreFonts();
			
			// Scaling factor
			defaultUnit = setUnit ( unit );
				
			// format & orientation
			defaultSize = size;
			defaultOrientation = orientation;
			defaultRotation = rotation;

			//Page margins (1 cm)
			var margin:Number = 28.35/k;
			setMargins ( margin, margin );

			//Interior cell margin (1 mm)
			cMargin = margin/10;

			//Line width (0.2 mm)
			lineWidth = .567/k;

			//Automatic page break
			setAutoPageBreak (true, margin * 2 );

			//Full width display mode
			setDisplayMode( Display.FULL_WIDTH );
			
			// enable zlib compression
			isCompressed = false;

			//Set default PDF version number
			pdfVersion = PDF.PDF_VERSION;
			
		}

		/**
		* Lets you specify the left, top, and right margins
		*
		* @param left Left margin
		* @param top Right number
		* @param right Top number
		* @param bottom Bottom number
		* @example
		* This example shows how to set margins for the PDF document :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setMargins ( 10, 10, 10, 10 );
		* </pre>
		* </div>
		*/
		public function setMargins ( left:Number, top:Number, right:Number=-1, bottom:Number=20 ):void
		{
			lMargin = left;
			tMargin = top;
			if( right == -1 ) right = left;
			bMargin = bottom;
			rMargin = right;
		}

		/**
		* Lets you retrieve the margins dimensions
		*
		* @return Rectangle
		* @example
		* This example shows how to get the margins dimensions :
		* <div class="listing">
		* <pre>
		*
		* var marginsDimensions:Rectangle = myPDF.getMargins ();
		* // output : (x=10.00, y=10.0012, w=575.27, h=811.88)
		* trace( marginsDimensions )
		* </pre>
		* </div>
		*/
		public function getMargins ():Rectangle
		{
			return new Rectangle( lMargin, tMargin, getCurrentPage().width - rMargin - lMargin, getCurrentPage().height - bMargin - tMargin );
		}

		/**
		* Lets you specify the left margin
		*
		* @param margin Left margin
		* @example
		* This example shows how set left margin for the PDF document :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setLeftMargin ( 10 );
		* </pre>
		* </div>
		*/
		public function setLeftMargin (margin:Number):void
		{
			lMargin = margin;
			if( nbPages > 0 && currentX < margin ) currentX = margin;
		}

		/**
		* Lets you specify the top margin
		*
		* @param margin Top margin
		* @example
		* This example shows how set top margin for the PDF document :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setTopMargin ( 10 );
		* </pre>
		* </div>
		*/
		public function setTopMargin (margin:Number):void
		{

			tMargin = margin;

		}

		/**
		* Lets you specify the bottom margin
		*
		* @param margin Bottom margin
		* @example
		* This example shows how set bottom margin for the PDF document :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setBottomMargin ( 10 );
		* </pre>
		* </div>
		*/
		public function setBottomMargin (margin:Number):void
		{

			bMargin = margin;

		}

		/**
		* Lets you specify the right margin
		*
		* @param margin Right margin
		* @example
		* This example shows how set right margin for the PDF document :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setRightMargin ( 10 );
		* </pre>
		* </div>
		*/
		public function setRightMargin (margin:Number):void
		{
			rMargin = margin;
		}

		/**
		 * Lets you enable or disable auto page break mode and triggering margin 
		 * 
		 * @param auto Page break mode
		 * @param margin Bottom margin
		 * 
		 */		
		public function setAutoPageBreak ( auto:Boolean, margin:Number ):void
		{
			autoPageBreak = auto;
			bMargin = margin;
			if ( currentPage != null ) pageBreakTrigger = currentPage.h-margin;
		}

		/**
		* Lets you set a specific display mode, the DisplayMode takes care of the general layout of the PDF in the PDF reader
		*
		* @param zoom Zoom mode, can be Display.FULL_PAGE, Display.FULL_WIDTH, Display.REAL, Display.DEFAULT
		* @param layout Layout of the PDF document, can be Layout.SINGLE_PAGE, Layout.ONE_COLUMN, Layout.TWO_COLUMN_LEFT, Layout.TWO_COLUMN_RIGHT
		* @param mode PageMode can be pageMode.USE_NONE, PageMode.USE_OUTLINES, PageMode.USE_THUMBS, PageMode.FULL_SCREEN
		* @example
		* This example creates a PDF which opens at full page scaling, one page at a time :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setDisplayMode (Display.FULL_PAGE, Layout.SINGLE_PAGE);
		* </pre>
		* </div>
		* To create a full screen PDF you would write :
		* <div class="listing">
		* <pre>
		* 
		* myPDF.setDisplayMode( Display.FULL_PAGE, Layout.SINGLE_PAGE, PageMode.FULLSCREEN );
		* </pre>
		* </div>
		*/
		public function setDisplayMode ( zoom:String='FullWidth', layout:String='SinglePage', mode:String='UseNone' ):void
		{
			zoomMode = zoom;
			layoutMode = layout;
			pageMode = mode;
		}

		/**
		* Lets you set a title for the PDF
		*
		* @param title The title
		* @example
		* This example shows how to set a specific title to the PDF tags :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setTitle ( "AlivePDF !" );
		* </pre>
		* </div>
		*/
		public function setTitle ( title:String ):void
		{
			documentTitle = title;
		}

		/**
		* Lets you set a subject for the PDF
		*
		* @param subject The subject
		* @example
		*  This example shows how to set a specific subject to the PDF tags :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setSubject ( "Any topic" );
		* </pre>
		* </div>
		*/
		public function setSubject ( subject:String ):void
		{
			documentSubject = subject;
		}

		/**
		* Sets the specified author for the PDF
		*
		* @param author The author
		* @example
		* This example shows how to add a specific author to the PDF tags :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setAuthor ( "Bob" );
		* </pre>
		* </div>
		*/
		public function setAuthor ( author:String ):void
		{
			documentAuthor = author;
		}

		/**
		* Sets the specified keywords for the PDF
		*
		* @param keywords The keywords
		* @example
		* This example shows how to add some keywords to the PDF tags :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setKeywords ( "Design, Agency, Communication, etc." );
		* </pre>
		* </div>
		*/
		public function setKeywords ( keywords:String ):void
		{
			documentKeywords = keywords;
		}

		/**
		* Sets the specified creator for the PDF
		*
		* @param creator Name of the PDF creator
		* @example
		* This example shows how to set a creator name to the PDF tags :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setCreator ( "My Application 1.0" );
		* </pre>
		* </div>
		*/
		public function setCreator ( creator:String ):void
		{
			documentCreator = creator;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF compression API
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Lets you activate zlib compression for the current PDF
		 *   
		 * @param compressed
		 * @example
		 * This example shows how to activate zlib compression :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.isCompressed = true;
		 * </pre>
		 * </div>
		 */	
		public function set isCompressed ( compressed:Boolean ):void
		{
			compress = compressed;	
		}
		
		public function get isCompressed ():Boolean
		{	
			return compress;	
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF paging API
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/**
		* Lets you specify an alias for the total number of pages
		*
		* @param alias Alias to use
		* @example
		* This example shows how to show the total number of pages :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setAliasNbPages ( "[nb]" );
		* myPDF.textStyle( new RGBColor (0,0,0), 1 );
		* myPDF.setFont( FontFamily.HELVETICA, Style.NORMAL, 18 );
		* // then use the alias when needed
		* myPDF.addText ("There are [nb] pages in the PDF !", 150, 50);
		* </pre>
		* </div>
		*/
		public function setAliasNbPages ( alias:String='{nb}' ):void
		{
			aliasNbPages = alias;
		}

		/**
		* Lets you rotate a specific page (between 1 and n-1)
		*
		* @param number Page number
		* @param rotation Page rotation (must be a multiple of 90)
		* @throws RangeError
		* @example
		* This example shows how to rotate the first page 90 clock wise :
		* <div class="listing">
		* <pre>
		*
		* myPDF.rotatePage ( 1, 90 );
		* </pre>
		* </div>
		* This example shows how to rotate the first page 90 counter clock wise :
		* <div class="listing">
		* <pre>
		*
		* myPDF.rotatePage ( 1, -90 );
		* </pre>
		* </div>
		 * 
		*/
		public function rotatePage ( number:int, rotation:Number ):void
		{
			if ( number > 0 && number <= arrayPages.length ) arrayPages[number-1].rotate ( rotation );

			else throw new RangeError ("No page available, please select a page from 1 to " + arrayPages.length);
		}
		
		/**
		 * Lets you add a page to the current PDF
		 *  
		 * @param page
		 * @example
		 * 
		 * This example shows how to add an A4 page with a landscape orientation :
		 * <div class="listing">
		 * <pre>
		 *
		 * var page:Page = new Page ( Orientation.LANDSCAPE, Unit.MM, Size.A4 );
		 * myPDF.addPage( page );
		 * </pre>
		 * </div>
		 * This example shows how to add a page with a custom size :
		 * <div class="listing">
		 * <pre>
		 *
		 * var customSize:Size = new Size ( [420.94, 595.28], "CustomSize", [5.8,  8.3], [148, 210] );
		 * var page:Page = new Page ( Orientation.PORTRAIT, Unit.MM, customSize );
		 * myPDF.addPage ( page );
		 * </pre>
		 * </div>
		 * 
		 */		
		public function addPage ( page:Page=null ):Page
		{
			if ( page == null ) page = new Page ( defaultOrientation, defaultUnit, defaultSize, defaultRotation );

			arrayPages.push ( page );
				
			reference = (3+(nbPages<< 1))+' 0 R';
			
			references += reference+'\n';

			if ( state == 0 ) open();

			var family:String = fontFamily;
			var style:String = fontStyle+(underline ? 'U' : '');
			var size:Number = fontSizePt;
			var lw:Number = lineWidth;
			var dc:String = strokeStyle;
			var fc:String = fillColor;
			var tc:String = addTextColor;
			var cf:Boolean = colorFlag;

			if( nbPages > 0 ) finishPage();

			//Start new page
			currentPage = startPage ( page != null ? page.orientation : defaultOrientation );
			
			//Set line cap style to square
			write ( Caps.SQUARE );
			
			//Set line width
			lineWidth = lw;
			write( sprintf('%.2f w',lw*k) );
			
			//Set font
			if( family ) setFont(family,style, size);
			
			//Set colors
			strokeStyle = dc;
			if( dc != '0 G' ) write (dc);
			fillColor = fc;
			if( fc != '0 g' ) write (fc);
			addTextColor = tc;
			colorFlag = cf;
			
			//Restore line width
			if(lineWidth!=lw)
			{
				lineWidth=lw;
				write(sprintf('%.2f w',lw*k));
			}
			
			//Restore font
			if ( family ) setFont ( family, style, size );
			
			//Restore colors
			if(strokeStyle != dc)
			{
				strokeStyle = dc;
				write(dc);
			}
			if(fillColor != fc)
			{
				fillColor = fc;
				write(fc);
			}
			
			addTextColor = tc;
			colorFlag = cf;
			
			dispatcher.dispatchEvent( new PageEvent ( PageEvent.ADDED, currentPage ) );
						
			return page;
		}

		/**
		* Lets you retrieve a Page object
		*
		* @param page page number, from 1 to total numbers of pages
		* @return Page
		* @example
		* This example shows how to retrieve the first page :
		* <div class="listing">
		* <pre>
		*
		* var page:Page = myPDF.getPage ( 1 );
		* </pre>
		* </div>
		*/
		public function getPage ( page:int ):Page
		{
			if ( page > 0 && page <= arrayPages.length ) return arrayPages [page-1];

			else throw new RangeError ("Can't retrieve page " + page + ".");
		}
		
		/**
		* Lets you retrieve all the PDF pages
		*
		* @return Array
		* @example
		* This example shows how to retrieve all the PDF pages :
		* <div class="listing">
		* <pre>
		*
		* var pdfPages:Array = myPDF.getPages ();
		*
		* for each ( var p:* in pdfPages ) trace( p );
		* 
		* outputs :
		* 
		* [Page orientation=Portrait width=210 height=297]
		* [Page orientation=Landscape width=297 height=210]
		* 
		* </pre>
		* </div>
		*/
		public function getPages ():Array
		{
			if ( arrayPages.length ) return arrayPages;

			else throw new RangeError ("No pages available !");
		}
		
		/**
		* Lets you move to a Page in the PDF
		*
		* @param page page number, from 1 to total numbers of pages
		* @example
		* This example shows how to move to the first page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.gotoPage ( 1 );
		* // draw on the first page
		* myPDF.lineStyle( new RGBColor(0xFF0000), 2, 0 );
	    * myPDF.drawRect( 60, 60, 40, 40 ); 
		* </pre>
		* </div>
		*/
		public function gotoPage ( page:int ):void
		{
			if ( page > 0 && page <= arrayPages.length ) currentPage = arrayPages[page-1];
			
			else throw new RangeError ("Can't find page " + page + ".");
		}

		/**
		* Lets you remove a Page from the PDF
		*
		* @param page page number, from 1 to total numbers of pages
		* @return Page
		* @example
		* This example shows how to remove the first page :
		* <div class="listing">
		* <pre>
		* myPDF.removePage ( 1 );
		* </pre>
		* If you want to remove pages each by each, you can combine removePage with getPageCount
		* <pre>
		* myPDF.removePage ( myPDFEncoder.getPageCount() );
		* </pre>
		* </div>
		*/
		public function removePage ( page:int ):Page
		{
			if ( page > 0 && page <= arrayPages.length ) return arrayPages.splice ( page-1, 1 )[0];

			else throw new RangeError ("Cannot remove page " + page + ".");
		}
		
		/**
		* Lets you remove all the pages from the PDF
		*
		* @example
		* This example shows how to remove all the pages :
		* <div class="listing">
		* <pre>
		* myPDF.removeAllPages();
		* </pre>
		* </div>
		*/
		public function removeAllPages ():void 
		{	
			arrayPages = new Array();	
		}

		/**
		* Lets you retrieve the current Page
		*
		* @return Page A Page object
		* @example
		* This example shows how to retrieve the current page :
		* <div class="listing">
		* <pre>
		*
		* var page:Page = myPDF.getCurrentPage ();
		* </pre>
		* </div>
		*/
		public function getCurrentPage ():Page
		{
			if ( arrayPages.length > 0 ) return currentPage;

			else throw new RangeError ("Can't retrieve the current page, " + arrayPages.length + " pages available.");
		}

		/**
		* Lets you retrieve the number of pages in the PDF document
		*
		* @return int Number of pages in the PDF
		* @example
		* This example shows how to retrieve the number of pages :
		* <div class="listing">
		* <pre>
		*
		* var totalPages:int = myPDF.getPageCount ();
		* </pre>
		* </div>
		*/
		public function get totalPages ():int
		{
			return arrayPages.length;
		}
		
		/**
		* Lets you insert a line break for text
		*
		* @param height Line break height
		* @example
		* This example shows how to add a line break :
		* <div class="listing">
		* <pre>
		*
		* myPDF.newLine ( 10 );
		* </pre>
		* </div>
		*/
		public function newLine ( height:*='' ):void
		{
			currentX = lMargin;
			currentY += (height is String) ? lasth : height;
		}

		/**
		* Lets you retrieve the X position for the current page
		*
		* @return Number the X position
		*/
		public function getX ():Number
		{
			return currentX;
		}

		/**
		* Lets you retrieve the Y position for the current page
		*
		* @return Number the Y position
		*/
		public function getY ():Number
		{
			return currentY;
		}

		/**
		* Lets you specify the X position for the current page
		*
		* @param x The X position
		*/
		public function setX ( x:Number ):void
		{
			currentX = ( x >= 0 ) ? x : currentPage.w+x;
		}

		/**
		* Lets you specify the Y position for the current page
		*
		* @param y The Y position
		*/
		public function setY ( y:Number ):void
		{
			currentX = lMargin;
			currentY = ( y >= 0 ) ? y : currentPage.h+y;
		}

		/**
		* Lets you specify the X and Y position for the current page
		*
		* @param x The X position
		* @param y The Y position
		*/
		public function setXY ( x:Number, y:Number ):void
		{
			setY( y );
			setX( x );
		}
		
		/**
		 * Returns the default PDF Size
		 * 
		 * @return Size
		 * 
		 */		
		public function getDefaultSize ():Size
		{
			return defaultSize;	
		}
		
		/**
		 * Returns the default PDF orientation
		 * 
		 * @return String
		 * 
		 */		
		public function getDefaultOrientation ():String 
		{
			return defaultOrientation;	
		}
		
		/**
		 * Returns the default PDF unit unit
		 * 
		 * @return String
		 * 
		 */		
		public function getDefaultUnit ():String 
		{	
			return defaultUnit;	
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF Drawing API
		*
		* moveTo()
		* lineTo()
		* end()
		* curveTo()
		* lineStyle()
		* beginFill()
		* endFill()
		* drawRect()
		* drawRoundRect()
		* drawCircle()
		* drawEllipse()
		* drawPolygone()
		* drawRegularPolygone()
		* drawPath()
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/**
		* Lets you specify the opacity for the next drawing operations, from 0 (100% transparent) to 1 (100% opaque)
		*
		* @param alpha Opacity
		* @param blendMode Blend mode, can be Blend.DIFFERENCE, BLEND.HARDLIGHT, etc.
		* @example
		* This example shows how to set the transparency to 50% for any following drawing, image or text operation :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setAlpha ( .5 );
		* </pre>
		* </div>
		*/	
		public function setAlpha ( alpha:Number, blendMode:String='Normal' ):void
		{
			var graphicState:int = addExtGState( { 'ca' : alpha, 'SA' : true, 'CA' : alpha, 'BM' : '/' + blendMode } );

			setExtGState ( graphicState );
		}

		/**
		* Lets you move the current drawing point to the specified destination
		*
		* @param x X position
		* @param y Y position
		* @example
		* This example shows how to move the pen to 120,200 :
		* <div class="listing">
		* <pre>
		*
		* myPDF.moveTo ( 120, 200 );
		* </pre>
		* </div>
		*/
		public function moveTo ( x:Number, y:Number ):void
		{
			write ( x*k + " " + (currentPage.h-y)*k + " m");
		}

		/**
		* Lets you draw a stroke from the current point to the new point
		*
		* @param x X position
		* @param y Y position
		* @example
		* This example shows how to draw some dashed lines in the current page with specific caps style and joint style :
		* <br><b>Important : Always call the end() method when you're done</b>
		* <div class="listing">
		* <pre>
		*
		* myPDF.lineStyle( new RGBColor ( 0x990000 ), 1, 1 );
		* myPDF.moveTo ( 10, 20 );
		* myPDF.lineTo ( 40, 20 );
		* myPDF.lineTo ( 40, 40 );
		* myPDF.lineTo ( 10, 40 );
		* myPDF.lineTo ( 10, 20 );
		* myPDF.end();
		* </pre>
		* </div>
		*/
		public function lineTo ( x:Number, y:Number ):void
		{
			write ( x*k + " " + (currentPage.h-y)*k+ " l");
		}

		/**
		* The end method closes the stroke
		*
		* @example
		* This example shows how to draw some dashed lines in the current page with specific caps style and joint style :
		* <br><b>Important : Always call the end() method when you're done</b>
		* <div class="listing">
		* <pre>
		* 
		* myPDF.lineStyle( new RGBColor ( 0x990000 ), 1, 1 );
		* myPDF.moveTo ( 10, 20 );
		* myPDF.lineTo ( 40, 20 );
		* myPDF.lineTo ( 40, 40 );
		* myPDF.lineTo ( 10, 40 );
		* myPDF.lineTo ( 10, 20 );
		* // end the stroke
		* myPDF.end();
		* </pre>
		* </div>
		*/
		public function end ():void
		{
			write ( !filled ? "s" : windingRule == WindingRule.NON_ZERO ? "b" : "b*" );
		}

		/**
		* The curveTo method draws a cubic bezier curve
		* @param controlX1
		* @param controlY1
		* @param controlX2
		* @param controlY2
		* @param finalX3
		* @param finalY3
		* @example
		* This example shows how to draw some curves lines in the current page :
		* <br><b>Important : Always call the end() method when you're done</b>
		* <div class="listing">
		* <pre>
		*
		* myPDF.lineStyle ( new RGBColor ( 0x990000 ), 1, 1, null, CapsStyle.NONE, JointStyle.MITER );
		* myPDF.moveTo ( 10, 200 );
		* myPDF.curveTo ( 120, 210, 196, 280, 139, 195 );
		* myPDF.curveTo ( 190, 110, 206, 190, 179, 205 );
		* myPDF.end();
		* </pre>
		* </div>
		*/	
		public function curveTo ( controlX1:Number, controlY1:Number, controlX2:Number, controlY2:Number, finalX3:Number, finalY3:Number ):void
		{
			write (controlX1*k + " " + (currentPage.h-controlY1)*k + " " + controlX2*k + " " + (currentPage.h-controlY2)*k+ " " + finalX3*k + " " + (currentPage.h-finalY3)*k + " c");
		}

		/**
		* Sets the stroke style
		* @param color
		* @param thickness
		* @param flatness
		* @param alpha
		* @param rule
		* @param blendMode
		* @param style
		* @param caps
		* @param joints
		* @param miterLimit
		* @example
		* This example shows how to draw a star with an "even odd" rule :
		* <div class="listing">
		* <pre>
		*
		* myPDF.lineStyle( new RGBColor ( 0x990000 ), 1, 0, 1, Rule.EVEN_ODD, null, null, Caps.NONE, Joint.MITER );
		* 
		* myPDF.beginFill( new RGBColor ( 0x009900 ) );
		* myPDF.moveTo ( 66, 10 );
		* myPDF.lineTo ( 23, 127 );
		* myPDF.lineTo ( 122, 50 );
		* myPDF.lineTo ( 10, 49 );
		* myPDF.lineTo ( 109, 127 );
		* myPDF.end();
		* 
		* </pre>
		* </div>
		* This example shows how to draw a star with an "non-zero" winding rule :
		* <div class="listing">
		* <pre>
		*
		* myPDF.lineStyle( new RGBColor ( 0x990000 ), 1, 0, 1, Rule.NON_ZERO_WINDING, null, null, Caps.NONE, Joint.MITER );
		* 
		* myPDF.beginFill( new RGBColor ( 0x009900 ) );
		* myPDF.moveTo ( 66, 10 );
		* myPDF.lineTo ( 23, 127 );
		* myPDF.lineTo ( 122, 50 );
		* myPDF.lineTo ( 10, 49 );
		* myPDF.lineTo ( 109, 127 );
		* myPDF.end();
		* 
		* </pre>
		* </div>
		 * 
		*/	
		public function lineStyle ( color:Color, thickness:Number=1, flatness:Number=0, alpha:Number=1, rule:String="NonZeroWinding", blendMode:String="Normal", style:DashedLine=null, caps:String=null, joints:String=null, miterLimit:Number=3 ):void
		{
			strokeColor ( color );
			windingRule = rule;
			lineWidth = thickness;
		 	setAlpha ( alpha, blendMode );

			if ( nbPages > 0 ) write ( sprintf ('%.2f w', thickness*k) );
			
			write ( flatness + " i ");
			write ( style != null ? style.pattern : '[] 0 d' );

			if ( caps != null ) write ( caps );			
			if ( joints != null ) write ( joints );
			
			write ( miterLimit + " M" );
		}

		/**
		* Sets the stroke color for different color spaces CMYK, RGB and DEVICEGRAY
		*/
		private function strokeColor ( color:Color ):void
		{
			var op:String;

			// RGB ColorSpace
			if ( color is RGBColor )
			{

				op = "RG";

				var r:Number = (color as RGBColor).r/255;
				var g:Number = (color as RGBColor).g/255;
				var b:Number = (color as RGBColor).b/255;

				write ( r + " " + g + " " + b + " " + op );

			// CMYK ColorSpace
			} else if ( color is CMYKColor )
			{

				op = "K";

				var c:Number = (color as CMYKColor).cyan / 100;
				var m:Number = (color as CMYKColor).magenta / 100;
				var y:Number = (color as CMYKColor).yellow / 100;
				var k:Number = (color as CMYKColor).black / 100;

				write ( c + " " + m + " " + y + " " + k + " " + op );

			// Gray ColorSpace
			} else
			{
				op = "G";

				var gray:Number = (color as GrayColor).gray / 100;

				write ( gray + " " + op );
			}
		}

		/**
		* Sets the text color for different color spaces CMYK, RGB, and DEVICEGRAY
		* @param
		*/
		private function textColor ( color:Color ):void
		{
			var op:String;

			// RGB ColorSpace
			if ( color is RGBColor )
			{
				op = !textRendering ? "rg" : "RG"

				var r:Number = (color as RGBColor).r/255;
				var g:Number = (color as RGBColor).g/255;
				var b:Number = (color as RGBColor).b/255;

				addTextColor = r + " " + g + " " + b + " " + op;

			// CMYK ColorSpace
			} else if ( color is CMYKColor )
			{
				op = !textRendering ? "k" : "K"

				var c:Number = (color as CMYKColor).cyan / 100;
				var m:Number = (color as CMYKColor).magenta / 100;
				var y:Number = (color as CMYKColor).yellow / 100;
				var k:Number = (color as CMYKColor).black / 100;

				addTextColor = c + " " + m + " " + y + " " + k + " " + op;

			// Gray ColorSpace
			} else
			{
				op = !textRendering ? "g" : "G"

				var gray:Number = (color as GrayColor).gray / 100;

				addTextColor = gray + " " + op;
			}
		}

		/**
		* Sets the filling color for different color spaces CMYK/RGB/DEVICEGRAY
		*
		* @param color Color object, can be CMYKColor, GrayColor, or RGBColor
		* @example
		* This example shows how to create a red rectangle in the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		* myPDF.drawRect ( new Rectangle ( 10, 26, 50, 25 ) );
		* </pre>
		* </div>
		*/
		public function beginFill ( color:Color ):void
		{
			filled = true;

			var op:String;

			// RGB ColorSpace
			if ( color is RGBColor )
			{
				op = "rg";

				var r:Number = (color as RGBColor).r/255;
				var g:Number = (color as RGBColor).g/255;
				var b:Number = (color as RGBColor).b/255;

				write ( r + " " + g + " " + b + " " + op );

			// CMYK ColorSpace
			} else if ( color is CMYKColor )
			{
				op = "k";

				var c:Number = (color as CMYKColor).cyan / 100;
				var m:Number = (color as CMYKColor).magenta / 100;
				var y:Number = (color as CMYKColor).yellow / 100;
				var k:Number = (color as CMYKColor).black / 100;

				write ( c + " " + m + " " + y + " " + k + " " + op );

			// Gray ColorSpace
			} else
			{
				op = "g";

				var gray:Number = (color as GrayColor).gray / 100;

				write ( gray + " " + op );
			}
		}

		/**
		* Ends all previous filling
		*
		* @example
		* This example shows how to create a red rectangle in the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		* myPDF.moveTo ( 10, 10 );
		* myPDF.lineTo ( 20, 90 );
		* myPDF.lineTo ( 90, 50);
		* myPDF.end()
		* myPDF.endFill();
		* </pre>
		* </div>
		*/
		public function endFill ():void
		{
			filled = false;
		}

		/**
		* The drawRect method draws a rectangle shape
		* @param rect A flash.geom.Rectange object
		* @example
		* This example shows how to create a blue rectangle in the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.lineStyle ( new RGBColor ( 0x990000 ), 1, .3, null, CapsStyle.ROUND, JointStyle.MITER );
		* myPDF.beginFill ( new RGBColor ( 0x009900 ) );
		* myPDF.drawRect ( new Rectangle ( 20, 46, 100, 45 ) );
		* </pre>
		* </div>
		*/
		public function drawRect ( rect:Rectangle ):void
		{
			var style:String = filled ? 'b' : 'S';
			write (sprintf('%.2f %.2f %.2f %.2f re %s', (rect.x)*k, (currentPage.h-(rect.y))*k, rect.width*k, -rect.height*k, style));
		}

		/**
		* The drawRoundedRect method draws a rounded rectangle shape
		* @param rect A flash.geom.Rectange object
		* @param ellipseWidth Angle radius
		* @example
		* This example shows how to create a rounded green rectangle in the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.lineStyle ( new RGBColor ( 0x00FF00 ), 1, 0, .3, BlendMode.NORMAL, null, CapsStyle.ROUND, JointStyle.MITER );
		* myPDF.beginFill ( new RGBColor ( 0x009900 ) );
		* myPDF.drawRoundRect ( new Rectangle ( 20, 46, 100, 45 ), 20 );
		* </pre>
		* </div>
		*/
		public function drawRoundRect ( rect:Rectangle, ellipseWidth:Number ):void
		{
			var k:Number = k;
			var hp:Number = currentPage.h;
			var MyArc:Number = 4/3 * (Math.sqrt(2) - 1);
			write(sprintf('%.2f %.2f m',(rect.x+ellipseWidth)*k,(hp-rect.y)*k ));
			var xc:Number = rect.x+rect.width-ellipseWidth;
			var yc:Number = rect.y+ellipseWidth;
			write(sprintf('%.2f %.2f l', xc*k,(hp-rect.y)*k ));
			curve(xc + ellipseWidth*MyArc, yc - ellipseWidth, xc + ellipseWidth, yc - ellipseWidth*MyArc, xc + ellipseWidth, yc);
			xc = rect.x+rect.width-ellipseWidth ;
			yc = rect.y+rect.height-ellipseWidth;
			write(sprintf('%.2f %.2f l',(rect.x+rect.width)*k,(hp-yc)*k));
			curve(xc + ellipseWidth, yc + ellipseWidth*MyArc, xc + ellipseWidth*MyArc, yc + ellipseWidth, xc, yc + ellipseWidth);
			xc = rect.x+ellipseWidth;
			yc = rect.y+rect.height-ellipseWidth;
			write(sprintf('%.2f %.2f l',xc*k,(hp-(rect.y+rect.height))*k));
			curve(xc - ellipseWidth*MyArc, yc + ellipseWidth, xc - ellipseWidth, yc + ellipseWidth*MyArc, xc - ellipseWidth, yc);
			xc = rect.x+ellipseWidth;
			yc = rect.y+ellipseWidth;
			write(sprintf('%.2f %.2f l',(rect.x)*k,(hp-yc)*k ));
			curve(xc - ellipseWidth, yc - ellipseWidth*MyArc, xc - ellipseWidth*MyArc, yc - ellipseWidth, xc, yc - ellipseWidth);
			var style:String = filled ? 'b' : 'S';
			write(style);	
		}
		
		/**
		 * The drawComplexRoundRect method draws a rounded rectangle shape
		 * 
		 * @param rect A flash.geom.Rectange object
		 * @param topLeftEllipseWidth Angle radius
		 * @param bottomLeftEllipseWidth Angle radius
		 * @param topRightEllipseWidth Angle radius
		 * @param bottomRightEllipseWidth Angle radius
		 * 
		 * @example
		 * This example shows how to create a complex rounded green rectangle (different angles radius) in the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.lineStyle ( new RGBColor ( 0x00FF00 ), 1, 0, .3, BlendMode.NORMAL, null, CapsStyle.ROUND, JointStyle.MITER );
		 * myPDF.beginFill ( new RGBColor ( 0x009900 ) );
		 * myPDF.drawComplexRoundRect( new Rectangle ( 5, 5, 40, 40 ), 16, 16, 8, 8 );
		 * </pre>
		 * </div>
		 * 
		 */		
		public function drawComplexRoundRect ( rect:Rectangle, topLeftEllipseWidth:Number, bottomLeftEllipseWidth:Number, topRightEllipseWidth:Number, bottomRightEllipseWidth:Number ):void
		{
			var k:Number = k;
			var hp:Number = currentPage.h;
			var MyArc:Number = 4/3 * (Math.sqrt(2) - 1);
			write(sprintf('%.2f %.2f m',(rect.x+topLeftEllipseWidth)*k,(hp-rect.y)*k ));
			var xc:Number = rect.x+rect.width-topRightEllipseWidth;
			var yc:Number = rect.y+topRightEllipseWidth;
			write(sprintf('%.2f %.2f l', xc*k,(hp-rect.y)*k ));
			curve(xc + topRightEllipseWidth*MyArc, yc - topRightEllipseWidth, xc + topRightEllipseWidth, yc - topRightEllipseWidth*MyArc, xc + topRightEllipseWidth, yc);
			xc = rect.x+rect.width-bottomRightEllipseWidth ;
			yc = rect.y+rect.height-bottomRightEllipseWidth;
			write(sprintf('%.2f %.2f l',(rect.x+rect.width)*k,(hp-yc)*k));
			curve(xc + bottomRightEllipseWidth, yc + bottomRightEllipseWidth*MyArc, xc + bottomRightEllipseWidth*MyArc, yc + bottomRightEllipseWidth, xc, yc + bottomRightEllipseWidth);
			xc = rect.x+bottomLeftEllipseWidth;
			yc = rect.y+rect.height-bottomLeftEllipseWidth;
			write(sprintf('%.2f %.2f l',xc*k,(hp-(rect.y+rect.height))*k));
			curve(xc - bottomLeftEllipseWidth*MyArc, yc + bottomLeftEllipseWidth, xc - bottomLeftEllipseWidth, yc + bottomLeftEllipseWidth*MyArc, xc - bottomLeftEllipseWidth, yc);
			xc = rect.x+topLeftEllipseWidth;
			yc = rect.y+topLeftEllipseWidth;
			write(sprintf('%.2f %.2f l',(rect.x)*k,(hp-yc)*k ));
			curve(xc - topLeftEllipseWidth, yc - topLeftEllipseWidth*MyArc, xc - topLeftEllipseWidth*MyArc, yc - topLeftEllipseWidth, xc, yc - topLeftEllipseWidth);
			var style:String = filled ? 'b' : 'S';
			write(style);
		}

		/**
		* The drawEllipse method draws an ellipse
		* @param x X Position
		* @param y Y Position
		* @param radiusX X Radius
		* @param radiusY Y Radius
		* @example
		* This example shows how to create a rounded red ellipse in the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.lineStyle ( new RGBColor ( 0x990000 ), 1, .3, new DashedLine ([0, 1, 2, 6]), CapsStyle.NONE, JointStyle.ROUND );
		* myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		* myPDF.drawEllipse( 45, 275, 40, 15 );
		* </pre>
		* </div>
		*/
		public function drawEllipse ( x:Number, y:Number, radiusX:Number, radiusY:Number ):void
		{
			var style:String = filled ? 'b' : 'S';

			var lx:Number = 4/3*(1.41421356237309504880-1)*radiusX;
			var ly:Number = 4/3*(1.41421356237309504880-1)*radiusY;
			var k:Number = k;
			var h:Number = currentPage.h;

			write(sprintf('%.2f %.2f m %.2f %.2f %.2f %.2f %.2f %.2f c',
				(x+radiusX)*k,(h-y)*k,
				(x+radiusX)*k,(h-(y-ly))*k,
				(x+lx)*k,(h-(y-radiusY))*k,
				x*k,(h-(y-radiusY))*k));
			write(sprintf('%.2f %.2f %.2f %.2f %.2f %.2f c',
				(x-lx)*k,(h-(y-radiusY))*k,
				(x-radiusX)*k,(h-(y-ly))*k,
				(x-radiusX)*k,(h-y)*k));
			write(sprintf('%.2f %.2f %.2f %.2f %.2f %.2f c',
				(x-radiusX)*k,(h-(y+ly))*k,
				(x-lx)*k,(h-(y+radiusY))*k,
				x*k,(h-(y+radiusY))*k));
			write(sprintf('%.2f %.2f %.2f %.2f %.2f %.2f c %s',
				(x+lx)*k,(h-(y+radiusY))*k,
				(x+radiusX)*k,(h-(y+ly))*k,
				(x+radiusX)*k,(h-y)*k,
				style));
		}

		/**
		* The drawCircle method draws a circle
		* @param x X Position
		* @param y Y Position
		* @param radius Circle Radius
		* @example
		* This example shows how to create a rounded red ellipse in the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		* myPDF.drawCircle ( 30, 180, 20 );
		* </pre>
		* </div>
		*/
		public function drawCircle( x:Number, y:Number, radius:Number ):void
		{
			drawEllipse ( x, y, radius, radius );
		}

		/**
		* The drawPolygone method draws a polygone
		* @param points Array of points
		* @example
		* This example shows how to create a polygone with a few points :
		* <div class="listing">
		* <pre>
		*
		* myPDF.beginFill ( new RGBColor ( 0x990000 ) );
		* myPDF.drawPolygone ( [89, 40, 20, 90, 40, 50, 10, 60, 70, 90] );
		* </pre>
		* </div>
		*/
		public function drawPolygone ( points:Array ):void
		{
			var lng:int = points.length;
			var i:int = 0;

			while ( i < lng )
			{
				i == 0 ? moveTo ( points[i], points[i+1] ) : lineTo ( points[i], points[i+1] );
				i+=2;
			}
			end();
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF Interactive API
		*
		* addNote()
		* addTransition()
		* addBookmark()
		* addLink()
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/**
		* Lets you add a text annotation to the current page
		*
		* @param x Note X position
		* @param y Note Y position
		* @param width Note width
		* @param height Note height
		* @param text Text for the note
		* @example
		* This example shows how to add a note annotation in the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.addNote (100, 75, 50, 50, "A note !");
		* </pre>
		* </div>
		*/
		public function addTextNote ( x:Number, y:Number, width:Number, height:Number, text:String="A note !" ):void
		{
			var rectangle:String = x*k + ' ' + (((currentPage.h-y)*k) - (height*k)) + ' ' + ((x*k) + (width*k)) + ' ' + (currentPage.h-y)*k;

			currentPage.annotations += ( '<</Type /Annot /Name /Help /Border [0 0 1] /Subtype /Text /Rect [ '+rectangle+' ] /Contents ('+text+')>>' );
		}
		
		/**
		* Lets you add a stamp annotation to the current page
		*
		* @param style Stamp style can be StampStyle.CONFIDENTIAL, StampStyle.FOR_PUBLIC_RELEASE, etc.
		* @param x Note X position
		* @param y Note Y position
		* @param width Note width
		* @param height Note height
		* @example
		* This example shows how to add a stamp annotation in the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.addStampNote ( StampStyle.CONFIDENTIAL, 15, 15, 50, 50 );
		* </pre>
		* </div>
		*/
		public function addStampNote ( style:String, x:Number, y:Number, width:Number, height:Number ):void
		{
			var rectangle:String = x*k + ' ' + (((currentPage.h-y)*k) - (height*k)) + ' ' + ((x*k) + (width*k)) + ' ' + (currentPage.h-y)*k;
			
			currentPage.annotations += ( '<</Type /Annot /Name /'+style+' /Subtype /Stamp /Rect [ '+rectangle+' ]>>' );	
		}

		/**
		* Lets you add a bookmark
		*
		* @param text Text appearing in the outline panel
		* @param level Specify the bookmark's level
		* @param y Position in the current page to go
		* @param red Red offset for the text color
		* @param green Green offset for the text color
		* @param blue Blue offset for the text color
		* @example
		* This example shows how to add a bookmark for the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.addBookmark("A bookmark", 0, 0, 0, .9, 0);
		* myPDF.addPage();
		* myPDF.addBookmark("Another bookmark", 0, 60, .9, .9, 0);
		* </pre>
		* </div>
		*/
		public function addBookmark ( text:String, level:int, y:Number, color:RGBColor ):void
		{
			if( y == -1 ) y = getY();

			outlines.push ( { 't' : text == null ? 'Page ' + nbPages : text, 'l' : level,'y' : y,'p' : nbPages, redMultiplier : color.r, greenMultiplier : color.g, blueMultiplier : color.b } );
		}
		
		/**
		* Lets you add clickable link to a specific position
		*
		* @param x Page Format, can be Size.A3, Size.A4, Size.A5, Size.LETTER or Size.LEGAL
		* @param y
	    * @param width
	    * @param height
	    * @param link
	    * @param highlight
		* @example
		* This example shows how to add an invisible clickable link in the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.addLink ( 70, 4, 60, 16, "http://www.alivepdf.org");
		* </pre>
		* </div>
		*/
		public function addLink ( x:Number, y:Number, width:Number, height:Number, link:*, highlight:String="I" ):void
		{
			var rectangle:String = x*k + ' ' + (((currentPage.h-y)*k) - (height*k)) + ' ' + ((x*k) + (width*k)) + ' ' + (currentPage.h-y)*k;

			currentPage.annotations += "<</Type /Annot /Subtype /Link /Rect ["+rectangle+"] /Border [0 0 0] /H /"+highlight+" ";

			if ( link is String ) currentPage.annotations += "/A <</S /URI /URI "+escapeString(link)+">>>>";

			else
			{
				var l:String = links[link];
				var h:Number = orientationChanges[l[0]] != null ? currentPage.wPt : currentPage.hPt;
				currentPage.annotations += sprintf('/Dest [%d 0 R /XYZ 0 %.2f null]>>',1+2*l[0],h-l[1]*k);
			}
		}

		/**
		* Lets you add a transition between each PDF page
		* Note : PDF must be shown in fullscreen to see the transitions, use the setDisplayMode method with the PageMode.FULL_SCREEN parameter
		* 
		* @param style Transition style, can be Transition.SPLIT, Transition.BLINDS, BLINDS.BOX, Transition.WIPE, etc.
		* @param duration The transition duration
		* @param dimension The dimension in which the the specified transition effect occurs
		* @param motionDirection The motion's direction for the specified transition effect
		* @param transitionDirection The direction in which the specified transition effect moves
		* @example
		* This example shows how to add a 4 seconds "Wipe" transition between the first and second page :
		* <div class="listing">
		* <pre> 
		* myPDF.addPage();  
		* myPDF.addTransition (Transition.WIPE, 4, Dimension.VERTICAL);
		* </pre>
		* </div>
		*/
		public function addTransition ( style:String='R', duration:Number=1, dimension:String='H', motionDirection:String='I', transitionDirection:int=0 ):void
		{
			currentPage.addTransition ( style, duration, dimension, motionDirection, transitionDirection );
		}

		/**
		* Lets you control the way the document is to be presented on the screen or in print.
		*
		* @param toolbar Toolbar behavior
		* @param menubar Menubar behavior
		* @param windowUI WindowUI behavior
		* @param fitWindow Specify whether to resize the document's window to fit the size of the first displayed page.
		* @param centeredWindow Specify whether to position the document's window in the center of the screen.
		* @param displayTitle Specify whether the window's title bar should display the document title taken from the value passed to the setTitle method
		* @example
		* This example shows how to present the document centered on the screen with no toolbars :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setViewerPreferences (ToolBar.HIDE, MenuBar.HIDE, WindowUI.HIDE, FitWindow.DEFAULT, CenterWindow.CENTERED);
		* </pre>
		* </div>
		*/
		public function setViewerPreferences ( toolbar:String='false', menubar:String='false', windowUI:String='false', fitWindow:String='false', centeredWindow:String='false', displayTitle:String='false' ):void
		{
			viewerPreferences = '/ViewerPreferences << /HideToolbar '+toolbar+' /HideMenubar '+menubar+' /HideWindowUI '+windowUI+' /FitWindow '+fitWindow+' /CenterWindow '+centeredWindow+' /DisplayDocTitle '+displayTitle+' >>';
		}

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF font API
		*
		* setFont()
		* setFontSize()
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/**
		* Lets you add a new font to the current PDF (automatically embedded)
		*
		* @param family Page Format, can be Size.A3, Size.A4, Size.A5, Size.LETTER or Size.LEGAL
		* @example
		* This example shows how to add a new font :
		* <div class="listing">
		* <pre>
		*
		* myPDF.addFont ( 1 );
		* </pre>
		* </div>
		*/
		private function addFont ( family:String, style:String='', pFile:String='' ):void
		{

			family = family.toLowerCase();
			
			if( pFile=='' ) pFile = findAndReplace(' ','',family) + style.toLowerCase()+'.php';
			
			if( family=='arial' ) family = 'helvetica';
			
			style = style.toUpperCase();
			
			if ( style=='IB' ) style='BI';
			var fontkey:String = family + style;
			
			if( fonts[fontkey] != null ) throw new Error ('Font already added: ' + family + ' ' + style);
			if( name == null ) throw new Error ('Could not include font definition file');
			
			var i:int = getNumImages ( fonts.length )+1;
			
			fonts[fontkey] = { i : i, type : type, name : name, desc : desc, up : up, ut : ut, cw : cw, enc : enc, file : pFile };
			
			if (diff)
			{
				//Search existing encodings
				d = 0;
				nb = diffs.length;
				for ( var j:int = 1; j <= nb ;j++ )
				{
					if(diffs[j]==diff)
					{
						d=j;
						break;
					}
				}
				if( d==0 )
				{
					d = nb+1;
					diffs[d]=diff;
				}
				fonts[fontkey].diff = d;
			}
			
			if (pFile)
			{
				if ( type == 'TrueType' ) fontFiles[pFile] = { length1 : originalsize };
				else fontFiles[pFile] = { length1 : size1, length2 : size2 };
			}
		}

		/**
		* Lets you set a specific font
		*
		* @param amily Font family, can be any of FontFamily.COURIER, FontFamily.HELVETICA, FontFamily.ARIAL, FontFamily.TIMES, FontFamily.SYMBOL, FontFamily.ZAPFDINGBATS.
		* @param style Any font style, can be Style.BOLD, Style.ITALIC, Style.BOLD_ITALIC, Style.NORMAL
		* @example
		* This example shows how to set the Helvetica font, with a bold style :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setFont( FontFamily.HELVETICA, Style.BOLD );
		* </pre>
		* </div>
		*/
		public function setFont ( family:String , style:String='', size:int=0 ):void
		{	
			family = family.toLowerCase();
			
			if ( family == '' ) family = fontFamily;
			if ( family == 'arial' ) family = 'helvetica';
			else if ( family == 'symbol' || family == 'zapfdingbats' ) style='';
			style = style.toUpperCase();

			if( style.indexOf ('U')!= -1 )
			{

				underline = true;
				style = findAndReplace( 'U','', style );

			} else underline = false;

			if( style == 'IB' ) style =' BI';
			if( size == 0 ) size = fontSizePt;
			if( fontFamily == family && fontStyle == style && fontSizePt == size ) return;
			
			fontkey = family+style;
			
			if( (fonts[fontkey] == null ))
			{
				if((standardFonts[fontkey] != null ))
				{
					if((FontMetrics[fontkey] == null ))
					{
						file = family;
						if( family == 'times' || family == 'helvetica' ) file += style.toLowerCase();
						if( FontMetrics[fontkey] == null ) throw new Error('Could not include font metric file');

					}
					var i:int = getNumImages(fonts)+1;
					fonts[fontkey]= { i : i, type : 'core', name : standardFonts[fontkey], up : -100, ut : 50, cw : FontMetrics[fontkey] };

				} else throw new Error ('Undefined font: '+family+' '+style);
			}
			
			fontFamily = family;
			fontStyle = style;
			fontSizePt = size;
			fontSize = size/k;
			currentFont = fonts[fontkey];
			if ( nbPages>0 ) write (sprintf('BT /F%d %.2f Tf ET', currentFont.i, fontSizePt));
		}

		/**
		* Lets you set a new size for the current font
		*
		* @param size Font size
		* @example
		* This example shows how to se the current font to 18 :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setFontSize( 18 );
		* </pre>
		* </div>
		*/
		public function setFontSize(size:int):void
		{
			if(fontSizePt == size) return;
			fontSizePt = size;
			fontSize = size/k;
			if(nbPages>0) write (sprintf('BT /F%d %.2f Tf ET',currentFont.i,fontSizePt));
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF text API
		*
		* addText()
		* textStyle()
		* addCell()
		* addMultiCell()
		* writeText()
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/**
		* Lets you set some text to any position on the page
		*
		* @param text The text to add
		* @param x X position
		* @param y Y position
		* @example
		* This example shows how to set some text to a specific place :
		* <div class="listing">
		* <pre>
		*
		* myPDF.addText ('Cubic Bezier curve with curveTo', 14, 110);
		* </pre>
		* </div>
		*/
		public function addText ( text:String, x:Number=0, y:Number=0 ):void	
		{
			var s:String = sprintf('BT %.2f %.2f Td (%s) Tj ET',x*k, (currentPage.h-y)*k, escape(text));
			if (underline && text !='') s += ' '+doUnderline(x,y,text);
			if (colorFlag) s = 'q ' + addTextColor + ' ' + s +' Q';
			write(s);
		}

		/**
		* Sets the text style
		*
		* @param color Color object, can be CMYKColor, GrayColor, or RGBColor
		* @param alpha Text opacity
		* @param rendering pRendering Specify the text rendering mode
		* @param wordSpace Spaces between each words
		* @param characterSpace Spaces between each characters
		* @param scale Text scaling
		* @param leading Text leading
		* @example
		* This example shows how to set a specific black text style with full opacity :
		* <div class="listing">
		* <pre>
		*
		* myPDF.textStyle ( new RGBColor ( 0x000000 ), 1 ); 
		* </pre>
		* </div>
		*/
		public function textStyle ( color:Color, alpha:Number=1, rendering:int=0, wordSpace:Number=0, characterSpace:Number=0, scale:Number=100, leading:Number=0 ):void
		{
			write ( sprintf ( '%d Tr', textRendering = rendering ) );
			textColor ( color );
			setAlpha ( alpha );
			write ( wordSpace + ' Tw ' + characterSpace + ' Tc ' + scale + ' Tz ' + leading + ' TL ' );
			colorFlag = ( fillColor != addTextColor );
		}

		/**
		* Add a cell with some text to the current page
		*
		* @param width Cell width
		* @param height Cell height
		* @param text Text to add into the cell
		* @param ln Sets the new position after cell is drawn, default value is 0
		* @param align Lets you center or align the text into the cell
		* @param fill Lets you specify if the cell is colored (1) or transparent (0)
		* @param link Any http link, like http://www.mylink.com
		* @return Page
		* @example
		* This example shows how to write some text within a cell :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setFont(FontFamily.HELVETICA, 'B', 12);
		* myPDF.textStyle ( new RGBColor ( 0x990000 ) );
		* myPDF.addCell(50,10,'Some text into a cell !',1,1);
		* </pre>
		* </div>
		* This example shows how to write some clikable text within a cell :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setFont(FontFamily.HELVETICA, 'B', 12);
		* myPDF.textStyle ( new RGBColor ( 0x990000 ) );
		* myPDF.addCell(50,10,'A clikable cell !', 1, 1, null, 0, "http://www.alivepdf.org");
		* </pre>
		* </div>
		*/
		public function addCell ( width:Number=0, height:Number=0, text:String='', border:*=0, ln:Number=0, align:String='', fill:Number=0, link:String='' ):void
		{
			//Output a cell
			var k:Number = this.k;

			if( this.currentY + height > this.pageBreakTrigger && !this.inFooter && this.acceptPageBreak() )
			{
				//Automatic page break
				var x:Number = this.currentX;
				ws=this.ws;
				if(ws>0)
				{
					this.ws=0;
					this.write('0 Tw');
				}
				this.addPage( new Page ( this.currentOrientation, this.defaultUnit, this.defaultSize ,currentPage.rotation ) );
				this.currentX = x;
				if(ws>0)
				{
					this.ws=ws;
					this.write(sprintf('%.3f Tw',ws*k));
				}
			}

			if ( currentPage.w==0 ) currentPage.w = currentPage.w-this.rMargin-this.currentX;
			
			var s:String = new String();
			var op:String;

			if( fill == 1 || border == 1 )
			{
				if ( fill == 1 ) op = ( border == 1 ) ? 'B' : 'f';
				else op = 'S';
				
				s = sprintf('%.2f %.2f %.2f %.2f re %s ',this.currentX*k,(currentPage.h-this.currentY)*k,width*k,-height*k,op);
			}

			if ( border is String )
			{
				currentX = this.currentX;
				currentY = this.currentY;

				var tmpBorder:String = String ( border );

				if( tmpBorder.indexOf('L') != -1 ) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',currentX*k,(currentPage.h-currentY)*k,currentX*k,(currentPage.h-(currentY+height))*k);
				if( tmpBorder.indexOf ('T') != -1) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',currentX*k,(currentPage.h-currentY)*k,(currentX+width)*k,(currentPage.h-currentY)*k);
				if( tmpBorder.indexOf ('R') != -1) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',(currentX+width)*k,(currentPage.h-currentY)*k,(currentX+width)*k,(currentPage.h-(currentY+height))*k);
				if( tmpBorder.indexOf ('B') != -1 ) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',currentX*k,(currentPage.h-(currentY+height))*k,(currentX+width)*k,(currentPage.h-(currentY+height))*k);
			}

			if ( text !== '' )
			{
				var dx:Number;
				if ( align=='R' ) dx = width-this.cMargin-this.getStringWidth(text);
				else if( align=='C' ) dx = (width-this.getStringWidth(text))/2;
				else dx = this.cMargin;
				if(this.colorFlag) s+='q '+this.addTextColor+' ';
				var txt2:String = findAndReplace(')','\\)',findAndReplace('(','\\(',findAndReplace('\\','\\\\',text)));
				s+=sprintf('BT %.2f %.2f Td (%s) Tj ET',(this.currentX+dx)*k,(currentPage.h-(this.currentY+.5*height+.3*this.fontSize))*k,txt2);
				if(this.underline) s+=' '+doUnderline(this.currentX+dx,this.currentY+.5*height+.3*this.fontSize,text);
				if(this.colorFlag) s+=' Q';
				if( link ) this.addLink (this.currentX+dx,this.currentY+.5*height-.5*this.fontSize,this.getStringWidth(text),this.fontSize, link);
			}

			if ( s ) this.write(s);

			this.lasth = currentPage.h;

			if( ln >0 )
			{
				//Go to next line
				this.currentY += height;
				if( ln ==1) this.currentX = this.lMargin;

			} else this.currentX += width;
		}

		/**
		* Add a multicell with some text to the current page
		*
		* @param width Cell width
		* @param height Cell height
		* @param text Text to add into the cell
		* @param border Lets you specify if a border should be drawn around the cell
		* @param align Lets you center or align the text into the cell, values can be L (left align), C (centered), R (right align), J (justified) default value
		* @param filled Lets you specify if the cell is colored (1) or transparent (0)
		* @return Page
		* @example
		* This example shows how to write a table made of text cells :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setFont( FontFamily.COURIER, Style.BOLD, 14 );
		* myPDF.textStyle ( new RGBColor ( 0x990000 ) );
		* myPDF.addMultiCell ( 70, 24, "A multicell :)", 1);
		* myPDF.addMultiCell ( 70, 24, "A multicell :)", 1);
		* </pre>
		* </div>
		*/
		public function addMultiCell ( width:Number, height:Number, text:String, border:*=0, align:String='J', filled:int=0):void
		{
			cw = currentFont.cw;

			if ( width==0 ) width = currentPage.w-this.rMargin - this.currentX;

			var wmax:Number = (width-2*this.cMargin)*1000/this.fontSize;
			var s:String = findAndReplace ("\r",'',text);
			var nb:int = s.length;

			if( nb > 0 && s.charAt(nb-1) == "\n" ) nb--;

			var b:* = 0;

			if( border )
			{
				if( border == 1 )
				{
					border='LTRB';
					b='LRT';
					b2='LR';
				}
				else
				{
					b2='';
					if(border.indexOf('L')!= -1) b2+='L';
					if(border.indexOf('R')!= -1) b2+='R';
					b = (border.indexOf('T')!= -1) ? b2+'T' : b2;
				}
			}

			var sep:int = -1;
			var i:int = 0;
			var j:int = 0;
			var l:int = 0;
			var ns:int = 0;
			var nl:int = 1;
			var c:String;
			
			var cwAux:int = 0;

			while (i<nb)
			{
				
			 	c = s.charAt(i);
			 	
				if (c=="\n")
				{
					if (this.ws>0)
					{
						this.ws=0;
						this.write('0 Tw');
					}
					
					this.addCell(width,height,s.substr(j,i-j),b,2,align,filled);
					i++;
					sep=-1;
					j=i;
					l=0;
					ns=0;
					nl++;
					
					if(border && nl==2) b=b2;
					continue;
					
				}
				
				if(c==' ')
				{
					sep=i;
					var ls:int = l;
					ns++;
				}
				
				// TBO
				cwAux = cw[c] as int;
				if (cwAux == 0) cwAux = 580;
				l += cwAux;

				if (l>wmax)
				{
					if(sep==-1)
					{
						if(i==j) i++;
						if(this.ws>0)
						{
							this.ws=0;
							this.write('0 Tw');
						}
						this.addCell(width,height,s.substr(j,i-j),b,2,align,filled);
					}
					else
					{
						if(align=='J')
						{
							this.ws=(ns>1) ? (wmax-ls)/1000*this.fontSize/(ns-1) : 0;
							this.write(sprintf('%.3f Tw',this.ws*this.k));
						}
						
						this.addCell(width,height,s.substr(j,sep-j),b,2,align,filled);
						i=sep+1;
						
					}
					
					sep=-1;
					j=i;
					l=0;
					ns=0;
					nl++;
					if ( border && nl == 2 ) b = b2;
					
				}
				else i++;
			}
			//Last chunk
			if(this.ws>0)
			{
				this.ws=0;
				this.write('0 Tw');
			}

			if ( border && border.indexOf ('B')!= -1 ) b += 'B';
			this.addCell ( width,height,s.substr(j,i-j),b,2,align,filled );
			this.currentX = this.lMargin;
		}

		/**
		* Lets you write some text
		*
		* @param lineHeight Line height, lets you specify height between each lines
		* @param text Text to write, to put a line break just add a \n in the text string
		* @param link Any link, like http://www.mylink.com, will open te browser when clicked
		* @example
		* This example shows how to add some text to the current page :
		* <div class="listing">
		* <pre>
		*
		* myPDF.writeText ( 5, "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.", "http://www.google.fr");
		* </pre>
		* </div>
		* This example shows how to add some text with a clickable link :
		* <div class="listing">
		* <pre>
		*
		* myPDF.writeText ( 5, "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.", "http://www.google.fr");
		* </pre>
		* </div>
		*/
		public function writeText ( lineHeight:Number, text:String, link:String='' ):void
		{
			//Output text in flowing mode
			var cw:Object = this.currentFont.cw;
			var w:Number = currentPage.w-this.rMargin-this.currentX;
			var wmax:Number = (w-2*this.cMargin)*1000/this.fontSize;
			var s:String = findAndReplace ("\r",'', text);
			//var s:String = ",,,"
			var nb:int = s.length;
			var sep:int = -1;
			var i:int = 0;
			var j:int = 0;
			var l:int = 0;
			var nl:int = 1;
			var c:String;

			while( i<nb )
			{
				//Get next character
				c = s.charAt(i);

				if( c == "\n" )
				{
					//Explicit line break
					this.addCell (w,lineHeight,s.substr(j,i-j),0,2,'',0,link);
					i++;
					sep=-1;
					j=i;
					l=0;
					if(nl==1)
					{
						this.currentX = this.lMargin;
						w = currentPage.w-this.rMargin-this.currentX;
						wmax= (w-2*this.cMargin)*1000/this.fontSize;
					}
					nl++;
					continue;
				}
				if(c==' ') sep=i;
				l+=cw[c];
				//trace( cw[c] );
				if( l > wmax )
				{
					//Automatic line break
					if(sep==-1)
					{
						if(this.currentX>this.lMargin)
						{
							//Move to next line
							this.currentX = this.lMargin;
							this.currentY += currentPage.h;
							w = currentPage.w-this.rMargin-this.currentX;
							wmax = (w-2*this.cMargin)*1000/this.fontSize;
							i++;
							nl++;
							continue;
						}
						if(i==j) i++;
						this.addCell (w,lineHeight,s.substr(j,i-j),0,2,'',0,link);
					}
					else
					{
						this.addCell (w,lineHeight,s.substr(j,sep-j),0,2,'',0,link);
						i=sep+1;
					}
					sep=-1;
					j=i;
					l=0;
					if(nl==1)
					{
						this.currentX=this.lMargin;
						w=currentPage.w-this.rMargin-this.currentX;
						wmax=(w-2*this.cMargin)*1000/this.fontSize;
					}
					nl++;
				}
				else i++;
			}
			//Last chunk
			if (i!=j) this.addCell (l/1000*this.fontSize,lineHeight,s.substr(j),0,0,'',0,link);
		}
		
		/**
		* Lets you activate the auto pagination mode
		*
		* @param activate Activate the auto pagination mode
		* @example
		* This example shows how to activate the auto pagination mode :
		* <div class="listing">
		* <pre>
		*
		* myPDF.setAutoPagination ( true );
		* </pre>
		* </div>
		*/
		private function setAutoPagination ( activate:Boolean ):void
		{
			if ( autoPagination != activate ) autoPagination = activate;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF saving API
		*
		* save()
		* textStyle()
		* addCell()
		* addMultiCell()
		* writeText()
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		/**
		* 
		*
		* @param method Can be se to Method.LOCAL, the savePDF will return the PDF ByteArray. When Method.REMOTE is passed, just specify the path to the create.php file
		* @param url The url of the create.php file
		* @param downloadMethod Lets you specify the way the PDF is going to be available. Use Download.INLINE if you want the PDF to be opened in the browser, use Download.ATTACHMENT if you want to make it available with a save-as dialog box
		* @param fileName The name of the PDF, only available when Method.REMOTE is used
		* @return The ByteArray PDF when Method.LOCAL is used, otherwise the method returns null
		* @example
		* This example shows how to save the PDF on the desktop with the AIR runtime :
		* <div class="listing">
		* <pre>
		*
		* var f:FileStream = new FileStream();
  	    * file = File.desktopDirectory.resolvePath("generate.pdf");
  	    * f.open( file, FileMode.WRITE);
  	    * var bytes:ByteArray = myPDF.save( Method.LOCAL );
  	    * f.writeBytes(bytes);
  	    * f.close(); 
		* </pre>
		* </div>
		* 
		* This example shows how to save the PDF through a download dialog-box with Flash or Flex :
		* <div class="listing">
		* <pre>
		*
		* myPDF.save( Method.REMOTE, "http://localhost/save.php", Download.ATTACHMENT );
		* </pre>
		* </div>
		* 
		* This example shows how to view the PDF in the browser with Flash or Flex :
		* <div class="listing">
		* <pre>
		*
		* myPDF.save( Method.REMOTE, "http://localhost/save.php", Download.INLINE );
		* </pre>
		* </div>
		* 
		*/
		public function save ( method:String, url:String='', downloadMethod:String='inline', fileName:String='generated.pdf' ):*
		{
			dispatcher.dispatchEvent( new ProcessingEvent ( ProcessingEvent.STARTED ) );

			var started:Number = getTimer();

			finish();
			
			dispatcher.dispatchEvent ( new ProcessingEvent ( ProcessingEvent.COMPLETE, getTimer() - started ) );
			
			buffer.position = 0;

			if ( method == Method.LOCAL ) return buffer;
			else if ( method == Method.BASE_64 ) return Base64.encode64 ( buffer );

			var header:URLRequestHeader = new URLRequestHeader ("Content-type", "application/octet-stream");
			var myRequest:URLRequest = new URLRequest ( url+'?name='+fileName+'&method='+downloadMethod );
			myRequest.requestHeaders.push (header);
			myRequest.method = URLRequestMethod.POST;
			myRequest.data = save( Method.LOCAL );

			navigateToURL ( myRequest, "_blank" );

			return null;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF image API
		*
		* addImage()
		* textStyle()
		* addCell()
		* addMultiCell()
		* writeText()
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * The addImage method takes an incoming DisplayObject. A JPG or PNG snapshot is done and included in the PDF document
		 * 
		 * @param displayObject
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param imageFormat
		 * @param quality
		 * @param alpha
		 * @param resizeMode
		 * @param blendMode
		 * @param keepTransformation
		 * @param link
		 * @example
		 * This example shows how to add a 100% compression quality JPG image into the current page at a position of 0,0 with no resizing behavior :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addImage ( displayObject, 0, 0, 0, 0, ImageFormat.JPG, 100, .2 );
		 * </pre>
		 * </div>
		 */	 
		public function addImage ( displayObject:DisplayObject, x:Number=0, y:Number=0, width:Number=0, height:Number=0, imageFormat:String="PNG", quality:Number=100, alpha:Number=1, resizeMode:String="None", blendMode:String="Normal", keepTransformation:Boolean=true, link:String='' ):void
		{
			var bytes:ByteArray;
			
			var bitmapDataBuffer:BitmapData = new BitmapData ( displayObject.width, displayObject.height, false );
			
			bitmapDataBuffer.draw ( displayObject, keepTransformation ? displayObject.transform.matrix : null );
			
			if ( imageFormat == ImageFormat.PNG ) 
			{
				bytes = PNGEncoder.encode ( bitmapDataBuffer, 1 );
			} else
			{
				var encoder:JPEGEncoder = new JPEGEncoder ( quality );
				bytes = encoder.encode ( bitmapDataBuffer ); 
			}
			
			addImageStream ( bytes, x, y, width, height, alpha, resizeMode, blendMode, keepTransformation, link );
		}
		
		/**
		 * The addImageStream method takes an incoming image as a ByteArray. This method can be used to embed high-quality images (300 dpi) to the PDF
		 * 
		 * @param imageBytes
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param alpha
		 * @param resizeMode
		 * @param blendMode
		 * @param keepTransformation
		 * @param link
		 * @example
		 * This example shows how to add an image as a ByteArray into the current page with a page resize behavior :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addImageStream( bytes, 0, 0, 0, 0, 1, ImageResize.RESIZE_PAGE );
		 * </pre>
		 * </div>
		 */	 
		public function addImageStream ( imageBytes:ByteArray, x:Number=0, y:Number=0, width:Number=0, height:Number=0, alpha:Number=1, resizeMode:String="None", blendMode:String="Normal", keepTransformation:Boolean=true, link:String='', isMask:Boolean=false ):void	
		{
			setAlpha ( alpha, blendMode );

			if( streamDictionary[imageBytes] == null )
			{
				imageBytes.position = 0;
				
				var id:int = getNumImages ( streamDictionary )+1;
				
				if ( imageBytes.readUnsignedShort() == PDF.JPG_HEADER ) image = new JPEGImage ( imageBytes, id );
				
				else if ( !(imageBytes.position = 0) && imageBytes.readUnsignedShort() == PDF.PNG_HEADER ) image = new PNGImage ( imageBytes, id );
				
				else throw new Error ("Image format not supported for now.");

				streamDictionary[imageBytes] = image;

			} else image = streamDictionary[imageBytes];

			if ( width == 0 && height == 0 )
			{
				width = image.width/k;
				height = image.height/k;
			}
			
			if ( width == 0 ) width = height*image.width/image.height;
			if ( height == 0 ) height = width*image.height/image.width;

			if ( resizeMode == ResizeMode.RESIZE_PAGE )
			{
				currentPage.resize( image.width, image.height );
				
				currentPage.w = currentPage.wPt/k;
				currentPage.h = currentPage.hPt/k;

			} else if ( resizeMode == ResizeMode.FIT_TO_PAGE )
			{		
				var ratio:Number = Math.min ( currentPage.width / image.width, currentPage.height / image.height );

				width *= ratio;
				height *= ratio;
			}
			
			write (sprintf('q %.2f 0 0 %.2f %.2f %.2f cm', width*k, height*k, x*k, (currentPage.h-(y+height))*k));
			write (sprintf('/I%d Do Q', image.i));

			if ( link != '' ) addLink( x, y, width, height, link );
		}
		
		public function toString ():String 
		{
			return "[PDF totalPages="+totalPages+" pdfVersion="+pdfVersion+" alivepdfVersion="+PDF.ALIVEPDF_VERSION+"]";	
		} 

		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* Private members
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		private function finish():void
		{
			if ( state < 3 ) close();
		}
		
		public function setUnit ( unit:String ):String
		{
			if ( unit == Unit.POINT ) k = 1;
			else if ( unit == Unit.MM ) k = 72/25.4;
			else if ( unit == Unit.CM ) k = 72/2.54;
			else if ( unit == Unit.INCHES ) k = 72;
			else throw new RangeError ('Incorrect unit: ' + unit);
			
			return unit;	
		}
		
		private function acceptPageBreak():Boolean
		{
			return autoPageBreak;	
		}

		private function curve ( x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number ):void
		{
			var h:Number = currentPage.h;

			write(sprintf('%.2f %.2f %.2f %.2f %.2f %.2f c ', x1*k, (h-y1)*k, x2*k, (h-y2)*k, x3*k, (h-y3)*k));
		}

		private function getStringWidth( content:String ):Number
		{
			cw = currentFont.cw
			var w:Number = 0;
			var l:int = content.length;
			
			// TBO
			var cwAux:Number = 0;
			
			while (l--) 
			{
				cwAux += cw[content.charAt(l)] as Number;
				if ( isNaN ( cwAux ) ) cwAux = 580;
			}
						
			w += cwAux;
			return w*fontSize/1000;
		}

		private function open():void
		{
			state = 1;	
		}

		private function close ():void
		{
			if( state == 3 ) return;
			if( arrayPages.length == 0 ) addPage();
			finishPage();
			finishDocument();	
		}

		private function addExtGState( graphicState:Object ):int
		{
			extgstates.push ( graphicState );
			return extgstates.length-1;
		}

		private function setExtGState( graphicState:int ):void
		{
			write(sprintf('/GS%d gs', graphicState));	
		}

		private function insertExtGState():void
		{
			var lng:int = extgstates.length;
			
			for ( var i:int = 0; i < lng; i++)
			{
				newObj();
				extgstates[i].n = n;
				write('<</Type /ExtGState');
				for (var k:String in extgstates[i]) write('/'+k+' '+extgstates[i][k]);
				write('>>');
				write('endobj');
			}
		}

		private function getChannels ( color:Number ):String
		{
			var r:Number = (color & 0xFF0000) >> 16;
			var g:Number = (color & 0x00FF00) >> 8;
			var b:Number = (color & 0x0000FF);

			return (r / 255) + " " + (g / 255) + " " + (b / 255);
		}

		private function getCurrentDate ():String
		{
			var myDate:Date = new Date();

			var year:Number = myDate.getFullYear();
			var month:*= myDate.getMonth() < 10 ? "0"+Number(myDate.getMonth()+1) : myDate.getMonth()+1;
			var day:Number = myDate.getDate();
			var hours:* = myDate.getHours() < 10 ? "0"+Number(myDate.getHours()) : myDate.getHours();
			var currentDate:String = myDate.getFullYear()+''+month+''+day+''+hours+''+myDate.getMinutes();

			return currentDate;
		}

		private function findAndReplace ( search:String, replace:String, source:String ):String
		{
			return source.replace( new RegExp ( search ), replace );
		}

		private function createPageTree():void
		{
			compressedPages = new ByteArray();

			nb = arrayPages.length;

			if( aliasNbPages != null )
			{
				for( n = 0; n<nb; n++ ) arrayPages[n].content = findAndReplace ( aliasNbPages, ( nb as String ), arrayPages[n].content );
			}

			filter = (compress) ? '/Filter /FlateDecode ' : '';

			offsets[1] = buffer.length;
			write('1 0 obj');
			write('<</Type /Pages');
			write('/Kids ['+references+']');
			write('/Count '+nb);
			write('>>');
			write('endobj');
			
			var p:String;
			var page:Page;

			for( var i:int = 0; i < nb; i++ )
			{
				page = arrayPages[i];

				newObj();
				write('<</Type /Page');
				write('/Parent 1 0 R');
				write (sprintf ('/MediaBox [0 0 %.2f %.2f]', page.width, page.height) );
				write ('/Resources 2 0 R');
				if ( page.annotations != '' ) write ('/Annots [' + page.annotations + ']');
				write ('/Rotate ' + page.rotation);
				write ('/Dur ' + 3);
				if ( page.transitions.length ) write ( page.transitions );
				write ('/Contents '+(n+1)+' 0 R>>');
				write ('endobj');
				
				if ( compress ) 
				{
					compressedPages.writeMultiByte( page.content+"\n", "windows-1250" );
					compressedPages.compress();
					compressedPages.position = 0;
					newObj();
					write('<<'+filter+'/Length '+compressedPages.length+'>>');
					write('stream');
					buffer.writeBytes( compressedPages );
					buffer.writeUTFBytes("\n");
					write('endstream');
					write('endobj');					
				} else 
				{
					newObj();
					write('<<'+filter+'/Length '+page.content.length+'>>');
					writeStream(page.content.substr(0, page.content.length-1));
					write('endobj');
				}
			}
		}

		private function writeXObjectDictionary():void
		{
			for each ( var image:Object in streamDictionary ) write('/I'+image.i+' '+image.n+' 0 R');
		}

		private function writeResourcesDictionary():void
		{
			write('/ProcSet [/PDF /Text /ImageB /ImageC /ImageI]');
			write('/Font <<');
			for each( var font:* in fonts ) write('/F'+font.i+' '+font.n+' 0 R');
			write('>>');
			write('/XObject <<');
			writeXObjectDictionary();
			write('>>');
			write('/ExtGState <<');
			for (var k:String in extgstates) write('/GS'+k+' '+extgstates[k].n +' 0 R');
			write('>>');
		}

		private function insertImages ():void
		{
			var filter:String = (compress) ? '/Filter /FlateDecode ' : '';
			
			var stream:ByteArray;

			for each ( var image:PDFImage in streamDictionary )
			{
				newObj();
				image.n = n;
				write('<</Type /XObject');
				write('/Subtype /Image');
				write('/Width '+image.width);
				write('/Height '+image.height);

				if( image.cs =='Indexed' ) write ('/ColorSpace [/Indexed /DeviceRGB '+((image as PNGImage).pal.length/3-1)+' '+(n+1)+' 0 R]');
				else
				{
					write('/ColorSpace /'+image.cs);
					if( image.cs == 'DeviceCMYK' ) write ('/Decode [1 0 1 0 1 0 1 0]');
				}

				write ('/BitsPerComponent '+image.bpc);
				
				if (image.f != null ) write ('/Filter /'+image.f);
				
				if ( image is PNGImage || image is GIFImage )		
				{
					if ( image.parameters != null ) write (image.parameters);

					if ( image.trns != null && image.trns is Array )
					{
						var trns:String = '';
						var lng:int = image.trns.length;
						for(var i:int=0;i<lng;i++) trns += image.trns[i]+' '+image.trns[i]+' ';
						write('/Mask ['+trns+']');	
					}
				}

				stream = image.bytes;
				write('/Length '+stream.length+'>>');
				write('stream');
				buffer.writeBytes (stream);
				buffer.writeUTFBytes ("\n");
				write("endstream");
				write('endobj');

				if(image.cs == 'Indexed' )
				{
					newObj();
					var pal:String = compress ? (image as PNGImage).pal : (image as PNGImage).pal
					write('<<'+filter+'/Length '+pal.length+'>>');
					writeStream(pal);
					write('endobj');
				}
			}
		}

		private function insertFonts ():void
		{
			var nf:int = this.n;

			for (var diff:String in this.diffs)
			{
				this.newObj();
				this.write('<</Type /Encoding /BaseEncoding /WinAnsiEncoding /Differences ['+diff+']>>');
				this.write('endobj');
			}

			for ( var p:String in this.fonts )
			{
				var font:Object = this.fonts[p];

				font.n = this.n+1;
				
				var type:String = font.type;
				var name:String = font.name;

				if( type == 'core' )
				{
					//Standard font
					this.newObj();
					this.write('<</Type /Font');
					this.write('/BaseFont /'+name);
					this.write('/Subtype /Type1');
					if( name != 'Symbol' && name != 'ZapfDingbats' ) this.write ('/Encoding /WinAnsiEncoding');
					this.write('>>');
					this.write('endobj');
				}
				else if( type == 'Type1' || type == 'TrueType' )
				{
					//Additional Type1 or TrueType font
					this.newObj();
					this.write('<</Type /Font');
					this.write('/BaseFont /'+name);
					this.write('/Subtype /'+type);
					this.write('/FirstChar 32 /LastChar 255');
					this.write('/Widths '+(this.n+1)+' 0 R');
					this.write('/FontDescriptor '+(this.n+2)+' 0 R');

					if( font.enc )
					{
						if( font.diff != null ) this.write ('/Encoding '+(nf+font.diff)+' 0 R');
						else this.write ('/Encoding /WinAnsiEncoding');
					}

					this.write('>>');
					this.write('endobj');
					//Widths
					this.newObj();
					var cw:Object = font.cw;
					var s:String = '[';
					for(var i:int=32; i<=255; i++) s += cw[String.fromCharCode(i)]+' ';
					this.write(s+']');
					this.write('endobj');
					//Descriptor
					this.newObj();
					s = '<</Type /FontDescriptor /FontName /'+name;
					for (var q:String in font.desc ) s += ' /'+q+' '+font.desc[q];
					var file:Object = font.file;
					if (file) s +=' /FontFile'+(type=='Type1' ? '' : '2')+' '+this.fontFiles[file].n+' 0 R';
					this.write(s+'>>');
					this.write('endobj');
				}
				else throw new Error("Unsupported font type: " + type );
			}
		}

		private function writeResources():void
		{
			insertExtGState();
			insertFonts();
			insertImages();
			offsets[2] = buffer.length;
			write('2 0 obj');
			write('<<');
			writeResourcesDictionary();
			write('>>');
			write('endobj');
			insertBookmarks();
		}

		private function insertBookmarks ():void
		{
			var nb:int = outlines.length;
			if ( nb == 0 ) return;

			var lru:Array = new Array;
			var level:Number = 0;
			var o:Object;

			for ( var i:String in outlines )
			{
				o = outlines[i];

				if(o.l > 0)
				{
					var parent:* = lru[o.l-1];
					//Set parent and last pointers
					outlines[i].parent=parent;
					outlines[parent].last=i;
					if(o.l > level)
					{
						//Level increasing: set first pointer
						outlines[parent].first=i;
					}
				}
				else outlines[i].parent=nb;
				if(o.l<=level && int(i)>0)
				{
					//Set prev and next pointers
					var prev:int =lru[o.l];
					outlines[prev].next=i;
					outlines[i].prev=prev;
				}
				lru[o.l]=i;
				level=o.l;
			}
			
			//Outline items
			var n:int = n+1;
			var p:Object;
			
			for ( var j:String in outlines )
			{
				p = outlines[j];

				newObj();
				write('<</Title '+escapeString(p.t));
				write('/Parent '+(n+o.parent)+' 0 R');
				if(p.prev != null ) write('/Prev '+(n+p.prev)+' 0 R');
				if(p.next != null ) write('/Next '+(n+p.next)+' 0 R');
				if(p.first != null ) write('/First '+(n+p.first)+' 0 R');
				if(p.last != null ) write('/Last '+(n+p.last)+' 0 R');
				write ('/C ['+p.redMultiplier+' '+p.greenMultiplier+' '+p.blueMultiplier+']');
				write(sprintf('/Dest [%d 0 R /XYZ 0 %.2f null]',1+2*p.p,(currentPage.h-p.y)*k));
				write('/Count 0>>');
				write('endobj');
			}
			//Outline root
			newObj();
			outlineRoot = n;
			write('<</Type /Outlines /First '+n+' 0 R');
			write('/Last '+(n+lru[0])+' 0 R>>');
			write('endobj');
		}

		private function insertInfos():void
		{
			write ('/Producer '+escapeString('Alive PDF '+PDF.ALIVEPDF_VERSION));
			if ((documentTitle != null)) write('/Title '+escapeString(documentTitle));
			if ((documentSubject != null)) write('/Subject '+escapeString(documentSubject));
			if ((documentAuthor != null)) write('/Author '+escapeString(documentAuthor));
			if ((documentKeywords != null)) write('/Keywords '+escapeString(documentKeywords));
			if ((documentCreator != null)) write('/Creator '+escapeString(documentCreator));
			write('/CreationDate '+escapeString('D:'+getCurrentDate()));
		}

		private function createCatalog ():void
		{
			write('/Type /Catalog');
			write('/Pages 1 0 R');
			
			if ( zoomMode == Display.FULL_PAGE ) write('/OpenAction [3 0 R /Fit]');
			else if ( zoomMode == Display.FULL_WIDTH ) write('/OpenAction [3 0 R /FitH null]');
			else if ( zoomMode == Display.REAL ) write('/OpenAction [3 0 R /XYZ null null 1]');
			else if ( !(zoomMode is String) ) write('/OpenAction [3 0 R /XYZ null null '+(zoomMode/100)+']');
			
			write('/PageLayout /'+layoutMode);

			if ( viewerPreferences.length ) write ( viewerPreferences );
			
			if ( outlines.length )
			{
				write('/Outlines '+outlineRoot+' 0 R');
				write('/PageMode /UseOutlines');
			}
		}

		private function createHeader():void
		{
			write('%PDF-'+pdfVersion);
		}

		private function createTrailer():void
		{
			write('/Size '+(n+1));
			write('/Root '+n+' 0 R');
			write('/Info '+(n-1)+' 0 R');
		}

		private function finishDocument():void
		{	
			if ( pageMode == PageMode.USE_ATTACHMENTS ) pdfVersion = "1.6";
			else if ( layoutMode == Layout.TWO_PAGE_LEFT || layoutMode == Layout.TWO_PAGE_RIGHT ) pdfVersion = "1.5";
			else if ( extgstates.length && pdfVersion < "1.4" ) pdfVersion = "1.4";
			else if ( outlines.length ) pdfVersion = "1.4";
			
			createHeader();
			var started:Number = getTimer();
			createPageTree();
			dispatcher.dispatchEvent ( new ProcessingEvent ( ProcessingEvent.PAGE_TREE, getTimer() - started ) );
			started = getTimer();
			writeResources();
			dispatcher.dispatchEvent ( new ProcessingEvent ( ProcessingEvent.RESOURCES, getTimer() - started ) );
			
			//Info
			newObj();
			write('<<');
			insertInfos();
			write('>>');
			write('endobj');
			//Catalog
			newObj();
			write('<<');
			createCatalog();
			write('>>');
			write('endobj');
			//Cross-ref
			var o:int = buffer.length;
			write('xref');
			write('0 '+(n+1));
			write('0000000000 65535 f ');
			for(var i:int=1;i<=n;i++) write(sprintf('%010d 00000 n ',offsets[i]));
			//Trailer
			write('trailer');
			write('<<');
			createTrailer();
			write('>>');
			write('startxref');
			write(o);
			write('%%EOF');
			state = 3;
		}

		private function startPage ( newOrientation:String ):Page
		{
			nbPages = arrayPages.length;
			state = 2;
			currentX = lMargin;
			currentY = tMargin;
			fontFamily = '';

			if ( newOrientation == '' ) newOrientation = defaultOrientation;
			else if ( newOrientation != defaultOrientation ) orientationChanges[nbPages] = true;
			
			pageBreakTrigger = arrayPages[nbPages-1].h-bMargin;
			currentOrientation = newOrientation;
			
			return arrayPages[nbPages-1];
		}

		private function finishPage():void
		{
			state = 1;
		}

		private function newObj():void
		{
			offsets[++n] = buffer.length;
			write (n+' 0 obj');
		}

		private function doUnderline( x:Number, y:Number, content:String ):String
		{
			up = currentFont.up
			ut = currentFont.ut
			currentPage.w = getStringWidth(content)+ws*substrCount(content,' ');
			return sprintf('%.2f %.2f %.2f %.2f re f',x*k,(currentPage.h-(y-up/1000*fontSize))*k,currentPage.w*k,-ut/1000*fontSizePt);
		}

	   private function substrCount ( content:String, search:String ):int
	   {
			return content.split (search).length;	
	   }

		private function getNumImages ( object:Object ):int
		{
			var num:int = 0;
			for (var p:String in object) num++;
			return num;
		}

		private function escapeString(content:String):String
		{
			return '('+escape(content)+')';
		}

		private function escape(content:String):String
		{
			return findAndReplace(')','\\)',findAndReplace('(','\\(',findAndReplace('\\','\\\\',content)));
		}

		private function writeStream(stream:String):void
		{
			write('stream');
			write(stream);
			write('endstream');
		}

		private function write( content:* ):void
		{
			if ( currentPage == null ) throw new Error ("No pages available, please call the addPage method first !");
			if ( state == 2 ) currentPage.content += content+"\n";
			else buffer.writeMultiByte( content+"\n", "windows-1252s" );
		}

		//--
		//-- IEventDispatcher
		//--

		public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		public function dispatchEvent( event:Event ):Boolean
		{
			return dispatcher.dispatchEvent( event );
		}

		public function hasEventListener( type:String ):Boolean
		{
			return dispatcher.hasEventListener( type );
		}

		public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void
		{
			dispatcher.removeEventListener( type, listener, useCapture );
		}

		public function willTrigger( type:String ):Boolean
		{
			return dispatcher.willTrigger( type );
		}

	}

}