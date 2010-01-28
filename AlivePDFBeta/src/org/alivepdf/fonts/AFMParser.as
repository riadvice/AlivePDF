package org.alivepdf.fonts
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.alivepdf.events.CharacterEvent;

	// This class is working but still beta and will be optimized (* types to be removed)
	public final class AFMParser extends EventDispatcher
	{
		protected static var fix:Object = { 'Edot':'Edotaccent','edot':'edotaccent','Idot':'Idotaccent','Zdot':'Zdotaccent','zdot':'zdotaccent',
											'Odblacute':'Ohungarumlaut','odblacute':'ohungarumlaut','Udblacute':'Uhungarumlaut','udblacute':'uhungarumlaut',
											'Gcedilla':'Gcommaaccent','gcedilla':'gcommaaccent','Kcedilla':'Kcommaaccent','kcedilla':'kcommaaccent',
											'Lcedilla':'Lcommaaccent','lcedilla':'lcommaaccent','Ncedilla':'Ncommaaccent','ncedilla':'ncommaaccent',
											'Rcedilla':'Rcommaaccent','rcedilla':'rcommaaccent','Scedilla':'Scommaaccent','scedilla':'scommaaccent',
											'Tcedilla':'Tcommaaccent','tcedilla':'tcommaaccent','Dslash':'Dcroat','dslash':'dcroat','Dmacron':'Dcroat','dmacron':'dcroat',
											'combininggraveaccent':'gravecomb','combininghookabove':'hookabovecomb','combiningtildeaccent':'tildecomb',
											'combiningacuteaccent':'acutecomb','combiningdotbelow':'dotbelowcomb','dongsign':'dong' };
		
		protected static const reg:RegExp = /[ ]+/;
		protected static const C:String = "C";
		protected static const AC:String = "20AC";
		protected static const EURO:String = "Euro";
		
		private static const TRUETYPE:int = 0x10000;
		private static const OPENTYPE:int = 0x4F54544F;
		private static const TYPE1:int = 0;
		
		protected var _widths:Dictionary;
		protected var _fontName:String;
		protected var _ascender:*;
		protected var _capHeight:*;
		protected var _capXHeight:*;
		protected var _descender:*;
		protected var _isFixedPitch:Boolean;
		protected var _italicAngle:*;
		protected var _missingWidth:int;
		protected var _stdVW:*;
		protected var _underlineThickness:*;
		protected var _underlinePosition:*;
		protected var _weight:String;
		protected var _flags:int;
		protected var _stemV:*;
		protected var _boundingBox:Array;
		protected var _differences:String;
		protected var _type:String;
		
		protected var fm:Dictionary = new Dictionary(true);
		protected var widthsBuffer:Dictionary = new Dictionary(true);

		public function AFMParser( stream:ByteArray, afm:ByteArray, encoding:Class )
		{
			makeFont ( stream, afm, encoding );
		}
		
		/**
		 * 
		 * @param enc
		 * @return 
		 * 
		 */		
		protected function readMap(enc:ByteArray):Array
		{
			enc.position = 0;
			var a:String = enc.readUTFBytes(enc.bytesAvailable);
			var cc2gn:Array = new Array();
			var tab:Array = a.split("\n");
			
			for each(var item:String in tab)
			{
				if( item.charAt(0) == '!' )
				{
					var e:Array = item.split(AFMParser.reg);
					var cc:int = int("0x"+e[0].substr(1));
					var gn:String = e[2];
					cc2gn[cc ]= gn;
				}
			}
			
			for(var i:int = 0; i<=0xFF; i++)
			{
				if(cc2gn[i] == null )
					cc2gn[i] = '.notdef';
			}
			return cc2gn;
		}
		
		
		protected function readAFM(file:ByteArray, map:Array):Dictionary
		{
			widthsBuffer.length = 0;
			var a:String = file.readUTFBytes(file.bytesAvailable);		
			var buffer:Array = a.split("\n");
			
			for each( var item:String in buffer )
			{
				var e:Array = item.split(" ");
				
				if(e.length<2)
					continue;
				
				var code:String = e[0];
				var param:String = e[1];
				
				if( code == AFMParser.C )
				{
					var cc:int = int(e[1]);
					var w:int = e[4];
					var gn:String = e[7];

					if(gn.substr(-4) == AFMParser.AC)
						gn = AFMParser.EURO
					
					if( AFMParser.fix[gn] != null )
					{
						for (var n:String in map)
						{
							if(map[n] == AFMParser.fix[gn])
								map[n] = gn;
						}
					}
					
					if( map.length == 0 )
						widthsBuffer[cc] = w;
					else
					{
						widthsBuffer[gn] = w;
						if(gn=='X')
							_capXHeight = e[13];
					}
					if(gn == '.notdef')
						_missingWidth = w;	
				}
				
				else if(code == 'FontName')
					_fontName = param;
				else if(code=='Weight')
					_weight = param;
				else if(code=='ItalicAngle')
					_italicAngle = int(param)
				else if(code=='Ascender')
					_ascender = int(param);
				else if(code=='Descender')
					_descender = int(param);
				else if(code=='UnderlineThickness')
					_underlineThickness = int(param);
				else if(code=='UnderlinePosition')
					_underlinePosition = int(param);
				else if(code=='IsFixedPitch')
					_isFixedPitch = (param=='true');
				else if(code=='FontBBox')
					_boundingBox = new Array (e[1],e[2],e[3],e[4]);
				else if(code=='CapHeight')
					_capHeight = int(param);
				else if(code=='StdVW')
					_stdVW = int(param);
			}
			
			if ( _fontName == null )
				throw new Error('FontName not found');
			
			if ( map.length > 0 )
			{
				if( widthsBuffer['.notdef'] == null )
					widthsBuffer['.notdef'] = 600;
				if( widthsBuffer['Delta'] == null  && widthsBuffer['increment'] != null )
					widthsBuffer['Delta'] = widthsBuffer['increment'];
				
				for(var i:int = 0; i<=0xFF;i++)
				{
					if( widthsBuffer[map[i]] == null )
						widthsBuffer[i] = widthsBuffer['.notdef'];
					else widthsBuffer[i] = widthsBuffer[map[i]];
				}
			};
			return widthsBuffer;
		}
		
		protected function makeFontDescriptor(fm:Object, symbolic:Boolean):void
		{
			_ascender = _ascender != null ? _ascender : 1000;
			_descender = _descender != null ? _descender : -200;
			
			var ch:int;
			
			if( _capHeight != null )
				_capHeight = _capHeight
			else if( _capXHeight != null )
				_capHeight = _capXHeight;
			else
				_capHeight = _ascender;
			
			if( _isFixedPitch )
				_flags += 1<<0;
			if(symbolic)
				_flags += 1<<2;
			if(!symbolic)
				_flags += 1<<5;
			if( _italicAngle != 0 && _isFixedPitch != 0 )
				_flags += 1<<6;
			
			if( _boundingBox == null )
				_boundingBox = new Array(0, _descender-100, 1000, _ascender+100);

			if ( _italicAngle == null )
				_italicAngle = 0;

			if( _stdVW != null )
				_stemV = _stdVW;
			else if( _weight != null  && _weight.match('/bold|black/i') )
				_stemV = 120;
			else
				_stemV = 70;
		}
		
		protected function makeWidthArray(buffer:Dictionary):Dictionary
		{
			fm.length = 0;
			for(var i:int = 0; i<=0xFF; i++)
				fm[String.fromCharCode(i)] = buffer[i];
			return fm;
		}
		
		protected function makeFontEncoding(map:Array):String
		{
			var ref:Array = readMap( new CodePage.CP1252() );
			var s:String = new String();
			var last:int = 0;
			
			for(var i:int = 32; i<=0xFF; i++)
			{
				if(map[i] != ref[i])
				{
					if(i!=last+1)
						s += i+' ';
					last = i;
					s +='/'+map[i]+' ';
				}
			}
			return s;
		}
		
		public function makeFont(fontfile:ByteArray, afmfile:ByteArray, enc:Class):void
		{
			var patch:Array = new Array();

			var map:Array = readMap( new enc() );
				
			for (var p:String in patch)
					map[p] = patch[p];
			
			var fm:Dictionary = readAFM(afmfile,map);
			
			var differences:String;
			
			differences = makeFontEncoding(map);
			
			if ( differences.length ) 
				_differences = differences;
			
			makeFontDescriptor(fm, map.length == 0);
			
			if (fontfile)
			{
				fontfile.position = 0;
				var header:uint = fontfile.readUnsignedInt();
				
				if( header == AFMParser.TRUETYPE )
					_type = 'TrueType';
				else if ( header == AFMParser.OPENTYPE )
					_type = 'OpenType';
				else if( header == AFMParser.TYPE1 )
					_type = 'Type1';
				else
					throw new Error('Error: unrecognized font file.');
			}
			else
			{
				if( type!='TrueType' && type != 'Type1' )
					throw new Error('<b>Error:</b> incorrect font type: '+type);
			}
			
			if( _underlinePosition == null )
				_underlinePosition = -100;
			if( _underlineThickness == null )
				_underlineThickness = 50;
			
			_widths = makeWidthArray(fm);
		}

		public function get boundingBox():Array
		{
			return _boundingBox;
		}

		public function get weight():String
		{
			return _weight;
		}

		public function get underlinePosition():*
		{
			return _underlinePosition;
		}

		public function get underlineThickness():*
		{
			return _underlineThickness;
		}

		public function get stdVW():int
		{
			return _stdVW;
		}

		public function get missingWidth():int
		{
			return _missingWidth;
		}

		public function get italicAngle():int
		{
			return _italicAngle;
		}

		public function get descender():int
		{
			return _descender;
		}

		public function get capXHeight():int
		{
			return _capXHeight;
		}

		public function get capHeight():int
		{
			return _capHeight;
		}

		public function get ascender():int
		{
			return _ascender;
		}

		public function get fontName():String
		{
			return _fontName;
		}

		public function get widths():Dictionary
		{
			return _widths;
		}

		public function get stemV():int
		{
			return _stemV;
		}

		public function get differences():String
		{
			return _differences;
		}

		public function get type():String
		{
			return _type;
		}
	}
}