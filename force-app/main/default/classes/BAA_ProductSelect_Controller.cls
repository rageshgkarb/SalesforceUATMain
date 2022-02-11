/* ---------------------------------------------------------------------------------------------------------- */
/* C002??    Sub Organisation type                                                                            */
/* ---------------------------------------------------------------------------------------------------------- */
/* C0056    Business Type field                                                                               */
/* ---------------------------------------------------------------------------------------------------------- */


global class BAA_ProductSelect_Controller 
{
    private aLog.Logger Log = new aLog.Logger('BAA_ProductSelect_Controller');
    public Account Acc{get;set;}
    public Opportunity Opp{get;set;}
    public String Name{get;set;}

    public string ProductType{get;set;}
    public string AccessToFunds{get;set;}
    public transient List<IBB_Product_Suitability__c> ibbProductSuitList {get; set;}
    public List<SelectOption> ibbProductSuitSelect {get; set;}
    public Map<String, String> ibbProductNameMap = new Map<String, String>();
    public String ibbProductSelected {get; set;}
    
    
    /* C002?? *
    public string Organisation {get;set;}
    * C002?? end */

    //public DynamicFields Fields{get;set;}

    //public Map<String,DynamicFields.DataField> f{get;set;}

    public BAA_ProductSelect_Controller ()
    {
        system.debug(existingAccountId );
    
        if(existingAccountId != null)
        {
        /* C0056 start
            List<Account> tempAcc = [select id,name ,Organisation_type__c ,Organisation_sub_type__c, How_did_you_hear_about_IBB__c  
            
                    from account where id=:existingAccountId limit 1];
                    */
            List<Account> tempAcc = [select id,name ,Organisation_type__c ,Organisation_sub_type__c,Business_Type__c, How_did_you_hear_about_IBB__c  
            
                    from account where id=:existingAccountId limit 1];
                    /* C0056 end*/
                    
                    system.debug(tempAcc);
                            
            if(tempAcc.size() == 1)
            {
                Acc = tempAcc[0];
                Name = acc.name;
                
                system.debug(name);
            }
        }
        else
        {
            Acc = new Account(RecordTypeid=recType.id );            
        }
        Opp = new Opportunity();

        //Fields = new DynamicFields('BAA_ProductSelect');
        //f = Fields.Data;


    }
    
    public String existingAccountId
    {
        get{
            if (existingAccountId== null)
            {
                existingAccountId= ApexPages.currentPage().getParameters().get('AccountId');
            }
            return existingAccountId;
        }
        set;
    }
    
    public RecordType recType {
        get {
            if (recType == null){            
                recType = [select id from recordType where ispersontype=false and sobjectType='account' and DeveloperName = 'Business_Account' limit 1];
            }
            return recType;
        }
        set;
    }
    
    public RecordType oppRecType {
        get {
            if (oppRecType == null){            
                  oppRecType = [select id from recordType where  sobjectType='opportunity' and DeveloperName = 'NPAA' limit 1];
            }
            return oppRecType ;
        }
        set;
    }
    
    public List<SelectOption> Campaigns
    {
        get{
            List<SelectOption> options = new List<SelectOption>();
            SelectOption  none = new SelectOption('None','');
                        
            List<Campaign> tempCamps = [select name, id from Campaign where IsActive = true and (EndDate = null or EndDate < TOMORROW) order by name];
            
            for(Campaign c : tempCamps)
            {
                SelectOption sel = new SelectOption(c.id, c.Name);
                options.add(sel);
            }            
            return options;
        }
    }
    
    public String getProductsSuitJson    
    {
        get{
            ibbProductSuitList = [select id,IBB_Product__c, name,Maximum_deposit_amount__c, minimum_deposit_amount__c 
            ,Minimum_age__c,Maximum_age__c,IBB_product__r.Category_of_Product__c,Number_of_applicants__c
            ,Access_to_Funds__c, IBB_product__r.name, IBB_Product_Name__c  
             from IBB_Product_Suitability__c where Show_On_BAA__c= true order by name];
         
         List<ProdTableEntry> pe = new List<ProdTableEntry>();
         for(IBB_Product_Suitability__c p : ibbProductSuitList)
         {
             ProdTableEntry e = new ProdTableEntry();
             e.Name = p.IBB_product__r.name;
             e.Access = p.Access_to_funds__c;
             e.MinAge = string.valueof(p.Minimum_age__c);
             e.MaxAge = string.valueof(p.Maximum_age__c);
             e.Category = p.IBB_product__r.Category_of_Product__c;
             e.MinDeposit = string.valueof(p.Minimum_deposit_amount__c);
             e.MaxDeposit = string.valueof(p.Maximum_deposit_amount__c);
             e.MaxApplicants = string.valueof(p.Number_of_applicants__c);
             e.Id = p.IBB_Product__c;
             pe.add(e);
         }
         
         ibbProductSuitSelect = new List<SelectOption>();
          ibbProductSuitSelect.add(new SelectOption('null',' -- Please Select -- '));
                for (IBB_Product_Suitability__c ibbps : ibbProductSuitList){
                    ibbProductSuitSelect.add(new SelectOption(ibbps.IBB_Product__c,ibbps.IBB_Product_Name__c));
                    ibbProductNameMap.put(ibbps.IBB_Product__c, ibbps.IBB_Product_Name__c);
                }
         
        
        return Json.serialize(pe);
        }
    }
    
    /* C002?? start *
    public List<SelectOption> getSubOrganisations ()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<BAASubOrganisations__c> subOrgs = [SELECT Sub_Organisation_Type__c
                                                FROM    BAASubOrganisations__c
                                                WHERE    Organisation_Type__c = :Organisation];
                                                
        options.add(new SelectOption('Please select','Please select'));
        for (BAASubOrganisations__c org : subOrgs)
        {
            options.add(new SelectOption(org.Sub_Organisation_Type__c,org.Sub_Organisation_Type__c));
        }
        
        return options;
    }
    * C002??? end */


    public String getVar (string a)
    {
        return a + '!!!';
    }

    public Map<String,string> vars
    {
      get{
      Map<String,string> v = new Map<String,string>();
      v.put('1','click it');
      v.put('2','double click it');
      return v;
      }
    }

    public Map<String,boolean> req
    {
      get{
      Map<String,boolean> v = new Map<String,boolean>();
      v.put('1',true);
      v.put('2',false);
      return v;
      }
    }

    public Map<String,String> labelV
    {
      get{
      Map<String,String> v = new Map<String,String>();
      v.put('1','FirstName');
      v.put('2','LastName');
      return v;
      }
    }
    
/*
hjhj

*/

    
    public class ProdTableEntry{
      public String Name {get; set;}
      public String Access{get; set;}
      public String MinAge {get; set;}
      public String MaxAge {get; set;}
      public String MinDeposit{get; set;}
      public String MaxDeposit{get; set;}
      public String MaxApplicants{get; set;}
      public String shortname {get; set;}
      public String Category{get;set;}
      public String Id{get;set;}
      public ProdTableEntry()
      {
      }
      /*public ProdTableEntry(String pName, String pAccess, String pMinAge, String pMaxAge, String pMinDeposit, String pMaxDeposit)
      { this.Name = pName;
      this.Access = pAccess;
      this.MinAge  = pMinAge ;
      this.MaxAge  = pMaxAge ;
      this.MinDeposit = pMinDeposit;
      this.MaxDeposit = pMaxDeposit;
      //this.MaxApplicants = ( pName=='Fixed Term Deposits' ) ? '2' : '4';
      this.MaxApplicants = '2';
      //this.shortname = pShortname;
      }
      */
    }
    
    public PageReference Next()
    {
        PageReference ref = null;
        try
        {
            ref = Complete();
        }
        catch(Exception ex)
        {
            system.debug('EXEX' + ex);
            Log.Fatal('Exception',ex);
        }
        aLog.Save();
        return ref;
    }
        
    public PageReference Complete()
    {
        system.debug('Prod:' + ibbProductSelected   );
        
        //check account name        
        List<Account> lstAccounts;
        if(existingAccountId != null)
        {
            lstAccounts = [select id from account where id!=:existingAccountId and name=:Name limit 1];
        }
        else
        {
            lstAccounts = [select id from account where name=:Name limit 1];
        }
        
        if(lstAccounts.size() > 0)
        {
            Acc.Name.addError('Business name already exists');
            return null;
        }
        
        
    
        IBB_Product__c product = [select ibb_product_set__c, ibb_product_set__r.name from ibb_Product__c where id=:ibbProductSelected   ];
    
        Acc.RecordTypeId = recType.id;
        Acc.Name= Name;
        //Acc.LastName ='-';
        upsert Acc;
        Opp.RecordTypeId = oppRecType.id;
        Opp.AccountId = Acc.id;
        Opp.Name = 'TEst';
        Opp.StageName = 'Product Select';
        Opp.closedate = datetime.now().date();
        Opp.ibb_product__c = product.id;
        Opp.Interested_in__c = product.ibb_product_set__r.name;
        
        Opp.ProductEventDirector__c = EventHelper.GetDirectorIdByProductSet(product.ibb_product_set__c);        
        
        system.debug('Director on opp:' + Opp.ProductEventDirector__c);
        
        system.debug('About to insert opp');
        upsert Opp;
        system.debug('insert opp finished');
        
        
        if(Opp.HPP_extended_opportunity__c == null)
        {
            HPP_extended_opportunity__c tempExOpp = new HPP_extended_opportunity__c ();
            tempExOpp.Opportunity__c = opp.id;
            insert tempExOpp;
            Opp.HPP_extended_opportunity__c = tempExOpp.id;
            update Opp;
        }
        system.debug('Inserted ex opp');
        
        //create applicant
        Applicant__c app = new Applicant__c();
        app.Opportunity__c = Opp.id;
        app.Applicant_Number__c = 1;
        app.Primary_Account_Holder__c = true;
        app.Prospect_Customer__c = Acc.id;
        insert app;
        
        system.debug('Inserted applicant');
        
        IBBEvents ibbEvent = new IBBEvents(Opp.ProductEventDirector__c );
        system.debug('Created ibb events');        
        ibbEvent.CreateFirstEvent(opp.id);        
        system.debug('Created first event');
        
        return new PageReference('/apex/HPPEventRedirect?oppid='  + opp.id);  
    }
    
    @RemoteAction
    global static List<BAA_Suitability__c> GetSettings()
    {
        List<BAA_Suitability__c> lst = [select Organisation_Type__c, Suitability_Id__c from BAA_Suitability__c];
        return lst;
    }
    
    @RemoteAction
    global static List<BAA_Data.ProductSuitabilityData> GetProductSuitability()
    {
         List<IBB_Product_Suitability__c> productSuitability;
    
        
            productSuitability = [select id,IBB_Product__c, name,Maximum_deposit_amount__c, minimum_deposit_amount__c 
            ,Minimum_age__c,Maximum_age__c,IBB_product__r.Category_of_Product__c,Number_of_applicants__c
            ,Access_to_Funds__c, IBB_product__r.name, IBB_Product_Name__c
             from IBB_Product_Suitability__c where Show_On_BAA__c= true order by name];             
        
       
         
        List<BAA_Data.ProductSuitabilityData> suitabilityList = new List<BAA_Data.ProductSuitabilityData>();
        for(IBB_Product_Suitability__c p: productSuitability)
        {
            BAA_Data.ProductSuitabilityData item = new BAA_Data.ProductSuitabilityData();
            item.Name = p.IBB_product__r.name;
            item.Access = p.Access_to_funds__c;
            item.MinAge = string.valueof(p.Minimum_age__c);
            item.MaxAge = string.valueof(p.Maximum_age__c);
            item.Category = p.IBB_product__r.Category_of_Product__c;
            item.MinDeposit = string.valueof(p.Minimum_deposit_amount__c);
            item.MaxDeposit = string.valueof(p.Maximum_deposit_amount__c);
            item.MaxApplicants = string.valueof(p.Number_of_applicants__c);
            item.Over16 = p.Minimum_age__c == 16 ? 'yes' : 'no';
            item.Id = p.IBB_Product__c;
            item.SuitId = p.id;           
            
            if(item.Access.equalsIgnoreCase('Fixed Term'))                item.Access = 'fixed';                 
            if(item.Access.equalsIgnoreCase('Instant Access'))                item.Access = 'Instant';                
            if(item.Access.equalsIgnoreCase('Withdrawal with Notice'))                item.Access = 'Notice'; 
            if(string.isNotBlank(item.Category) && item.Category.equalsIgnoreCase('Tax Free Savings'))                item.Category = 'taxfree';            
            if(string.isNotBlank(item.Category) && item.Category.equalsIgnoreCase('Savings Account'))                item.Category = 'savings';
            if(string.isNotBlank(item.Category) && item.Category.equalsIgnoreCase('Current Account'))                item.Category = 'current'; 
                
            
            suitabilityList.add(item);
        }
        
        return suitabilityList;
    }
    
}