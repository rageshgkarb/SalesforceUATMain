/* -------------------------------------------------------------------------------------------------------------- */
/* C0635    Removed common functions to BaseEventController class                                                */
/* -------------------------------------------------------------------------------------------------------------- */
public class HPPEventAIPController extends HPPBaseEventController 
{
    private aLog.Logger Log = new aLog.Logger('HPPEventAIPController');
    public Integer whichLine{get;set;}
    public Account TempAccount{get;set;}
    public String TempFirstName{get;set;} 
    public String TempLastName{get;set;} 
    public String TempTitle{get;set;}     
    public Dummy_Account__c ap{get;set;}    
    public Actions.IAction RCEAction{get;set;}    
    public Boolean HasEmail{get;set;}
    public Boolean HasMail{get;set;}
    public Boolean HasPhone{get;set;}
    public Boolean HasSMS{get;set;}
    public Boolean HasNone{get;set;}    
    public Boolean IsExternal {get;set;}
    
    public List<Account> ExistingAccounts {get;set;}

    public PageReference AddApplicant()
    {        
        LiabilitiesHelperFunctions.SetPageHeader();    
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
             for(Account a : Accounts)
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
       
        insert addAcc;
        
        AddExistingAccount(addAcc.id);
        
        return null;
    }
    
    public Boolean ShowExisting
    {
        get{
            if(ExistingAccounts == null)
                return false;
            return ExistingAccounts.Size() > 0;
        }
    }
    
    public String KeyFactsLink
    {
        get
        {            
            return LiabilitiesHelperFunctions.GetResourceURL(prod.Risk_Features_Document__c);           
        }
    }
    
    public String IDDLink
    {
        get
        {           
            return LiabilitiesHelperFunctions.GetResourceURL(prodSet.IDD_Document__c);            
        }
    }
    
    public List<SelectOption> getTitles() {
            List<SelectOption> options = new List<SelectOption>();
             options.add(new SelectOption('Mr','Mr'));
            options.add(new SelectOption('Mrs','Mrs'));
            options.add(new SelectOption('Miss','Miss'));
            options.add(new SelectOption('Ms','Ms'));
            options.add(new SelectOption('Dr','Dr'));            
            options.add(new SelectOption('Other','Other'));
             options.add(new SelectOption('Prof','Prof'));
              options.add(new SelectOption('Sheikh','Sheikh'));
            return options;
    }
             
    public boolean RCEFailed{get;set;}         
             
    public PageReference CallRCE()
    {
        RCEFailed  = false;
        Opp.Attachment_Offer_Letter__c = null;
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id);        
        system.debug('result: ' + args.ReturnValue);        
        if(args.ReturnValue != 'SUCCESS')
        {
            RCEFailed = true;        
        }    
        
    
        
        UpdateDearField();        
        return null;
    }   
    
    private void UpdateDearField()
    {
        String dear = 'Dear ';
        
        boolean first = true;
        
        for(Account a : accounts)
        {
            if(first)
            {
                dear += a.Salutation+ ' ' + a.lastname;
                first = false;
                continue;
            }
             //dear += ' and ' +  a.Salutation+ ' ' + a.lastname;
             //C0760 Offer letter Enhancement start
            dear += ' , ' +  a.Salutation+ ' ' + a.lastname;
           }
           if(!accounts.isEmpty() && accounts.size() ==4||accounts.size() ==3||accounts.size() ==2){
              dear = dear.reverse().replaceFirst(',', 'dna').reverse();
            }
        dear += ',';
         //C0760 Offer letter Enhancement end
        
        Opp.Dear_customer__c = dear; 
        update opp;        
    }
               
    
    public void AddExistingAccount(String accountId)
    {
           //check account is not already added
           for(Account a : Accounts)
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
           Accounts.add(addAcc); 
           
           //create applicant
           Applicant__c addApp = new Applicant__c();
           addApp.Applicant_Number__c = Applicants.size() + 1;
           addApp.Opportunity__c = Opp.id;
           addApp.Prospect_Customer__c = addAcc.id;
           
           insert addApp;
           addApp.Prospect_Customer__r = addAcc;
           Applicants.add(addApp);
           
           //tempAccount = new Account();
           ap.AccountLookup__c=null;
           Opp.Number_of_People_Applying__c = Accounts.size();
           update opp;
    }

    public PageReference LookupApplicant() 
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        ExistingAccounts =null;
        
        if(Opp.Number_of_People_Applying__c >= prodSet.Max_No_of_Applicants__c)
        {
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Maximum number of applicants is ' + prodSet.Max_No_of_Applicants__c);
            ApexPages.addMessage(myMsg); 
            return null;
        }
        
        if(ap!= null)
        {
            AddExistingAccount(ap.AccountLookup__c);            
        }
        return null;
    }      
    
    
    public boolean QuoteReceived
    {
        get{
            List<IBBQuotation__c> quotes = [select id, RCERetrieved__c from IBBQuotation__c where QuoteToBeAIP__c = true and Opportunity__c = : Opp.id];
            if(quotes.size() > 0)
            {
                return quotes[0].RCERetrieved__c;            
            }
            return false;
        }
    }

    public boolean DocLinkCreated
    {
    get{
        List<IBBQuotation__c> quotes = [select id, Attachment_FIS__c from IBBQuotation__c where id =: Opp.IbbQuotation__c ];
        if(quotes.size() == 0)
            return false;
            
            return quotes[0].Attachment_FIS__c != null;               
        }
    }

    public string DocLink
    {
        get{
            string link = '';//Quotation document is still being generated.';            
    
            List<IBBQuotation__c> quotes = [select id, Attachment_FIS__c from IBBQuotation__c where id =: Opp.IBBQuotation__c ];
            if(quotes.size() == 0)
                return link;
            
            if(quotes[0].Attachment_FIS__c == null)
                return link;
    
           return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' +quotes[0].Attachment_FIS__c + '"><b>FIS/FQS Document</b></a>';
       }      
    }
    
    public Boolean ContainsOption(String option)
    {
        return Acc.marketing_preference__C.containsIgnoreCase(option);
    }
    
    public void SetUpBoxes()
    {  
        HasEmail = false;
        HasMail = false;
        HasPhone = false;
        HasSMS = false;
    
        if( Acc.marketing_preference__C == null)
            return;
        HasEmail = !ContainsOption('email');
        HasMail= !ContainsOption('mail');
        HasPhone= !ContainsOption('phone');
        HasSMS= !ContainsOption('sms');
    }
    
    public boolean DocCreated
    {
        get
        {
            List<IBBQuotation__c> quotes = [select id from IBBQuotation__c where QuoteToBeAIP__c = true and Opportunity__c = : Opp.id order by createddate desc limit 1];
            if(quotes.size() == 0)
                return false;
    
            return quotes[0].Conga_FIS__c != null;
        }    
    }
    
    public String App1Css
    {
        get{
            if(CurApp == 1)
            {
                return 'active';
            }
            return '';    
        }
    }
    
    public String App2Css
    {
        get{
            if(CurApp == 2)
            {
                return 'active';
            }
            return '';    
        }
    }    
    
    public String App3Css
    {
        get{
            if(CurApp == 3)
            {
                return 'active';
            }
            return '';    
        }
    }    
    
    public String App4Css
    {
        get{
            if(CurApp == 4)
            {
                return 'active';
            }
            return '';    
        }
    }  
        
    public Account CreateAcc(Integer no)
    {
        return null;
    
        system.debug('****************** creating account ' + no);
        Account acc = new Account();
        
        if(IsExternal)
        {
            acc.recordtype = recTypeExternal ;
        }
        else
        {
            acc.recordtype =   accRecType;
        }      
        
        acc.LastName = 'Account';
        acc.FirstName = 'Temp';
        
        system.debug(acc.recordtype);
        
        insert acc;
        
        Applicant__c app = new Applicant__c ();
        app.Prospect_Customer__c= acc.id;
        app.Opportunity__c= Opp.id;
        app.Applicant_Number__c = no;
        app.Primary_Account_Holder__c = false;
        insert app;        
        
        return DataHelper.GetAccount(acc.id)[0];
    }
    
    public PageReference setUp()
    {
         try
        {
            Log.Info('Calling stubs');
            IBBDependentObjectFactory.CreateRCEStubs (opp);
        }
        catch(Exception ex)
        {
            Log.Fatal(ex.getMessage());
        }
    
        LiabilitiesHelperFunctions.SetPageHeader();    
        if(Accounts.Size() < Opp.Number_of_People_Applying__c)
        {
            Accounts.add( CreateAcc(integer.valueof(opp.Number_of_People_Applying__c)));
        }
        
        aLog.Save();
        
        IsExternal =false;
        return  null;
    }
    
    public PageReference setUpExternal()
    {
         try
        {
            Log.Info('Calling stubs');
            IBBDependentObjectFactory.CreateRCEStubs (opp);
        }
        catch(Exception ex)
        {
            Log.Fatal(ex.getMessage());
        }
    
        LiabilitiesHelperFunctions.SetPageHeader();    
        if(Accounts.Size() < Opp.Number_of_People_Applying__c)
        {
            Accounts.add( CreateAcc(integer.valueof(opp.Number_of_People_Applying__c)));
        }
        
        aLog.Save();
        IsExternal =true;
        return  null;
    }
    
    public PageReference Save()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        update Acc;
        return null;
    }
    
    public PageReference SaveValidate()
    {    
        LiabilitiesHelperFunctions.SetPageHeader();    
        update Acc;
        return null;
    }
    
    public PageReference AIPDeclaration()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        PageReference pageRef ;
        if(IsExternal)
        {
            pageRef = new PageReference('/apex/External_HPPEventAIPDec');
        }
        else
        {
            pageRef = new PageReference('/apex/HPPEventAIPDec');
        }
        
        return pageRef;
    }
    
    public PageReference AIPConfirmation()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        PageReference pageRef ;
        if(IsExternal)
        {
            pageRef = new PageReference('/apex/External_HPPEventAIPCon');
        }
        else
        {
            pageRef = new PageReference('/apex/HPPEventAIPCon');
        }

        return pageRef;
    }    
    
    private boolean ProcessProduct()
    {
        //check products
        IBB_Product__c pro;
        for(IBB_Product__c pp : Products)
        {
            if(pp.id == Opp.IBB_Product__c)
            {
                pro = pp;
                break;
            }
        }
        if(pro == null)
            return false;
        
        Decimal ftv = 100 / Opp.Purchase_price_market_value__c * opp.Finance_Required__c;
        // M00021
        ftv = ftv.setScale(2, RoundingMode.HALF_UP);
        
        
        if(ftv > pro.Max_finance_to_value_FTV__c)
        /* M00021 end */
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Max FTV is ' + pro.Max_finance_to_value_FTV__c + '%, this application has been calculated at ' + ftv.setScale(1) + '%');
            ApexPages.addMessage(myMsg);
            return false;
        }
    
        update Opp;
        update exOpp;    
        //RCEAction.RunAction(opp.id);
        
        Prod = DataHelper.GetProduct(Opp.IBB_Product__c)[0];
        return true;
    }
    
    public PageReference ExternalProductEntered()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
         if(!ProcessProduct())
            return null;
        
        PageReference p =    Setup();    
        PageReference pageRef ;
        pageRef = new PageReference('/apex/External_HPPEventAIPApplicants');
        IsExternal = true;
        return pageRef;
    }
    
    public PageReference ProductEntered()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        if(!ProcessProduct())
            return null;
        
        PageReference p =    Setup();    
        PageReference pageRef ;
        pageRef = new PageReference('/apex/HPPEventAIPApplicants');
        IsExternal = false;
        return pageRef;
    }
    
    public PageReference CreateDoc()
    {
        LiabilitiesHelperFunctions.SetPageHeader();
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
    
    public RecordType accRecType
    {
      get 
      {
          if (oppRecType == null)
          {  
              system.debug('************ getting rec type');          
              oppRecType = [select id from recordType where  sobjectType='account' and DeveloperName = 'ProspectCustomer' limit 1];
          }
          system.debug('************ fetched rec type');
          return oppRecType ;
      }
    }
    
    public RecordType recTypeExternal {
        get {
            if (recTypeExternal == null){            
                recTypeExternal = [select id from recordType where ispersontype=true and sobjectType='account' and DeveloperName = 'HPP_CAA_External' limit 1];
            }
            return recTypeExternal ;
        }
        set;
    }
    
    public void ProcessCheckBox()
    {   
        Acc.marketing_preference__C = '';
       
        if(!HasMail)
            Acc.marketing_preference__C += 'mail ';
            
        if(!HasEmail)
            Acc.marketing_preference__C += 'email ';
    
        if(!HasPhone)
            Acc.marketing_preference__C += 'phone ';  
    
        if(!HasSMS)
            Acc.marketing_preference__C += 'sms ';  
    }

    public HPPEventAIPController() 
    {         
         //Biztalk
         RCEAction= new Actions.ActionRCE2 ();         
         
         //Fake
         //RCEAction = new ActionsFake.RCE();
         
         ap = new Dummy_Account__c();
         tempAccount = new Account();
 
        SetUpBoxes(); 
    }
    
    public Boolean IsPremier
    {
        get{return Opp.Interested_in__c.equalsIgnoreCase('Home Purchase Plan Premier');}
    }
    
    public RecordType oppRecType {
        get {
            if (oppRecType == null){            
                  oppRecType = [select id from recordType where  sobjectType='opportunity' and DeveloperName = 'HPP_CAA' limit 1];
            }
            return oppRecType ;
        }
        set;
    }
    
    public PageReference Applicant1()
    {    
      return SetPage(1);
    }
    public PageReference Applicant2()
    {
      return SetPage(2);
    }
    
    public void SaveData()
    {
        update acc;
        update opp;
        update exopp;
    }
    
    public PageReference LastApp()
    {
        SaveData();
        return SetPage(integer.valueof(Opp.Number_of_People_Applying__c));
    }
    
    public PageReference SetPage(Integer appNo)
    {  
        LiabilitiesHelperFunctions.SetPageHeader();    
        SaveData();      
        CurApp = AppNo;
        SetUpBoxes();
        
        if(IsExternal)
        {
            return new PageReference('/apex/External_HPPEventAIPApplicant');
        }
        else
        {
            return new PageReference('/apex/HPPEventAIPApplicant');
        }
    }
    
    public PageReference NextAPP()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        SaveData();
        if(curapp < Opp.Number_of_People_Applying__c)
        {
            return SetPage(curapp +1);
        }
        else
        {
            return AIPConfirmation();
        }
    }
    
    public PageReference PreviousAPP()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        SaveData();
        if(curapp > 1)
        {
            return SetPage(curapp -1);
        }
        else
        {
            return ApplicantsPage();
        }
    }
    
    public PageReference Applicant3()
    {
       return SetPage(3);
    }
    public PageReference Applicant4()
    {
     return   SetPage(4);
    }
    public PageReference ProductDetails()
    {    
        LiabilitiesHelperFunctions.SetPageHeader();    
        Opp.Number_of_People_Applying__c = Accounts.size();
        update opp;  
    
        ProcessCheckBox();
        CurApp = 1;
        SetUpBoxes();

        if(IsExternal)
        {
            return new PageReference('/apex/External_HPPEventAIP');
        }
        else
        {
            return new PageReference('/apex/HPPEventAIP');
        }
    }
    
    public List<IBB_Product__c> Products{
    get
    {
        if(Products == null)
        {
            Products = [select id,Max_finance_to_value_FTV__c , name from IBB_Product__c 
            where IBB_Product_Set__c = :prodSet.id and ShowOnAIP__c=true 
                and CongaWelcomeLetter__c != null 
                and Conga_Offer_Letter__c != null
                and Conga_FIS__c != null
            ];  
        }
        return products;
    }
    set{}
    }
    
    
    public PageReference delItem()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        Decimal appNo;
        for(Integer i = 0 ; i < Applicants.size();i++)
        {
            if(Applicants[i].Applicant_Number__c == whichLine)
            {
                //remove from accounts
                for(Integer x=0;x<Accounts.size();x++)
                {
                    if(Accounts[x].id == Applicants[i].Prospect_Customer__c)
                    {           
                        appNo = Applicants[i].Applicant_Number__c;
                        Accounts.remove(x);
                        break;
                    }
                }   
                
                Applicant__c remove = Applicants.remove(i);
                delete remove;
                break;            
            }
        
        }   
        Opp.Number_of_People_Applying__c = Accounts.size();
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
    
    public List<SelectOption> getProductItems(){   
     
        List<SelectOption> options = new List<SelectOption>();
               
        for(IBB_Product__c prods : Products)
        {
               options.add(new SelectOption(prods.id,prods.name));    
        }

        return options;
    }
    
    public PageReference ApplicantsPage()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        SaveData();
        PageReference pageRef ;
        if(IsExternal)
        {
            return new PageReference('/apex/External_HPPEventAIPApplicants?id=' + Event.id);
        }
        else
        {
            return new PageReference('/apex/HPPEventAIPApplicants?id=' + Event.id);
        }   
    }    
    
    
    public PageReference CreateAIPLetter()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        try
        {   
            CongaSettings sett = new CongaSettings(prodset.Conga_AIP_Letter__c);                         
            sett.CallConga(opp.id); 
            
            if(sett.AttachmentId != null)
            {
                Opp.Attachment_AIP_Letter__c = sett.AttachmentId;
                update opp;
            }
            
               } catch (Exception e) {
               system.debug('Error :' + e);
           
        }
        return null;
    }
   
    
    public PageReference Complete()
    {       
        LiabilitiesHelperFunctions.SetPageHeader();    
        ProcessCheckBox();       
        IsCompleted =true;        
        IBBEvents director = new IBBEvents(opp.ProductEventDirector__c);
        director.CompleteEvent(EventLog, opp);
        return null;
    }  
    
    public PageReference CompleteAIP()
    { 
        return new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);
    }
    
    public boolean AIPLinkCreated
    {
        get{            
            return Opp.Attachment_AIP_Letter__c != null;
        }
    }
    
    public string AIPLetterLink
    {    
        get{
            if(AIPLinkCreated)
                return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + Opp.Attachment_AIP_Letter__c + '"><b>AIP letter</b></a>';   
            return '';// 'AIP letter is still being generated.';  
            }
    }   
}