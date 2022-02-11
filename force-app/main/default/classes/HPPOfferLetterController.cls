/* -------------------------------------------------------------------------------- */
/* C00108 / P00001 More info for productswitching                                   */
/* -------------------------------------------------------------------------------- */
public class HPPOfferLetterController extends HPPBaseEventController
{
    public Actions.IAction RCEAction{get;set;} 
      //CO760 START
     public Valuation_Report__c ValReport{get;set;} 
     public Account acc{get; set;}
     public HPPEventConditionHelper helper{get;set;}
     public HPPEventConditionHelper.ConditionItem CurrentItem{get;set;}
     public Integer edCondition{get;set;}
     public list<Applicant__c> appli{get;set;}
     List<Account> accToUpdate{get;set;}
     public string s{get;set;}
     public integer i=1;
     public List<Applicant__c> sortedAppliBTLLTD{get;set;}
     //C0760-OfferLetter Enhancements ; Start
      public PageReference BulkDeleteCondition()
    { 
        list<HPPEventConditionHelper.ConditionItem> dummyList =  new list<HPPEventConditionHelper.ConditionItem>();
        set<string> itemIds = new set<string>();
        for(HPPEventConditionHelper.ConditionItem item : Helper.CIList){
            if(item.deleteLine){                
                itemIds.add(item.id);
            }else{
                dummyList.add(item);
            }
        }
        if(itemIds.size ()>0)
            Helper.deleteBulkItem(itemIds);
            
        Helper.CIList =  new list<HPPEventConditionHelper.ConditionItem>();
        if(dummyList.size() > 0){
            Helper.CIList.addAll(dummyList);    
        } 
        return null; 
    }
     //C0760-OfferLetter Enhancements ; End
     public PageReference EditCondition()
    {
        CurrentItem = helper.CIList[edCondition];         
        return null;
    }
    public PageReference Cancel()
    {
        CurrentItem = null;
        return null;
    }
    
    public PageReference Save2()
    {
        Special_condition_item__c sci = Helper.GetItem(CurrentItem.id);
        CurrentItem.Save(sci);   
         List<Case> FiCases1 = [select CaseNumber, id,satisfied__c,FI_Reason__c, Credit_accepted__c,Further_Information__c, Further_Info_Satisfied__c , underwriter_comments__c,  BDM_comments__c,  createddate, CreatedBy.Name from case where Opportunity__c=:opp.id];
         return null;
    }
    
    public PageReference Hide()
    {
        Special_condition_item__c sci = Helper.GetItem(CurrentItem.id);
        system.debug(sci);
        CurrentItem.Save(sci);
        CurrentItem = null;
        return null;
    }
     //CO760 End
    public HPPOfferLetterController()
    {
        RCEAction= new Actions.ActionRCE2 ();  
        /* C00108 start */ 
        IsProductSwitch = opp.recordtype.Name == 'ProductSwitching' ? true : false;
        /* C00108 end */
        //CO760 START
        helper = new HPPEventConditionHelper(Acc,Opp,ExOpp);
        helper.Load();
        // C0760 added MV_of_property__c for offer letter checklist 
        ValReport = [select Building_reinstatement_value__c,Market_Value_Present_Condition__c,MV_of_property__c from Valuation_Report__c where opportunity__c=:opp.id order by createddate desc limit 1];
        acc=[select RegisteredAddressCountry__c,Customer_Address_District__c,RegisteredAddressPostCode__c,RegisteredAddressCity__c,salutation,isPersonAccount,RegisteredAddressStreet__c,FirstName,LastName,BillingPostalCode,BillingStreet,Organisation_type__c,BillingCity,Organisation_sub_type__c,BillingCountry from account where Id=:opp.AccountId];
        //1832636: To display applicants accroding to its applicant number
        appli=[select Prospect_Customer__r.RecordTypeId,Prospect_Customer__r.RegisteredAddressCountry__c,Prospect_Customer__r.Customer_Address_District__c,Prospect_Customer__r.RegisteredAddressPostCode__c,Prospect_Customer__r.RegisteredAddressCity__c,Prospect_Customer__r.RegisteredAddressStreet__c,Prospect_Customer__r.Organisation_type__c,Prospect_Customer__r.Organisation_sub_type__c,Prospect_Customer__r.Name,Prospect_Customer__r.isPersonAccount,Prospect_Customer__r.Salutation,Prospect_Customer__r.FirstName,Prospect_Customer__r.LastName,Prospect_Customer__r.BillingPostalCode,Prospect_Customer__r.BillingStreet,Prospect_Customer__r.BillingCity,Prospect_Customer__r.BillingCountry from Applicant__c where Opportunity__c=:opp.id order by Applicant_Number__c];
        system.debug('appli'+appli);
        system.debug('appli size'+appli.size());
    }
     //CO760 START
     public PageReference save(){
       
        accToUpdate = new List<Account>();
        for(Integer i = 0; i< appli.size();i++ )
        {
        Account ac = new account();
        if(opp.Interested_in__c !='Buy To Let Limited Company Purchase Plan'){
                if(i==0)
        {
        if (appli[0].Prospect_Customer__r.BillingPostalCode== null||appli[0].Prospect_Customer__r.BillingPostalCode=='')
        {
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Current Address Post Code: You must enter a value'));
        } 
        if (appli[0].Prospect_Customer__r.BillingStreet== null||appli[0].Prospect_Customer__r.BillingStreet=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Current Address street: You must enter a value'));
        }
        if (appli[0].Prospect_Customer__r.BillingCity== null||appli[0].Prospect_Customer__r.BillingCity=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Current Address City: You must enter a value'));
        }
        if (appli[0].Prospect_Customer__r.BillingCountry== null||appli[0].Prospect_Customer__r.BillingCountry=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Current Address Country: You must enter a value'));
        }
        else
           {
                ac.BillingPostalCode = appli[0].Prospect_Customer__r.BillingPostalCode;
                ac.BillingStreet = appli[0].Prospect_Customer__r.BillingStreet;
                ac.BillingCity = appli[0].Prospect_Customer__r.BillingCity;
                ac.BillingCountry = appli[0].Prospect_Customer__r.BillingCountry;
                ac.Customer_Address_District__c = appli[0].Prospect_Customer__r.Customer_Address_District__c;
           }
        }
        if (appli[i].Prospect_Customer__r.Salutation == null||appli[i].Prospect_Customer__r.Salutation=='') {
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Title: You must enter a value'));
        }  
        else if (appli[i].Prospect_Customer__r.FirstName== null||appli[i].Prospect_Customer__r.FirstName=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'FirstName: You must enter a value'));
        }  
        else if (appli[i].Prospect_Customer__r.LastName== null||appli[i].Prospect_Customer__r.LastName=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'LastName: You must enter a value'));
        }  
        else
        {
            //after all validations are passed
            ac.Salutation = appli[i].Prospect_Customer__r.Salutation ;
            ac.FirstName=appli[i].Prospect_Customer__r.FirstName;
            ac.LastName=appli[i].Prospect_Customer__r.LastName;
            system.debug('------------>'+ac.FirstName);
         }
         }else{
                  if(i==0)
        {
        if (appli[0].Prospect_Customer__r.RegisteredAddressPostCode__c== null||appli[0].Prospect_Customer__r.RegisteredAddressPostCode__c=='')
        {
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Current Address Post Code: You must enter a value'));
        }  
        if (appli[0].Prospect_Customer__r.RegisteredAddressStreet__c== null||appli[0].Prospect_Customer__r.RegisteredAddressStreet__c=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Current Address street: You must enter a value'));
        }
        if (appli[0].Prospect_Customer__r.RegisteredAddressCity__c== null||appli[0].Prospect_Customer__r.RegisteredAddressCity__c=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Current Address City: You must enter a value'));
        }
        if (appli[0].Prospect_Customer__r.RegisteredAddressCountry__c== null||appli[0].Prospect_Customer__r.RegisteredAddressCountry__c=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Current Address Country: You must enter a value'));
        }
        else
           {
                ac.RegisteredAddressPostCode__c= appli[0].Prospect_Customer__r.RegisteredAddressPostCode__c;
                ac.RegisteredAddressStreet__c= appli[0].Prospect_Customer__r.RegisteredAddressStreet__c;
                ac.RegisteredAddressCity__c= appli[0].Prospect_Customer__r.RegisteredAddressCity__c;
                ac.RegisteredAddressCountry__c= appli[0].Prospect_Customer__r.RegisteredAddressCountry__c;
           }
        if (appli[0].Prospect_Customer__r.Name== null||appli[0].Prospect_Customer__r.Name=='') {
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'OrganisationName: You can not change organisation name'));
        }  
        else if (appli[0].Prospect_Customer__r.Organisation_type__c== null||appli[0].Prospect_Customer__r.Organisation_type__c=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'OrganisationType: You must enter a value'));
        }  
        else if (appli[0].Prospect_Customer__r.Organisation_sub_type__c== null||appli[0].Prospect_Customer__r.Organisation_sub_type__c=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'OrganisationSubType: You must enter a value'));
        }  
        else
        {
            //after all validations are passed
            ac.Name= appli[0].Prospect_Customer__r.Name;
            ac.Organisation_type__c=appli[0].Prospect_Customer__r.Organisation_type__c;
            ac.Organisation_sub_type__c=appli[0].Prospect_Customer__r.Organisation_sub_type__c;
            system.debug('------------>'+ac.FirstName);
         }
        }
        if(i>0){
        if (appli[i].Prospect_Customer__r.Salutation == null||appli[i].Prospect_Customer__r.Salutation=='') {
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Title: You must enter a value'));
        }  

        else if (appli[i].Prospect_Customer__r.FirstName== null||appli[i].Prospect_Customer__r.FirstName=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'FirstName: You must enter a value'));
        }  
        else if (appli[i].Prospect_Customer__r.LastName== null||appli[i].Prospect_Customer__r.LastName=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'LastName: You must enter a value'));
        }  
        else
        {
            //after all validations are passed
            ac.Salutation = appli[i].Prospect_Customer__r.Salutation ;
            ac.FirstName=appli[i].Prospect_Customer__r.FirstName;
            ac.LastName=appli[i].Prospect_Customer__r.LastName;
            system.debug('------------>'+ac.FirstName);
         }
         }
         }
            ac.id=appli[i].Prospect_Customer__r.id;
            // 1832636 : Not to include the first and last name of limited company products
            ac.RecordTypeId = appli[i].Prospect_Customer__r.RecordTypeId;
            system.debug('account id---->'+ac.id);
            system.debug('Record type Id'+ac.RecordTypeId);
            accToUpdate.add(ac);
        }
        if (opp.New_property_street__c== null||opp.New_property_street__c=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'New property street: You must enter a value'));
        }
        if (opp.New_property_country__c== null||opp.New_property_country__c=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'New property country: You must enter a value'));
        }
        if (opp.New_property_city__c== null||opp.New_property_city__c=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'New property city: You must enter a value'));
        }
         if (opp.New_property_postcode__c== null||opp.New_property_postcode__c=='') {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'New property postcode: You must enter a value'));
        }
         if (opp.Finance_Required__c== null||opp.Finance_Required__c==0) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Finance Amount: You must enter a value'));
        }
        if(opp.StageName=='Offer'){
            String dear = 'Dear ';
            boolean first = true;
            for(Account a : accToUpdate)
            {
                // 1832636 : Not to include the first and last name of limited company products
                if(a.RecordTypeId != label.Business_account_record_type_ID){
                if(first)
                {
                    dear += a.Salutation+ ' ' + a.lastname;
                    first = false;
                    continue;
                }             
                dear += ' , ' +  a.Salutation+ ' ' + a.lastname;
               }
           }
               if(!accToUpdate.isEmpty() && accToUpdate.size() ==4||accToUpdate.size() ==3||accToUpdate.size() ==2){
                  dear = dear.reverse().replaceFirst(',', 'dna').reverse();
                }
            dear += ',';
            Opp.Dear_customer__c = dear; 
                system.debug('Dear'+opp.Dear_Customer__c);
        }
        //C0760 Offer letter Enhancement end
         opp.Market_value_of_Property__c= valReport.Market_value_present_condition__c;
         update ValReport;
         update opp;
         update ExOpp;
         update accToUpdate;
         system.debug('saluation----------------'+appli[0].id);
         //Offer Letter Checklist ; 3/3/2020
         Setup();
         opp = DataHelper.GetOpportunity(opp.id)[0];//Offer letter checklist enhancement to display admin fee ; 16/4/2020
         return null;
     }
     //CO760 End
    public PageReference Setup()
    {
        system.debug('Setup Method');
        if(exopp.Offer_letter_sent__c == null)
        {
            exopp.Offer_letter_sent__c = Date.today();
            //update exopp;
        }   
         
        try
        {
            ErrorLog.Fatal('Calling stubs');
            IBBDependentObjectFactory.CreateRCEStubs (opp);
            
            
            //create clause items
            Standard_Clause_Helper helper = new Standard_Clause_Helper(opp.id);
            helper.run();
            
        }
        catch(Exception ex)
        {
            ErrorLog.Fatal(ex.getMessage());
        }
         
         //CallRCE(); 
        return null;
    }
    
    
    /* C00108 start */
    public boolean IsProductSwitch {get;set;}
    /* C00108 end */
    
    public boolean RCECalled{get;set;}
    public boolean StartRCEPolling{get;set;}
    public boolean RCEFailed{get;set;}
    
    public PageReference CallRCE()
    {
    System.debug('calling RCE ---------->');
        Opp.Attachment_Offer_Letter__c = null;            
        RCEFailed =false;    
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id); 
        if(args.ReturnValue != 'SUCCESS')
        {
            RCEFailed = true;        
        }                
      
        return null;
    }
    
    public Boolean RCECompleted
    {
        get{
            Opp = DataHelper.GetOpportunity(Opp.id)[0];
            if(opp.IBBQuotation__c == null)
                return false;
            
            IBBQuotation__c ibb  = [select RCERetrieved__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];
            return ibb.RCERetrieved__c;
        }        
    }
    
    public PageReference PoolRCE()
    {
        if (RCECompleted)
        {
            StartRCEPolling = false;            
        }
        return null;
    }

    /*
    public PageReference CreateFisDoc()
    {
        Opp = DataHelper.GetOpportunity(opp.id)[0];
        
        if(opp.IBBQuotation__c == null)
            return null;
        
        system.debug('Quote id ' + opp.IBBQuotation__c );
        IBBQuotation__c  quote = [select id,DealType__c,IBBProduct__c,Term_Of_Finance__c,DealAmount__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];

        CongaSettings sett = new CongaSettings(prod.Conga_FIS__c);                         
        string body= sett.CallConga(quote.id);   
        
        if(sett.AttachmentId != null)
        {
            quote.Attachment_FIS__c= sett.AttachmentId;
            update quote;
        }
        return null;
    }
    */

    public PageReference CreateDoc()
    {    

    
        String congaTemplateId;
        if(opp.purpose_of_finance__c.equalsIgnoreCase('New Purchase'))
        {
            congaTemplateId = prod.Conga_Offer_Letter__c;
        }
        if(opp.purpose_of_finance__c.equalsIgnoreCase('Refinancing'))
        {
            congaTemplateId = prod.CongaOfferLetterRefinance__c;
        }
        if(opp.purpose_of_finance__c.equalsIgnoreCase('Equity Release'))
        {
            congaTemplateId = prod.CongaOfferLetterEquityRelease__c;
        }  
        /*C0782: REAC changes start    */  
        if(opp.purpose_of_finance__c.equalsIgnoreCase('Car purchase')||opp.purpose_of_finance__c.equalsIgnoreCase('Home improvements')||opp.purpose_of_finance__c.equalsIgnoreCase('Furnishings')||opp.purpose_of_finance__c.equalsIgnoreCase('3rd party Debt consolidation')||opp.purpose_of_finance__c.equalsIgnoreCase('Property purchase/deposit')||opp.purpose_of_finance__c.equalsIgnoreCase('Others'))
        {
            congaTemplateId = prod.Conga_Offer_Letter__c;
        }        
       /* C0782: REAC changes end*/      
        if(productswitch)
        {
            congaTemplateId = prod.Conga_Offer_Letter_Switch__c;
        }
        
    
        CongaSettings sett = new CongaSettings(congaTemplateId);                         
        string body= sett.CallConga(Opp.id,true);   
        
        if(sett.AttachmentId != null)
        {
            opp.Attachment_Offer_Letter__c= sett.AttachmentId;
            update opp;
        }      
        
        
        
        
        
        
        return null;
    }
    
    /*
    public string FisDocLink
    {
        get{
               List<IBBQuotation__c>  quote = [select id,Attachment_FIS__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];
               
               if(quote.size() == 0)
                   return null;
               
               if(quote[0].Attachment_FIS__c != null)
               {             
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + quote[0].Attachment_FIS__c+ '"><b>FIS</b></a>';
               }
            return null;      
            }
    }
    */
    /* CAT 00748212 start */
    public String KeyFactsLink
    {
        get
        {
            return LiabilitiesHelperFunctions.GetResourceURL(prod.Risk_Features_Document__c);           
        }
    }
   /* CAT 00748212 end */
    public string DocLink
    {
        get{   
            if(DocLinkCreated)                 
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + opp.Attachment_Offer_Letter__c+ '"><b>Offer Letter</b></a>';
            return '';      
            }
    }    
    
    public boolean DocLinkCreated
    {
    get{ 
        return opp.Attachment_Offer_Letter__c!= null;
        }
    }
    
     public PageReference Complete()
    {       
        try
        {
            update exopp;
        }
        catch(Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'eRROR ' + ex.getMessage()   );
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        
        
        
        CompleteEvent();
        
        system.debug('Created event - event ctl ' + CreatedEvent );
        
        return GoToNextEvent();         
    }   
}