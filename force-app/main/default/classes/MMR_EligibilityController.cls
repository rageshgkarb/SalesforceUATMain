/* ------------------------------------------------------------------------------------ */
/* C0586                                                                                */
/* ------------------------------------------------------------------------------------ */

public without sharing class  MMR_EligibilityController 
{
    public Boolean displayIncomeAssisted {get ; set ;}  // C0586
    public String IsPrefSelected        {get ; set ;}  // C0737
    public Integer NumApplying          {get;set;}
    Transient List<IBB_Product_Set__c> ProductSets;
     public boolean isChanged{get;set;}//C0785: HPP - Automatic Valuation Model   
    public String GetIDDDocument(String type,Boolean faceToFace) {
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
    
    public String HPPDocumentNon{
        get{
            return GetIDDDocument('HPP',false);
        }
    }
    public String HPSDocumentNon{
        get{
            return GetIDDDocument('HPS',false);
        }
    }
    public String PremierDocumentNon{
        get{
            return GetIDDDocument('Premier',false);
        }
    }
    public String BTLDocumentNon{
        get{
            return GetIDDDocument('BTL',false);
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
    public Boolean IsBTL_LTD { get; set;}
    public Boolean IsBTL { get; set;}
    // Public Date DateConvertedtoCustomer{ get; set;} //C0782 REAC Changes 
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
    
    // C0644
    public RecordType recTypeBusiness {
        get {
            if (recTypeBusiness == null){            
                recTypeBusiness = [select id from recordType where ispersontype=false and sobjectType='account' and DeveloperName = 'Business_Account' limit 1];
            }
            return recTypeBusiness ;
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
    
  public boolean IsFirstPage {get;set;}

  
  public Postcode__c Bdm{get;set;} 
  public String BdmLink{get;set;}
  public String BdmName{get;set;}
  public String RoundRobinUserId {get;set;}
  
  
  
    public MMR_EligibilityController () {
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
        system.debug('existingSFDCCustomerId-------'+existingSFDCCustomerId);
        if(existingSFDCCustomerId != null)
        {
            Applicant1  = DataHelper.GetAccount(existingSFDCCustomerId)[0];
            system.debug('Applicant1 found during constructor:'+Applicant1);
            Applicant = new Applicant__c();
            FirstName = Applicant1.FirstName;
            Surname= Applicant1.LastName;
            Title=Applicant1.Salutation;
           // DateConvertedtoCustomer = Applicant1.Date_Converted_to_Customer__c;// REAC Changes 
            Apexpages.currentPage().getParameters().put('ExistingAccountId', existingSFDCCustomerId);
           
        }   

        IsFirstPage = true;
   }


   // public Integer NoApps{get;set;}

    public Account Applicant1{get;set;}
    public Account Applicant2{get;set;}
    public Account Applicant3{get;set;}
    public Account Applicant4{get;set;}
    public Account Applicant5{get;set;} // C0644 Fifth applicant is 4th Director
           
    public void ProcessCheckBox()
    {   
        HasEmail = !HasNone && HasEmail;
        HasNewsletter = !HasNone && HasNewsletter;
        HasMail = !HasNone && HasMail;
        HasSMS = !HasNone && HasSMS;
        HasPhone = !HasNone && HasPhone;

        Applicant1.No_Contact__c = HasNone;
        Applicant1.Contact_by_Email_New__c = HasEmail;
        Applicant1.Contact_by_Newsletter_New__c = HasNewsletter;
        Applicant1.Contact_by_Post_New__c = HasMail;
        Applicant1.Contact_by_SMS_New__c = HasSMS;
        Applicant1.Contact_by_Telephone_New__c = HasPhone;

    }   
   
    public void EmailError()
    {
          String msg = 'Please enter an email address.'  ;
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
          ApexPages.addMessage(myMsg);
    }
  //C0785: HPP - Automatic Valuation Model Start
     public void checkEligibilityForAVM(){       
        isChanged = false;
        HPPAVM__c av= HPPAVM__c.getValues('HPPAVM');
        Decimal pmar= av.pMaxAVMPropertyValue__c;
        Decimal pftv= av.pMaxAVMFTV__c;
        Decimal ftv = 100 / Opp.Purchase_price_market_value__c * opp.Finance_Required__c;
        ftv = ftv.setScale(2, RoundingMode.HALF_UP);   
        if(opp.Purchase_price_market_value__c>pmar ||ftv>pftv){
        isChanged=true;
        }
    }
   //C0785: HPP - Automatic Valuation Model End
    public PageReference check()
    {
           
        // C0737 Start 
        if(!HasNewsletter && !HasEmail && !HasMail && !HasSMS && !HasPhone && !HasNone){
            String msg = 'Please select a marketing preference, we cannot proceed with your application without capturing this information.';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
            ApexPages.addMessage(myMsg);
            IsPrefSelected = 'No';
            return null;
        }else{
            IsPrefSelected = 'Yes';
        }
        // C0737 End 
        Boolean isEligible = false;
    
        EligibleOutput = '';
        WasAccountFound = false;
        System.debug('Applicant1.Are_you_happy_for_IBB_to_hold_your_data__c==>'+Applicant1.Are_you_happy_for_IBB_to_hold_your_data__c);
        if(Applicant1.Are_you_happy_for_IBB_to_hold_your_data__c != 'Yes')
        {
            String msg = 'You have indicated that you are not happy for IBB to store your information.';
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
              ApexPages.addMessage(myMsg);
              return null;
        }

        if(Opp.Intermediary_Contact__c!=null && Opp.Were_you_aware_of_the_procuration_fee__c==null) // C0694
        {
            String msg = 'Please answer the question \"Were you aware that the intermediary will receive a procuration fee if this deal completes?\" under \"Marketing Information\" before continuing.';
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
              ApexPages.addMessage(myMsg);
              return null;
        }

        if(IsBTL_LTD && !('Holding and maintenance'.equalsIgnoreCase(Applicant1.Nature_of_Business_NPAA__c)))
        {
            String msg = 'The nature of this business is not compatible with this product.';
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
              ApexPages.addMessage(myMsg);
              return null;
        }
    
        System.debug('IS BTL LTD = '+IsBTL_LTD);
        System.debug('Applicant1 RecType='+Applicant1.RecordTypeID);
        System.debug('Applicant1 FirstNAme='+Applicant1.FirstName);
        System.debug('Applicant1 LastName='+Applicant1.LastName);
        System.debug('Applicant1 Title='+Applicant1.Salutation);
        
        
        EligibleOutput  = '';
        if(!IsBTL_LTD)
        {
            Applicant1.FirstName = FirstName;
            Applicant1.LastName= Surname;
            Applicant1.Salutation = Title;
        }
    
    
    
    
    
    ProcessCheckBox();
    
    if(!HasEmail  )
    {
        if(Applicant1.PersonEmail == null && !IsBTL_LTD)
        {
            EmailError();
            return null;
        }
        
        if(Applicant1.PersonEmail == '' && !IsBTL_LTD)
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
                String msg = 'Combination of first name, last name and data of birth already exist.  Id : ' + a.id ;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                ApexPages.addMessage(myMsg);
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
    
    System.debug('Applicant1 - '+Applicant1);

    upsert Applicant1;
    Opp.AccountId = Applicant1.id; 
    
    if(isNew)
    {
        Applicant1 = DataHelper.GetAccount(Applicant1.id )[0];
    }
    
    
    
    
    //Opp.Number_of_People_Applying__c= NoApps;
    Opp.Stagename ='Awaiting Assessment';
    Opp.closedate = datetime.now().date();
    Opp.Web_Form_Data__c = webFormDataId;
        //C0782 REAC Changes ; start; Save value for REAC Finance Required in backend
    if(opp.Interested_in__c.contains('REAC')){
    Opp.Finance_Required__c = Opp.REAC_Amount__c + Opp.Outstanding_Finance_Amount__c;
    system.debug('REAC Finance Required'+Opp.Finance_Required__c);
    }
    // C0782 REAC Changes ; End
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
    Opp.HPP_extended_opportunity__c = exOpp.id;
    
    List<String> reasons = LiabilitiesHelperFunctions.IsEligible(Applicant1,Opp,Applicant2,Applicant3,Applicant4);
    
    system.debug('reasons');
    system.debug(reasons);
    
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
    
    /* C0586
    if(reasons[0] == 'YES')
    */
    Opp.Income_Assisted_Application__c = false ;
    if(reasons[0] == 'YES' || 
        (!IsBTL_LTD && reasons [0] == 'The information you have submitted indicates that the monthly rental income is not sufficient.'
         && reasons .size() == 1 )) // C0586 & C0644 add in Ltd Co. check as IAA is not valid
    {       
        /* C0586 */
        if (reasons [0] == 'The information you have submitted indicates that the monthly rental income is not sufficient.')
        {
            displayIncomeAssisted = true;
            EligibleOutput  = 'Applicant is Eligible - Proceed as an Income Assisted Application';
            Opp.Income_Assisted_Application__c = true ;
        }
        else 
        {
            displayIncomeAssisted = false;
            EligibleOutput  = 'Applicant is Eligible';

        }
        /* C0586 end */

        // C0586 EligibleOutput  = 'Applicant is Eligible'; 
        Opp.StageName = 'HPP -Eligible Opportunity';
        
        
        try    
        {
             update Opp;
        }
        catch(Exception ex)
        {
            return null;
        }
    
   
    
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

        try
        {
            update Opp;
        }
        catch(Exception ex)
        {
            return null;
        }
    
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
        IsBTL_LTD=false;
        IsBTL = false;  
        if(Applicant1 == null)
        {
            system.debug('Applicant1 not found during setup:');
            Applicant1 = new Account(RecordTypeId = recType.Id, FirstName='', LastName='', Salutation = '');     
        }
        else
        {
            system.debug('Applicant1 found during setup:'+Applicant1);
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
    
    public Id webFormDataId{get;set;}

    public PageReference ChangeNumApps()
    {
       Date d = Date.Today(); //REAC changes start  
       List<Opportunity> oppCount = [select id from Opportunity where accountid = :existingSFDCCustomerId]; //REAC Changes 
       system.debug('oppCount'+oppCount.size());
      if(opp.interested_in__c != '--None--'){ //REAC changes  end  
        IBB_Product_Set__c prodSet = [select id,Max_No_of_Applicants__c, ShortProductType__c,ProductSetType__c  from IBB_Product_Set__c where name = :opp.interested_in__c limit 1 ];
         
        if(Opp.Number_of_People_Applying__c > prodSet.Max_No_of_Applicants__c )
        {
            String msg = 'Only ' + prodSet.Max_No_of_Applicants__c +' applicants allowed for ' + opp.interested_in__c  ;
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
             ApexPages.addMessage(myMsg);  
            return null;
        }
           /*C0782 REAC Changes start: Removed code hanges as part of Enhancement
        if(!String.isBlank(existingSFDCCustomerId)){
            
            if(opp.interested_in__c.contains('REAC') && DateConvertedtoCustomer!=null && DateConvertedtoCustomer.monthsBetween(d) <= 6){
                String msg = 'You can not create new opportunity, because customer Date Converted to Customer is less than 6 months';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
                ApexPages.addMessage(myMsg);  
                return null;
            }
        
            if(opp.interested_in__c.contains('REAC') && oppCount.size() >= 3){
                String msg = 'You can not create new opportunity as this account already has 3 opportunities';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
                ApexPages.addMessage(myMsg);  
                return null;
            }
        }
        C0782 REAC Changes End*/
        if(prodSet.ShortProductType__c=='BTLLC')
        {
            IsBTL_LTD=true;
            if(String.isBlank(existingSFDCCustomerId))
            {
                Applicant1 = new Account(RecordTypeId = recTypeBusiness.Id, Organisation_Type__c='Limited Company', Customer_Type__c='Limited Company');
            }
        }

        if(prodSet.ProductSetType__c=='BTL')
        {
            IsBTL=true;
        }

        
        
        // C0644 Ltd Companies can have 5 applicants (Co. + 4 Dir's)
        if(IsBTL_LTD)
        {
            if(String.isBlank(existingSFDCCustomerId))
            {
                if(Opp.Number_of_People_Applying__c> 0)
                    Applicant2 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
           
                if(Opp.Number_of_People_Applying__c> 1)
                    Applicant3 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
           
                if(Opp.Number_of_People_Applying__c> 2)
                    Applicant4 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');

                if(Opp.Number_of_People_Applying__c> 3)
                    Applicant5 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
            }
            else
            {
                // New method to create applicants based on existing customer's CPF relationships (Directors)
                if(IsFirstPage)
                {
                    getExistingDirectors();
                }

            }

        }
        else
        {
            if(Opp.Number_of_People_Applying__c> 1)
            Applicant2 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
           
             if(Opp.Number_of_People_Applying__c> 2)
            Applicant3 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
           
             if(Opp.Number_of_People_Applying__c> 3)
            Applicant4 = new Account(RecordTypeId = recType.Id, FirstName='New', LastName='Account');
        }

        IsFirstPage =false;

        SetUpBoxes();

        
        webFormDataId = Apexpages.currentPage().getParameters().get('webFormDataId');
       return null;        
    }//C0782 Code changes start
    else{ 
            String msg = 'Interested In: You must enter a value';
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
            ApexPages.addMessage(myMsg);  
            return null;
        }
    // REAC Changes End
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
    
    public void SetUpBoxes()
    {  
        // C0697
        HasEmail = Applicant1.Contact_by_Email_New__c !=null ? Applicant1.Contact_by_Email_New__c : false;
        HasMail= Applicant1.Contact_by_Post_New__c!=null ? Applicant1.Contact_by_Post_New__c : false;
        HasPhone= Applicant1.Contact_by_Telephone_New__c!=null ? Applicant1.Contact_by_Telephone_New__c : false;
        HasSMS= Applicant1.Contact_by_SMS_New__c!=null ? Applicant1.Contact_by_SMS_New__c : false;
        HasNewsletter = Applicant1.Contact_by_Newsletter_New__c!=null ? Applicant1.Contact_by_Newsletter_New__c : false;
        HasNone = Applicant1.No_Contact__c!=null ? Applicant1.No_Contact__c : false;
        
    }
    
    public Boolean HasEmail{get;set;}
    public Boolean HasMail{get;set;}
    public Boolean HasPhone{get;set;}
    public Boolean HasSMS{get;set;}
    public Boolean HasNone{get;set;}
    public Boolean HasNewsletter{get;set;}
    
    
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

   private void getExistingDirectors()
    {
        // Get list of CPF relationships based on Applicant1
        List<CPF_Relationship__c> dirs = [select id,Child_Account__c,Shareholder_Percentage__c,Is_Director__c,Is_Shareholder__c,Position_Held__c from CPF_Relationship__c where Parent_Account__c=:Applicant1.id order by CreatedDate];
        
        // Get required data from above list to create each Applicant
        Integer i = 1;
        
        Opp.Number_of_People_Applying__c = dirs.Size();

        for(CPF_Relationship__c dir : dirs)
        {
            Account app = DataHelper.GetAccount(dir.Child_Account__c)[0];
            //app.Is_Director__c = dir.Is_Director__c;
            //app.Is_Shareholder__c = dir.Is_Shareholder__c;
            //app.Is_Signatory__c = dir.Is_Signatory__c;
            //app.Shareholder_Percentage__c = dir.Shareholder_Percentage__c;
            app.Position_Held__c = dir.Position_Held__c;
            if(i==1)
            {
                Applicant2 = app;
            }
            else if(i==2)
            {
                Applicant3 = app;
            }
            else if(i==3)
            {
                Applicant4 = app;
            }
            else if(i==4)
            {
                Applicant5 = app;
            }
            i++;
        }
    }
/***C0782 REAC Changes start*/
public List<SelectOption> getItems() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('--None--','--None--'));
    options.add(new SelectOption('Home Purchase Plan','Home Purchase Plan'));
    options.add(new SelectOption('Buy To Let Purchase Plan','Buy To Let Purchase Plan'));
    options.add(new SelectOption('Home Purchase Plan Premier','Home Purchase Plan Premier'));
    options.add(new SelectOption('Home Purchase Scotland','Home Purchase Scotland'));
    options.add(new SelectOption('Buy To Let Purchase Plan Scotland','Buy To Let Purchase Plan Scotland'));
    options.add(new SelectOption('Buy To Let Limited Company Purchase Plan','Buy To Let Limited Company Purchase Plan'));
    if(String.isNotBlank(existingSFDCCustomerId)){
     options.add(new SelectOption('REAC Home Purchase Plan','REAC Home Purchase Plan'));
     options.add(new SelectOption('REAC Buy To Let Purchase Plan','REAC Buy To Let Purchase Plan'));
     options.add(new SelectOption('REAC Home Purchase Scotland','REAC Home Purchase Scotland'));
     options.add(new SelectOption('REAC Buy To Let Purchase Plan Scotland','REAC Buy To Let Purchase Plan Scotland'));
     
     }
    return options;
} 

public List<SelectOption> getItemsFinance() {
    List<SelectOption> options = new List<SelectOption>();
    
 if(String.isNotBlank(existingSFDCCustomerId) && (Opp.Interested_in__c.contains('REAC'))){
  options.add(new SelectOption('--None--','--None--'));
  options.add(new SelectOption('Home improvements','Home improvements'));
  options.add(new SelectOption('Furnishings','Furnishings'));
  options.add(new SelectOption('Car purchase','Car purchase'));
  options.add(new SelectOption('3rd party Debt consolidation','3rd party Debt consolidation'));
  options.add(new SelectOption('Property purchase/deposit','Property purchase/deposit'));
  options.add(new SelectOption('Others','Others'));
 }
 else{
    options.add(new SelectOption('--None--','--None--'));
    options.add(new SelectOption('New Purchase','New Purchase'));
    options.add(new SelectOption('Refinancing','Refinancing'));
    options.add(new SelectOption('Shared ownership','Shared ownership'));
    options.add(new SelectOption('Right to buy','Right to buy'));
    options.add(new SelectOption('Key worker scheme','Key worker scheme'));
    }
    return options;
} 

/***C0782 REAC changes end*/
    /* Case:01931533 ; Added to get the property type; Start */
    public List<SelectOption> getPropertyType(){
        List<SelectOption> options = new List<SelectOption>();
        if(Opp.Interested_in__c.contains('Premier')){
            options.add(new SelectOption('--None--','--None--'));
            options.add(new SelectOption('Council property','Council property'));
            options.add(new SelectOption('Ex council property','Ex council property'));
            options.add(new SelectOption('Housing association','Housing association'));
            options.add(new SelectOption('Shared ownership','Shared ownership'));
            options.add(new SelectOption('Private Property (Holiday Home)','Private Property (Holiday Home)'));
            options.add(new SelectOption('Private Property (Investment/BTL)','Private Property (Investment/BTL)'));
        }else{
            options.add(new SelectOption('--None--','--None--'));
            options.add(new SelectOption('Council property','Council property'));
            options.add(new SelectOption('Ex council property','Ex council property'));
            options.add(new SelectOption('Housing association','Housing association'));
            options.add(new SelectOption('Shared ownership','Shared ownership'));
            options.add(new SelectOption('Private Property','Private Property'));
        }
        return options;
    }
    /* Case:01931533 ; Added to get the property type; End*/
}