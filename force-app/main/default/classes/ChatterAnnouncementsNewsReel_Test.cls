@isTest
private class ChatterAnnouncementsNewsReel_Test {
	
	@isTest static void test_method_one() {

		ChatterAnnoucementNewsReelSettings__c newReelSeetting = new ChatterAnnoucementNewsReelSettings__c(Name = 'Default', Scroll_Interval__c = 10000, Scroll_Speed__c = 10000);
		insert newReelSeetting;

		Test.setCurrentPage(Page.ChatterAnnouncementsNewsReel);

		ChatterAnnouncementsNewsReelController controller = new ChatterAnnouncementsNewsReelController();
		Integer scrollSpeed = controller.scrollSpeed;
		Integer scrollInterval = controller.scrollInterval;
	}
		
}