@isTest
public class MMRObservationFormTriggerHandlerTest 
{

static testMethod void setupData()
{
    Account act = new Account();
        act.No_Contact__c=false;
        act.Contact_by_Email_New__c=true;
        act.Contact_by_Post_New__c =true;
        act.Contact_by_SMS_New__c =true;
        act.Contact_by_Telephone_New__c = true;
        act.type='Industry';
        act.marketing_preference__C ='test@gmail.com';
        act.Contact_by_Newsletter_New__c=false;        
        act.FirstName='Alrayan';
        act.LastName='Bank';
        act.Nature_of_Business_NPAA__c='Holding and maintenance';
        act.Organisation_Type__c='Limited Company';
        act.Customer_Type__c='Limited Company';
        insert act;
    
        Opportunity opp = new Opportunity();   
        
        opp.Name = 'Test Data';
        opp.StageName = 'Test STage';
        opp.CloseDate = date.today();
        opp.AccountId = act.Id;
        opp.Interested_in__c = 'test';
        opp.Ex_Pat__c = 'test';
        opp.Income_Assisted_Application__c = true;
        opp.Estimated_actual_monthly_rental_income__c = 900;
        opp.Number_of_People_Applying__c = 5;
        opp.Term_of_Finance__c = 10;
        opp.Purchase_price_market_value__c = 900;
        opp.Number_of_Applicants__c = '3';
        opp.Finance_Required__c = 100;
        insert opp;
    
    	Person__c p1 = new Person__c();
    	p1.Name = 'Sufi test1';
    	insert p1;
    
    test.startTest();
    MMR_observation_form__c mf = new MMR_observation_form__c();
    mf.Staff_name__c = p1.id;
    mf.Opportunity_Name__c = opp.id;
    mf.Additional_applicants_confirmation__c = 'Yes';
    insert mf;
    mf.Additional_applicants_confirmation__c = 'No';
    update mf;  
    test.stopTest();
    
    
}    
}