package org.alivepdf.fonts
{
	public interface ICidFont extends IFont
	{	
		function get desc():Object;
		function get up():int;
		function get ut():int;
		function get dw():int;
		function get diff():String;
		function get originalsize():int;
		function get enc():String;
	 	function get cidinfo():Object;
		function get uni2cid():Object;
		function replaceCharactersWidth(value:Object):void;
	}
}