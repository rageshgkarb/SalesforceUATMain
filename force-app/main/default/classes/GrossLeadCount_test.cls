@isTest
public class GrossLeadCount_test{
    static testMethod void StdPageCount(){
        test.startTest();
            GrossLeadCount glc=new GrossLeadCount();
            Campaign cam=new Campaign();
            cam.name='test';
            cam.IsActive=true;
            cam.StartDate=Date.today();
            cam.Type='TV';
            insert cam;
            Lead l=new Lead();
            l.Primary_Source_Campaign__c=cam.id;
            l.LastName='veni';
            insert l;
           //GrossLeadCount.customPageCount(l);
        test.stopTest();
    }     
}