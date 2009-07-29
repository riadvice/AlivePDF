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
 * This library lets you generate PDF files with the Adobe Flash Player 9 and 10.
 * AlivePDF contains some code from the FPDF PHP library by Olivier Plathey (http://www.fpdf.org/)
 * Core Team : Thibault Imbert, Mark Lynch, Alexandre Pires, Marc Hugues
 * @version 0.1.5 current release
 * @url http://alivepdf.bytearray.org
 */

package org.alivepdf.pdf
{
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.alivepdf.cells.CellVO;
	import org.alivepdf.colors.CMYKColor;
	import org.alivepdf.colors.GrayColor;
	import org.alivepdf.colors.IColor;
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.data.Grid;
	import org.alivepdf.data.GridColumn;
	import org.alivepdf.decoding.Filter;
	import org.alivepdf.display.Display;
	import org.alivepdf.display.PageMode;
	import org.alivepdf.drawing.DashedLine;
	import org.alivepdf.drawing.WindingRule;
	import org.alivepdf.encoding.Base64;
	import org.alivepdf.encoding.JPEGEncoder;
	import org.alivepdf.encoding.PNGEncoder;
	import org.alivepdf.events.PageEvent;
	import org.alivepdf.events.ProcessingEvent;
	import org.alivepdf.fonts.CoreFont;
	import org.alivepdf.fonts.EmbeddedFont;
	import org.alivepdf.fonts.FontDescription;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.fonts.FontMetrics;
	import org.alivepdf.fonts.FontType;
	import org.alivepdf.fonts.IFont;
	import org.alivepdf.images.ColorSpace;
	import org.alivepdf.images.DoJPEGImage;
	import org.alivepdf.images.DoPNGImage;
	import org.alivepdf.images.GIFImage;
	import org.alivepdf.images.ImageFormat;
	import org.alivepdf.images.JPEGImage;
	import org.alivepdf.images.PDFImage;
	import org.alivepdf.images.PNGImage;
	import org.alivepdf.images.gif.player.GIFPlayer;
	import org.alivepdf.layout.Align;
	import org.alivepdf.layout.Layout;
	import org.alivepdf.layout.Mode;
	import org.alivepdf.layout.Position;
	import org.alivepdf.layout.Resize;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.operators.Drawing;
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
	 * 
	 * Multiple Wiimotes can be handled as well. It is possible to create up to four Wiimote objects.
	 * If more than four Wiimote objects have been created an error will be thrown. After one Wiimote
	 * object made a successful connection to the WiiFlash Server all the other Wiimote objects will
	 * fire the connect event immediately.
	 * 
	 * @author Thibault Imbert
	 * 
	 * @example
	 * This example shows how to create a PDF document :
	 * <div class="listing">
	 * <pre>
	 * 
	 * var myPDF:PDF = new PDF( Orientation.LANDSCAPE, Unit.MM, Size.A4 );
	 * </pre>
	 * </div>
	 * 
	 * This example shows how to listen for events during PDF creation :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener( ProcessingEvent.STARTED, generationStarted );
	 * myPDF.addEventListener( ProcessingEvent.PAGE_TREE, pageTreeGeneration );
	 * myPDF.addEventListener( ProcessingEvent.RESOURCES, resourcesEmbedding );
	 * myPDF.addEventListener( ProcessingEvent.COMPLETE, generationComplete );
	 * </pre>
	 * </div>
	 * 
	 * This example shows how to listen for an event when a page is added to the PDF :
	 * <div class="listing">
	 * <pre>
	 *
	 * myPDF.addEventListener( PageEvent.ADDED, pageAdded );
	 * </pre>
	 * </div>
	 */	
	public class PDF implements IEventDispatcher
	{
		
		protected static const PDF_VERSION:String = '1.3';
		protected static const ALIVEPDF_VERSION:String = '0.1.5';
		
		protected var format:Array;
		protected var size:Size;
		protected var margin:Number;
		protected var nbPages:int;
		protected var n:int;                 
		protected var offsets:Array;     
		protected var state:int;      
		protected var compress:Boolean;
		protected var defaultOrientation:String;
		protected var defaultSize:Size;
		protected var defaultRotation:int;
		protected var defaultUnit:String;
		protected var currentOrientation:String;
		protected var orientationChanges:Array;
		protected var strokeColor:IColor;
		protected var strokeStyle:String;
		protected var strokeAlpha:Number;
		protected var strokeFlatness:Number;
		protected var strokeBlendMode:String;
		protected var strokeDash:DashedLine;
		protected var strokeCaps:String;
		protected var strokeJoints:String;
		protected var strokeMiter:Number;
		protected var textAlpha:Number;
		protected var textLeading:Number;
		protected var textColor:IColor;
		protected var textScale:Number;
		protected var textSpace:Number;
		protected var textWordSpace:Number;
		protected var k:Number;             
		protected var leftMargin:Number;        
		protected var topMargin:Number;    
		protected var rightMargin:Number;        
		protected var bottomMargin:Number;    
		protected var currentMargin:Number;            
		protected var currentX:Number;
		protected var currentY:Number;
		protected var currentMatrix:Matrix;
		protected var lasth:Number;       
		protected var strokeThickness:Number;  
		protected var fonts:Array;          
		protected var fontFiles:Object;    
		protected var differences:Array;         
		protected var links:Array;           
		protected var fontFamily:String;     
		protected var fontStyle:String;       
		protected var underline:Boolean;       
		protected var fontSizePt:Number;      
		protected var windingRule:String;       
		protected var fillColor:String;       
		protected var addTextColor:String;       
		protected var colorFlag:Boolean;     
		protected var ws:Number;
		protected var helvetica:IFont;
		protected var autoPageBreak:Boolean;
		protected var pageBreakTrigger:Number;
		protected var inHeader:Boolean;    
		protected var inFooter:Boolean;    
		protected var zoomMode:*;     
		protected var zoomFactor:Number;     
		protected var layoutMode:String;         
		protected var pageMode:String;
		protected var documentTitle:String;            
		protected var documentSubject:String;       
		protected var documentAuthor:String;      
		protected var documentKeywords:String;    
		protected var documentCreator:String;     
		protected var aliasNbPages:String;   
		protected var version:String;
		protected var buffer:ByteArray;
		protected var streamDictionary:Dictionary;
		protected var compressedPages:ByteArray;
		protected var image:PDFImage;
		protected var fontSize:Number;
		protected var name:String;
		protected var type:String;
		protected var desc:String;
		protected var underlinePosition:Number;
		protected var underlineThickness:Number;
		protected var charactersWidth:Object;
		protected var d:Number;
		protected var nb:int;
		protected var size1:Number;
		protected var size2:Number;
		protected var currentFont:IFont;
		protected var defaultFont:IFont;
		protected var b2:String;
		protected var pageLinks:Array;
		protected var filter:String;
		protected var filled:Boolean
		protected var dispatcher:EventDispatcher;
		protected var arrayPages:Array;
		protected var arrayNotes:Array;
		protected var graphicStates:Array;
		protected var currentPage:Page;
		protected var outlines:Array;
		protected var outlineRoot:int;
		protected var textRendering:int;
		protected var viewerPreferences:String;
		protected var reference:String;
		protected var embeddedFileNameTree:int;
		protected var pagesReferences:Array;
		protected var nameDictionary:String;
		protected var displayObjectbounds:Rectangle;
		protected var coreFontMetrics:FontMetrics;
		protected var columnNames:Array;
		protected var columns:Array;
		protected var currentGrid:Grid;
		protected var isEven:int;
		protected var matrix:Matrix;
		protected var pushedFontName:String;
		protected var fontUnderline:Boolean;
		protected var jsResource:int;
		protected var javascript:String;
		
		protected var widths:*;
		protected var aligns:Array = new Array();
		protected var arrayMedia:Array = new Array();
		
		/**
		 * The PDF class represents a PDF document.
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
		
		public function PDF ( orientation:String='Portrait', unit:String='Mm', pageSize:Size=null, rotation:int=0 )
		{
			size = ( pageSize != null ) ? Size.getSize(pageSize).clone() : Size.A4.clone();
			
			if ( size == null  ) throw new RangeError ('Unknown page format : ' + pageSize +', please use a org.alivepdf.layout.' + 
				'Size object or any of those strings : Size.A3, Size.A4, Size.A5, Size.Letter, Size.Legal, Size.Tabloid');
			
			dispatcher = new EventDispatcher ( this );
			
			viewerPreferences = new String();
			outlines = new Array();
			arrayPages = new Array();
			arrayNotes = new Array();
			graphicStates = new Array();
			orientationChanges = new Array();
			nbPages = arrayPages.length;
			buffer = new ByteArray();
			offsets = new Array();
			fonts = new Array();
			pageLinks = new Array();
			fontFiles = new Object();
			differences = new Array();
			streamDictionary = new Dictionary();
			links = new Array();
			inHeader = inFooter = false;
			fontFamily = new String();
			fontStyle = new String();
			underline = false;
			strokeStyle = new String ('0 G');
			fillColor = new String ('0 g');
			addTextColor = new String ('0 g');
			colorFlag = false;
			matrix = new Matrix();
			
			pagesReferences = new Array();
			compressedPages = new ByteArray();
			coreFontMetrics = new FontMetrics();
			
			defaultUnit = setUnit ( unit );
			defaultSize = size;
			defaultOrientation = orientation;
			defaultRotation = rotation;
			
			n = 2;
			state = 0;
			lasth = 0;
			fontSizePt = 12;
			ws = 0;
			
			margin = 28.35/k;
			
			setMargins ( margin, margin );
			
			currentMargin = margin/10;
			
			strokeThickness = .567/k;
			
			setAutoPageBreak ( true, margin * 2 );
			
			setDisplayMode( Display.FULL_WIDTH );
			
			version = PDF.PDF_VERSION;
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
			leftMargin = left;
			topMargin = top;
			if( right == -1 ) right = left;
			bottomMargin = bottom;
			rightMargin = right;
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
			return new Rectangle( leftMargin, topMargin, getCurrentPage().width - rightMargin - leftMargin, getCurrentPage().height - bottomMargin - topMargin );
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
			leftMargin = margin;
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
			topMargin = margin;
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
			bottomMargin = margin;
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
			rightMargin = margin;
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
			bottomMargin = margin;
			if ( currentPage != null ) pageBreakTrigger = currentPage.h-margin;
		}
		
		/**
		 * Lets you set a specific display mode, the DisplayMode takes care of the general layout of the PDF in the PDF reader
		 *
		 * @param zoom Zoom mode, can be Display.FULL_PAGE, Display.FULL_WIDTH, Display.REAL, Display.DEFAULT
		 * @param layout Layout of the PDF document, can be Layout.SINGLE_PAGE, Layout.ONE_COLUMN, Layout.TWO_COLUMN_LEFT, Layout.TWO_COLUMN_RIGHT
		 * @param mode PageMode can be pageMode.USE_NONE, PageMode.USE_OUTLINES, PageMode.USE_THUMBS, PageMode.FULL_SCREEN
		 * @param zoomValue Zoom factor to be used when the PDF is opened, a value of 1.5 would open the PDF with a 150% zoom
		 * @example
		 * This example creates a PDF which opens at full page scaling, one page at a time :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setDisplayMode ( Display.FULL_PAGE, Layout.SINGLE_PAGE );
		 * </pre>
		 * </div>
		 * To create a full screen PDF you would write :
		 * <div class="listing">
		 * <pre>
		 * 
		 * myPDF.setDisplayMode( Display.FULL_PAGE, Layout.SINGLE_PAGE, PageMode.FULLSCREEN );
		 * </pre>
		 * 
		 * To create a PDF which will open with a 150% zoom, you would write :
		 * <div class="listing">
		 * <pre>
		 * 
		 * myPDF.setDisplayMode( Display.REAL, Layout.SINGLE_PAGE, PageMode.USE_NONE, 1.5 );
		 * </pre>
		 * </div>
		 */
		public function setDisplayMode ( zoom:String='FullWidth', layout:String='SinglePage', mode:String='UseNone', zoomValue:Number=1 ):void
		{
			zoomMode = zoom;
			zoomFactor = zoomValue;
			layoutMode = layout;
			pageMode = mode;
		}
		
		/**
		 * Lets you set specify the timing (in seconds) a page is shown when the PDF is shown in fullscreen mode
		 *
		 * @param title The title
		 * @example
		 * This example shows how to set a specific advance timing (5 seconds) for the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.setAdvanceTiming ( 5 );
		 * </pre>
		 * 
		 * You can also specify this on the Page object :
		 * <div class="listing">
		 * <pre>
		 *
		 * var page:Page = new Page ( Orientation.PORTRAIT, Unit.MM );
		 * page.setAdvanceTiming ( 5 );
		 * myPDF.addPage ( page );
		 * </pre>
		 * </div>
		 */
		public function setAdvanceTiming ( timing:int ):void
		{
			currentPage.advanceTiming = timing;
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
			
			pagesReferences.push ( (3+(arrayPages.length<<1))+' 0 R' );
			
			arrayPages.push ( currentPage = page );
			
			if ( state == 0 ) open();
			
			var family:String = fontFamily;
			var size:Number = fontSizePt;
			var lw:Number = strokeThickness;
			var dc:String = strokeStyle;
			var fc:String = fillColor;
			var tc:String = addTextColor;
			var cf:Boolean = colorFlag;
			
			if( nbPages > 0 )
			{
				inFooter = true;
				footer();
				inFooter = false;
				finishPage();
			}
			
			startPage ( page != null ? page.orientation : defaultOrientation );
			
			if ( strokeColor != null ) lineStyle ( strokeColor, strokeThickness, strokeFlatness, strokeAlpha, windingRule, strokeBlendMode, strokeDash, strokeCaps, strokeJoints, strokeMiter );
			if ( textColor != null ) textStyle ( textColor, textAlpha, textRendering, textSpace, textSpace, textScale, textLeading );
			if ( currentFont != null ) setFont ( currentFont, fontSizePt );
			
			inHeader = true;
			header();
			inHeader = false;
			
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
		 * for each ( var p:Page in pdfPages ) trace( p );
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
			else throw new RangeError ("No pages available.");
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
		 * var totalPages:int = myPDF.totalPages;
		 * </pre>
		 * </div>
		 */
		public function get totalPages():int
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
			currentX = leftMargin;
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
			if (acceptPageBreak()) currentX = ( x >= 0 ) ? x : currentPage.w + x;	
			else currentX = x;
		}
		
		/**
		 * Lets you specify the Y position for the current page
		 *
		 * @param y The Y position
		 */
		public function setY ( y:Number ):void
		{
			if (acceptPageBreak()) 
			{
				currentX = leftMargin;
				currentY = ( y >= 0 ) ? y : currentPage.h + y;
			} else currentY = y;
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
		* AlivePDF transform API
		*
		* skew()
		* rotate()
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function skew(ax:Number, ay:Number, x:Number=-1, y:Number=-1):void
		{
			if(x == -1)
				x = getX();
			
			if(y == -1)
				y = getY();
			
			if(ax == 90 || ay == 90)
				throw new RangeError("Please use values between -90° and 90° for skewing.");
			
			x *= k;
			y = (currentPage.h - y) * k;
			ax *= Math.PI / 180;
			ay *= Math.PI / 180;
			matrix.identity();
			matrix.a = 1;
			matrix.b = Math.tan(ay);
			matrix.c = Math.tan(ax);
			matrix.d = 1;
			getMatrixTransformPoint(x, y);
			transform(matrix);
		}
		
		public function rotate(angle:Number, x:Number=-1, y:Number=-1):void
		{
			if(x == -1)
				x = getX();
			
			if(y == -1)
				y = getY();
			
			angle *= Math.PI / 180;
			x *= k;
			y = (currentPage.h - y) * k;
			matrix.identity();
			matrix.rotate(-angle);
			getMatrixTransformPoint(x, y);
			transform(matrix);
		}
		
		protected function transform(tm:Matrix):void
		{
			write(sprintf('%.3f %.3f %.3f %.3f %.3f %.3f cm', tm.a, tm.b, tm.c, tm.d, tm.tx, tm.ty));
		}
		
		protected function getMatrixTransformPoint(px:Number, py:Number):void
		{
			var position:Point = new Point(px, py);
			var deltaPoint:Point = matrix.deltaTransformPoint(position);
			matrix.tx = px - deltaPoint.x;
			matrix.ty = py - deltaPoint.y;
		}
		
		public function startTransform():void
		{
			write('q');
		}
		
		public function stopTransform():void
		{
			write('Q');
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF Header and Footer API
		*
		* header()
		* footer()
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function header():void
		{
			/*
			//to be overriden (uncomment for a demo )
			var newFont:CoreFont = new CoreFont ( FontFamily.HELVETICA );
			this.setFont(newFont, 12);
			this.textStyle( new RGBColor (0x000000) );
			this.addCell(80);
			this.addCell(30,10,'Title',1,0,'C');
			this.newLine(20);*/
		}
		
		public function footer():void
		{
			/*
			//to be overriden (uncomment for a demo )
			this.setXY (15, -15);
			var newFont:CoreFont = new CoreFont ( FontFamily.HELVETICA );
			this.setFont(newFont, 8);
			this.textStyle( new RGBColor (0x000000) );
			this.addCell(0,10,'Page '+(totalPages-1),0,0,'C');
			this.newLine(20);*/
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
		* drawComplexRoundRect()
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
		public function lineStyle ( color:IColor, thickness:Number=1, flatness:Number=0, alpha:Number=1, rule:String="NonZeroWinding", blendMode:String="Normal", style:DashedLine=null, caps:String=null, joints:String=null, miterLimit:Number=3 ):void
		{
			setStrokeColor ( strokeColor = color );
			strokeThickness = thickness;
			strokeAlpha = alpha;
			strokeFlatness = flatness;
			windingRule = rule;
			strokeBlendMode = blendMode;
			strokeDash = style;
			strokeCaps = caps;
			strokeJoints = joints;
			strokeMiter = miterLimit;
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
		protected function setStrokeColor ( color:IColor ):void
		{
			var op:String;
			
			if ( color is RGBColor )
			{
				op = "RG";
				
				var r:Number = (color as RGBColor).r/255;
				var g:Number = (color as RGBColor).g/255;
				var b:Number = (color as RGBColor).b/255;
				
				write ( r + " " + g + " " + b + " " + op );
				
			} else if ( color is CMYKColor )
			{	
				op = "K";
				
				var c:Number = (color as CMYKColor).cyan / 100;
				var m:Number = (color as CMYKColor).magenta / 100;
				var y:Number = (color as CMYKColor).yellow / 100;
				var k:Number = (color as CMYKColor).black / 100;
				
				write ( c + " " + m + " " + y + " " + k + " " + op );
				
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
		protected function setTextColor ( color:IColor ):void
		{
			var op:String;
			
			if ( color is RGBColor )
			{
				
				op = !textRendering ? "rg" : "RG"
					
					var r:Number = (color as RGBColor).r/255;
				var g:Number = (color as RGBColor).g/255;
				var b:Number = (color as RGBColor).b/255;
				
				addTextColor = r + " " + g + " " + b + " " + op;
				
			} else if ( color is CMYKColor )
			{
				
				op = !textRendering ? "k" : "K"
					
					var c:Number = (color as CMYKColor).cyan / 100;
				var m:Number = (color as CMYKColor).magenta / 100;
				var y:Number = (color as CMYKColor).yellow / 100;
				var k:Number = (color as CMYKColor).black / 100;
				
				addTextColor = c + " " + m + " " + y + " " + k + " " + op;
				
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
		public function beginFill ( color:IColor ):void
		{
			filled = true;
			
			var op:String;
			
			if ( color is RGBColor )
			{
				op = "rg";
				
				var r:Number = (color as RGBColor).r/255;
				var g:Number = (color as RGBColor).g/255;
				var b:Number = (color as RGBColor).b/255;
				
				write ( r + " " + g + " " + b + " " + op );
				
			} else if ( color is CMYKColor )
			{
				op = "k";
				
				var c:Number = (color as CMYKColor).cyan / 100;
				var m:Number = (color as CMYKColor).magenta / 100;
				var y:Number = (color as CMYKColor).yellow / 100;
				var k:Number = (color as CMYKColor).black / 100;
				
				write ( c + " " + m + " " + y + " " + k + " " + op );
				
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
			var style:String = filled ? Drawing.CLOSE_AND_FILL_AND_STROKE : Drawing.STROKE;
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
			var style:String = filled ? Drawing.CLOSE_AND_FILL_AND_STROKE : Drawing.STROKE;
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
			var style:String = filled ? Drawing.CLOSE_AND_FILL_AND_STROKE : Drawing.STROKE;
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
			var style:String = filled ? Drawing.CLOSE_AND_FILL_AND_STROKE : Drawing.STROKE;
			
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
		public function addBookmark ( text:String, level:int=0, y:Number=0, color:RGBColor=null ):void
		{
			if ( color == null ) color = new RGBColor ( 0x000000 );
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
			viewerPreferences = '<< /HideToolbar '+toolbar+' /HideMenubar '+menubar+' /HideWindowUI '+windowUI+' /FitWindow '+fitWindow+' /CenterWindow '+centeredWindow+' /DisplayDocTitle '+displayTitle+' >>';
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF font API
		*
		* addFont()
		* removeFont()
		* setFont()
		* setFontSize()
		* getTotalFonts()
		* totalFonts
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		protected function addFont ( font:IFont ):IFont
		{
			pushedFontName = font.name;
			
			if ( !fonts.some(filterCallback) ) fonts.push ( font );
			
			fontFamily = font.name;
			
			var addedFont:EmbeddedFont;
			
			if ( font is EmbeddedFont )
			{
				addedFont = font as EmbeddedFont;	
				
				if ( addedFont.differences )
				{
					d = 0;
					nb = differences.length;
					for ( var j:int = 1; j <= nb ;j++ )
					{
						if(differences[j] == addedFont.differences)
						{
							d=j;
							break;
						}
					}
					if( d == 0 )
					{
						d = nb+1;
						differences[d] = addedFont.differences;
					}
					fonts[fonts.length-1].differences = d;
				}
				
			}
			
			return font;
		}
		
		private function filterCallback ( element:IFont, index:int, arr:Array ):Boolean
		{	
			return element.name == pushedFontName;	
		}
		
		/**
		 * Lets you set a specific font
		 *
		 * @param A font, can be a core font (org.alivepdf.fonts.CoreFont), or an embedded font (org.alivepdf.fonts.EmbeddedFont)
		 * @param size Any font size
		 * @param underlined if text should be underlined
		 * @example
		 * This example shows how to set the Helvetica font, with a bold style :
		 * <div class="listing">
		 * <pre>
		 *
		 * var font:CoreFont = new CoreFont ( FontFamily.HELVETICA_BOLD );
		 * myPDF.setFont( font );
		 * </pre>
		 * </div>
		 */
		public function setFont ( font:IFont, size:int=12, underlined:Boolean=false ):void
		{	
			pushedFontName = font.name;
			
			var result:Array = fonts.filter(filterCallback);
			currentFont = result.length ? result[0] : addFont( font );		
			
			underline = underlined;
			fontFamily = currentFont.name;
			fontSizePt = size;
			fontSize = size/k;
			
			if ( nbPages > 0 ) write (sprintf('BT /F%d %.2f Tf ET', currentFont.id, fontSizePt));
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
		public function setFontSize ( size:int ):void
		{	
			if( fontSizePt == size ) return;
			fontSizePt = size;
			fontSize = size/k;
			if( nbPages > 0 ) write (sprintf('BT /F%d %.2f Tf ET', currentFont.id, fontSizePt));	
		}
		
		/**
		 * Lets you remove an embedded font from the PDF
		 *
		 * @param font The embedded font
		 * @example
		 * This example shows how to remove an embedded font :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.removeFont( myEmbeddedFont );
		 * </pre>
		 * </div>
		 */
		public function removeFont ( font:IFont ):void
		{
			if ( font.type == FontType.CORE ) throw new Error('The font you have passed is a Core font. Core fonts cannot be removed as they are not embedded in the PDF.');
			
			var position:int = fonts.indexOf(font);
			
			if ( position != -1 ) fonts.splice(position, 1);
			else throw new Error ("Font cannot be found.");	
		}
		
		/**
		 * Lets you retrieve the number of fonts used in the PDF document
		 *
		 * @return int Number of fonts (embedded or not) used in the PDF
		 * @example
		 * This example shows how to retrieve the number of fonts :
		 * <div class="listing">
		 * <pre>
		 *
		 * var totalFonts:int = myPDF.totalFonts;
		 * </pre>
		 * </div>
		 */
		public function get totalFonts():int
		{
			return fonts.length;	
		}
		
		/**
		 * Lets you retrieve the fonts used in the PDF document
		 *
		 * @return Array An Array of fonts objects
		 * @example
		 * This example shows how to retrieve the fonts :
		 * <div class="listing">
		 * <pre>
		 *
		 * var fonts:Array = myPDF.getFonts();
		 * </pre>
		 * </div>
		 */
		public function getFonts():Array
		{
			return fonts;	
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
			var s:String = sprintf('BT %.2f %.2f Td (%s) Tj ET',x*k, (currentPage.h-y)*k, escapeIt(text));
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
		public function textStyle ( color:IColor, alpha:Number=1, rendering:int=0, wordSpace:Number=0, characterSpace:Number=0, scale:Number=100, leading:Number=0 ):void
		{	
			textColor = color;
			textAlpha = alpha;
			textWordSpace = wordSpace;
			textSpace = characterSpace;
			textScale = scale;
			textLeading = leading;
			
			write ( sprintf ( '%d Tr', textRendering = rendering ) );
			setTextColor ( color );
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
			if( currentY + height > pageBreakTrigger && !inHeader && !inFooter && acceptPageBreak() )
			{
				var x:Number = currentX;
				
				if( ws>0 )
				{
					ws=0;
					write('0 Tw');
				}
				addPage( new Page ( currentOrientation, defaultUnit, defaultSize ,currentPage.rotation ) );
				currentX = x;
				if( ws>0 ) write(sprintf('%.3f Tw',ws*k));
			}
			
			if ( currentPage.w == 0 ) currentPage.w = currentPage.w-rightMargin-currentX;
			
			var s:String = new String();
			var op:String;
			
			if( fill == 1 || border == 1 )
			{
				if ( fill == 1 ) op = ( border == 1 ) ? Drawing.FILL_AND_STROKE : Drawing.FILL;
				else op = Drawing.STROKE;
				s = sprintf('%.2f %.2f %.2f %.2f re %s ', currentX*k, (currentPage.h-currentY)*k, width*k, -height*k, op);
				endFill();
			}
			
			if ( border is String )
			{
				var borderBuffer:String = String ( border );
				
				if( borderBuffer.indexOf (Align.LEFT) != -1 ) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',currentX*k,(currentPage.h-currentY)*k,currentX*k,(currentPage.h-(currentY+height))*k);
				if( borderBuffer.indexOf (Align.TOP) != -1) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',currentX*k,(currentPage.h-currentY)*k,(currentX+width)*k,(currentPage.h-currentY)*k);
				if( borderBuffer.indexOf (Align.RIGHT) != -1) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',(currentX+width)*k,(currentPage.h-currentY)*k,(currentX+width)*k,(currentPage.h-(currentY+height))*k);
				if( borderBuffer.indexOf (Align.BOTTOM) != -1 ) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',currentX*k,(currentPage.h-(currentY+height))*k,(currentX+width)*k,(currentPage.h-(currentY+height))*k);
			}
			
			if ( text !== '' )
			{
				var dx:Number;
				
				if ( align==Align.RIGHT ) dx = width-currentMargin-getStringWidth(text);
				else if( align==Align.CENTER ) dx = (width-getStringWidth(text))/2;
				else dx = currentMargin;
				
				if(colorFlag) s+='q '+addTextColor+' ';
				
				var txt2:String = findAndReplace(')','\\)',findAndReplace('(','\\(',findAndReplace('\\','\\\\',text)));
				s+=sprintf('BT %.2f %.2f Td (%s) Tj ET',(currentX+dx)*k,(currentPage.h-(currentY+.5*height+.3*fontSize))*k,txt2);
				
				if(underline) s+=' '+doUnderline(currentX+dx,currentY+.5*height+.3*fontSize,text);
				if(colorFlag) s+=' Q';
				
				if( link ) addLink (currentX+dx,currentY+.5*height-.5*fontSize,getStringWidth(text),fontSize, link);
			}
			
			if ( s != '' ) write(s);
			
			lasth = currentPage.h;
			
			if( ln > 0 )
			{
				
				currentY += height;
				if( ln ==1) currentX = leftMargin;
				
			} else currentX += width;
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
			charactersWidth = currentFont.charactersWidth;
			
			if ( width==0 ) width = currentPage.w - rightMargin - currentX;
			
			var wmax:Number = (width-2*currentMargin)*1000/fontSize;
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
					if(border.indexOf(Align.LEFT)!= -1) b2+= Align.LEFT;
					if(border.indexOf(Align.RIGHT)!= -1) b2+= Align.RIGHT;
					b = (border.indexOf(Align.TOP)!= -1) ? b2+Align.TOP : b2;
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
					if (ws>0)
					{
						ws=0;
						write('0 Tw');
					}
					
					addCell(width,height,s.substr(j,i-j),b,2,align,filled);
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
				cwAux = charactersWidth[c] as int;
				if (cwAux == 0) cwAux = 580;
				l += cwAux;
				
				if (l>wmax)
				{
					
					if(sep==-1)
					{
						if(i==j) i++;
						if(ws>0)
						{
							ws=0;
							write('0 Tw');
						}
						addCell(width,height,s.substr(j,i-j),b,2,align,filled);
					}
					else
					{
						if(align==Align.JUSTIFIED)
						{
							ws=(ns>1) ? (wmax-ls)/1000*fontSize/(ns-1) : 0;
							write(sprintf('%.3f Tw',ws*k));
						}
						
						addCell(width,height,s.substr(j,sep-j),b,2,align,filled);
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
			
			if(ws>0)
			{
				ws=0;
				write('0 Tw');
			}
			
			if ( border && border.indexOf ('B')!= -1 ) b += 'B';
			addCell ( width,height,s.substr(j,i-j),b,2,align,filled );
			currentX = leftMargin;
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
			var cw:Object = currentFont.charactersWidth;
			var w:Number = currentPage.w-rightMargin-currentX;
			var wmax:Number = (w-2*currentMargin)*1000/fontSize;
			
			var s:String = findAndReplace ("\r",'', text);
			var nb:int = s.length;
			var sep:int = -1;
			var i:int = 0;
			var j:int = 0;
			var l:int = 0;
			var nl:int = 1;
			var c:String;
			var cwAux:int
			
			while( i<nb )
			{
				c = s.charAt(i);
				
				if( c == "\n" )
				{
					
					addCell (w,lineHeight,s.substr(j,i-j),0,2,'',0,link);
					i++;
					sep=-1;
					j=i;
					l=0;
					if(nl==1)
					{
						currentX = leftMargin;
						w = currentPage.w-rightMargin-currentX;
						wmax= (w-2*currentMargin)*1000/fontSize;
					}
					nl++;
					continue;
				}
				
				if(c==' ') sep=i;
				
				// TBO
				cwAux = cw[c] as int;
				if (cwAux == 0) cwAux = 580;
				l += cwAux;
				
				if( l > wmax )
				{
					//Automatic line break
					if(sep==-1)
					{
						if(currentX>leftMargin)
						{
							//Move to next line
							currentX = leftMargin;
							currentY += currentPage.h;
							w = currentPage.w-rightMargin-currentX;
							wmax = (w-2*currentMargin)*1000/fontSize;
							i++;
							nl++;
							continue;
						}
						if(i==j) i++;
						addCell (w,lineHeight,s.substr(j,i-j),0,2,'',0,link);
					}
					else
					{
						addCell (w,lineHeight,s.substr(j,sep-j),0,2,'',0,link);
						i=sep+1;
					}
					sep=-1;
					j=i;
					l=0;
					if(nl==1)
					{
						currentX=leftMargin;
						w=currentPage.w-rightMargin-currentX;
						wmax=(w-2*currentMargin)*1000/fontSize;
					}
					nl++;
				}
				else i++;
			}
			if (i!=j) addCell (l/1000*fontSize,lineHeight,s.substr(j),0,0,'',0,link);
		}
		
		/**
		 * Lets you write some text with basic HTML type formatting
		 *
		 * @param pHeight Line height, lets you specify height between each lines
		 * @param pText Text to write, to put a line break just add a \n in the text string
		 * @param pLink Any link, like http://www.mylink.com, will open te browser when clicked
		 * @example
		 * 
		 * Only a limited subset of tags are currently supported
		 *  <b> </b>
		 *  <i> </i>
		 *  <br />  used to create a new line
		 * 
		 * This example shows how to add some text to the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.writeHtmlText ( 5, "Lorem ipsum <b>dolor</b> sit amet, consectetuer<br /> adipiscing elit.");
		 * </pre>
		 * </div>
		 * This example shows how to add some text with a clickable link :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.writeText2 ( 5, "Lorem ipsum dolor sit amet, consectetuer adipiscing elit.", "http://www.google.fr");
		 * </pre>
		 * </div>
		 */
		public function writeFlashHtmlText ( pHeight:Number, pText:String, pLink:String='' ):void
		{
			//Output text in flowing mode
			var cw    : Object     = this.currentFont.charactersWidth;
			var w     : Number     = currentPage.w-this.rightMargin-this.currentX;
			var wmax  : Number     = (w-2*this.currentMargin)*1000/this.fontSize;
			var s     : String     = findAndReplace ("\r",'',pText);
			
			// Strip all \n's as we don't use them - use <br /> tag for returns
			s = findAndReplace("\n",'',s);  
			
			var nb      : int;        // Count of number of characters in section
			var sep     : int = -1;   // Stores the position of the last seperator
			var lenAtSep: Number = 0; // Store the length at the last seprator 
			var i       : int = 0;    // Counter for looping through each string
			var j       : int = 0;    // Counter which is updated with character count to be actually output (taking auto line breaking into account)
			var l       : int = 0;    // Length of the the current character string
			var k       : int = 0;    // Counter for looping through each item in the parsed XML array  
			var ns      : int = 0;
			
			//XML whitespace is important for this text parsing - so save prev value so we can restore it.
			var prevWhiteSpace    : Boolean = XML.ignoreWhitespace;
			XML.ignoreWhitespace = false;
			var aTaggedString     : Array = parseTags ( new XML( "<html>"+s+"</html>" ) );
			XML.ignoreWhitespace = prevWhiteSpace;
			
			//Stores the cell snippets for the current line
			var currentLine      : Array = new Array(); 
			var cellVO           : CellVO;
			
			//Variables to track the state of the current text
			var fontBold         : Boolean = false; 
			var fontItalic       : Boolean = false;
			fontUnderline     = false;
			var textAlign        : String = '';  // '' 'C' or 'R'  ??Does 'J' work??
			var attr             : XML;
			
			// total number of HTML tags
			var lng:int = aTaggedString.length;
			
			//Loop through each item in array
			for ( k=0; k < lng; k++ )
			{            	
				//Handle any tags and if unknown then handle as text    
				switch ( aTaggedString[k].tag.toUpperCase() )
				{	
					//Process Tags
					case "<TEXTFORMAT>":
					case "</TEXTFORMAT>":
						break;
					case "<P>":
						
					for each ( attr in aTaggedString[k].attr )
					{	
						switch ( String (attr.name() ) ) {
							
							case "ALIGN": 
								textAlign = String ( attr ).charAt(0);
								break;
							default:
								break;
						}
					}
						break;
					case "</P>":
						renderLine(currentLine,textAlign);
						
						currentLine     = new Array();
						this.currentX   = this.leftMargin;
						textAlign       = '';
						ns              = 0;
						
						this.lineBreak ( pHeight );
						break;
					case "<FONT>":
						for each ( attr in aTaggedString[k].attr )
						{
							switch ( String (attr.name() ) )
							{	
								case "FACE":
									break;
								case "SIZE":
									this.fontSizePt = parseInt(String ( attr ));
									break;
								case "COLOR":
									break;
								case "LETTERSPACING":
									break;
								case "KERNING":
									break;
								default:
									break;
							}
					}
					case "</FONT>":
						break;
					case "<B>":
						fontBold = true;
						break;
					case "</B>":
						fontBold = false;
						break;
					case "<I>":
						fontItalic = true;
						break;
					case "</I>":
						fontItalic = false;
						break;
					case "<U>":
						fontUnderline = true;
						break;
					case "</U>":
						fontUnderline = false;
						break;
					case "<BR>":
						// Both cases will set line break to true.  It is typically entered as <br /> 
						// but the parser converts this to a start and end tag
						this.lineBreak ( pHeight );
					case "</BR>":
					default:
						//Process text                    
						
						//Create a blank CellVO for this part
						cellVO            = new CellVO();	
						cellVO.fontSizePt = this.fontSizePt;
						cellVO.underlined = fontUnderline;
						
						//Set the font for calculation of character widths
						var newFont:IFont = new CoreFont ( getFontStyleString(fontBold,fontItalic,fontFamily) );
						setFont ( newFont, cellVO.fontSizePt );
						cellVO.font = newFont;
						
						//Font character width lookup table
						cw      = this.currentFont.charactersWidth; 
						
						//Current remaining space per line
						w       = currentPage.w-this.rightMargin-this.currentX;
						
						//Size of a full line of text
						wmax    = (w-2*this.currentMargin)*1000/this.fontSize;  
						
						//get text from string
						s   = aTaggedString[k].value; 
						
						//Length of string
						nb  = s.length;
						
						i   =  0;
						j   =  0;
						sep = -1;
						l   =  0;
						
						while( i < nb )
						{
							//Get next character
							var c : String = s.charAt(i);
							
							//Found a seperator
							if ( c == ' ' ) { 
								sep      = i;    //Save seperator index
								lenAtSep = l;    //Save seperator length
								ns++;
							}
							
							//Add the character width to the length;
							l += cw[c];
							
							//Are we Over the char width limit?
							if ( l > wmax )
							{	
								//Automatic line break
								if ( sep == -1 )
								{
									// No seperator to force at character
									
									if(this.currentX>this.leftMargin) {
										
										//Move to next line
										this.currentX  = this.leftMargin;
										this.currentY += pHeight;
										
										w    = currentPage.w-this.rightMargin-this.currentX;
										wmax = (w-2*this.currentMargin)*1000/this.fontSize;
										
										i++;
										continue;
									}
									
									if ( i == j ) 
										i++;
									
									l = 0;
									
									//Add the cell to the current line
									with ( cellVO )
									{	
										x     = this.currentX;
										y     = this.currentY;
										width = l/1000*this.fontSize;
										height= pHeight;
										text  = s.substr(j,i-j);
									}
									
									currentLine.push ( cellVO );
									
									//Just done a line break so render the line
									renderLine ( currentLine, textAlign );
									currentLine = new Array();
									
									//Update x and y positions            
									this.currentX = this.leftMargin;
									
								} else 
								{
									
									//Split at last seperator
									
									//Add the cell to the current line
									with ( cellVO ) {
										
										x      = this.currentX;
										y      = this.currentY;
										width  = lenAtSep/1000*this.fontSize;
										height = pHeight;
										text   = s.substr ( j, sep-j );
										//border = true;   // useful for debugging rendering problems
									}
									
									currentLine.push ( cellVO );
									
									if ( textAlign == Align.JUSTIFIED )
									{
										this.ws=(ns>1) ? (wmax-lenAtSep)/1000*this.fontSize/(ns-1) : 0;
										this.write(sprintf('%.3f Tw',this.ws*this.k));
									}
									
									//Just done a line break so render the line
									renderLine(currentLine,textAlign);
									currentLine = new Array();
									
									//Update x and y positions            
									this.currentX = this.leftMargin;
									
									w = currentPage.w - 2 * this.currentMargin;
									i = sep + 1;
								}
								
								sep= -1;
								j  = i;
								l  = 0;
								ns = 0;
								
								this.currentX = this.leftMargin;
								
								w   = currentPage.w - this.rightMargin - this.currentX;
								wmax= ( w-2 * this.currentMargin ) * 1000 / this.fontSize;
								
							} else 
								i++;
						}
						
						//Last chunk 
						if ( i != j )
						{	
							//If any remaining chars then print them out                            
							//Add the cell to the current line
							
							with ( cellVO )
							{	
								x = this.currentX;
								y = this.currentY;
								width = l/1000*this.fontSize;
								height = pHeight;
								text = s.substr(j);
								//border = true;   // useful for debugging rendering problems
							}
							
							//Last chunk
							if ( this.ws>0 )
							{
								this.ws=0;
								this.write('0 Tw');
							}                
							
							currentLine.push ( cellVO );
							
							//Update X positions
							this.currentX += cellVO.width;
							
						} 
						break;        
				}        
				
				//Is there a finished line     
				// or last line and there is something to display
				
				if ( k == aTaggedString.length && currentLine.length > 0 )
				{
					renderLine(currentLine,textAlign);	
					this.lineBreak(pHeight);
					currentLine = new Array();
				}	
			}
			
			//Is there anything left to render before we exit?
			if ( currentLine.length ) {
				
				renderLine ( currentLine, textAlign );
				this.lineBreak ( pHeight );
				currentLine = new Array();
			}            
			
			//Set current y off the page to force new page.
			this.currentY += currentPage.h;    
		}
		
		protected function lineBreak ( pHeight : Number ) : void
		{	
			this.currentX  = this.leftMargin;
			this.currentY += pHeight;
		}
		
		protected function getFontStyleString (  bold : Boolean, italic : Boolean, family: String ) : String
		{
			var font:String = family;
			var position:int;
			
			if ( (position = font.indexOf("-")) != -1 )
				font = font.substr(0, position);
			
			if ( bold && italic ) 
				font += "-BoldOblique";
			else if ( bold )
				font += "-Bold";
			else if ( italic )
				font += "-Oblique";
			
			return font;
		}
		
		protected function renderLine ( lineArray : Array, align : String = '' ) : void
		{	
			var cellVO    : CellVO;
			var availWidth: Number = currentPage.w - this.leftMargin - this.rightMargin;
			var lineLength: Number = 0;
			var offsetX   : Number = 0; 
			var offsetY   : Number = 0; 
			var i         : int;
			
			var firstCell : CellVO = CellVO(lineArray[0]);
			
			if ( firstCell == null )
				return;
			
			//Check if we need a new page for this line
			if ( firstCell.y + firstCell.height > this.pageBreakTrigger )
			{	
				this.addPage ( this.currentPage.clone() );
				
				//Use offsetY to push already specified coord for this line back up to top of page
				offsetY = this.currentY - firstCell.y;                                
			}
			var lng:int = lineArray.length;
			
			//Calculate offset if we are aligning center or right
			for(i = 0; i < lng; i++)
				lineLength += CellVO(lineArray[i]).width;
			
			//Adjust offset based on alignment
			if ( align == Align.CENTER ) 
				offsetX = (availWidth - lineLength)/2;
			else if ( align == Align.RIGHT )
				offsetX = availWidth - lineLength;
			
			// Loop through the cells in the line and draw
			for(i = 0; i < lng; i++)
			{	
				cellVO = CellVO ( lineArray[int(i)] );
				
				currentX = cellVO.x + offsetX;
				currentY = cellVO.y + offsetY;
				
				setFont ( cellVO.font, cellVO.fontSizePt, cellVO.underlined );
				addCell ( cellVO.width, cellVO.height, cellVO.text, cellVO.border, 2, align, cellVO.fill, cellVO.link );
			}
			
		}
		
		protected function parseTags ( myXML : XML ) : Array
		{	
			var aTags    : Array     = new Array();
			var children : XMLList   = myXML.children();
			var lng:int = children.length();
			
			for( var i : int=0; i < lng; i++ )
			{	
				if ( children[i].name() != null )
				{	
					aTags.push({tag:'<'+children[i].name()+'>',attr:children[i].attributes(),value:""});
					
					//Recurse into this tag and return them all as an array
					var returnedTags    : Array = parseTags ( children[i] );
					
					for ( var j : int = 0; j < returnedTags.length; j++ )
						aTags.push( returnedTags[j] );
					
					aTags.push({tag:'</'+children[i].name()+'>',attr:children[i].attributes(),value:""});
					
				} else 
					
					aTags.push({tag:"none", attr:new XMLList(), value:children[i]});
			}
			
			return aTags;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF data API
		*
		* addGrid()
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function addGrid ( grid:Grid, x:Number=0, y:Number=0, repeatHeader:Boolean=true ):void
		{	
			currentGrid = grid;
			currentGrid.x = x;
			currentGrid.y = y;
			columns = currentGrid.columns;
			var buffer:Array = grid.dataProvider;
			var i:int = 0;
			var j:int = 0;
			
			if ( columns == null )
			{
				var firstItem:* = buffer[0];
				var fields:Array = new Array();
				var column:GridColumn;
				for ( var p:String in firstItem )
					fields.push ( p );
				fields.sort();
				columns = new Array();
				var fieldsLng:int = fields.length;
				for (i = 0; i< fieldsLng; i++)
					columns.push ( new GridColumn ( fields[i], fields[i], 30 ) );
			}
			
			var row:Array;
			columnNames = new Array();
			var lng:int = buffer.length;
			var lngColumns:int = columns.length;	
			var item:*;
			
			for (i = 0; i< lngColumns; i++)
				columnNames.push ( columns[i].headerText );
			
			var rect:Rectangle = getRect ( columnNames );
			if ( checkPageBreak(rect.height) )
				addPage();
			
			beginFill ( grid.headerColor );
			setXY ( x+getX(), y+getY() );
			addRow( columnNames, 0, rect );
			endFill();
			
			for (i = 0; i< lng; i++)
			{
				item = buffer[i];
				row = new Array();
				for (j = 0; j< lngColumns; j++)
				{
					row.push (item[columns[j].dataField] != null ? item[columns[j].dataField] : "");
					nb = Math.max(nb,nbLines(columns[j].width,row[j]));
				}
				
				rect = getRect ( row );
				setX ( x + getX() );
				
				if ( checkPageBreak(rect.height) )
				{
					addPage();
					setXY ( x+getX(), y+getY() );
					if ( repeatHeader ) 
					{
						beginFill(grid.headerColor);
						addRow (columnNames, 0, getRect (columnNames) );
						endFill();
						setX ( x + getX() );
					}
				}
				
				if ( grid.alternateRowColor && Boolean(isEven = i&1) )
				{
					beginFill( grid.backgroundColor );
					addRow( row, 1, rect );
					endFill();
				} else addRow( row, 1, rect );
			}
		}
		
		protected function getRect ( rows:Array ):Rectangle
		{
			var nb:int = 0;
			var lng:int = rows.length;
			
			for(var i:int=0;i<lng;i++) nb = Math.max(nb,nbLines(columns[i].width,rows[i]));
			
			var ph:int = 5;
			var h:Number = ph*nb;
			var x:Number = 0;
			var y:Number = 0;
			var a:String;
			var w:Number = 0;
			
			return new Rectangle(x,y,w,h);
		}
		
		protected function addRow(data:Array, style:int, rect:Rectangle):void
		{		    
			var a:String;
			var x:Number = 0;
			var y:Number = 0;
			var w:Number = 0;
			var ph:int = 5;
			var h:Number = rect.height;
			var lng:int = data.length;
			
			for(var i:int=0;i<lng;i++)
			{
				a = style ? columns[i].cellAlign : columns[i].headerAlign;
				rect.x = x = getX();
				rect.y = y = getY();
				rect.width = w = columns[i].width;
				drawRect( rect );
				addMultiCell(w,ph,data[i],0,a);
				setXY(x+w,y);
			}
			newLine(h);
		}
		
		protected function checkPageBreak(height:Number):Boolean
		{
			return getY()+height>pageBreakTrigger;
		}
		
		protected function nbLines(width:int,text:String):int
		{
			var cw:Object = currentFont.charactersWidth;
			if(width==0) width = currentPage.w-rightMargin-leftMargin;
			
			var wmax:int = (width-2*currentMargin)*1000/fontSize;
			var s:String = findAndReplace("\r",'',text);
			var nb:int = s.length;
			
			if(nb>0 && s.charAt(nb-1)=="\n") nb--;
			
			var sep:Number=-1;
			var i:int=0;
			var j:int=0;
			var l:int=0;
			var nl:int=1;
			
			while(i<nb)
			{
				var c:String = s.charAt(i);
				if(c=="\n")
				{
					i++;
					sep=-1;
					j=i;
					l=0;
					nl++;
					continue;
				}
				if(c==' ') sep=i;
				l+=cw[c];
				if(l>wmax)
				{
					if(sep==-1)
					{
						if(i==j)
							i++;
					}
					else
						i=sep+1;
					sep=-1;
					j=i;
					l=0;
					nl++;
				}
				else
					i++;
			}
			return nl;
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
		 * @param frame The frame where the window whould be opened
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
		public function save ( method:String, url:String='', downloadMethod:String='inline', fileName:String='generated.pdf', frame:String="_blank" ):*
		{
			dispatcher.dispatchEvent( new ProcessingEvent ( ProcessingEvent.STARTED ) );
			var started:Number = getTimer();
			finish();
			dispatcher.dispatchEvent ( new ProcessingEvent ( ProcessingEvent.COMPLETE, getTimer() - started ) );
			buffer.position = 0;
			var output:* = null;
			
			switch (method)
			{
				case Method.LOCAL : 
					output = buffer;
					break;	
				
				case Method.BASE_64 : 
					output = Base64.encode64 ( buffer );
					break;
				
				case Method.REMOTE :
					var header:URLRequestHeader = new URLRequestHeader ("Content-type","application/octet-stream");
					var myRequest:URLRequest = new URLRequest (url+'?name='+fileName+'&method='+downloadMethod );
					myRequest.requestHeaders.push (header);
					myRequest.method = URLRequestMethod.POST;
					myRequest.data = buffer;
					navigateToURL ( myRequest, frame );
					break;
				
				default:
					throw new Error("Unknown Method \"" + method + "\"");
			}
			return output;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF SWF API
		*
		* addSWF()
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private function addSWF ( swf:ByteArray ):void
		{
			// coming soon
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF JavaScript API
		*
		* addJavaScript()
		*
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		/**
		 * The addJavaScript allows you to inject JavaScript code to be executed when the PDF document is opened
		 * 
		 * @param script
		 * @example
		 * This example shows how to open the print dialog when the PDF document is opened :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addJavaScript ("print(true);");
		 * </pre>
		 * </div>
		 */	 
		public function addJavaScript ( script:String ):void
		{
			javascript = script;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* AlivePDF image API
		*
		* addImage()
		* addImageStream()
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
		 * @param resizeMode
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param keepTransformation
		 * @param imageFormat
		 * @param quality
		 * @param alpha
		 * @param blendMode
		 * @param link
		 * @example
		 * This example shows how to add a 100% compression quality JPG image into the current page at a position of 0,0 with no resizing behavior :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addImage ( displayObject, 0, 0, 0, 0, true, ImageFormat.JPG, 100, .2 );
		 * </pre>
		 * </div>
		 */	 
		public function addImage ( displayObject:DisplayObject, resizeMode:Resize=null, x:Number=0, y:Number=0, width:Number=0, height:Number=0, rotation:Number=0, alpha:Number=1, keepTransformation:Boolean=true, imageFormat:String="PNG", quality:Number=100, blendMode:String="Normal", link:String='' ):void
		{	
			if ( streamDictionary[displayObject] == null )
			{	
				var bytes:ByteArray;				
				var bitmapDataBuffer:BitmapData;
				var transformMatrix:Matrix;
				
				displayObjectbounds = displayObject.getBounds( displayObject );
				
				if ( keepTransformation )
				{
					bitmapDataBuffer = new BitmapData ( displayObject.width+2, displayObject.height+2, false );
					transformMatrix = displayObject.transform.matrix;
					transformMatrix.tx = transformMatrix.ty = 0;
					transformMatrix.translate( -(displayObjectbounds.x*displayObject.scaleX)+2, -(displayObjectbounds.y*displayObject.scaleY)+2 );
					
				} else 
				{	
					bitmapDataBuffer = new BitmapData ( displayObject.width+2, displayObject.height+2, false );
					transformMatrix = new Matrix();
					transformMatrix.translate( -displayObjectbounds.x+1, -displayObjectbounds.y+1 );
				}
				
				bitmapDataBuffer.draw ( displayObject, transformMatrix );
				
				var id:int = getTotalProperties ( streamDictionary )+1;
				
				if ( imageFormat == ImageFormat.JPG ) 
				{
					var encoder:JPEGEncoder = new JPEGEncoder ( quality );
					bytes = encoder.encode ( bitmapDataBuffer );
					image = new DoJPEGImage ( bitmapDataBuffer, bytes, id );
					
				} else 
				{
					bytes = PNGEncoder.encode ( bitmapDataBuffer, 1 );
					image = new DoPNGImage ( bitmapDataBuffer, bytes, id );
				}
				
				streamDictionary[displayObject] = image;
				
			} else image = streamDictionary[displayObject];
			
			placeImage( x, y, width, height, rotation, resizeMode, link );
		}
		
		/**
		 * The addImageStream method takes an incoming image as a ByteArray. This method can be used to embed high-quality images (300 dpi) to the PDF.
		 * You must specify the image color space, if you don't know, there is a lot of chance the color space will be ColorSpace.DEVICE_RGB.
		 * 
		 * @param imageBytes
		 * @param colorSpace
		 * @param resizeMode
		 * @param x
		 * @param y
		 * @param width
		 * @param height
		 * @param alpha
		 * @param blendMode
		 * @param keepTransformation
		 * @param link
		 * @example
		 * This example shows how to add an RGB image as a ByteArray into the current page :
		 * <div class="listing">
		 * <pre>
		 *
		 * myPDF.addImageStream( bytes, ColorSpace.DEVICE_RGB );
		 * </pre>
		 * This example shows how to add a CMYK image as a ByteArray into the current page, the image will take the whole page :
		 * <div class="listing">
		 * <pre>
		 * var resize:Resize = new Resize ( Mode.FULL_PAGE, Position.CENTERED ); 
		 * myPDF.addImageStream( bytes, ColorSpace.DEVICE_RGB, resize );
		 * </pre>
		 * This example shows how to add a CMYK image as a ByteArray into the current page, the image will take the whole page but white margins will be preserved :
		 * <div class="listing">
		 * <pre>
		 * var resize:Resize = new Resize ( Mode.RESIZE_PAGE, Position.CENTERED ); 
		 * myPDF.addImageStream( bytes, ColorSpace.DEVICE_RGB, resize );
		 * </pre>
		 * </div>
		 */	 
		public function addImageStream ( imageBytes:ByteArray, colorSpace:String, resizeMode:Resize=null, x:Number=0, y:Number=0, width:Number=0, height:Number=0, rotation:Number=0, alpha:Number=1, blendMode:String="Normal", link:String='' ):void
		{	
			setAlpha ( alpha, blendMode );

			if ( streamDictionary[imageBytes] == null )
			{
				imageBytes.position = 0;
				
				var id:int = getTotalProperties ( streamDictionary )+1;
				
				if ( imageBytes.readUnsignedShort() == JPEGImage.HEADER ) image = new JPEGImage ( imageBytes, colorSpace, id );
				else if ( !(imageBytes.position = 0) && imageBytes.readUnsignedShort() == PNGImage.HEADER ) image = new PNGImage ( imageBytes, colorSpace, id );
				else if ( !(imageBytes.position = 0) && imageBytes.readUTFBytes(3) == GIFImage.HEADER ) 
				{
					imageBytes.position = 0;
					var decoder:GIFPlayer = new GIFPlayer();
					var capture:BitmapData = decoder.loadBytes( imageBytes );
					var bytes:ByteArray = PNGEncoder.encode ( capture, 1 );
					image = new DoPNGImage ( capture, bytes, id );
				}
				else throw new Error ("Image format not supported for now.");
				
				streamDictionary[imageBytes] = image;
				
			} else image = streamDictionary[imageBytes];
			
			placeImage( x, y, width, height, rotation, resizeMode, link );
		}
		
		protected function placeImage ( x:Number, y:Number, width:Number, height:Number, rotation:Number, resizeMode:Resize, link:String ):void
		{
			if ( width == 0 && height == 0 )
			{
				width = image.width/k;
				height = image.height/k;
			}
			
			if ( width == 0 ) width = height*image.width/image.height;
			if ( height == 0 ) height = width*image.height/image.width;
			
			var realWidth:Number = currentPage.width-(leftMargin+rightMargin)*k;
			var realHeight:Number = currentPage.height-(bottomMargin+topMargin)*k;
			
			var xPos:Number = 0;
			var yPos:Number = 0;
			
			if ( resizeMode == null )
				resizeMode = new Resize ( Mode.NONE, Position.LEFT );
			
			if ( resizeMode.mode == Mode.RESIZE_PAGE )
			{
				currentPage.resize( image.width+(leftMargin+rightMargin)*k, image.height+(bottomMargin+topMargin)*k, k );
				
			} else if ( resizeMode.mode == Mode.FULL_PAGE )
			{
				setMargins(0,0,0,0);
				resizeMode.position = Position.LEFT;
				currentPage.resize( image.width+(leftMargin+rightMargin)*k, image.height+(bottomMargin+topMargin)*k, k );
				
			} else if ( resizeMode.mode == Mode.FIT_TO_PAGE )
			{			
				var ratio:Number = Math.min ( realWidth/image.width, realHeight/image.height );
				
				if ( ratio < 1 )
				{
					width *= ratio;
					height *= ratio;
				}
			}
			
			if ( resizeMode.mode != Mode.RESIZE_PAGE )
			{		
				if ( resizeMode.position == Position.CENTERED )
				{	
					x = (realWidth - (width*k))>>1;
					y = (realHeight - (height*k))>>1;
					
				} else if ( resizeMode.position == Position.RIGHT )
					x = (realWidth - (width*k));
				
			}
			
			xPos = x+leftMargin*k;
			yPos = (resizeMode.position == Position.CENTERED && resizeMode.mode != Mode.RESIZE_PAGE) ? y+(bottomMargin+topMargin)*k : ((currentPage.h-topMargin)-(y+height))*k;

			rotate(rotation);
			write (sprintf('q %.2f 0 0 %.2f %.2f %.2f cm', width*k, height*k, xPos, yPos));
			write (sprintf('/I%d Do Q', image.resourceId));
			
			if ( link != '' ) addLink( xPos, yPos, width*k, height*k, link );
		}
		
		public function toString ():String
		{	
			return "[PDF totalPages="+totalPages+" embeddedFonts="+totalFonts+" PDFVersion="+version+" AlivePDFVersion="+PDF.ALIVEPDF_VERSION+"]";	
		} 
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/*
		* protected members
		*/
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		protected function finish():void
		{
			close();
		}
		
		protected function setUnit ( unit:String ):String
		{	
			if ( unit == Unit.POINT ) k = 1;
			else if ( unit == Unit.MM ) k = 72/25.4;
			else if ( unit == Unit.CM ) k = 72/2.54;
			else if ( unit == Unit.INCHES ) k = 72;
			else throw new RangeError ('Incorrect unit: ' + unit);
			
			return unit;	
		}
		
		protected function acceptPageBreak():Boolean
		{
			return autoPageBreak;
		}
		
		protected function curve ( x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number ):void
		{
			var h:Number = currentPage.h;
			write(sprintf('%.2f %.2f %.2f %.2f %.2f %.2f c ', x1*k, (h-y1)*k, x2*k, (h-y2)*k, x3*k, (h-y3)*k));
		}
		
		protected function getStringWidth( content:String ):Number
		{
			charactersWidth = currentFont.charactersWidth;
			var w:Number = 0;
			var l:int = content.length;
			
			var cwAux:int = 0;
			
			while (l--) 
			{	
				cwAux += charactersWidth[content.charAt(l)] as int;
				if ( isNaN ( cwAux ) ) cwAux = 580;
			}
			
			w = cwAux;
			return w*fontSize/1000;
		}
		
		protected function open():void
		{
			state = 1;
		}
		
		protected function close ():void
		{
			if( arrayPages.length == 0 ) 
				addPage();
			inFooter = true;
			footer();
			inFooter = false;
			finishPage();
			finishDocument();	
		}
		
		protected function addExtGState( graphicState:Object ):int
		{
			graphicStates.push ( graphicState );
			return graphicStates.length-1;
		}
		
		protected function setExtGState( graphicState:int ):void
		{	
			write(sprintf('/GS%d gs', graphicState));	
		}
		
		protected function insertExtGState():void
		{
			var lng:int = graphicStates.length;
			
			for ( var i:int = 0; i < lng; i++)
			{
				newObj();
				graphicStates[i].n = n;
				write('<</Type /ExtGState');
				for (var k:String in graphicStates[i]) write('/'+k+' '+graphicStates[i][k]);
				write('>>');
				write('endobj');
			}
		}
		
		protected function getChannels ( color:Number ):String
		{
			var r:Number = (color & 0xFF0000) >> 16;
			var g:Number = (color & 0x00FF00) >> 8;
			var b:Number = (color & 0x0000FF);
			
			return (r / 255) + " " + (g / 255) + " " + (b / 255);
		}
		
		protected function getCurrentDate ():String
		{
			var myDate:Date = new Date();
			var year:Number = myDate.getFullYear();
			var month:*= myDate.getMonth() < 10 ? "0"+Number(myDate.getMonth()+1) : myDate.getMonth()+1;
			var day:Number = myDate.getDate();
			var hours:* = myDate.getHours() < 10 ? "0"+Number(myDate.getHours()) : myDate.getHours();
			var currentDate:String = myDate.getFullYear()+''+month+''+day+''+hours+''+myDate.getMinutes();
			
			return currentDate;
		}
		
		protected function findAndReplace ( search:String, replace:String, source:String ):String
		{
			return source.split(search).join(replace);
		}
		
		protected function createPageTree():void
		{
			compressedPages = new ByteArray();
			
			nb = arrayPages.length;
			
			if( aliasNbPages != null )
				for( n = 0; n<nb; n++ ) 
					arrayPages[n].content = findAndReplace ( aliasNbPages, ( nb as String ), arrayPages[n].content );
			
			filter = (compress) ? '/Filter /'+Filter.FLATE_DECODE+' ' : '';
			
			offsets[1] = buffer.length;
			write('1 0 obj');
			write('<</Type /Pages');
			write('/Kids ['+pagesReferences.join(" ")+']');
			write('/Count '+nb+'>>');
			write('endobj');
			
			var p:String;
			
			for each ( var page:Page in arrayPages )	
			{
				newObj();
				write('<</Type /Page');
				write('/Parent 1 0 R');
				write (sprintf ('/MediaBox [0 0 %.2f %.2f]', page.width, page.height) );
				write ('/Resources 2 0 R');
				if ( page.annotations != '' ) write ('/Annots [' + page.annotations + ']');
				write ('/Rotate ' + page.rotation);
				if ( page.advanceTiming != 0 ) write ('/Dur ' + page.advanceTiming);
				if ( page.transitions.length ) write ( page.transitions );
				write ('/Contents '+(n+1)+' 0 R>>');
				write ('endobj');
				
				if ( compress ) 
				{
					compressedPages.writeMultiByte( page.content+"\n", "windows-1252" );
					compressedPages.compress();
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
		
		protected function writeXObjectDictionary():void
		{
			for each ( var image:PDFImage in streamDictionary ) 
			write('/I'+image.resourceId+' '+image.n+' 0 R');
		}
		
		protected function writeResourcesDictionary():void
		{
			write('/ProcSet [/PDF /Text /ImageB /ImageC /ImageI]');
			write('/Font <<');
			for each( var font:IFont in fonts ) 
			write('/F'+font.id+' '+font.resourceId+' 0 R');
			write('>>');
			write('/XObject <<');
			writeXObjectDictionary();
			write('>>');
			write('/ExtGState <<');
			for (var k:String in graphicStates) 
				write('/GS'+k+' '+graphicStates[k].n +' 0 R');
			write('>>');
		}
		
		protected function insertImages ():void
		{
			var filter:String = (compress) ? '/Filter /'+Filter.FLATE_DECODE+' ': '';
			var stream:ByteArray;
			
			for each ( var image:PDFImage in streamDictionary )
			{
				newObj();
				image.n = n;
				write('<</Type /XObject');
				write('/Subtype /Image');
				write('/Width '+image.width);
				write('/Height '+image.height);
				
				if( image.colorSpace == ColorSpace.INDEXED ) write ('/ColorSpace [/'+ColorSpace.INDEXED+' /'+ColorSpace.DEVICE_RGB+' '+((image as PNGImage).pal.length/3-1)+' '+(n+1)+' 0 R]');
				else
				{
					write('/ColorSpace /'+image.colorSpace);
					if( image.colorSpace == ColorSpace.DEVICE_CMYK ) write ('/Decode [1 0 1 0 1 0 1 0]');
				}
				
				write ('/BitsPerComponent '+image.bitsPerComponent);
				
				if (image.filter != null ) write ('/Filter /'+image.filter);
				
				if ( image is PNGImage || image is GIFImage )
				{
					if ( image.parameters != null ) write (image.parameters);
					
					if ( image.transparency != null && image.transparency is Array )
					{
						var trns:String = '';
						var lng:int = image.transparency.length;
						for(var i:int=0;i<lng;i++) trns += image.transparency[i]+' '+image.transparency[i]+' ';
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
				
				if( image.colorSpace == ColorSpace.INDEXED )
				{
					newObj();
					var pal:String = compress ? (image as PNGImage).pal : (image as PNGImage).pal
					write('<<'+filter+'/Length '+pal.length+'>>');
					writeStream(pal);
					write('endobj');
				}
			}
		}
		
		protected function insertFonts ():void
		{
			var nf:int = n;
			
			for (var diff:String in differences)
			{
				newObj();
				write('<</Type /Encoding /BaseEncoding /WinAnsiEncoding /Differences ['+diff+']>>');
				write('endobj');
			}
			
			var font:IFont;
			var embeddedFont:EmbeddedFont;
			var fontDescription:FontDescription;
			var type:String;
			var name:String;
			var charactersWidth:Object;
			var s:String;
			var lng:int;
			
			for each ( font in fonts )
			{
				if ( font is EmbeddedFont )
				{
					if ( font.type == FontType.TRUETYPE )
					{
						embeddedFont = font as EmbeddedFont;
						fontDescription = embeddedFont.description;
						newObj();
						write ('<</Length '+embeddedFont.stream.length);
						write ('/Filter /'+Filter.FLATE_DECODE);
						write ('/Length1 '+embeddedFont.originalSize+'>>');
						write('stream');
						buffer.writeBytes (embeddedFont.stream);
						buffer.writeUTFBytes ("\n");
						write("endstream");
						write('endobj');	
					}			
				}
				
				font.resourceId = n+1;
				type = font.type;
				name = font.name;
				
				if( type == FontType.CORE )
				{
					newObj();
					write('<</Type /Font');
					write('/BaseFont /'+name);
					write('/Subtype /Type1');
					if( name != FontFamily.SYMBOL && name != FontFamily.ZAPFDINGBATS ) write ('/Encoding /WinAnsiEncoding');
					write('>>');
					write('endobj');
				}
				else if( type == FontType.TYPE1 || type == FontType.TRUETYPE )
				{						
					newObj();
					write('<</Type /Font');
					write('/BaseFont /'+name);
					write('/Subtype /'+type);
					write('/FirstChar 32');
					write('/LastChar 255');
					write('/Widths '+(n+1)+' 0 R');
					write('/FontDescriptor '+(n+2)+' 0 R');
					if( embeddedFont.encoding != null )
					{
						if( embeddedFont.differences != null ) this.write ('/Encoding '+(int(nf)+int(embeddedFont.differences))+' 0 R');
						this.write ('/Encoding /WinAnsiEncoding');
					}
					write('>>');
					write('endobj');
					newObj();
					s = '[ ';
					for(var i:int=0; i<255; i++) s += (embeddedFont.widths[i])+' ';
					write(s+']');
					write('endobj');
					newObj();
					write('<</Type /FontDescriptor');
					write('/FontName /'+name); 
					write('/FontWeight '+fontDescription.fontWeight);
					write('/Descent '+fontDescription.descent);
					write('/Ascent '+fontDescription.ascent);
					write('/AvgWidth '+fontDescription.averageWidth);
					write('/Flags '+fontDescription.flags);
					write('/FontBBox ['+fontDescription.boundingBox[0]+' '+fontDescription.boundingBox[1]+' '+fontDescription.boundingBox[2]+' '+fontDescription.boundingBox[3]+']');
					write('/ItalicAngle '+ fontDescription.italicAngle);
					write('/StemV '+fontDescription.stemV);
					write('/MissingWidth '+fontDescription.missingWidth);
					write('/CapHeight '+fontDescription.capHeight);
					write('/FontFile'+(type=='Type1' ? '' : '2')+' '+(embeddedFont.resourceId-1)+' 0 R>>');
					write('endobj');
					
				} else throw new Error("Unsupported font type: " + type );
			}
		}
		
		protected function insertJS():void
		{
			newObj();
			jsResource = n;
			write('<<');
			write('/Names [(EmbeddedJS) '+(n+1)+' 0 R]');
			write('>>');
			write('endobj');
			newObj();
			write('<<');
			write('/S /JavaScript');
			write('/JS '+escapeString(javascript));
			write('>>');
			write('endobj');	
		}
		
		protected function writeResources():void
		{
			insertExtGState();
			insertFonts();
			insertImages();
			if ( javascript != null ) insertJS();
			offsets[2] = buffer.length;
			write('2 0 obj');
			write('<<');
			writeResourcesDictionary();
			write('>>');
			write('endobj');
			insertBookmarks();
		}
		
		protected function insertBookmarks ():void
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
		
		protected function insertInfos():void
		{
			write ('/Producer '+escapeString('AlivePDF '+PDF.ALIVEPDF_VERSION));
			if ((documentTitle != null)) write('/Title '+escapeString(documentTitle));
			if ((documentSubject != null)) write('/Subject '+escapeString(documentSubject));
			if ((documentAuthor != null)) write('/Author '+escapeString(documentAuthor));
			if ((documentKeywords != null)) write('/Keywords '+escapeString(documentKeywords));
			if ((documentCreator != null)) write('/Creator '+escapeString(documentCreator));
			write('/CreationDate '+escapeString('D:'+getCurrentDate()));
		}
		
		protected function createCatalog ():void
		{
			write('/Type /Catalog');
			write('/Pages 1 0 R');
			
			if ( zoomMode == Display.FULL_PAGE ) write('/OpenAction [3 0 R /Fit]');
			else if ( zoomMode == Display.FULL_WIDTH ) write('/OpenAction [3 0 R /FitH null]');
			else if ( zoomMode == Display.REAL ) write('/OpenAction [3 0 R /XYZ null null '+zoomFactor+']');
			else if ( !(zoomMode is String) ) write('/OpenAction [3 0 R /XYZ null null '+(zoomMode/100)+']');
			
			write('/PageLayout /'+layoutMode);
			
			if ( viewerPreferences.length ) write ( '/ViewerPreferences '+ viewerPreferences );
			
			if ( outlines.length )
			{
				write('/Outlines '+outlineRoot+' 0 R');
				write('/PageMode /UseOutlines');
			} else write('/PageMode /'+pageMode);
			
			if ( javascript != null )  write('/Names <</JavaScript '+(jsResource)+' 0 R>>');
		}
		
		protected function createHeader():void
		{
			write('%PDF-'+version);
		}
		
		protected function createTrailer():void
		{
			write('/Size '+(n+1));
			write('/Root '+n+' 0 R');
			write('/Info '+(n-1)+' 0 R');
		}
		
		protected function finishDocument():void
		{	
			if ( pageMode == PageMode.USE_ATTACHMENTS ) version = "1.6";
			else if ( layoutMode == Layout.TWO_PAGE_LEFT || layoutMode == Layout.TWO_PAGE_RIGHT ) version = "1.5";
			else if ( graphicStates.length && version < "1.4" ) version = "1.4";
			else if ( outlines.length ) version = "1.4";
			//Resources
			createHeader();
			var started:Number;
			started = getTimer();
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
		
		protected function startPage ( newOrientation:String ):void
		{
			nbPages = arrayPages.length;
			state = 2;
			
			currentX = leftMargin;
			currentY = topMargin;
			
			if ( newOrientation == '' ) newOrientation = defaultOrientation;
			else if ( newOrientation != defaultOrientation ) orientationChanges[nbPages] = true;
			
			pageBreakTrigger = arrayPages[nbPages-1].h-bottomMargin;
			currentOrientation = newOrientation;
		}
		
		protected function finishPage():void
		{
			state = 1;	
		}
		
		protected function newObj():void
		{
			offsets[++n] = buffer.length;
			write (n+' 0 obj');
		}
		
		protected function doUnderline( x:Number, y:Number, content:String ):String
		{
			underlinePosition = currentFont.underlinePosition;
			underlineThickness = currentFont.underlineThickness;
			currentPage.w = getStringWidth(content)+ws*substrCount(content,' ');
			return sprintf('%.2f %.2f %.2f %.2f re f',x*k,(currentPage.h-(y-underlinePosition/1000*fontSize))*k,currentPage.w*k,-underlineThickness/1000*fontSizePt);
		}
		
		protected function substrCount ( content:String, search:String ):int
		{
			return content.split (search).length;			
		}
		
		protected function getTotalProperties ( object:Object ):int
		{
			var num:int = 0;
			for (var p:String in object) num++;
			return num;
		}
		
		protected function escapeString(content:String):String
		{
			return '('+escapeIt(content)+')';
		}
		
		protected function escapeIt(content:String):String
		{
			return findAndReplace(')','\\)',findAndReplace('(','\\(',findAndReplace('\\','\\\\',findAndReplace('\r','\\r',content))));
		} 
		
		protected function writeStream(stream:String):void
		{
			write('stream');
			write(stream);
			write('endstream');
		}
		
		protected function write( content:* ):void
		{
			if ( currentPage == null ) throw new Error ("No pages available, please call the addPage method first.");
			if ( state == 2 ) currentPage.content += content+"\n";
			else buffer.writeMultiByte( content+"\n", "windows-1252" );
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