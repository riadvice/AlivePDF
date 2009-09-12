package org.alivepdf.fonts.unicodefonts
{
	import flash.utils.getTimer;
	import mx.core.ByteArrayAsset;
	import org.alivepdf.fonts.ICidFont;

	public class ArialUnicodeMS implements ICidFont
	{
		//Metrics
		[Embed( source="arialunicid0_metrics", mimeType="application/octet-stream" )]
		private static var arialunicid0Metrics:Class;
		
		[Embed( source="uni2cid/uni2cid_ag15", mimeType="application/octet-stream" )]
		private static var uni2cid_ag15:Class;
		
		[Embed( source="uni2cid/uni2cid_ac15", mimeType="application/octet-stream" )]
		private static var uni2cid_ac15:Class;
		
		[Embed( source="uni2cid/uni2cid_aj16", mimeType="application/octet-stream" )]
		private static var uni2cid_aj16:Class;
		
		[Embed( source="uni2cid/uni2cid_ak12", mimeType="application/octet-stream" )]
		private static var uni2cid_ak12:Class;
		
		private static var _offset:int = 31;
			
		protected var _type:String = 'cidfont0';
		protected var _name:String = 'ArialUnicodeMS';
		protected var _underlinePosition:int = -100;
		protected var _underlineThickness:int = 50;

// 		For unicode font, the characterWidth table is not defined as 'char' -> Width but as 'charcode' -> Width
		protected var _charactersWidth:Object;
		protected var _numGlyphs:int;
		protected var _resourceId:int;
		protected var _id:int;			 
		
		protected var _desc:Object = {
						'Ascent':1069,
						'Descent':-271,
						'CapHeight':1069,
						'Flags':32,
						'FontBBox':'[-1011 -330 2260 1078]',
						'ItalicAngle':0,
						'StemV':70,
						'MissingWidth':600
					};
		
		protected var _up:int = -100;
		protected var _ut:int = 50;
		protected var _dw:int = 1000;
				
		protected var _diff:String = '';
		protected var _originalsize:int = 23275812;
		
		protected var _enc:String;
		protected var _cidinfo:Object;
		
		protected var _uni2cid:Object;

		/**
		 * Constructor
		 */		
		public function ArialUnicodeMS(cid:int=CidInfo.CHINESE_SIMPLIFIED)
		{
			_id = getTimer();
			initCID(cid);
			_charactersWidth = parseMetricsFile(new arialunicid0Metrics);
		}
		
		private function initCID(cid:int):void{
			
			switch (cid) {
				case CidInfo.CHINESE_TRADITIONAL :
					_enc = 'UniCNS-UTF16-H'
					_cidinfo = {Registry:'Adobe',Ordering:'CNS1',Supplement:0} ;
					_uni2cid = parseMetricsFile(new uni2cid_ac15);
				break;
				case CidInfo.CHINESE_SIMPLIFIED :
					_enc = 'UniGB-UTF16-H'
					_cidinfo = {Registry:'Adobe',Ordering:'GB1',Supplement:2} ;
					_uni2cid = parseMetricsFile(new uni2cid_ag15);
				break;
				case CidInfo.KOREAN :
					_enc = 'UniKS-UTF16-H'
					_cidinfo = {Registry:'Adobe',Ordering:'Korea1',Supplement:0} ;
					_uni2cid = parseMetricsFile(new uni2cid_ak12);
				break;
				case CidInfo.JAPANESE:
				 	_enc = 'UniJIS-UTF16-H'
					_cidinfo = {Registry:'Adobe',Ordering:'Japan1',Supplement:5} ;
					_uni2cid = parseMetricsFile(new uni2cid_aj16);
				break;
			}
			
		}
		
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get charactersWidth():Object
		{
			return _charactersWidth;
		}
		
		/**
		 * reaplace charactersWidth
		 *  @param value
		 * */
		public function  replaceCharactersWidth(value:Object):void{
			_charactersWidth = value;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get name():String
		{	
			return _name;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get numGlyphs():int
		{
			return _numGlyphs;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get type():String
		{
			return _type;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get id ():int
		{	
			return _id;	
		}
		
		/**
		 * 
		 * @param id
		 * 
		 */		
		public function set id ( id:int ):void
		{
			_id = id;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get underlineThickness():int
		{
			return _underlineThickness;;	
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get underlinePosition():int
		{
			
			return _underlinePosition;
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */		
		public function get resourceId():int
		{
			return _resourceId;	
		}
		
		/**
		 * 
		 * @param resourceId
		 * 
		 */		
		public function set resourceId( resourceId:int ):void
		{
			_resourceId = resourceId;	
		}
		
		public function toString ():String 
		{
			return "[CidFont name="+name+" type="+ type +"]";	
		}
		
	
		
		/**
		 * 
		 * @return 
		 * 
		 */	
		public function get desc():Object {
			return _desc;
		}
		
		
		/**
		 * 
		 * @return 
		 * 
		 */	
		public function get up():int{
			return _up;
		}
		
		
		/**
		 * 
		 * @return 
		 * 
		 */	
		public function get ut():int{
			return _ut;
		}
		
		
		
		/**
		 * 
		 * @return 
		 * 
		 */	
		public function get dw():int{
			return _dw;
		}
		
		
	 	/**
		 * 
		 * @return 
		 * 
		 */	
		public function get diff():String {
			
			return _diff;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */	
		public function get originalsize():int{
			return _originalsize;
		}
		
		 		
		/**
		 * 
		 * @return 
		 * 
		 */	
		public function get enc():String {
			
			return _enc;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */	
	 	public function get cidinfo():Object{
	 		return _cidinfo;
	 	};
	 	
	 	
	 	public function get uni2cid():Object{
	 		return _uni2cid;
	 	}
	 	
		/**
		 * 
		 * @Parse Metric File 
		 * 
		 * 
		 */	
		private function parseMetricsFile ( metricFile:ByteArrayAsset ):Object{
			var ret:Object = new Object();
			var content:String = metricFile.readUTFBytes( metricFile.length );
			var sourceCodes:Array = content.split(',');

			var arr:Array;
			for (var i:int = 0; i< sourceCodes.length; i++){
				
				arr = (sourceCodes[i] as String).replace('\r\n', '').split('=>');
				ret[arr[0]] = arr[1];
			}
			return ret;
		}
		
	}
}
