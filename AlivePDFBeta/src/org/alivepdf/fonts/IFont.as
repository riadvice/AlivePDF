package org.alivepdf.fonts
{
	public interface IFont
	{
		
		function get name():String;
		function get id():int;
		function get type():String;
		function get resourceId():int;
		function set resourceId(resourceId:int):void;
		function get underlinePosition():int;
		function get underlineThickness():int;
		function get charactersWidth():Object;
		function get numGlyphs():int;
		
	}
}