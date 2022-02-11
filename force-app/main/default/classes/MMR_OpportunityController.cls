public without sharing class  MMR_OpportunityController 
{
    public Integer NumApplying{get;set;}
        public String GetIDDDocument(String type)
    {
        for(IBB_Product_Set__c p : GetProductSets)
        {
            if(p.ProductSetType__c.equalsIgnoreCase(type))
            {
                return LiabilitiesHelperFunctions.GetResourceURL( p.IDD_Document__c);
            }            
        }
        return null;
    }
    
     Transient List<IBB_Product_Set__c> ProductSets;
    
    public List<IBB_Product_Set__c> GetProductSets
    {
        get{
            if(ProductSets== null)
            {
                ProductSets = [select id,name,IDD_Document__c,ProductSetType__c  from ibb_product_set__c  where ProductSetType__c != null ];
            }
            return ProductSets;
        }
    }
    
    
    public String HPPDocument{
        get{
            return GetIDDDocument('HPP');
        }
    }
    public String HPSDocument{
        get{
            return GetIDDDocument('HPS');
        }
    }
    public String PremierDocument{
        get{
            return GetIDDDocument('Premier');
        }
    }
    public String BTLDocument{
        get{
            return GetIDDDocument('BTL');
        }
    }
    
    


    public String EligibleOutput { get; set; }
    public String FirstName{get;set;}
    public String Surname{get;set;}
    public String Title{get;set;}
    public HPP_extended_opportunity__c exOpp{get;set;}
    public Applicant__c Applicant{get;set;}
    public Boolean WasAccountFound{get;set;}
    public List<Account> AccountsFound{get;set;}
    public Event Meeting{get;set;}
    public Boolean IsExternal {get;set;}
    
    public boolean AllowAIP{get;set;}

    public String msg{
    get{
        String html = '<ul>';
    
        for(ApexPages.Message m : ApexPages.getMessages())
        {
            html += '<li>' + m.getSummary() +  '</li>';
        }
        
        html += '</ul>';
        
        return html;
    }
    }

    public RecordType recType {
        get {
            if (recType == null){            
                recType = [select id from recordType where ispersontype=true and sobjectType='account' and DeveloperName = 'ProspectCustomer' limit 1];
            }
            return recType;
        }
        set;
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
    
    
    
    
     public RecordType oppRecType {
        get {
            if (oppRecType == null){            
                  oppRecType = [select id from recordType where  sobjectType='opportunity' and DeveloperName = 'HPP_CAA' limit 1];
            }
            return oppRecType ;
        }
        set;
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

    public boolean IsFirstPage {get;set;}

  
  public Postcode__c Bdm{get;set;} 
  public String BdmLink{get;set;}
  public String BdmName{get;set;}
  public String RoundRobinUserId {get;set;}
  
  
  
    public MMR_OpportunityController () {
        NumApplying = 1;
        IsFirstPage = true;
    
       Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        List<USer> usr = [select name, AIP_Allowed__c from user where id=:   UserInfo.getUserId() ];
         AllowAIP = usr[0]. AIP_Allowed__c == 'Yes' ;
        IsExternal = false;
       
   
        ShowAppointment = false;
        MeetingDate = new Dummy_Account__c();
        MeetingDate.Date_Of_Birth__c = Date.today();
        Meeting = new Event();
        AccountsFound = new List<Account>();
        system.debug('CTOR');
        Applicant = new Applicant__c();
        exOpp = new HPP_extended_opportunity__c ();
        if(existingSFDCCustomerId != null)
        {
            Applicant1  = DataHelper.GetAccount(existingSFDCCustomerId )[0];
            Applicant = new Applicant__c();
            FirstName = Applicant1.FirstName;
            Surname= Applicant1.LastName;
            Title=Applicant1.Salutation;            
        }   
         else
         {
              // Applicant1 = new Account();     
 // Applicant1 .StageName= null;
 //Applicant1.CloseDate = null;
         
     //    system.debug(Applicant1.RecordTypeId);
         
       //  Applicant1.name = 'TEMP'; 
     }                                    
                                            
//Opp.name = 'Eligible';
IsFirstPage = true;
//Opp.CloseDate = null;
  
       
                                           
        if(Opp==null)
        {
           // NoApps = 1;
        }
    
        

    }


   // public Integer NoApps{get;set;}

    public Account Applicant1{get;set;}
    public Account Applicant2{get;set;}
    public Account Applicant3{get;set;}
    public Account Applicant4{get;set;}
           
    public void ProcessCheckBox()
    {   
    Applicant1.marketing_preference__C = '';
   
    if(!HasMail)
        Applicant1.marketing_preference__C += 'mail ';
        
    if(!HasEmail)
        Applicant1.marketing_preference__C += 'email ';

    if(!HasPhone)
        Applicant1.marketing_preference__C += 'phone ';  

    if(!HasSMS)
        Applicant1.marketing_preference__C += 'sms '; 
    }   
   
    public void EmailError()
    {
          String msg = 'Please enter an email address.'  ;
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
          ApexPages.addMessage(myMsg);
    }
   
    public PageReference check()
    {
        Boolean isEligible = false;
    
        EligibleOutput = '';
    WasAccountFound = false;
    
    if(Applicant1.Are_you_happy_for_IBB_to_hold_your_data__c == 'No')
    {
        String msg = 'You have indicated that you are not happy for IBB to store your information.'  ;
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
          ApexPages.addMessage(myMsg);
          return null;
    }
    
    
    EligibleOutput  = '';
    Applicant1.FirstName = FirstName;
    Applicant1.LastName= Surname;
    Applicant1.Salutation = Title;
    
    
    
    
    
    ProcessCheckBox();
    
    if(!HasEmail  )
    {
        if(Applicant1.PersonEmail == null)
        {
            EmailError();
            return null;
        }
        
        if(Applicant1.PersonEmail == '')
        {
            EmailError();
            return null;
        }
    }
    
    
    if(!IsExternal)
    {
    List<Account> accs = [select id, lastname,firstname,EBS_ID__c,Date_of_Birth__c, name  from account where lastname=:Applicant1.lastname and firstname=:Applicant1.firstname and Date_of_Birth__c =: Applicant1.Date_of_Birth__c   ];
    
    AccountsFound = new List<Account>();
    
    for(Account a : accs)
    {
        if(a.id != Applicant1.id)
        {
            WasAccountFound = true;
             //String msg = 'Combination of first name, last name and data of birth already exist.  Id : ' + a.id  ;
             //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
             //ApexPages.addMessage(myMsg);
            AccountsFound.add(a); 
        }
    }
    
    
    if(AccountsFound.size() > 0 )
    {
        WasAccountFound = true;  
        return null;      
    }
    }
    
    
    
    boolean isNew = Applicant1.id == null;
    
    upsert Applicant1  ;
    Opp.AccountId = Applicant1.id; 
    
    if(isNew)
    {
        Applicant1 = DataHelper.GetAccount(Applicant1.id )[0];
    }
    
    
    
    
    //Opp.Number_of_People_Applying__c= NoApps;
    Opp.Stagename ='Awaiting Assessment';
    Opp.closedate = datetime.now().date();
    upsert Opp;
    
    if(Applicant.id == null)
    {
    Applicant.Opportunity__c= Opp.id;
    Applicant.Prospect_Customer__c = Applicant1.id;
    Applicant.Applicant_Number__c = 1;
    upsert Applicant;
    }
    
    if(exOpp.Opportunity__c== null)
    {
        exOpp.Opportunity__c = Opp.Id;
    }

    exOpp.EmailAddressHPPCAAComms__c = Applicant1.PersonEmail; // C00099
    upsert exOpp;
    
    List<String> reasons = LiabilitiesHelperFunctions.IsEligible(Applicant1,Opp,Applicant2,Applicant3,Applicant4);
    
    
    String reason='';
    
    for(String r : reasons)
    {
        reason += r + '\n';
    }
    
    IBB_Product_Set__c productSet = [select id from IBB_Product_Set__c where name=:Opp.Interested_in__c  ];
    
    String directorId;
    if(IsExternal)
    {
        directorId = EventHelper.GetExternalDirectorIdByProductSet(productSet .id);
    }
    else
    {
        directorId = EventHelper.GetDirectorIdByProductSet(productSet .id);
    }
   
       
    
    Opp.ProductEventDirector__c = directorId ;
    
    if(reasons[0] == 'YES')
    {       
    
    EligibleOutput  = 'Applicant is Eligible';
    Opp.StageName = 'HPP -Eligible Opportunity';
    
    update Opp;
    
    isEligible =true;

    
    //Set up appointment
    
    system.debug('IsExternal : ' + IsExternal );
    system.debug('PostCode : ' + Applicant1.BillingPostalCode);
    
    Postcode__c Bdm;
    
    if(!IsExternal )
        Bdm = FunctionHelper.GetPostcodeSeller(Applicant1.BillingPostalCode);   
    
    system.debug('Bdm after postcode lookup :' + Bdm);
    
    String userId;
    
      system.debug('bdm ' + bdm);
    
    
    if(Bdm != null)
    {
        if(Bdm.user__c != null)
        {
            userId = Bdm.user__c;
        }
        else
        {
            if(RoundRobinUserId == null)
            {
                RoundRobinUserId = FunctionHelper.GetRoundRobinUserId();                
            }
            userId = RoundRobinUserId;
        }
    }
    else
    {
        if(RoundRobinUserId == null)
        {
            RoundRobinUserId = FunctionHelper.GetRoundRobinUserId();
        }
        userId = RoundRobinUserId;
    }
    
       if(Opp.Seller__c == null)
            Opp.Seller__c = userId;
    
        system.debug('BDM id :' + userId );
        
        List<User> usr = [select name from User where id=: userId  limit 1];
        if(usr.size() > 0)
        {
            BdmName= usr[0].name;
        }
        
        Integer month= Date.today().month() - 1;
        Integer year= Date.today().year();        
        
        BdmLink = '/00U/c?cType=1&cal_lkid='+ userid +'&md0=' + year +'&md1=' + month;
        
       
        Meeting.Subject = 'New ' + Opp.Interested_in__c;
       update opp;
   
    
    
    }
    else
    {
    Opp.Reason_for_ineligible_referral__c = reason;
    Opp.StageName = 'Not Eligible - HPP';

    update Opp;
    
    EligibleOutput  = '<ul>';
    
        for(Integer i = 0; i< reasons.size();i++)
        {
            EligibleOutput += '<li>' + reasons[i] + '</li>';
        }
        EligibleOutput  += '</ul>';
    }
    
    
    if(isEligible && IsExternal )
    {
        return ExternalAIP();
    }
    
    return null;
    }
    
    public string EventId{get;set;}
    
   public Boolean IsChecked(String value)
    {
        if(value == null)
            return false;
            
        if(value.toLowerCase() == 'on')
            return true;
            
        return false;
    
    }
    
    public PageReference Setup()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        IsExternal = false;    
        if(Applicant1 == null)
        {
         Applicant1 = new Account(RecordTypeId = recType.Id, FirstName='', LastName='');     
        }
    
        Opp = new Opportunity(RecordType = oppRecType); 
        Opp.RecordTypeId = oppRecType.id;
        Opp.Name= 'HPP CAA - ' + Applicant1.name ;   
        Opp.Stagename ='Awaiting Assessment';
        Opp.closedate = datetime.now().date();
        Opp.Number_of_People_Applying__c = 1;
        
        opp.CustomerEmailRequired__c = true;    // C00099
        
        Applicant__c app = new Applicant__c ();
        app.Prospect_Customer__c= Applicant1 .id;
        app.Applicant_Number__c = 1;
        app.Primary_Account_Holder__c = true;            
    return null;
    }
    
    private Campaign externalCampaign {
        get {
            if (externalCampaign == null) {
                if (String.isNotBlank(Opp.Name)) {
                    List<Campaign> campaigns = new List<Campaign>();
                    
                    if (Opp.Name.contains('Home Purchase Plan')) {
                        campaigns = [
                            SELECT Name
                            FROM Campaign
                            WHERE Name = 'HPP - Website enquiry (HPB1WEB)'
                            LIMIT 1
                        ];
                    }
                    else if (Opp.Name.contains('Buy to Let')) {
                        campaigns = [
                            SELECT Name
                            FROM Campaign
                            WHERE Name = 'HPP - Website enquiry (HPB1WEB)'
                            LIMIT 1
                        ];
                    }
                    
                    if (!campaigns.isEmpty()) {
                        externalCampaign = campaigns.get(0);
                    }
                }
            }
            else {
                externalCampaign = null;
            }
            
            return externalCampaign;
        }
        set;
    }
    
     public PageReference SetupExternal()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        IsExternal = true;
        if(Applicant1 == null)
        {
            Applicant1 = new Account(RecordTypeId = recTypeExternal.Id, FirstName='', LastName='');     
        }
    
        Opp = new Opportunity(RecordType = oppRecType); 
        Opp.RecordTypeId = oppRecType.id;
        Opp.Name= 'HPP CAA - ' + Applicant1.name ;   
        Opp.Stagename ='Awaiting Assessment';
        Opp.closedate = datetime.now().date();
        Opp.Number_of_People_Applying__c = 1;
        
        if (externalCampaign != null) {
            Opp.CampaignId =  externalCampaign.Id;
        }
        
        Applicant__c app = new Applicant__c ();
        app.Prospect_Customer__c= Applicant1 .id;
        app.Applicant_Number__c = 1;
        app.Primary_Account_Holder__c = true;
                    
        return null;
    }
    
    public PageReference changeNumApps()
    {      
        IBB_Product_Set__c prodSet = [select id,Max_No_of_Applicants__c  from IBB_Product_Set__c where name = :opp.interested_in__c limit 1 ];
        
        if(Opp.Number_of_People_Applying__c > prodSet.Max_No_of_Applicants__c  )
        {
         
            String msg = 'Only ' + prodSet.Max_No_of_Applicants__c +' applicants allowed for ' + opp.interested_in__c  ;
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
             ApexPages.addMessage(myMsg);  
            return null;
        }
        
    
        IsFirstPage =false;
        
        if(Opp.Number_of_People_Applying__c> 1)
           Applicant2 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
           
             if(Opp.Number_of_People_Applying__c> 2)
           Applicant3 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
           
             if(Opp.Number_of_People_Applying__c> 3)
           Applicant4 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
        
        
       return null;        
    }
    
     public String existingSFDCCustomerId {
        get {
            if (existingSFDCCustomerId == null && !IsExternal){
                existingSFDCCustomerId = ApexPages.currentPage().getParameters().get('ExistingAccountId');
            }
            return existingSFDCCustomerId;
        }
        set;
    }    
    
    public Opportunity Opp{get;set;}
     
     
    public void CompleteEvent()
    {
        IBBEvents ibbEvent = new IBBEvents(Opp.ProductEventDirector__c );
        ibbEvent.CreateFirstEvent(opp.id);
        Completed = true;
    } 
    public boolean Completed{get;set;}   
    public PageReference CompleteAIP()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        CompleteEvent();        
        return null;
    }
    
    public PageReference ExternalAIP()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        CompleteEvent();
        EventLog__c ev = [select id from EventLog__c where opportunity__c = :opp.id limit 1];
        EventId = ev.id;   
      
            return new PageReference('/apex/External_Eligible');   
    }
    
    public PageReference AIP()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        CompleteEvent();
        EventLog__c ev = [select id from EventLog__c where opportunity__c = :opp.id limit 1];
        EventId = ev.id;   
      
            return new PageReference('/apex/HPPEventRedirect?oppid='  + opp.id);  
 
    }
    
    public Boolean ContainsOption(String option)
    {
        return Applicant1 .marketing_preference__C.containsIgnoreCase(option);
    }
    
    public void SetUpBoxes()
    {  

    
    
        if( Applicant1 .marketing_preference__C == null)
            return;
        HasEmail = !ContainsOption('email');
        HasMail= !ContainsOption('mail');
        HasPhone= !ContainsOption('phone');
        HasSMS= !ContainsOption('sms');
        
    }
    
    public Boolean HasEmail{get;set;}
    public Boolean HasMail{get;set;}
    public Boolean HasPhone{get;set;}
    public Boolean HasSMS{get;set;}
    public Boolean HasNone{get;set;}
    
    
    public Dummy_Account__c MeetingDate{get;set;}
    
    
    
    public String OptionTime{get;set;}
    public String OptionEndTime{get;set;}
    
     public List<SelectOption> OptionTimes {
        get {
            if (OptionTimes == null) {
                DateTime DT_TM1 = DateTime.newInstance(Date.Today(), Time.newInstance(7,0,0,0));
                DateTime DT_TM2 = DT_TM1;
                DateTime DT_TM3 = DateTime.newInstance(Date.Today(), Time.newInstance(19,0,0,0));
                 
                OptionTimes = new List<SelectOption>();
                while (DT_TM1.isSameDay(DT_TM2) && (DT_TM1  <= DT_TM3) ) {
                    String strTM = DT_TM1.Format('h:mm a');
                    OptionTimes.add(new SelectOption(strTM,strTM));
                    DT_TM1 = DT_TM1.addMinutes(30);
                }
            }
            return OptionTimes;
        }
        private set;
    }
    
    public PageReference DoNothing ()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        system.debug('action date: ' +OptionTime );
        return null;
    }
    
    public boolean ShowAppointment {get;set;}
    
    public PageReference BookAppointment()
    {
        LiabilitiesHelperFunctions.SetPageHeader();    
        Meeting.ActivityDateTime = DateTime.newInstance(MeetingDate.Date_Of_Birth__c,ParseTime(OptionTime));

        return null;
    }
    
    private Time ParseTime(String strTime) {
        Integer TM_H;
        Integer TM_M;
        String TM_AP;
        String[] tmp;
 
        tmp = strTime.split(':', 2);
        TM_H = Integer.valueOf(tmp[0]);
         
        tmp = tmp[1].split(' ', 2);
        TM_M = Integer.valueOf(tmp[0]);
        TM_AP = tmp[1];
        return Time.newInstance(TM_H + (TM_AP.startsWith('P') ? 12 : 0), TM_M, 0, 0);
    }
    
    public List<SelectOption> OptionEndTimes {
        get {
                if(OptionTime == null)
                {
                  OptionTime =  DateTime.newInstance(Date.Today(), Time.newInstance(7,0,0,0)).Format('h:mm a');
                }         
           
                DateTime DT_TM1 =    DateTime.newInstance(Date.Today(),ParseTime(OptionTime)).addMinutes(30);
                DateTime DT_TM2 = DT_TM1;
                DateTime DT_TM3 = DateTime.newInstance(Date.Today(), Time.newInstance(19,0,0,0));
                 
                OptionTimes = new List<SelectOption>();
                while (DT_TM1.isSameDay(DT_TM2) && (DT_TM1  <= DT_TM3) ) {
                    String strTM = DT_TM1.Format('h:mm a');
                    OptionTimes.add(new SelectOption(strTM,strTM));
                    DT_TM1 = DT_TM1.addMinutes(30);
                }
            
            
            return OptionTimes;
            }
        
        private set;
    }
    
}