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
* AlivePDF is based on the FPDF PHP library by Olivier Plathey (http://www.fpdf.org/)
* Core Team : Thibault Imbert, Mark Lynch, Alexandre Pires, Marc Hugues, christoph.k
* @version 0.1.4.9 Current Release
* @url alivepdf.bytearray.org
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
    import org.alivepdf.colors.Color;
    import org.alivepdf.colors.GrayColor;
    import org.alivepdf.colors.RGBColor;
    import org.alivepdf.data.Grid;
    import org.alivepdf.data.GridColumn;
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
    import org.alivepdf.fonts.FontFamily;
    import org.alivepdf.fonts.FontType;
    import org.alivepdf.fonts.Style;
    import org.alivepdf.html.HTMLTag;
    import org.alivepdf.images.GIFImage;
    import org.alivepdf.images.ImageFormat;
    import org.alivepdf.images.ImageHeader;
    import org.alivepdf.images.JPEGImage;
    import org.alivepdf.images.PDFImage;
    import org.alivepdf.images.PNGImage;
    import org.alivepdf.images.ResizeMode;
    import org.alivepdf.layout.Align;
    import org.alivepdf.layout.Layout;
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
    public class PDF implements IEventDispatcher
    {

        protected static const PDF_VERSION:String = '1.3';
        protected static const ALIVEPDF_VERSION:String = '0.1.4.8';

        //current page number
        protected var nbPages:int;
        //current object number
        protected var n:int;      
        //array of object offsets            
        protected var offsets:Array;
        //current document state        
        protected var state:int;
        //compression flag        
        protected var compress:Boolean;
        //default orientation        
        protected var defaultOrientation:String;
        //default format  
        protected var defaultSize:Size;
        //default rotation  
        protected var defaultRotation:int;
        //default unit  
        protected var defaultUnit:String;
        //current orientation
        protected var currentOrientation:String;
        //array indicating orientation changes 
        protected var orientationChanges:Array;
        //scale factor (number of points in user unit)
        protected var k:Number;
        //left margin             
        protected var lMargin:Number;
        //top margin           
        protected var tMargin:Number;
        //right margin       
        protected var rMargin:Number;
        //page break margin          
        protected var bMargin:Number;
        //cell margin      
        protected var cMargin:Number;            
        protected var currentX:Number;
        protected var currentY:Number;
        //last cell printed
        protected var lasth:Number;
        //line width in user unit        
        protected var lineWidth:Number;
        //array of standard font names       
        protected var standardFonts:Object;
        //array of used fonts        
        protected var fonts:Object;
        //array of font files          
        protected var fontFiles:Array;
        //array of encoding differences         
        protected var diffs:Array;
        //array of internal links            
        protected var links:Array;
        //current font family              
        protected var fontFamily:String;
        //current font style         
        protected var fontStyle:String;
        //underlining flag        
        protected var underline:Boolean;
        //current font size in points        
        protected var fontSizePt:Number;
        //commands for drawing color        
        protected var strokeStyle:String;
        //winding number rule
        protected var windingRule:String;
        //commands for filling color        
        protected var fillColor:String;   
        //commands for text color       
        protected var addTextColor:String;
        //indicates whether fill and text colors are different        
        protected var colorFlag:Boolean;
        //word spacing       
        protected var ws:Number;
        //automatic page breaking      
        protected var autoPageBreak:Boolean;
        //threshold used to trigger page breaks
        protected var pageBreakTrigger:Number;
        //flag set when processing header
        protected var inHeader:Boolean;
        //flag set when processing footer
        protected var inFooter:Boolean;
        //zoom display mode       
        protected var zoomMode:*;
        //layout display mode         
        protected var layoutMode:String;         
        protected var pageMode:String;
        //document infos
        protected var documentTitle:String;            
        protected var documentSubject:String;       
        protected var documentAuthor:String;      
        protected var documentKeywords:String;    
        protected var documentCreator:String;
        //alias for total number of pages        
        protected var aliasNbPages:String;
        //PDF version number      
        protected var pdfVersion:String;
        protected var buffer:ByteArray;
        protected var streamDictionary:Dictionary;
        protected var compressedPages:ByteArray;
        protected var encryptRef:int;
        protected var image:PDFImage;
        protected var fontSize:Number;
        protected var name:String;
        protected var type:String;
        protected var desc:String;
        protected var up:Number;
        protected var ut:Number;
        protected var cw:Object;
        protected var enc:Number;
        protected var diff:Number;
        protected var d:Number;
        protected var nb:int;
        protected var originalsize:Number;
        protected var size1:Number;
        protected var size2:Number;
        protected var fontkey:String;
        protected var file:String;
        protected var currentFont:Object;
        protected var b2:String;
        protected var pageLinks:Array;
        protected var filter:String;
        protected var inited:Boolean;
        protected var filled:Boolean
        protected var dispatcher:EventDispatcher;
        protected var arrayPages:Array;
        protected var arrayNotes:Array;
        protected var extgstates:Array;
        protected var currentPage:Page;
        protected var outlines:Array;
        protected var rotationMatrix:Matrix;
        protected var outlineRoot:int;
        protected var angle:Number;
        protected var textRendering:int;
        protected var autoPagination:Boolean;
        protected var viewerPreferences:String;
        protected var drawingRule:String;
        protected var reference:String;
        protected var references:String;
        protected var zoomFactor:Number;
        protected var zoomRectangle:Rectangle;
        protected var columns:Array;
        protected var currentGrid:Grid;
        protected var isEven:int;
        protected var columnNames:Array;
        protected var matrix:Matrix;

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
            inHeader = inFooter = false;
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
            matrix = new Matrix();

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
            isCompressed = true;

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
            setXY( left, top );
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
        public function setDisplayMode ( zoomStyle:String='FullWidth', layout:String='SinglePage', mode:String='UseNone', zoomValue:Number=1, rectangle:Rectangle=null ):void
        {
            zoomMode = zoomStyle;
            zoomFactor = zoomValue;
            zoomRectangle = rectangle != null ? rectangle : new Rectangle (0,0,0,0);
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

            if( nbPages > 0 )
            {
            	inFooter = true;
				footer();
				inFooter = false;
				finishPage();
            }

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
            
            //Page header
			inHeader = true;
			header();
			inHeader = false;
            
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
        * AlivePDF Header and Footer API
        *
        * header()
        * footer()
        */
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        public function header():void
        {
        	/* to be overriden (uncomment for a demo )
        	this.setFont( FontFamily.ARIAL, Style.BOLD, 10 );
        	this.addCell(80);
    		this.addCell(30,10,'Title',1,0,'C');
    		this.newLine(20);*/
        }
        
        public function footer():void
        {
        	/* to be overriden (uncomment for a demo )
        	this.setY (-15);
        	this.setFont( FontFamily.ARIAL, Style.ITALIC, 8 );
    		this.addCell(0,10,'Page '+totalPages,0,0,'C');
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
        protected function strokeColor ( color:Color ):void
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
        protected function textColor ( color:Color ):void
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
            if ( family == '' ) family = fontFamily;
            if ( family == FontFamily.ARIAL ) family = 'helvetica';
            else if ( family == FontFamily.SYMBOL || family == FontFamily.ZAPFDINGBATS ) style='';
            style = style.toUpperCase();
            
            family = family.toLowerCase();

            if( style.indexOf (Style.UNDERLINE)!= -1 )
            {
                underline = true;
                style = findAndReplace(Style.UNDERLINE,'', style);

            } else underline = false;

            if( size == 0 ) size = fontSizePt;
            
            fontkey = family+style;
            
            if( (fonts[fontkey] == null ))
            {
                if((standardFonts[fontkey] != null ))
                {
                    if((FontMetrics[fontkey] == null ))
                    {
                        file = family;
                        if( family == FontFamily.TIMES || family == FontFamily.HELVETICA ) file += style.toLowerCase();
                        if( FontMetrics[fontkey] == null ) throw new Error('Could not include font metric file');
                    }
                    var i:int = getNumImages(fonts)+1;
                    fonts[fontkey]= { i : i, type : FontType.CORE, name : standardFonts[fontkey], up : -100, ut : 50, cw : FontMetrics[fontkey] };

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
		
		private function transform(tm:Matrix):void
		{
			write(sprintf('%.3f %.3f %.3f %.3f %.3f %.3f cm', tm.a, tm.b, tm.c, tm.d, tm.tx, tm.ty));
		}

		private function getMatrixTransformPoint(px:Number, py:Number):void
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
            var k:Number = k;

            if( currentY + height > pageBreakTrigger && !inHeader && !inFooter && acceptPageBreak() )
            {
                //Automatic page break
                var x:Number = currentX;
                ws=ws;
                if(ws>0)
                {
                    ws=0;
                    write('0 Tw');
                }
                addPage( new Page ( currentOrientation, defaultUnit, defaultSize ,currentPage.rotation ) );
                currentX = x;
                if(ws>0)
                {
                    ws=ws;
                    write(sprintf('%.3f Tw',ws*k));
                }
            }

            if ( currentPage.w==0 ) currentPage.w = currentPage.w-rMargin-currentX;
            
            var s:String = new String();
            var op:String;

            if( fill == 1 || border == 1 )
            {
                if ( fill == 1 ) op = ( border == 1 ) ? 'B' : 'f';
                else op = 'S';
                
                s = sprintf('%.2f %.2f %.2f %.2f re %s ',currentX*k,(currentPage.h-currentY)*k,width*k,-height*k,op);
            }

            if ( border is String )
            {
                currentX = currentX;
                currentY = currentY;

                var tmpBorder:String = String ( border );

                if( tmpBorder.indexOf('L') != -1 ) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',currentX*k,(currentPage.h-currentY)*k,currentX*k,(currentPage.h-(currentY+height))*k);
                if( tmpBorder.indexOf('T') != -1) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',currentX*k,(currentPage.h-currentY)*k,(currentX+width)*k,(currentPage.h-currentY)*k);
                if( tmpBorder.indexOf('R') != -1) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',(currentX+width)*k,(currentPage.h-currentY)*k,(currentX+width)*k,(currentPage.h-(currentY+height))*k);
                if( tmpBorder.indexOf('B') != -1 ) s+=sprintf('%.2f %.2f m %.2f %.2f l S ',currentX*k,(currentPage.h-(currentY+height))*k,(currentX+width)*k,(currentPage.h-(currentY+height))*k);
            }

            if ( text !== '' )
            {
                var dx:Number;
                if ( align==Align.RIGHT ) dx = width-cMargin-getStringWidth(text);
                else if( align==Align.CENTER ) dx = (width-getStringWidth(text))/2;
                else dx = cMargin;
                if(colorFlag) s+='q '+addTextColor+' ';
                var txt2:String = findAndReplace(')','\\)',findAndReplace('(','\\(',findAndReplace('\\','\\\\',text)));
                s+=sprintf('BT %.2f %.2f Td (%s) Tj ET',(currentX+dx)*k,(currentPage.h-(currentY+.5*height+.3*fontSize))*k,txt2);
                if(underline) s+=' '+doUnderline(currentX+dx,currentY+.5*height+.3*fontSize,text);
                if(colorFlag) s+=' Q';
                if( link ) addLink (currentX+dx,currentY+.5*height-.5*fontSize,getStringWidth(text),fontSize, link);
            }

            if ( s ) write(s);

            lasth = currentPage.h;

            if( ln >0 )
            {
                //Go to next line
                currentY += height;
                if( ln ==1) currentX = lMargin;

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
            cw = currentFont.cw;

            if ( width==0 ) width = currentPage.w-rMargin - currentX;

            var wmax:Number = (width-2*cMargin)*1000/fontSize;
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
                cwAux = cw[c] as int;
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
            //Last chunk
            if(ws>0)
            {
                ws=0;
                write('0 Tw');
            }

            if ( border && border.indexOf ('B')!= -1 ) b += 'B';
            addCell ( width,height,s.substr(j,i-j),b,2,align,filled );
            currentX = lMargin;
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
            var cw:Object = currentFont.cw;
            var w:Number = currentPage.w-rMargin-currentX;
            var wmax:Number = (w-2*cMargin)*1000/fontSize;
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
                    addCell (w,lineHeight,s.substr(j,i-j),0,2,'',0,link);
                    i++;
                    sep=-1;
                    j=i;
                    l=0;
                    if(nl==1)
                    {
                        currentX = lMargin;
                        w = currentPage.w-rMargin-currentX;
                        wmax= (w-2*cMargin)*1000/fontSize;
                    }
                    nl++;
                    continue;
                }
                if(c==' ') sep=i;
                l+=cw[c];
                if( l > wmax )
                {
                    //Automatic line break
                    if(sep==-1)
                    {
                        if(currentX>lMargin)
                        {
                            //Move to next line
                            currentX = lMargin;
                            currentY += currentPage.h;
                            w = currentPage.w-rMargin-currentX;
                            wmax = (w-2*cMargin)*1000/fontSize;
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
                        currentX=lMargin;
                        w=currentPage.w-rMargin-currentX;
                        wmax=(w-2*cMargin)*1000/fontSize;
                    }
                    nl++;
                }
                else i++;
            }
            //Last chunk
            if (i!=j) 
                addCell (l/1000*fontSize,lineHeight,s.substr(j),0,0,'',0,link);
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
        *  <font> </font>
        *  <u> </u>
        *  <br />  used to create a new line
        * 
        * This example shows how to add some basic HTML text to the current page :
        * <div class="listing">
        * <pre>
        *
        * myPDF.writeFlashHtmlText( 5, "Lorem ipsum dolor <b>sit amet</b>, consectetur <font color='#990000'>adipiscing elit</font>. Sed eget orci. <i>Fusce luctus feugiat tortor</i>.");
        * </pre>
        * </div>
        */
        public function writeFlashHtmlText ( pHeight:Number, pText:String, pLink:String='' ):void
        {
            //Output text in flowing mode
            
            var cw    : Object     = currentFont.cw;
            var w     : Number     = currentPage.w-rMargin-currentX;
            var wmax  : Number     = (w-2*cMargin)*1000/fontSize;
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
            var aTaggedString     : Array = parseTags ( new XML( "<HTML>"+s+"</HTML>" ) );
                        
            XML.ignoreWhitespace = prevWhiteSpace;
            
            //Stores the cell snippets for the current line
            var currentLine      : Array = new Array(); 
            var cellVO           : CellVO;
            
            //Variables to track the state of the current text
            var fontBold         : Boolean = false; 
            var fontItalic       : Boolean = false;
            var fontUnderline    : Boolean = false;
            var textAlign        : String = ''; 
            var attr             : XML;

            var cwAux            : int;

            var fs               : int;      // Font size
            var fc               : RGBColor; // font color;
            var cs               : int;      // character space ( not implemented yet )
            
            var lng:int = aTaggedString.length;

            //Loop through each item in array
            for ( k=0; k < lng; k++ )
            {            
                //Handle any tags and if unknown then handle as text    
                switch ( aTaggedString[k].tag )
                {    
                    //Process Tags
                    case "<TEXTFORMAT>":
                    case "</TEXTFORMAT>":
                        break;
                    case "<P>":

                        for each ( attr in aTaggedString[k].attr ) {

                            switch ( String ( attr.name() ).toUpperCase() ) {

                                case "ALIGN": 
                                     textAlign = String ( attr ).charAt(0);
                                     break;
                                default:
                                    // TODO: are there more attributes!!?!?!
                                    break;
                            }
                        }
                        break;
                    case "</P>":
						renderLine(currentLine,textAlign);
						
						currentLine     = new Array();
						currentX   = lMargin;
						textAlign       = '';
                        ns              = 0;
						
                        lineBreak ( pHeight );
                        break;
                    case "<FONT>":
                        for each ( attr in aTaggedString[k].attr ) {

                            switch ( String ( attr.name() ).toUpperCase() ) {

                                case "FACE":
                                    // TODO: Add Font Face Support
                                    break;
                                case "SIZE":
                                    fs = parseInt( String ( attr ) );
                                    break;
                                case "COLOR":
                                    fc = RGBColor.hexStringToRGBColor( String ( attr ) );
                                    break;
                                case "LETTERSPACING":
                                    cs = parseInt( String ( attr ) );
                                    break;
                                case "KERNING":
                                    // TODO
                                    break;
                                default:
                                    break;
                            }
                        }
                        break;
                    case "</FONT>":
                        fc = new RGBColor (0);
                        break;
                    case "<A>":
                    case "</A>":
                        // TODO: link support
                        break;
                    case "<IMG>":
                        // TODO: Implement image support
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
                        lineBreak ( pHeight );
                    case "</BR>":
                    default:
                        //Process text                    
                    
                        //Create a blank CellVO for this part
                        cellVO            = new CellVO();
                        cellVO.fontStyle  = getFontStyleString(fontBold,fontItalic,fontUnderline);
                        cellVO.fontFamily = fontFamily;

                        cellVO.fontSizePt     = fs;
                        cellVO.color          = fc;
                        cellVO.characterSpace = cs;  // this is only stored, this isn't implemented
                        
                        //Set the font for calculation of character widths

                        //TODO: Change this to not call setFont but to get currentFont.cw 
                        // directly ro prevent mutliple font lines being output to PDF
                        setFont ( cellVO.fontFamily, cellVO.fontStyle, cellVO.fontSizePt );
                                    
                        //Font character width lookup table
                        cw      = currentFont.cw; 
                        
                        //Current remaining space per line
                        w       = currentPage.w-rMargin-currentX;
                        
                        //Size of a full line of text
                        wmax    = (w-2*cMargin)*1000/fontSize;  
                        
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
                            if ( c == ' ' )
                            { 
                                sep      = i;    //Save seperator index
                                lenAtSep = l;    //Save seperator length
                                ns++;
                            }

                            //Add the character width to the length;
                            cwAux = cw[c] as int;
                            
                            if ( cwAux == 0 ) 
                                cwAux = 580;

                            l += cwAux;
                            
                            //Are we Over the char width limit?
                            if ( l > wmax )
                            {
                                //Automatic line break
                                if ( sep == -1 )
                                {
                                     // No seperator to force at character
                                     
                                    if(currentX>lMargin)
                                    {
                                        //Move to next line
                                        currentX  = lMargin;
                                        currentY += pHeight;

                                        w    = currentPage.w-rMargin-currentX;
                                        wmax = (w-2*cMargin)*1000/fontSize;

                                        i++;
                                        continue;
                                    }
                                    
                                    if ( i == j ) 
                                        i++;
                                    
                                    //Set the lenght to the size before it was greater than wmax
                                    l -= cwAux;
                                    
                                    //Add the cell to the current line
                                    cellVO.x     = currentX;
                                    cellVO.y     = currentY;
                                    cellVO.width = l/1000*fontSize;
                                    cellVO.height= pHeight;
                                    cellVO.text  = s.substr(j,i-j);
                                    
                                    currentLine.push ( cellVO );
                        
                                    //Just done a line break so render the line
                                    renderLine ( currentLine, textAlign );
                                    currentLine = new Array();
                        
                                    //Update x and y positions            
                                    currentX = lMargin;
                                    
                                } else
                                {
                                    
                                    //Split at last seperator
                                    
                                    //Add the cell to the current line
                                    cellVO.x      = currentX;
                                    cellVO.y      = currentY;
                                    cellVO.width  = lenAtSep/1000*fontSize;
                                    cellVO.height = pHeight;
                                    cellVO.text   = s.substr ( j, sep-j );

                                    currentLine.push ( cellVO );
                                    
                                    if ( textAlign == Align.JUSTIFIED )
                                    {
                                        ws=(ns>1) ? (wmax-lenAtSep)/1000*fontSize/(ns-1) : 0;
                                        write(sprintf('%.3f Tw',ws*k));
                                    }

                                    //Just done a line break so render the line
                                    renderLine(currentLine,textAlign);
                                    currentLine = new Array();
                                    
                                    //Update x and y positions            
                                    currentX = lMargin;
                                
                                    w = currentPage.w - 2 * cMargin;
                                    i = sep + 1;
                                }
                                
                                sep= -1;
                                j  = i;
                                l  = 0;
                                ns = 0;
                                
                                currentX = lMargin;
                                
                                w   = currentPage.w - rMargin - currentX;
                                wmax= ( w-2 * cMargin ) * 1000 / fontSize;
                                
                            } else i++;
                        }
                        
                        //Last chunk 
                        if ( i != j )
                        {
                             //If any remaining chars then print them out                            
                            //Add the cell to the current line
                            
                            cellVO.x     = currentX;
                            cellVO.y     = currentY;
                            cellVO.width = l/1000*fontSize;
                            cellVO.height= pHeight;
                            cellVO.text  = s.substr(j);
                            
                            //Last chunk
                            if ( ws>0 )
                            {
                                ws=0;
                                write('0 Tw');
                            }                
                            
                            currentLine.push ( cellVO );

                            //Update X positions
                            currentX += cellVO.width;
                            
                        } 
                        break;
                }        

                //Is there a finished line     
                // or last line and there is something to display
                
                if ( k == aTaggedString.length && currentLine.length > 0 )
                {    
                    renderLine(currentLine,textAlign);
                    
                    lineBreak(pHeight);
                    
                    currentLine = new Array();
                }
            
            }
            
            //Is there anything left to render before we exit?
            if ( currentLine.length )
            {    
                renderLine ( currentLine, textAlign );
                lineBreak ( pHeight );
                currentLine = new Array();
            }            

            //Set current y off the page to force new page.
            currentY += currentPage.h;    
        }

        protected function lineBreak ( pHeight : Number ):void
        {    
            currentX  = lMargin;
            currentY += pHeight;
        }
        
        protected function getFontStyleString (  bold : Boolean, italic : Boolean, underline : Boolean ):String
        {    
            var fontStyle:String  = "";
                        
            if ( bold ) 
                fontStyle += "B";
                
            if ( italic ) 
                fontStyle += "I";
                
            if ( underline ) 
                fontStyle += "U";
                
            return fontStyle;
        }
        
        protected function renderLine ( lineArray : Array, align : String = '' ):void
        {    
            var cellVO    : CellVO;
            var availWidth: Number = currentPage.w - lMargin - rMargin;
            var lineLength: Number = 0;
            var offsetX   : Number = 0; 
            var offsetY   : Number = 0; 
            var i         : int;
            
            var firstCell : CellVO = CellVO(lineArray[0]);
            
            if ( firstCell == null )
                return;
                
            //Check if we need a new page for this line
            if ( firstCell.y + firstCell.height > pageBreakTrigger )
            {    
                addPage(new Page ( defaultOrientation, defaultUnit, defaultSize, defaultRotation ));
                //Use offsetY to push already specified coord for this line back up to top of page
                offsetY = currentY - firstCell.y;                                
            }
            
            var lng:int = lineArray.length;

            //Calculate offset if we are aligning center or right
            for(i = 0; i < lng; i++)
                lineLength += (lineArray[i] as CellVO).width;
                
            //Adjust offset based on alignment
            if ( align == Align.CENTER ) 
                offsetX = (availWidth - lineLength)/2;
            else if ( align == Align.RIGHT )
                offsetX = availWidth - lineLength;
                
            lng = lineArray.length;
            
            // Loop through the cells in the line and draw
            for(i = 0; i < lng; i++)
            {
                cellVO = lineArray[i] as CellVO;

                currentX = cellVO.x + offsetX;
                currentY = cellVO.y + offsetY;

                setFont ( cellVO.fontFamily, cellVO.fontStyle, cellVO.fontSizePt );
                
                // TODO: add support for character space
                if ( cellVO.color != null ) textColor ( cellVO.color );
                colorFlag = ( fillColor != addTextColor );
                addCell ( cellVO.width, cellVO.height, cellVO.text, cellVO.border, 2, "", cellVO.fill, cellVO.link );
            }     
        }
        
        protected function parseTags ( myXML : XML ):Array
        {
            var aTags    : Array     = new Array();
            var children : XMLList   = myXML.children();
            
            var lng:int = children.length();
            var returnedLng:int;
            
            for( var i : int=0; i < lng; i++ ) {

                if ( children[i].name() != null ) {
                    
                    aTags.push( new HTMLTag ( '<'+String(children[i].name()).toUpperCase()+'>', children[i].attributes(), "") );

                    //Recurse into this tag and return them all as an array
                    var returnedTags    : Array = parseTags ( children[i] );
                    returnedLng = returnedTags.length;
                    
                    for ( var j : int = 0; j < returnedLng; j++ )
                        aTags.push( returnedTags[j] );
                        
                    aTags.push( new HTMLTag ('</'+String(children[i].name()).toUpperCase()+'>', children[i].attributes(), "") );
                    
                } else aTags.push( new HTMLTag ( "none", new XMLList(), children[i] ) );
            }
            return aTags;
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
        protected function setAutoPagination ( activate:Boolean ):void
        {
            if ( autoPagination != activate ) autoPagination = activate;
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
		
				if ( grid.alternateRowColor && (isEven = i&1) )
				{
					beginFill( grid.backgroundColor );
					addRow( row, 1, rect );
					endFill();
				} else addRow( row, 1, rect );
			}
		}
		
		private function getRect ( rows:Array ):Rectangle
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
		
		private function addRow(data:Array, style:int, rect:Rectangle):void
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
		
		private function checkPageBreak(height:Number):Boolean
		{
		    return getY()+height>pageBreakTrigger;
		}
		
		private function nbLines(width:int,text:String):int
		{
		    var cw:Object = currentFont.cw;
		    if(width==0) width = currentPage.w-rMargin-lMargin;
		   
		    var wmax:int = (width-2*cMargin)*1000/fontSize;
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
		public function save ( method:String, url:String='', downloadMethod:String='inline', fileName:String='output.pdf', frame:String="_blank" ):*
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
                
                if ( imageBytes.readUnsignedShort() == ImageHeader.JPG ) image = new JPEGImage ( imageBytes, id );
                else if ( !(imageBytes.position = 0) && imageBytes.readUnsignedShort() == ImageHeader.PNG ) image = new PNGImage ( imageBytes, id );
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
        * protected members
        */
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        protected function finish():void
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

        protected function open():void
        {
            state = 1;    
        }

        protected function close ():void
        {
            if( state == 3 ) return;
            if( arrayPages.length == 0 ) addPage();
			inFooter = true;
			footer();
			inFooter = false;
            finishPage();
            finishDocument();    
        }

        protected function addExtGState( graphicState:Object ):int
        {
            extgstates.push ( graphicState );
            return extgstates.length-1;
        }

        protected function setExtGState( graphicState:int ):void
        {
            write(sprintf('/GS%d gs', graphicState));    
        }

        protected function insertExtGState():void
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
                	compressedPages = new ByteArray();
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
            for each ( var image:Object in streamDictionary ) write('/I'+image.i+' '+image.n+' 0 R');
        }

        protected function writeResourcesDictionary():void
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

        protected function insertImages ():void
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

        protected function insertFonts ():void
        {
            var nf:int = n;

            for (var diff:String in diffs)
            {
                newObj();
                write('<</Type /Encoding /BaseEncoding /WinAnsiEncoding /Differences ['+diff+']>>');
                write('endobj');
            }
            
            var type:String;
            var name:String;
            var font:Object;

            for ( var p:String in fonts )
            {
                font = fonts[p];
                font.n = n+1;
                
                type = font.type;
                name = font.name;

                if( type == FontType.CORE )
                {
                    //Standard font
                    newObj();
                    write('<</Type /Font');
                    write('/BaseFont /'+name);
                    write('/Subtype /Type1');
                    if( name != 'Symbol' && name != FontFamily.ZAPFDINGBATS ) write ('/Encoding /WinAnsiEncoding');
                    write('>>');
                    write('endobj');
                }
                else if( type == FontType.TYPE1 || type == FontType.TRUETYPE )
                {
                    //Additional Type1 or TrueType font
                    newObj();
                    write('<</Type /Font');
                    write('/BaseFont /'+name);
                    write('/Subtype /'+type);
                    write('/FirstChar 32 /LastChar 255');
                    write('/Widths '+(n+1)+' 0 R');
                    write('/FontDescriptor '+(n+2)+' 0 R');

                    if( font.enc )
                    {
                        if( font.diff != null ) write ('/Encoding '+(nf+font.diff)+' 0 R');
                        else write ('/Encoding /WinAnsiEncoding');
                    }

                    write('>>');
                    write('endobj');
                    //Widths
                    newObj();
                    var cw:Object = font.cw;
                    var s:String = '[';
                    for(var i:int=32; i<=255; i++) s += cw[String.fromCharCode(i)]+' ';
                    write(s+']');
                    write('endobj');
                    //Descriptor
                    newObj();
                    s = '<</Type /FontDescriptor /FontName /'+name;
                    for (var q:String in font.desc ) s += ' /'+q+' '+font.desc[q];
                    var file:Object = font.file;
                    if (file) s +=' /FontFile'+(type=='Type1' ? '' : '2')+' '+fontFiles[file].n+' 0 R';
                    write(s+'>>');
                    write('endobj');
                }
                else throw new Error("Unsupported font type: " + type );
            }
        }

        protected function writeResources():void
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
            write ('/Producer '+escapeString('Alive PDF '+PDF.ALIVEPDF_VERSION));
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
            else if ( zoomRectangle != null && zoomMode == Display.RECTANGLE ) write('/OpenAction [3 0 R /FitR '+zoomRectangle.left+' '+zoomRectangle.bottom+' '+zoomRectangle.right+' '+zoomRectangle.top+']');
            else if ( !(zoomMode is String) ) write('/OpenAction [3 0 R /XYZ null null '+(zoomMode/100)+']');
            
            write('/PageLayout /'+layoutMode);

            if ( viewerPreferences.length ) write ( viewerPreferences );
            
            if ( outlines.length )
            {
                write('/Outlines '+outlineRoot+' 0 R');
                write('/PageMode /UseOutlines');
            }
        }

        protected function createHeader():void
        {
            write('%PDF-'+pdfVersion);
        }

        protected function createTrailer():void
        {
            write('/Size '+(n+1));
            write('/Root '+n+' 0 R');
            write('/Info '+(n-1)+' 0 R');
        }

        protected function finishDocument():void
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

        protected function startPage ( newOrientation:String ):Page
        {
            nbPages = arrayPages.length;
            state = 2;
            setXY(lMargin, tMargin);
            fontFamily = '';

            if ( newOrientation == '' ) newOrientation = defaultOrientation;
            else if ( newOrientation != defaultOrientation ) orientationChanges[nbPages] = true;
            
            pageBreakTrigger = arrayPages[nbPages-1].h-bMargin;
            currentOrientation = newOrientation;
            
            return arrayPages[nbPages-1];
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
            up = currentFont.up
            ut = currentFont.ut
            var w:Number = getStringWidth(content)+ws*substrCount(content,' ');
            return sprintf('%.2f %.2f %.2f %.2f re f',x*k,(currentPage.h-(y-up/1000*fontSize))*k,w*k,-ut/1000*fontSizePt);
        }

       protected function substrCount ( content:String, search:String ):int
       {
            return content.split (search).length;    
       }

        protected function getNumImages ( object:Object ):int
        {
            var num:int = 0;
            for (var p:String in object) num++;
            return num;
        }

        protected function escapeString(content:String):String
        {
            return '('+escape(content)+')';
        }

        protected function escape(content:String):String
        {
            return findAndReplace(')','\\)',findAndReplace('(','\\(',findAndReplace('\\','\\\\',content)));
        }

        protected function writeStream(stream:String):void
        {
            write('stream');
            write(stream);
            write('endstream');
        }

        protected function write( content:* ):void
        {
            if ( currentPage == null ) throw new Error ("No pages available, please call the addPage method first !");
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