package org.alivepdf
{
	import flexunit.framework.TestSuite;

	public class AllTests extends TestSuite
	{
		public function AllTests(param:Object=null)
		{
			addTestSuite( TestHtml );
		}
	}
}