global class CAA_RM_Controller extends CAA_Core_Controller 
{
	/**************************************************/
	/* C0592                                          */
	/**************************************************/
	
   public PageReference RM_Init()
   {
       if(GoToLogin()) return new PageReference('/apex/CAA_product_screen');

	   //CAA_Data.PersonDetailsData data = new CAA_Data.PersonDetailsData();
        
       //List<Applicant__c> applicants = [select id, prospect_customer__c  from applicant__c 
                                            //where opportunity__c =: opportunityId order by applicant_number__c];
                                            
       //List<Opportunity> opp = [select AccountId, IBB_product__c,IBB_product__r.name, Account_with_IBB__c,CampaignId,Paper_Statements__c   from opportunity where id=:opportunityId];
       
       //if(opp.size()>0)
	   //{
	   	   //String context = opp[0].ibb_product__r.name.equalsIgnoreCase('ANC-HPP')? 'HPP' : 'CAA';
	   //}

       return null;
   }

   @RemoteAction
   global static Teller_Data.GenericResponse PasswordVerification(String userName, String password)
   {
       return Teller_Function_Overrides.PasswordVerification(userName, password);
   }

   
}