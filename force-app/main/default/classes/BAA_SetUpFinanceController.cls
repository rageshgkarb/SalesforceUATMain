/* ---------------------------------------------------------------------------------------------------- */
/* C00233    New controller                                                                             */
/* ---------------------------------------------------------------------------------------------------- */

public class BAA_SetUpFinanceController extends HPPBaseEventController
{
    public List<Asset_Relationship__c> theSecondaryAccountHolders {get;set;}
    public List<string> SetUpErrors {get;set;}
    public boolean SetupOK {get;set;}
    public IBBEvents.CompleteEventArgs args {get;set;}
    public boolean SetUpCalled {get;set;}
    public List<BAADecisionEngineMatrix__c> DEMatrixList {get;set;}    
    
    public Account_with_IBB__c theIBBAccount 
    {
        get
        {
            if ( theIBBAccount == null )
            {
                 theIBBAccount = new Account_With_IBB__c();
                 
                List<Account_With_IBB__c> theAccs = [SELECT    Id,
                                                               Primary_SFDC_Account__c,
                                                               IBB_Product__c,
                                                               Opportunity__c
                                                    FROM       Account_With_IBB__c
                                                    WHERE      Opportunity__c = :Opp.Id];
                                
                if (theAccs.Size() > 0)
                {
                    theIBBAccount = theAccs[0];
                }
                
            }
            
            return theIBBAccount;
        }
        
        set;
    }
    
   
    
    public List<string> theRelationships {get;set;}
    
    //public 
   
    public List<SelectOption> getRelationships() 
    {        
        List<SelectOption> options = new List<SelectOption>();
        List<EBS_Relationship__c> relationships = [select code__c, text__c from EBS_Relationship__c where relationship_type__c = 'BUSINESS' order by code__c];
        
        options.add(new SelectOption('','Please select'));
        for(EBS_Relationship__c r :  relationships)
        {
            options.add(new SelectOption(r.Code__c,r.text__c));
        }            

        return options;
    }
   
    public Opportunity thisOpp 
    {
        get
        {
            if (thisOpp == null)
            {
                thisOpp = [SELECT    NPAA_Application_signed__c,
                                      NPAA_Documents_Received__c,
                                      Date_Application_Received__c
                           FROM     Opportunity
                             WHERE    Id = :Opp.Id];
                                        
            }
            return thisOpp;
        }
        set;
    } 
    
    public Account_with_IBB__c AccWI {get;set;}
    
    public List<Applicant__c> theApplicants 
    {
        get
        {
            if (theApplicants == null)
            {
                theApplicants = [SELECT    Id,
                                            ApplicantName__c,
                                            Applicant_Number__c,
                                            Has_Mandate__c,
                                            Is_Director__c,
                                            Is_Shareholder__c,
                                            Is_Signatory__c,
                                            Primary_Account_Holder__c,
                                            
                                            Prospect_Customer__r.name,
                                            Opportunity__c
                                  FROM     Applicant__c
                                  WHERE    Opportunity__c = :opp.id
                                  ];
            }
            return theApplicants;
        }
        set;
    }
    
    public Applicant__c thePrimaryApplicant
    {
        get
        {
            if (thePrimaryApplicant == null)
            {
                for (Applicant__c app:theApplicants)
                {
                    if (app.Primary_Account_Holder__c == true)
                    {
                        thePrimaryApplicant = app;
                    }
                }
            }
            
            return thePrimaryApplicant;
        }
        set;
    }
    
    public List<Applicant__c> theSecondaryApplicants
    {
        get
        {
            if (theSecondaryApplicants == null)
            {
                for (Applicant__c app:theApplicants)
                {
                    if (app.Primary_Account_Holder__c == false)
                    {
                        theSecondaryApplicants.Add(app);
                    }
                }
            }
            return theSecondaryApplicants;
        }
        set;
    }
      
    public BAA_SetUpFinanceController ()
    {}
    
    public PageReference Setup()
    { 
        
    
        // Create the Account with IBB record then the JARs for the applicants
        theIBBAccount.Primary_SFDC_Account__c = thePrimaryApplicant.Prospect_Customer__c;
        theIBBAccount.IBB_Product__c = Prod.Id;
        theIBBAccount.Opportunity__c = Opp.Id;
        upsert theIBBAccount;
        
        thisOpp.Account_with_IBB__c = theIBBAccount.Id;
        upsert thisOpp;
        
        List<Asset_Relationship__c > lstAss = new List<Asset_Relationship__c >();        
        List<Asset_Relationship__c > existing = [select id, Account_with_IBB__c , Prospect_Customer__c from Asset_Relationship__c  where Account_with_IBB__c =: theIBBAccount.id ];
        
        List<IBB_Product__c> products = new List<IBB_Product__c>();
        products = [SELECT    ID,
                              IBB_Product_set__r.Name
                    FROM    IBB_Product__c
                    WHERE    id = :prod.id];
        IBB_Product__c product;
        if (products.size() > 0)
        {
            product = new IBB_Product__c();
            product = products[0];
        }
        
        DEMatrixList  = [SELECT Id,
                                  EntityType__c,
                                  ProductCategory__c,
                                  DoAML__c,
                                  DoCredit__c,
                                  DoSanction__c,
                                  DoSetUp__c
                           FROM   BAADecisionEngineMatrix__c
                           WHERE  ProductCategory__c = :product.IBB_Product_set__r.Name];
               
        for(Applicant__c a : theApplicants)
        {
            if (!a.Primary_Account_Holder__c)
            {
                BusinessDecisionMatrix matrix = new BusinessDecisionMatrix (a, DEMatrixList);
                if (matrix.ApplicantFound && !matrix.doSetUp )
                {
                    continue;
                }
            }
        
            // CHeck the DEMatrix to see if they go or not 
            //if (IgnoreTheApplicant (a) && !a.Primary_Account_Holder__c)
            //{
            //    continue;
            //}
        
        
            Boolean found= false;
            for(Asset_Relationship__c ar : existing  )
            {
                if(ar.Prospect_Customer__c  == a.Prospect_Customer__c)
                {
                    found = true;
                    lstAss.add(ar);
                }
            }
        
        
        
            if(!found)
            {
                Asset_Relationship__c ass = new Asset_Relationship__c();
                ass.Account_with_IBB__c = theIBBAccount.id;
                ass.Prospect_Customer__c = a.Prospect_Customer__c;
                lstAss.add(ass);
            }
        }
        lstAss[0].Primary_Account_Holder__c = true;
        
        upsert lstAss;
        
        theSecondaryAccountHolders = [SELECT id,
                                            Primary_Account_Holder__c,
                                            Prospect_Customer__r.Name,
                                            Prospect_Customer__c,
                                            Relationship_To_Primary_Applicant1__c,
                                            Account_with_IBB__c 
                                      FROM    Asset_Relationship__c
                                      WHERE    Primary_Account_Holder__c = false
                                      AND   Account_with_IBB__c =: theIBBAccount.id ];
        
        
        
        return CorrectPage('BAA_SetUpFinance1');
    }
    
    //TODO tidy this up soon
    public PageReference Setup2()
    { 
        // Create the Account with IBB record then the JARs for the applicants
        SetUpCalled = false;
        
        List<Asset_Relationship__c > lstAss = new List<Asset_Relationship__c >();        
        List<Asset_Relationship__c > existing = [select id, Account_with_IBB__c , Prospect_Customer__c from Asset_Relationship__c  where Account_with_IBB__c =: theIBBAccount.id ];
        
        
        List<IBB_Product__c> products = new List<IBB_Product__c>();
        products = [SELECT    ID,
                              IBB_Product_set__r.Name
                    FROM    IBB_Product__c
                    WHERE    id = :prod.id];
        IBB_Product__c product;
        if (products.size() > 0)
        {
            product = new IBB_Product__c();
            product = products[0];
        }
        
        DEMatrixList  = [SELECT Id,
                                  EntityType__c,
                                  ProductCategory__c,
                                  DoAML__c,
                                  DoCredit__c,
                                  DoSanction__c,
                                  DoSetUp__c
                           FROM   BAADecisionEngineMatrix__c
                           WHERE  ProductCategory__c = :product.IBB_Product_set__r.Name];
        
               
        for(Applicant__c a : theApplicants)
        {
            if (!a.Primary_Account_Holder__c)
            {
                BusinessDecisionMatrix matrix = new BusinessDecisionMatrix (a, DEMatrixList);
                if (matrix.ApplicantFound && !matrix.doSetUp )
                {
                    continue;
                }
            }
        
            Boolean found= false;
            for(Asset_Relationship__c ar : existing  )
            {
                if(ar.Prospect_Customer__c  == a.Prospect_Customer__c)
                {
                    found = true;
                    lstAss.add(ar);
                }
            }
        
            if(!found)
            {
                Asset_Relationship__c ass = new Asset_Relationship__c();
                ass.Account_with_IBB__c = theIBBAccount.id;
                ass.Prospect_Customer__c = a.Prospect_Customer__c;
                lstAss.add(ass);
            }
        }
        lstAss[0].Primary_Account_Holder__c = true;
        
        upsert lstAss;
        
        theSecondaryAccountHolders = [SELECT id,
                                            Primary_Account_Holder__c,
                                            Prospect_Customer__r.Name,
                                            Prospect_Customer__c,
                                            Relationship_To_Primary_Applicant1__c
                                      FROM    Asset_Relationship__c
                                      WHERE    Primary_Account_Holder__c = false
                                      AND   Account_with_IBB__c =: theIBBAccount.id];
        
        SetupErrors = new List<string>();
        SetupErrors = IBBDependentObjectFactory.CreateANCAWIJARStubs (opp, 'OpenCustomerAccount',true);
        
        return null;
    }
    
    public PageReference ContinueToEBS ()
    {
        
        update thisOpp;
        upsert theSecondaryAccountHolders;
        
        
        return new PageReference ('/apex/BAA_SetUpFinance2?oppid=' + opp.id);
    }
    
    public PageReference SetUpOnEBS ()
    {
        system.debug ('We are in setup method');
        //integer i = 1 / 0;
        setUpOK = false;
        Actions.ActionCreateBusinessOCAAndJARs SetUpAction = new Actions.ActionCreateBusinessOCAAndJARs ();
        
        args = SetUpAction.RunAction(opp.id);
        
        system.debug('DEResponse : ' + args.ReturnValue);
        
        SetUpCalled  = true;
        
        if(!args.ReturnValue.equalsIgnoreCase('SUCCESS'))
        {
           ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Fatal,'Unfortunately your request to set up the account has been unsuccessful, please contact I.T. Helpdesk and quote the opportunity number as stated above'));
           return null;
        }
       
            
        SetupOK= true;
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info,'Your request to set up on EBS has been successful, please complete the event'));
        return null;
        
    }
    
    public PageReference Complete()
    {
        CompleteEvent();
        return GoToNextEvent();
    }
}