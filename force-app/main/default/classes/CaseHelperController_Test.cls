@isTest(seeAllData = true)

public class CaseHelperController_Test{

    //for class CaseHelperController
    static TestMethod void CaseHelperController_Test(){
    
    //create a reference to vf page - Case Helper
    PageReference CaseHelper = Page.Case_Helper;
    Test.setCurrentPage(CaseHelper);
    
    //create test data
    Case cs = new Case(Description ='test');
    insert cs;
    
    //call constructor    
    ApexPages.standardController stdController = new ApexPages.standardController(cs);
    CaseHelperController obj_CaseHelper = new CaseHelperController(stdController);

    //invoke the remote action methods
    CaseHelperController.getInternalStaffContact();
      
    }

}