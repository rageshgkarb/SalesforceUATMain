/* -------------------------------------------------------------------------------------------- */
/* C0315	Prevent crash on insert of newOpp													*/
/* -------------------------------------------------------------------------------------------- */



public class HPPStartProductSwitchController extends HPPBaseEventController
{
    public Account_With_IBB__c AccWithIBB{get;set;}
    public IBB_Product__c CurrentProduct{get;set;}
    public IBB_Product__c Prod{get;set;}
    public IBB_Product_set__c ProdSet{get;set;}
    public List<Opportunity> ExistingOpps{get;set;}
    public Boolean AllowStart{get;set;}
    public decimal MarketValue{get;set;}
    
    public PageReference Setup()
    {
        AllowStart=true;
        try
        {
        MarketValue = opp.Purchase_price_market_value__c;
         List<IBB_Product__c> CurrentProducts = [select id,name,IBB_Product_set__c from ibb_product__c where id=: Opp.ibb_product__c ];
         
         if(CurrentProducts.size() == 0)
         {
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Could not find a linked product')  );
             AllowStart = false;
             return null;
         }
         CurrentProduct = CurrentProducts[0];
         
         
         
         
         
         ExistingOpps = [select name, id from opportunity where Switched_From_Opp__c =:OppId and iswon =false and isclosed =false  ];
         
         if(ExistingOpps.Size() > 0)
         {
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, 'There are already product switch opportunities open.')  );         
             AllowStart = false;
            // return null;
         }
         
         if(opp.Switched_From_Opp__c != null && opp.IsWon == false)
         {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, 'This is a product switch opportunity which has not been completed')  );         
            AllowStart = false;
            return null; 
         }
         
         
        ProdSet = [select id, name,Product_Switch_Director__c from ibb_product_set__c where id=: CurrentProduct.IBB_Product_set__c];
        
        
        
        List<account_with_ibb__c > lstAcc= [select id, name,Available_Balance__c ,Monthly_Repayment__c from account_with_ibb__c where id=:opp.account_with_ibb__c];
        
         if(lstAcc.size() == 0)
         {
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Could not find a linked account with ibb')  );
             AllowStart = false;
             return null;
         }
         else
         {
             AccWithIBB = lstAcc[0];
         }
       
        }
        catch(Exception ex)
        {
            AllowStart = false;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Fatal, ex.getMessage() ) );
        }
    
        return null;
    }
    
    
    public PageReference StartSwitch()
    {  
       //create new opp
        Opportunity newOpp = new Opportunity();
        //newOpp.IBB_product__c = SelectedProduct;
        
        
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Opportunity.fields.getMap();
        //List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        
      

        
        for(string fieldName : fldObjMap.keySet())
        {
            if(fldObjMap .get(fieldName).getDescribe().isUpdateable())
            {
           
                if(Opp.get(fieldName) != null)            
                    newOpp.put(fieldName, Opp.get(fieldName));        
            }
        }
        
        newOpp.id = null;
        newOpp.closeDAte = date.today();
        newOpp.ProductEventDirector__c = ProdSet.Product_Switch_Director__c;
        newOpp.STagename = 'New';
        newOpp.Switched_From_Opp__c = opp.id;
        newOpp.Finance_required__c = AccWithIBB.Available_Balance__c *-1;
        newOpp.Name =  Opp.name + ' Product Switch';
        newOpp.Account_with_ibb__c = null;
        newOpp.Product_Switch_Date__c = date.today();
        newOpp.IBBQuotation__c = null;
        newOpp.IBB_Product__c = null;
        newOpp.Purchase_price_market_value__c = MarketValue;
        newOpp.Attachment_Offer_Letter__c = null;
        newOpp.Attachment_Welcome_Letter__c = null;
        
        /*
        newOpp.Accountid = opp.Accountid ;
        
        
        newOpp.Name = 'New Opp for ' + Opp.name;
        
        newopp.interested_in__c = opp.interested_in__c;
        newOpp.Term_of_Finance__c= opp.Term_of_Finance__c;
        
        newOpp.Purchase_price_market_value__c = opp.Purchase_price_market_value__c;
        newOpp.New_Property_street__c = Opp.New_Property_street__c;
        newOpp.New_property_city__c = opp.New_property_city__c;
        newOpp.New_property_country__c=opp.New_property_country__c;
        newOpp.New_property_postcode__c = opp.New_property_postcode__c;
        newOpp.New_property_street__c = opp.New_property_street__c;
        */
        
        
        REcordType rt = [select id from recordtype where developername = 'ProductSwitching' and SobjectType='Opportunity' ];
        newOpp.recordtypeid = rt.id;
		
		/* C0311 start */
		
		Boolean newOppCreated = false;
        try
		{
			insert newOpp;
			newOppCreated = true;
		}
		catch (Exception ex)
		{
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 'The system cannot create the new Opportunity. A usual cause is the original Opportunity owner or seller has left.' ) );
		}
        
        if (newOppCreated)
		{
			/* C0311 end */
	        HPP_extended_opportunity__c exOpp = new HPP_extended_opportunity__c();
	        exOpp.Opportunity__c = newOpp.id;
	        insert exOpp;
	        
	        
	        List<Applicant__c> applicants = [select id,Prospect_Customer__c, Applicant_Number__c ,Primary_Account_Holder__c from  Applicant__c where Opportunity__c =:Opp.id  ];
	        
	        List<Applicant__c> newApps;
	        newApps = new List<Applicant__c>();
	        
	        for(Applicant__c applic : applicants )
	        {
	            Applicant__c app = new Applicant__c();
	            app.Prospect_Customer__c= applic.Prospect_Customer__c;
	            app.Opportunity__c = newOpp.id;
	            app.Applicant_Number__c =applic.Applicant_Number__c ;
	            app.Primary_Account_Holder__c= applic.Primary_Account_Holder__c;
	            newApps.add(app);  
	        }
	        
	        insert newApps;
	          
	               
	        
	        //Prod = [select id,Risk_Features_Document__c,Conga_FIS__c from IBB_Product__c where id=:selectedProduct];
	        
	        IBBEvents ibbEvent = new IBBEvents(ProdSet.Product_Switch_Director__c );
	        ibbEvent.CreateFirstEvent(newOpp.id);        
	        
	        EventLog__c ev= ibbEvent.GetCreatedEvent();
	        
	        
	               
	        if(ibbEvent .GetCreatedEventLocation() != null)
	        {
	            String url = ibbEvent .GetCreatedEventLocation() + '?id=' +ev.id;
	            system.debug('URL: '+ url );
	            return new PageReference( url);
	        }
	        else
	        {
	            return new PageReference( '/apex/HPPBOEvent?id=' + ev.id);
	        }   
		/* C0311 start */
		}
		else
		{
			return null;
		}
		/* C0311 end */
    }

}