@isTest 
public class CopyRequestCallBackBatchTest{
    static testMethod void testMethod1() {
        List<Lead> lstLead = new List<Lead>();
        for(Integer i=0 ;i <200;i++)
        {
            lead l = new lead();
            l.Are_you_an_existing_customer__c = 'True';
            l.Form_Type__c = 'Request Call Back';
            l.lastname = 'Test';
            lstLead.add(l);
        }
        
        insert lstLead;
        
        Test.startTest();

            CopyRequestCallBackBatch obj = new CopyRequestCallBackBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}