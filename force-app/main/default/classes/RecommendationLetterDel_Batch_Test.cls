/*******************************************************************
* Class Name: Test_Case_Related_Invocable
* Created By: Raiyan
* Purpose : Test Class for Case RecommendationLetterDel_Batch
********************************************************************/
@isTest
public class RecommendationLetterDel_Batch_Test{

    static testMethod void testAttachments(){
        Account acc =  createAccount();          
        Opportunity opp = createOpp(acc);   
        try{
            User u = [SELECT id FROM USER WHERE profile.name ='HPP CAA Intermediary'  AND isactive = true LIMIT 1];
            attachment att = new attachment();
            att.name ='Opp Recommendation Letter';
            att.body =Blob.valueOf('Unit Test Attachment Body');
            att.parentID = opp.id;
            att.ownerid = u.id;
            insert att;
        }catch(exception e){}
         
         test.startTest();
             database.executeBatch(new RecommendationLetterDel_Batch(null),2000);
         test.stopTest();
        
    }
    public static account createAccount(){
        Account acc = new Account();
        acc.Name = 'test1 Force26';
        insert acc;   
        return acc;
    }
    
    public static opportunity createOpp(Account acc){
        Opportunity opp = new Opportunity();   
        opp.Name = 'Test Data';
        opp.StageName = 'Test STage';
        opp.CloseDate = date.today();
        opp.AccountId = acc.Id;
        opp.Interested_in__c = 'test';
        opp.Ex_Pat__c = 'test';
        insert opp;   
        return opp;
    }
}