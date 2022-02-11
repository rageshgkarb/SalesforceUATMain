/**********************************************************************
 Purpose:
 --------
 Test class for IBBPortalSBController for the IBB Portal Sidebar page
 
 History
 ------- 
 VERSION AUTHOR DATE Description
 1.0 - 24/11/2014   Aidan Hosty    Initial Development

 ***********************************************************************/
@IsTest
public with sharing class IBBPortalSBController_TEST 
{

	public static void createPortal_Security_URL_Data()
	{
		List<Portal_Security_URLS__c> urls = new List<Portal_Security_URLS__c>();
		
		Portal_Security_URLS__c trustedUrl = new Portal_Security_URLS__c();
		trustedUrl.Name = '/home/';
		trustedUrl.Trusted__c = true;
		
		urls.add(trustedUrl);
		
		Portal_Security_URLS__c unTrustedUrl = new Portal_Security_URLS__c();
		unTrustedUrl.Name = '/001/';
		unTrustedUrl.Trusted__c = false;
		
		urls.add(unTrustedUrl);
		
		insert urls;
	}
	
	
	@IsTest(SeeAllData=false)
	public static void testController_UnTrusted()
	{
		createPortal_Security_URL_Data();
		Test.setCurrentPage(Page.IBBPortalSideBar);
		ApexPages.CurrentPage().getParameters().put('sdfcIFrameOrigin','https://c.cs18.visual.force.com/001/e');
		
		// Need to run as a Partner User?
		IBBPortalSidebarController controller = new IBBPortalSidebarController();
		controller.getParameters();
		controller.getIFrameOrigin();
		
		System.assert(controller.getIsSuspiciousActivity(), 'Url is suspicious');
		controller.getIsPartnerPortalUser();
		
		controller.createITIncident();
		
		controller.getSendNotificationEmail();
		
	}
	
	@IsTest(SeeAllData=false)
	public static void testController_Trusted()
	{
		createPortal_Security_URL_Data();
		// TODO - create test settings and Assert
		Test.setCurrentPage(Page.IBBPortalSideBar);
		ApexPages.CurrentPage().getParameters().put('sdfcIFrameOrigin','https://c.cs18.visual.force.com/home/home.jsp');
		
		// Need to run as a Partner User?
		IBBPortalSidebarController controller = new IBBPortalSidebarController();
		controller.getParameters();
		controller.getIFrameOrigin();
		
		System.assert(!controller.getIsSuspiciousActivity(), 'Url is not suspicious');
		controller.getIsPartnerPortalUser();
		
		controller.createITIncident();
		
		controller.getSendNotificationEmail();
		
	}
	
	
	public static TestMethod void testIsIdUrl()
	{
		IBBPortalSidebarController controller = new IBBPortalSidebarController();
		
		Map<String,Boolean> testValues = new Map<String,Boolean>();
		testValues.put('http://islamic-bank.force.com/001123456789012345/e',true);
		testValues.put('http://islamic-bank.force.com/001c000000YG84AAAT/e?noredirect=1',true);
		testValues.put('http://islamic-bank.force.com/001c000000YG84A/e?nooverride=1',true);
		testValues.put('https://cs14.salesforce.com/001c000000YG84AAAT/e?nooverride=1',true);
		testValues.put('https://eu0.salesforce.com/001c000000YG84AAAT/e?nooverride=1',true);
		testValues.put('https://eu0.salesforce.com/001c000000YG84A/e?nooverride=1',true);
		testValues.put('https://c.visual.force.com/001c000000YG84AAAT',true);
		testValues.put('https://c.cs18.visual.force.com/001c000000YG84AAAT/e',true);
		testValues.put('https://c.cs18.visual.force.com/001c000000YG84AAAT?xcsad',true);
		testValues.put('https://c.cs18.visual.force.com/001c000000YG84A?xcsad',true);
		testValues.put('https://c.cs18.visual.force.com/001c000000YG84AAAT?nooverride=',true);
		
		testValues.put('https://c.cs18.visual.force.com/001/e',false);
		testValues.put('https://c.cs18.visual.force.com/001/o',false);
		testValues.put('https://cs18.salesforce.com/001/e',false);
		testValues.put('https://eu1.salesforce.com/001/e',false);
		testValues.put('https://c.cs18.visual.force.com/home/home.jsp',false);
		testValues.put('https://c.visual.force.com/apex/newPage',false);
		testValues.put('https://c.visual.force.com/001c000000YG84/',false);
		testValues.put('https://c.visual.force.com/001c000000YG84?',false);
		testValues.put('https://c.visual.force.com/001c000000YG8/',false);
		testValues.put('https://c.visual.force.com/001c000000YG8?',false);
		testValues.put('https://c.visual.force.com/001c000000YG/',false);
		testValues.put('https://c.visual.force.com/001c000000YG?',false);
		testValues.put('https://c.visual.force.com/001c000000Y/',false);
		testValues.put('https://c.visual.force.com/001c000000Y?',false);
		testValues.put('https://c.visual.force.com/001c000000/',false);
		testValues.put('https://c.visual.force.com/001c000000?',false);
		testValues.put('https://c.visual.force.com/001c00000/',false);
		testValues.put('https://c.visual.force.com/001c00000?',false);
		testValues.put('https://c.visual.force.com/001c0000/',false);
		testValues.put('https://c.visual.force.com/001c0000?',false);
		testValues.put('https://c.visual.force.com/001c000/',false);
		testValues.put('https://c.visual.force.com/001c000?',false);
		testValues.put('https://c.visual.force.com/001c00/',false);
		testValues.put('https://c.visual.force.com/001c00?',false);
		testValues.put('https://c.visual.force.com/001c0/',false);
		testValues.put('https://c.visual.force.com/001c0?',false);
		testValues.put('https://c.visual.force.com/001c/',false);
		testValues.put('https://c.visual.force.com/001c?',false);	
		
		for (String s: testValues.keySet())
		{
			System.assertEquals(testValues.get(s), controller.urlStartsWithFullRecId(s),' Testing '+s);	
		}
	}
}