public class MMR_AIP_Applicants_Controller extends MMR_PageControllerBase
{
    public Integer whichLine{get;set;}
    public Opportunity Opp{get;set;}
    public Dummy_Account__c ap{get;set;}
    public Account TempAccount{get;set;}
    public String TempFirstName{get;set;} 
    public String TempLastName{get;set;} 
    public String TempTitle{get;set;}  
    public List<Account> ExistingAccounts {get;set;}
    public Boolean IsExternal {get;set;}
    public List<Account> Accs{get;set;}
    
     Transient List<IBB_Product_Set__c> ProductSets;
    
    public List<IBB_Product_Set__c> GetProductSets
    {
        get{
            if(ProductSets== null)
            {
                ProductSets = [select id,name,IDD_Document__c,IDD_NonF2F_Document__c ,ProductSetType__c  from ibb_product_set__c  where ProductSetType__c != null ];
            }
            return ProductSets;
        }
    } 
    
    public String GetIDDDocument(String type,Boolean faceToFace)
    {
        for(IBB_Product_Set__c p : GetProductSets)
        {
            if(p.ProductSetType__c.equalsIgnoreCase(type))
            {
                if(faceToFace)
                return LiabilitiesHelperFunctions.GetResourceURL( p.IDD_Document__c);
                
                return LiabilitiesHelperFunctions.GetResourceURL( p.IDD_NonF2F_Document__c);
            }            
        }
        return null;
    }
    
    public boolean IsHPP{
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('Home Purchase Plan');
        }
    }
    public boolean IsBTL{
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('Buy To Let Purchase Plan');
        }
    }
    public boolean IsPrem{
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('Home Purchase Plan Premier');
        }
    }
    public boolean IsHPS{
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('Home Purchase Scotland');
        }
    }
    public boolean IsHTB{
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('Help to Buy Home Purchase Plan');
        }
    }
       /*C0782 REAC changes start*/
     public boolean IsREACHPP{
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('REAC Home Purchase Plan');
        }
    }
     public boolean IsREACHPS{
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('REAC Home Purchase Scotland');
        }
    }
     public boolean IsREACBTL{
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('REAC Buy To Let Purchase Plan');
        }
    }
     public boolean IsREACBTLS{
        get{
            return Opp.Interested_in__c.equalsIgnoreCase('REAC Buy To Let Purchase Plan Scotland');
        }
    }
   
    /*C0782 REAC changes END*/
    
    
    public String HPPDocument{
        get{
            return GetIDDDocument('HPP',true);
        }
    }
    public String HPSDocument{
        get{
            return GetIDDDocument('HPS',true);
        }
    }
    public String PremierDocument{
        get{
            return GetIDDDocument('Premier',true);
        }
    }
    public String BTLDocument{
        get{
            return GetIDDDocument('BTL',true);
        }
    }
    public String HTBDocument{
        get{
            return GetIDDDocument('HTB',true);
        }
    }
    
    public PageReference Setup()
    {
        List<Debug__c> debugs = [select id from debug__c where opportunity__c =:opportunityid];
        if(debugs.size() == 0)
        {
            Debug__c d = new Debug__c();
            d.opportunity__c = opportunityid;
            insert d;
        } 
        
            
    
       tempAccount = new Account();
        IsExternal = false;
         ap = new Dummy_Account__c();
        String oppSoql = LiabilitiesHelperFunctions.SoqlQuery('MMR_AIP_Opp') + ' from Opportunity where id= \'' + opportunityId + '\'';
        system.debug('OPP soql :' + oppSoql);
        List<Opportunity > Opps = DataBase.Query(oppSoql);
        
        if(Opps==null)
            return null;
        if(Opps.size() != 1)
            return null;
            
        Opp = Opps[0];
        
        Applicants = [select id,Applicant_Number__c,Prospect_Customer__r.EBS_ID__c,Prospect_Customer__r.Salutation,Prospect_Customer__r.FirstName,Prospect_Customer__r.LastName,Prospect_Customer__r.Date_of_Birth__c  from Applicant__c where Opportunity__c= :opportunityid order by Applicant_Number__c];
        
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_AIP_Applicant') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
        }
        
        
        if(Opp != null)
        {
        if(Accs.size() > 1)
            Opp.Is_Joint_Application__c = true;
        }
        
        opp.Number_of_People_Applying__c = Accs.size();
        update opp;
        return null;
    }
    
    public PageReference LookupApplicant() 
    {   
        ExistingAccounts =null;
        
        if(ap.AccountLookup__c == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select an existing customer first');
            ApexPages.addMessage(myMsg); 
            return null;
        }
        
        
        
        if(Opp.Number_of_People_Applying__c >= prodSet.Max_No_of_Applicants__c)
        {
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Maximum number of applicants is ' + prodSet.Max_No_of_Applicants__c);
            ApexPages.addMessage(myMsg); 
            return null;
        }
        system.debug('AP is :' + ap );
        if(ap!= null)
        {
            AddExistingAccount(ap.AccountLookup__c);            
        }
        return null;
    } 
    
   public PageReference NextAIP()
    {
        return new PageReference('/apex/mmr_aip?id=' + eventid);
    }
  
    
     public PageReference delItem()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        Decimal appNo;
        for(Integer i = 0 ; i < accs.size();i++)
        {
            if(Applicants[i].Applicant_Number__c == whichLine)
            {
                //remove from accounts
                for(Integer x=0;x<accs.size();x++)
                {
                    if(accs[x].id == Applicants[i].Prospect_Customer__c)
                    {           
                        appNo = Applicants[i].Applicant_Number__c;
                        accs.remove(x);
                        break;
                    }
                }   
                
                Applicant__c remove = Applicants.remove(i);
                delete remove;
                break;            
            }
        
        }   
        Opp.Number_of_People_Applying__c = accs.size();
        update opp;                      
                      
        //re calculate application no.
        Integer found = 1;
        Integer find = 2;
       
        while(found < Applicants.size())
        {            
            system.debug('Looking for ' + find +' found ' + found);
        
            Boolean isFound = false;
            for(Applicant__c a : Applicants)
            {
                if(a.Applicant_Number__c == find)
                {
                    system.debug('Found find:' + find);
                    isFound = true;
                    found = found +1;
                    system.debug('setting no ' + a.Applicant_Number__c +' to ' + found);
                    a.Applicant_Number__c =found;
                    break;
                }
            }
            if(!isFound)
            {
                find = find+ 1;
                system.debug('Found item, now looking for ' + find);
            }            
        }
        update applicants;
        return null;
    }
    
     public void AddExistingAccount(String accountId)
    {
           //check account is not already added
           for(Account a : accs)
           {
                if (a.id == accountId)
                {
                    String msg = a.salutation + ' ' + a.firstname + ' ' + a.lastname +' already exists on this application';
                
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);
                    ApexPages.addMessage(myMsg);
                    return ;
                }
           }    
    
           //load applicant
           Account addAcc = DataHelper.GetAccount(accountId)[0];
           accs.add(addAcc); 
           
           //create applicant
           Applicant__c addApp = new Applicant__c();
           
           if(Applicants == null)return;
           
           addApp.Applicant_Number__c = Applicants.size() + 1;
           addApp.Opportunity__c = Opp.id;
           addApp.Prospect_Customer__c = addAcc.id;
           
           insert addApp;
           addApp.Prospect_Customer__r = addAcc;
           Applicants.add(addApp);
           
           //tempAccount = new Account();
           ap.AccountLookup__c=null;
           Opp.Number_of_People_Applying__c = accs.size();
           update opp;
       }
       
       public List<SelectOption> getTitles() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Mr','Mr'));
            options.add(new SelectOption('Mrs','Mrs'));
            options.add(new SelectOption('Miss','Miss'));
            options.add(new SelectOption('Ms','Ms'));
            options.add(new SelectOption('Dr','Dr'));   
            options.add(new SelectOption('Lady','Lady'));         
            options.add(new SelectOption('Other','Other'));
            options.add(new SelectOption('Prof','Prof'));
            options.add(new SelectOption('Sheikh','Sheikh'));
            options.add(new SelectOption('Captain','Captain'));
            options.add(new SelectOption('Mx','Mx'));
            return options;
    }
    
    public PageReference AddApplicant()
    {    
        if(Opp.Number_of_People_Applying__c >= prodSet.Max_No_of_Applicants__c)
        {
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Maximum number of applicants is ' + prodSet.Max_No_of_Applicants__c);
            ApexPages.addMessage(myMsg); 
            return null;
        }

        //search existing accounts
        if(!IsExternal)
        {
        ExistingAccounts = DataHelper.GetExistingAccounts(TempFirstName,TempLastName,tempAccount.Date_of_birth__c);
    
        if(ExistingAccounts.size() > 0 )
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Customer already exists in salesforce.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        }
        
        //if external, check all accounts on the current application
        if(IsExternal)
        {
             for(Account a : accs)
           {
                if (a.FirstName == TempFirstName && a.LastName == TempLastName && tempAccount.Date_of_birth__c == a.Date_of_birth__c  )
                {
                    String msg = a.salutation + ' ' + a.firstname + ' ' + a.lastname +' already exists on this application';
                
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);
                    ApexPages.addMessage(myMsg);
                    return null ;
                }
           }
        }
        
        Account addAcc = new Account();
            addAcc.recordtype = recType ;
            addAcc.firstname = TempFirstName;
            addAcc.lastname = TempLastName;
            addAcc.salutation = TempTitle;
            addAcc.Date_of_birth__c = tempAccount.Date_of_birth__c;
        
        try
        {
            
           
            insert addAcc;
        }
        catch(Exception ex)
        {
            return null;
        }    
        
        try
        {
            AddExistingAccount(addAcc.id);
        }
        catch(Exception ex)
        {
            
        }
        return null;
     }   

}