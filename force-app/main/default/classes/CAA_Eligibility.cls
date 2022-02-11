public class CAA_Eligibility
{
    public static List<ID> CreateCustomer(CAA_Data.CustomerEligibility data)
    {
        system.debug('Data:' + data);
        //return null;   
        
        Opportunity opp = new Opportunity();
        //Opportunity fields
        opp.CampaignId = data.Campaign;
        opp.Interested_in__c = data.InterestedIn;
        opp.Liabilities_eligibility_comments__c = data.Comments;
        opp.GA_Campaign_Source__c = data.Source;
        opp.GA_Campaign_Medium__c = data.Medium;
        opp.StageName ='Eligibility Completed';
        opp.Name = 'Eligibility';
        opp.CloseDate = Date.today();
        
        RecordType rec = [select id,name from recordtype where developername=:'CAA_Eligibility'];
        opp.recordtypeid = rec.id;
        
        if(string.isBlank(data.AccountId))
        {
            Account acc = new Account();        
            
            //Account fields
            acc.FirstName = data.FirstName;
            acc.LastName = data.LastName;        
            acc.BillingPostalCode = data.Postcode;
            acc.Home_Telephone_No__c = data.PreferedContact;
            acc.PersonEmail = data.Email;
            acc.Date_Of_Birth__c = data.DOB.Value; 
            acc.Salutation = data.Salutation;
            insert acc;       
            opp.AccountId = acc.id;
        }
        else
        {
            opp.AccountId = data.accountId;
        }
        
        if(data.WebFormDataId!=''){
            opp.Web_Form_Data__c = data.WebFormDataId;
        }
        
        insert opp;         
        
        return new List<ID>{opp.AccountId,opp.Id};        
    }
}