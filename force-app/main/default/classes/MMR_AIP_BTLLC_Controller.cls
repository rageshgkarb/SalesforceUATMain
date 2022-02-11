/***************/
/*  C0644      */
/***************/
public class MMR_AIP_BTLLC_Controller extends MMR_PageControllerBase
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
  public CPF_Relationship__c tempRel {get;set;}
    public CPF_Relationship__c Relationship{get;set;}
    public String RemoveEditRelationship{get;set;}
    public String ExistingRel{get;set;}
  public Decimal TotalShareholding
  {
    get 
    {
      if(TotalShareholding==null)
      {
        TotalShareholding=0;
      }
      return TotalShareholding;
    }
    set;
  }
  public Decimal MinShareholding {get; set;}
  public Boolean PassedAffordability{get;set;}
    public Boolean DocumentCreated{get;set;}
    public String FileId {get;set;}
    
    public Transient Interfaces.ICongaSettings m_congaSettings;  
    
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
    
    public String BTLDocument{
        get{
            return GetIDDDocument('BTL',true);
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
        
            
    Relationship = new CPF_Relationship__c();
    tempRel = new CPF_Relationship__c();
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
        
        LoadApplicants();

    TotalShareholding = Applicants[0].Prospect_Customer__r.Total_Director_Shareholding__c;
    if(TotalShareholding==null)
    {
      TotalShareholding=0;
    }

    if(Applicants.size()==1 && TotalShareholding>0)
    {
      // This indicates an application by an existing company so we need to create the applicant records for this Opp
      CreateExistingApplicants();
    }

    MinShareholding = [select value__c from BTL_LC_Min_Directors_Shareholding__c][0].value__c;
        
        Accs = new List<Account>();
        for(String accid : lstAccountIds )
        {
            String soql = LiabilitiesHelperFunctions.SoqlQuery('MMR_AIP_Applicant') + ' from account where id = \'' + accid + '\''  ;
            Account a = DataBase.Query(soql);
            Accs.add(a);
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
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Maximum number of directors is ' + (prodSet.Max_No_of_Applicants__c-1));
            ApexPages.addMessage(myMsg); 
            return null;
        }

    if(!passShareholderTests(tempRel))
    {
      return null;
    }

        system.debug('AP is :' + ap );
        if(ap!= null)
        {
            AddExistingAccount(ap.AccountLookup__c,tempRel);            
        }
        return null;
    } 
    
    
    public PageReference delItem()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        Decimal appNo;
        for(Integer i = 1 ; i < accs.size();i++)
        {
            if(Applicants[i].Applicant_Number__c == whichLine)
            {
                //remove from accounts
                for(Integer x=0;x<accs.size();x++)
                {
                    if(accs[x].id == Applicants[i].Prospect_Customer__c)
                    {           
                        appNo = Applicants[i].Applicant_Number__c;
            List<CPF_Relationship__c> relToDelete = [select id,Shareholder_Percentage__c from CPF_Relationship__c where Child_Account__c=:accs[x].id and Parent_Account__c=:accs[0].id limit 1];
            if(relToDelete.size()>0)
            {
              if(relToDelete[0].Shareholder_Percentage__c!=null)
              {
                TotalShareholding-=relToDelete[0].Shareholder_Percentage__c;
              }
              delete relToDelete;
            }
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
                      
         // Renumber applicants
    Integer num = 1;
    for(Applicant__c a : Applicants)
    {
      a.Applicant_Number__c=num;
      num++;
    }


    update applicants;
        return null;
    }

  public PageReference Complete()
    {
        try {
      update accs;
          update Opp;
        }
        catch (Exception ex) {
          System.debug('Exception on Update exOpp : ' + ex);
          return null;
        }
    
        CompleteEvent();
        return GoToNextEvent();
  
    }

  public Decimal Diff {get;set;}
    public Decimal hppRepayment {get;set;}
    public Decimal total{get;set;}
    
    public PageReference Afford()
    {
        Opp.Dear_customer__c = 'To whom it may concern';
    
    update opp;
        update accs;

        List<double> btlAffordResult=LiabilitiesHelperFunctions.btlAfford(opp,accs);
                
        double netIncome=btlAffordResult[2];
        hppRepayment=btlAffordResult[0];
        total=btlAffordResult[1];
  
        Diff=(netIncome-total).setScale(2);

    if ( Diff >= 0 || Opp.Income_Assisted_Application__c == true )
    {
      passedAffordability = true;
    }
    else
    {
      passedAffordability = false;
    }

        return null;
    }
    
    public PageReference CreateDoc()
    {
        system.debug('OPP id:' + opportunityId );
        
        if(m_congaSettings == null)
        {
            IBB_Product_Set__C ps = [select Conga_AIP_MMR__c from IBB_Product_Set__C where id=:Prodset.id];
            m_congaSettings = new CongaSettings(ps.Conga_AIP_MMR__c);
        }
        
        
        string body= m_congaSettings.CallConga(opportunityId);   
        
        if(m_congaSettings.GetAttachmentId() != null)
        {
            FileId =  m_congaSettings.GetAttachmentId();
            //opp.Attachment_Welcome_Letter__c= m_congaSettings.GetAttachmentId();
            DocumentCreated = true;
      System.debug('DocumentCreated='+DocumentCreated);
      //integer i=1/0;
            update opp;
        }      

        return null;
    }
    
    public void AddExistingAccount(String accountId, CPF_Relationship__c rel)
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

    // Does the applicant pass the age test?
    if(!passAgeTest(addAcc.Date_of_Birth__c))
    {
        String msg = addAcc.salutation + ' ' + addAcc.firstname + ' ' + addAcc.lastname +' needs to be 21 or over to apply';
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);
                ApexPages.addMessage(myMsg);
        TotalShareholding-=rel.Shareholder_Percentage__c;
                return ;
    }

    if(!passShareholderTests(rel))
    {
      return;
    }

        accs.add(addAcc); 
           
        //create applicant
        Applicant__c addApp = new Applicant__c();
           
        if(Applicants == null)return;
           
        addApp.Applicant_Number__c = Applicants.size() + 1;
        addApp.Opportunity__c = Opp.id;
        addApp.Prospect_Customer__c = addAcc.id;
    addApp.Is_Director__c = 'Yes';
        addApp.Is_Shareholder__c = rel.Is_Shareholder__c;
        addApp.Is_Signatory__c = rel.Is_Signatory__c;
        addApp.Shareholder_Percentage__c = rel.Shareholder_Percentage__c;
        addApp.Position_Held__c= rel.Is_Shareholder__c=='Yes' ? 'Director & Shareholder' : 'Director' ;
           
        insert addApp;
        addApp.Prospect_Customer__r = addAcc;
        Applicants.add(addApp);
           
        addRelationship(Accs[0].id,addAcc.id, rel);
    
    //tempAccount = new Account();
        ap.AccountLookup__c=null;
        Opp.Number_of_People_Applying__c = accs.size();
        update opp;
    }
       
    public List<SelectOption> getTitles()
  {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Mr','Mr'));
        options.add(new SelectOption('Mrs','Mrs'));
        options.add(new SelectOption('Miss','Miss'));
        options.add(new SelectOption('Ms','Ms'));
        options.add(new SelectOption('Dr','Dr'));            
        options.add(new SelectOption('Other','Other'));
        options.add(new SelectOption('Prof','Prof'));
        options.add(new SelectOption('Sheikh','Sheikh'));
        options.add(new SelectOption('Lady','Lady'));
        options.add(new SelectOption('Captain','Captain'));
        options.add(new SelectOption('Mx','Mx'));
        return options;
    }
    
    public PageReference AddApplicant()
    {    
        if(Opp.Number_of_People_Applying__c >= prodSet.Max_No_of_Applicants__c)
        {
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Maximum number of directors is ' + (prodSet.Max_No_of_Applicants__c-1));
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

    // Check required fields
    if(TempFirstName==null || TempLastName == null || TempAccount.Date_of_birth__c==null || TempAccount.Gross_Annual_Income__c==null || TempAccount.Net_Monthly_Income__c==null || TempAccount.Marital_Status__c==null)
    {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please complete all required fields.');
      ApexPages.addMessage(myMsg);
      return null;
    }

    // Does the applicant pass the age test?
    if(!passAgeTest(TempAccount.Date_of_Birth__c))
    {
        String msg = TempTitle + ' ' + TempFirstName + ' ' + TempLastName +' needs to be 21 or over to apply';
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,msg);
                ApexPages.addMessage(myMsg);
                return null;
    }

    if(!passShareholderTests(Relationship))
    {
      return null;
    }
        
        Account addAcc = new Account();
            addAcc.recordtype = recType ;
            addAcc.firstname = TempFirstName;
            addAcc.lastname = TempLastName;
            addAcc.salutation = TempTitle;
            addAcc.Date_of_birth__c = TempAccount.Date_of_birth__c;
      addAcc.Gross_Annual_Income__c = TempAccount.Gross_Annual_Income__c;
      addAcc.Net_Monthly_Income__c = TempAccount.Net_Monthly_Income__c;
      addAcc.Marital_Status__c = TempAccount.Marital_Status__c;
        
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
            AddExistingAccount(addAcc.id, Relationship);
        }
        catch(Exception ex)
        {
            
        }

    addRelationship(Accs[0].id,addAcc.id, Relationship);
    
        return null;
     }

   private void addRelationship(Id parentID, Id childId, CPF_Relationship__c rel)
   {
         CPF_Relationship__c tempRelationship;
         
         List<CPF_Relationship__c> tempRels = [select id from CPF_Relationship__c where parent_account__c =:parentID and child_account__c =:childId];          
         
         if(tempRels.size()== 0 )
         {
             tempRelationship = new CPF_Relationship__c ();
         }
         else
         {
             tempRelationship = tempRels[0];
         }
             
         tempRelationship.Parent_account__c = parentID;
         tempRelationship.Child_account__c = childId;
         tempRelationship.Is_Director__c = 'Yes';
         tempRelationship.Is_Shareholder__c = rel.Is_Shareholder__c;
         tempRelationship.Is_Signatory__c = rel.Is_Signatory__c;
         tempRelationship.Shareholder_Percentage__c = rel.Shareholder_Percentage__c;
         tempRelationship.Position_Held__c= rel.Is_Shareholder__c=='Yes' ? 'Director & Shareholder' : 'Director' ;
     
         upsert tempRelationship;

   }

   private void LoadApplicants()
   {
    Applicants = [select id,Applicant_Number__c,Prospect_Customer__r.Name,Prospect_Customer__r.Business_email_address__c,Prospect_Customer__r.EBS_ID__c,Prospect_Customer__r.Salutation,Prospect_Customer__r.FirstName,Prospect_Customer__r.LastName,Prospect_Customer__r.Date_of_Birth__c,Shareholder_Percentage__c,Prospect_Customer__r.Total_Director_Shareholding__c  from Applicant__c where Opportunity__c= :opportunityid order by Applicant_Number__c];
   }

   private Boolean passShareholderTests(CPF_Relationship__c rel)
   {
    if(rel.Is_Shareholder__c!='Yes')
    {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'All directors on the application must be shareholders.');
            ApexPages.addMessage(myMsg); 
            return false;
    }

    if((rel.Shareholder_Percentage__c==null || Integer.valueOf(rel.Shareholder_Percentage__c)<1))
    {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You must enter a value for this directors shareholding percentage.');
            ApexPages.addMessage(myMsg); 
            return false;
    }

    if(hasExceededShareholding(rel.Shareholder_Percentage__c))
    {
      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Maximum directors shareholding is 100% (Currently '+TotalShareholding+'%)');
            ApexPages.addMessage(myMsg); 
            return false;
    }
    return true;
   }

   private Boolean passAgeTest(Date dob)
   {
    if(Date.today()>=dob.addYears(21)) // TODO: Age should probably be put into a custom setting
    {
      return true;
    }
    return false;
   }

   private Boolean hasExceededShareholding(decimal newShareholding)
   {
    List<Account> ParentAcc = [select id,Total_Director_Shareholding__c from Account where id=:Accs[0].ID limit 1];
    if(ParentAcc[0].Total_Director_Shareholding__c==null)
    {
      ParentAcc[0].Total_Director_Shareholding__c=0;
    }
    if(ParentAcc.size()>0 && ParentAcc[0].Total_Director_Shareholding__c+newShareholding>100)
    {
      TotalShareholding=ParentAcc[0].Total_Director_Shareholding__c;
      return true;
    }

    TotalShareholding=ParentAcc[0].Total_Director_Shareholding__c+newShareholding;
    return false;
   }

  private void CreateExistingApplicants()
  {
    // Get list of CPF relationships based on Applicant1
    List<CPF_Relationship__c> dirs = [select id,Child_Account__c,Shareholder_Percentage__c,Is_Director__c,Is_Shareholder__c,Position_Held__c,Is_Signatory__c from CPF_Relationship__c where Parent_Account__c=:Applicants[0].Prospect_Customer__r.id order by CreatedDate];
    
    for(CPF_Relationship__c dir : dirs)
    {
      Applicant__c addApp = new Applicant__c();
      addApp.Applicant_Number__c = Applicants.size() + 1;
      addApp.Opportunity__c = Opp.id;
      addApp.Prospect_Customer__c = dir.Child_Account__c;
      addApp.Is_Director__c = dir.Is_Director__c;
      addApp.Is_Shareholder__c = dir.Is_Shareholder__c;
      addApp.Is_Signatory__c = dir.Is_Signatory__c;
      addApp.Shareholder_Percentage__c = dir.Shareholder_Percentage__c;
      addApp.Position_Held__c= dir.Position_Held__c;
            
      insert addApp;

      addApp.Prospect_Customer__r = DataHelper.GetAccount(dir.Child_Account__c)[0];
      Applicants.add(addApp);
      lstAccountIds.add(addApp.Prospect_Customer__c);
    }
  }
    
    
}