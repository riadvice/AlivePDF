package org.alivepdf.billing
{
	import flash.utils.ByteArray;
	
	public class Company
	{
		public var name:String;
		public var address:String;
		public var postalCode:String;
		public var city:String;
		public var country:String;
		public var phone:String;
		public var fax:String;
		public var logo:ByteArray;
		
		public function Company(name:String, address:String, cp:String, city:String)
		{
			this.name = name;
			this.address = address;
			this.postalCode = cp;
			this.city = city;
		}

	}
}