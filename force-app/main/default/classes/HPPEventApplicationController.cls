public class HPPEventApplicationController extends HPPBaseEventController {
    
    private final Boolean STORE_CARD_SECURITY_CODE = true;
    public Boolean getStoreCardSecurityCode() {
        return STORE_CARD_SECURITY_CODE;
    }

    public List<Property_information__c> BTLProperty { get; set; }

    public Integer rowDelete{get;set;}
    public Integer rowDeleteProperty{get;set;}
    public Integer rowDeleteAdult{get;set;}
    public Integer rowDeleteDepositSource{get;set;}
    public Integer rowDeleteCCJ{get;set;}
    public Integer rowDeleteDefault{get;set;}
    public Integer rowDeleteRefinanceSource{get;set;}
    public String deleteCardId{get;set;}
    public String editCardId{get;set;} 
    public String ValuationId{get;set;}   
    
    public PageReference DeleteCard()
    {
        for(CardWrapper c : Cards) {
            system.debug('Compare card id ' + c.card.id + ' vs ' + deleteCardId);
            if (c.card.id == deleteCardId) {            
                Card = c.card;
            }
        }
        
        if(card != null && String.isNotBlank(card.Id)) {
            system.debug('Card id : ' + card.id);
            delete Card;
            Card = new Card__c();
            LoadCards();
        }
        
        return null;
    }
    
    public PageReference EditCard()
    {
        system.debug('Card list size ' + cards.size());
        for(CardWrapper c : Cards)
        {
            system.debug('looking for card ' + editCardId +' against ' + c.card.id);
            if(c.card.id == editCardId)
            {
            system.debug('Found card');
            Card = c.card;
            }
        }
        return null;
    }

    public String cardExpiryDate {get; set;}
    public Card__c Card{get;set;}
    public List<CardWrapper> Cards{get;set;}
    public Boolean HasCards
    {
        get{
            return Cards.size() > 0;
        }
    }

    public List<GenericObject__c> RefinanceSource
    {
    get{
        return Helper.Type('RefinanceSource');
    }    
    }
    
    public PageReference AddRefinanceSource()
    {
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = opp.id;
        p.Type__c = 'RefinanceSource';
        Helper.ApplicationData .add(p);
        upsert helper.ApplicationData ;
        return null;
    }

     public PageReference RemoveRefinanceSource() {  
        
        GenericObject__c del = RefinanceSource[rowDeleteRefinanceSource];        
        for(GenericObject__c d : Helper.ApplicationData )
        {
            if(d.id == del.id)
            {                
                update Helper.ApplicationData ;
                delete d;  
                Helper.ApplicationData = DataHelper.GetGenericObject(Opp.id);      
                break;
            }
        }          
        return null;
    }


    public List<GenericObject__c> DepositSource
    {
    get{
        return Helper.Type('DepositSource');
    }    
    }
    
    public List<GenericObject__c> CCJ
    {
    get{
        return Data.CCJ;
    }    
    }
    
    public List<GenericObject__c> Defaults
    {
    get{
        return Data.Defaults;
    }    
    }
    
    public PageReference AddDefault()
    {
        system.debug('Adding Default');
        GenericObject__c p = new GenericObject__c();
        p.Account__c= acc.id;
        p.Type__c = 'Default';
        Helper.ApplicantData .add(p);
        upsert helper.ApplicantData ;
        
        acc.Default_number__c = Defaults.size();
        update acc;
        return null;
    }    
    
    public PageReference AddCCJ()
    {
        system.debug('Adding CCJ');
        GenericObject__c p = new GenericObject__c();
        p.Account__c= acc.id;
        p.Type__c = 'CCJ';
        Helper.ApplicantData .add(p);
        upsert helper.ApplicantData ;
        acc.Please_state_the_number_of_judgements__c= CCJ.size();
        update acc;
        return null;
    }
    
    public PageReference AddDepositSource()
    {
        system.debug('Adding deposit source');
        GenericObject__c p = new GenericObject__c();
        p.Opportunity__c = opp.id;
        p.Type__c = 'DepositSource';
        Helper.ApplicationData .add(p);
        upsert helper.ApplicationData ;
        return null;
    }

     public PageReference RemoveDepositSource() {  
        
        GenericObject__c del = DepositSource[rowDeleteDepositSource];        
        for(GenericObject__c d : Helper.ApplicationData )
        {
            if(d.id == del.id)
            {
                  
                update Helper.ApplicationData ;
                delete d;
                Helper.ApplicationData = DataHelper.GetGenericObject(Opp.id);      
                break;
            }
        }          
        update acc;
        return null;
    }
    
      public PageReference RemoveCCJ() {  
        
        GenericObject__c del = CCJ[rowDeleteCCJ];        
        for(GenericObject__c d : Helper.ApplicantData )
        {
            if(d.id == del.id)
            {
                  
                update Helper.ApplicantData ;
                delete d;
                Helper.ApplicantData = DataHelper.GetGenericObjectByAccount(accountIds);      
                break;
            }
        }        
         
        acc.Please_state_the_number_of_judgements__c= CCJ.size();
        update acc; 
        system.debug('No judgements : '+acc.Number_of_judgements__c +' : ' + CCJ.size());
        
        return null;
    }
    
    public PageReference RemoveDefault() {  
        
        GenericObject__c del = Defaults[rowDeleteDefault];        
        for(GenericObject__c d : Helper.ApplicantData )
        {
            if(d.id == del.id)
            {
                  
                update Helper.ApplicantData ;
                delete d;
                Helper.ApplicantData = DataHelper.GetGenericObjectByAccount(accountIds);      
                break;
            }
        }        
        acc.Default_number__c = Defaults.size();  
        update acc; 
        return null;
    }
    
    public void LoadCards()
    {
        cards = new List<CardWrapper>(); 
        if(accounts.size() == 0)
            return;
                
        List<Card__c> lstCard = [
            Select Id, Name,Account__c , Card_Name__c, Contact__r.Name, Contact__c, Card_Type__c, Card_Currency__c, Primary__c, Issue_Number__c, Security_Code__c, Token__c,
                Expiry_Month__c, Expiry_Year__c,Expiry_Year_Text__c, Valid_From_Month__c, Valid_From_Year__c, Valid_From_Year_Text__c, 
                Billing_City__c, Billing_Street__c, Billing_County_State__c, Billing_Post_Code__c, Billing_Country__c, 
                First_Name__c, Middle_Name__c, Last_Name__c, Card_Number_Encrypted__c, Expiry_Date_Encrypted__c, Security_Code_Encrypted__c 
            from Card__c 
            where Contact__c =: accounts[0].PersonContactId 
        ];
                                               
        for(Card__c c : lstCard)
        {
            cards.add(new CardWrapper (c));
        }                            
    }

    public PageReference AddCard()
    {
        system.debug('Adding card');
        card.Contact__c = Accounts[0].PersonContactId ;
        card.Account__c = Accounts[0].id;
        
        card.Card_Number_Encrypted__c = card.Name;
        
        card.Billing_City__c = Accounts[0].BillingCity;
        card.Billing_Country__c = Accounts[0].BillingCountry;
        card.Billing_County_State__c = acc.BillingState;
        card.Billing_Post_Code__c = Accounts[0].BillingPostalCode;
        card.Billing_Street__c = Accounts[0].BillingStreet;
        
        String token = stSecureTradingHandler.registerCard(card);
        
        if(String.isBlank(token)) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Card not saved.');
            ApexPages.addMessage(myMsg);
            card.Security_Code__c = null;
            card.Security_Code_Encrypted__c = null;
            //  card.Name = null;
            //  return null;
        }
        else {
            card.Name = '*'.repeat(12) + card.Name.right(4);

            //  Store the Token
            card.Token_Encrypted__c = token;
            
            //  Store the Expiry Date in an Encrypted field
            if (card.Expiry_Month__c != null && String.isNotBlank(card.Expiry_Year_Text__c)) {
                String expiryMonth = (card.Expiry_Month__c < 10) ?
                    '0' + card.Expiry_Month__c :
                    String.valueOf(card.Expiry_Month__c); 
                card.Expiry_Date_Encrypted__c = expiryMonth + '/' + card.Expiry_Year_Text__c;
            }
            else {
                card.Expiry_Date_Encrypted__c = null;
            }
            
            //  Blank most Card Details - only stored by Secure Trading
            card.Card_Number_Encrypted__c = null;
            /*card.Billing_City__c = null;
            card.Billing_Country__c = null;
            card.Billing_County_State__c = null;
            card.Billing_Post_Code__c = null;
            card.Billing_Street__c = null;*/
            card.Card_Name__c = null;
            card.Expiry_Month__c = null;
            card.Expiry_Year__c = null;
            card.Expiry_Year_Text__c = null;
            card.Issue_Number__c = null;
            card.Security_Code__c = null;
            card.Token__c = null;
            card.Valid_From_Month__c = null;
            card.Valid_From_Year__c = null;
            card.Valid_From_Year_Text__c = null;
             
            insert Card;
        }
        
        Card = new Card__c();
        Card.name='';
        LoadCards();      
        return null;
    }



    public PageReference Remove() {  
        
        Person_Debts__c del = Debt[rowDelete];        
        for(Person_Debts__c d : Helper.PersonDebts)
        {
            if(d.id == del.id)
            {
                delete d;  
                Helper.PersonDebts = DataHelper.GetDebts(accountIds);      
                break;
            }
        }
          
        return null;
    }
    
    public PageReference AddDebt() {      
        Person_Debts__c p = new Person_Debts__c();
        p.Owner_of_debt__c = Acc.id;
        Helper.PersonDebts .add(p);
        upsert helper.PersonDebts ;
        return null;
    }
    
    public PageReference RemoveProperty() 
    {
        Property_information__c del = Property[rowDeleteProperty];        
        for(Property_information__c d : Helper.AllPropertyInfo )
        {
            if(d.id == del.id)
            {
                delete d;  
                Helper.AllPropertyInfo = DataHelper.GetPropertyInfo(accountIds);      
                break;
            }
        }
          
        return null;
    
      
    
        Helper.RemoveProperty(CurApp-1,rowDeleteProperty); 
        return null;
    }
    
    public PageReference AddProperty() {  
        Property_information__c  p = new Property_information__c ();
        p.PersonAccount__c=  Acc.id;
        Helper.AllPropertyInfo.add(p);
        upsert helper.AllPropertyInfo ;
        return null;
    }  
    
    public PageReference RemoveAdult() {     
        helper.RemoveAdult(rowDeleteAdult);
        return null;
    }
    
    public PageReference AddAdult() {  
        Helper.AddAdult(Opp.id);
        
        return null;
    }

       
    public HPPEventApplicationHelper.HPPData Data
    {
        get{
            return  Helper.GetItem(Acc.id);  
        }
    }  
    
    public Budget_planner__c Budget
    {
        get{         
            return Data.Budget;        
        }    
    }
    
    public Property_information__c PropertyInfo{get;set;}    
    
 
    
    public List<Person_Debts__c> PersonDebts{get;set;}    
    public Integer NoApps{get;set;}

    
    public Boolean IsBuyToLet
    {
        get{
            return IsBTL;
        }
    }
    
    public String AppMenu
    {
    get{
    
        if(NoApps == null)
        return '';
        
        if(NoApps > 0)
        {
            String menu='';
            for(Integer i =0;i< NoApps;i++)
            {
                menu+= '<li><apex:commandLink action="{!PageApplicant'+(i+1)+'}" value="Applicant'+(i+1)+'" id="applicant'+(i+1)+'"/></li>';
            }
            return menu;
        }
        return '';
        }
    }
    
   
  

    public List<Person_Debts__c> Debt
    {
        get{ return Data.Debts;}
    }
    
    public List<Other_adults_in_the_property__c> OtherAdults
    {
        get{ return Helper.OtherAdults; }
    }
    
    
    public List<Property_information__c> Property
    {
        get{ return Data.Property;}
    }    

    public PageReference Setup()
    {
        SetupMinValues();
    
        if(Helper != null)
            return null;
            
        System.debug('no apps : ' + Accounts.size() + ' accountids ' + AccountIds);            
            
        Helper = new HPPEventApplicationHelper();
        Helper.Load(AccountIds,opp.id,accounts);
        HPPEventApplicationHelper.HPPData data = Helper.GetItem(Acc.id);                    
        LoadCards();
        
        ValuationId = ExOpp.Valuation_Table__c;
        if(ValuationId == null)
        {
            ValuationId = '--';
        }
    
        return null;
    }

    public Decimal TotalDeposit
    {
        get{
            decimal total=0;
            for(GenericObject__c o:  Helper.Type('DepositSource'))
            {
                if(o.Deposit_value__c != null)
                total +=  o.Deposit_value__c;
            }
            return total;
        }
    }
    
    public Decimal TotalRefinance
    {
        get{
            decimal total=0;
            for(GenericObject__c o:  Helper.Type('RefinanceSource'))
            {
                if(o.Deposit_value__c != null)
                total += o.Refinance_Value__c;
            }
            return total;
        }
    }

    public PageReference Save()
    {
        if(ValuationId != '--')
        ExOpp.Valuation_Table__c = ValuationId ;
        Opp.Total_Deposit_Value__c = TotalDeposit;
        Opp.Refinance_Value__c = TotalRefinance;
        Logger.Debug('Postcode => ' + Acc.BillingCountry);
        
        if( Acc.BillingCountry.equalsIgnoreCase('GBR') && (Acc.BillingPostalCode == null ||  Acc.BillingPostalCode==''))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please entere a postcode for current address');
            ApexPages.addMessage(myMsg);
        }
       
        update Opp;
        update ExOpp;
        update Accounts;    
    
        Helper.Save(Opp.id); 
        SetupMinValues();  
        return null;
    }
    
    
    
    public PageReference SaveValidate()
    {   
        
        
        
        
        Save();
        
         CompleteEvent(); 
   
        
        
        
        return null;
    }
  
    public List<Property_information__c> AllPropertyInfo {get;set;}

    public HPPEventApplicationHelper Helper{get;set;}

    // DecisionEngine Testing
    public Actions.IAction DecisionEngineAction{get;set;}
    //
    
    public HPPEventApplicationController  () 
    {     
        BTLProperty = new List<Property_information__c>();
        NoApps = integer.valueof( Opp.Number_of_People_Applying__c); 
        // DecisionEngine Testing
        DecisionEngineAction= new Actions.ActionDecisionEngine ();
        
        Cards = new List<CardWrapper>();
        Card = new Card__c();
        LoadCards();
        
        
    }
    
  
    
    public PageReference PageApplication1()
    {
        
        PageReference pageRef;
        String pageURL;
        pageURL = '/apex/HPPApplication1';
        pageRef = new PageReference(pageURL);
        return pageRef;    
    }
    public PageReference PageApplicant1()
    {
        Save();
        CurApp = 1;
        return  new PageReference('/apex/HPPApplication2');    
    }
    
    public PageReference PageApplicant2()
    {
        Save();
        CurApp = 2;
        return new PageReference('/apex/HPPApplication2');   
    }
    
    public PageReference PageApplicant3()
    {
        Save();
        CurApp = 3;
        return new PageReference('/apex/HPPApplication2');   
    }
    
    public PageReference PageApplicant4()
    {
        Save();
        CurApp = 4;
        return  new PageReference('/apex/HPPApplication2');    
    }   
    
    public PageReference PageApplication3()
    {
        Save();
        return new PageReference('/apex/HPPApplication3'); 
    }
    
    public PageReference PageApplication4()
    {
        Save();
        system.debug('Loading page 4');
        return new PageReference('/apex/HPPApplication4');    
    }
    
    public PageReference PageApplication5()
    {
        Save();
        return new PageReference('/apex/HPPApplication5');    
    }
    public PageReference PageApplication6()
    {
        Save();
        return new PageReference('/apex/HPPApplication6');   
    }
    
    public PageReference PageApplication7()
    {
        Save();
        return new PageReference('/apex/HPPApplication7');   
    }
    
    public PageReference NextEvent()
    {
        return new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);
    }
    
    public PageReference Complete()
    {       
       CompleteEvent();   
       
       system.debug('Created event - event ctl ' + CreatedEvent );
        
        if(CreatedEvent != null)
        {
             PageReference pageRef = null;
             return new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);

        }
        
        return null;            
    }  
    
    public PageReference SetPage(Integer appNo)
    {  
        //SaveData();      
        Save();
        CurApp = AppNo;        
        return new PageReference('/apex/HppApplication1');
    }
    
     public PageReference NextAPP()
    {
        if(curapp < Opp.Number_of_People_Applying__c)
        {
            return SetPage(curapp +1);
        }
        else
        {
            return PageApplication3();
        }
    }
    
    public PageReference PreviousAPP()
    {
        if(curapp > 1)
        {
            return SetPage(curapp -1);
        }
        else
        {
            return PageApplication1();
        }
    }
    
    public PageReference LastApp()
    {
        return SetPage(integer.valueof(Opp.Number_of_People_Applying__c));
    }
    
         
    public boolean showPrevAddress {get;set;}
    public boolean allAddressesEntered {get;set;}
    public boolean showPrevPrevAddress {get;set;}
    public boolean showPrevPrevPrevAddress {get;set;}
    
    public pageReference checkAddressDates(){
        
        PageReference pageRef;
        String pageURL;
        allAddressesEntered = true;
        Date currDate = acc.Date_moved_to_address__c;
        Date prevDate = acc.Date_moved_to_previous_address__c;
        Date prevprevDate = acc.Date_moved_to_prev_previous_address__c;
        Date todayDate = Date.today();
        if (currDate > todayDate)
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Date of moving cannot be after today'));
          return null;
        }
        if (prevDate != null && prevDate > todayDate)
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Date of moving cannot be after today'));
          return null;
        }
        if (prevprevDate != null && prevprevDate > todayDate)
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Date of moving cannot be after today'));
          return null;
        }
        integer daysAtCurrAddress = currDate.daysBetween(todayDate);
        integer daysAtPrevAddress = (prevDate == null ? 0 : prevDate.daysBetween(todayDate));
        integer daysAtPrevPrevAddress = (prevprevDate == null ? 0 : prevprevDate.daysBetween(todayDate));
        
        integer minimumAddressHistory = 1095;
        Date lifeDate = acc.Date_of_Birth__c;
        if ( lifeDate != null )
        {
            integer daysAlive = lifeDate.daysBetween(todayDate);
            if ( minimumAddressHistory > daysAlive )
            {
                minimumAddressHistory = daysAlive;
            }
            system.debug( ' minimumAddressHistory='+minimumAddressHistory+' daysAlive='+daysAlive);
        }
        
        if (daysAtCurrAddress < minimumAddressHistory){
            showPrevAddress = true;
            allAddressesEntered = false;
        }else if (daysAtCurrAddress >= minimumAddressHistory){
            showPrevAddress = false;
            allAddressesEntered = true;
        }   
        
        if (prevDate == null && daysAtCurrAddress < minimumAddressHistory){
            allAddressesEntered = false;
        }
        
        if (prevDate != null && daysAtPrevAddress < minimumAddressHistory){
            showPrevPrevAddress = true;
            allAddressesEntered = false;
        }else if (prevDate != null && daysAtPrevAddress >= minimumAddressHistory){
            showPrevPrevAddress = false;
            allAddressesEntered = true;
        }
        
        if (prevprevDate == null && prevDate != null && daysAtPrevAddress < minimumAddressHistory){
            allAddressesEntered = false;
        }
        
        if (prevprevDate != null && daysAtPrevPrevAddress < minimumAddressHistory){
            showPrevPrevPrevAddress = true; 
            allAddressesEntered = false;
        }else if (prevprevDate != null && daysAtPrevPrevAddress >= minimumAddressHistory){
            
            allAddressesEntered = true;
        }
        
        if (acc.Additional_Address_Details__c != null && acc.Additional_Address_Details__c != '' )
        {
           allAddressesEntered = true;
        }
        
        if (!allAddressesEntered){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please enter three years of addresses below.'));
            pageRef = ApexPages.currentPage();
            
        }
        else pageRef = null;
        return pageRef;
    }
    
    public void TestDE_SetAllIDs ()
    {
        //WebLogIds
        List<Applicant__c> applicants = [Select Id,
                            Opportunity__c, 
                            Prospect_Customer__c, 
                            Applicant_Number__c 
                      from Applicant__c
                      where Applicant__c.Opportunity__c = :opp.Id];
                      
        List<Web_Integration_Log__c> weblogs = new List<Web_Integration_Log__c>();
        List<Credit_Score__c> creditScores = new List<Credit_Score__c>();
        
        if (applicants.Size() > 0)
        {
            for (Applicant__c applicant:applicants)
            {
                Web_Integration_Log__c weblog = new Web_Integration_Log__c();
                weblog.AccountId__c = applicant.Prospect_Customer__c;
                weblogs.Add(weblog);
                
                Credit_Score__c creditScore = new Credit_Score__c();
                creditScore.Prospect_customer__c = applicant.Prospect_Customer__c;
                creditScore.Opportunity__c = opp.Id;
                creditScores.Add(creditScore);
            }
        }        
        insert weblogs;
        insert creditScores;       
    }    
    
    public string FISDocLink
    {
        get{
            string link = 'Quotation document is still being generated.';
    
            List<IBBQuotation__c> quotes = [select id,Attachment_FIS__c  from IBBQuotation__c where QuoteToBeAIP__c = true and Opportunity__c = : Opp.id];
            if(quotes.size() == 0)
                return link;
                
            if(quotes[0].Attachment_FIS__c== null)
                return     link;
                
            return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + quotes[0].Attachment_FIS__c+ '"><b>KFI Document</b></a>';
         }
    }
    

    public void TestDE_CallHPPDecisionEngine ()
    {
        DecisionEngineAction.RunAction(opp.id);
    }
    
    public class ApplicantData
    {
        
    }
    
    public List<Valuation_Table__c> Valuationss
    {
        get
        {
            /* C00101 start
            return  [select id,Type_of_valuation__c,Price_of_valuation__c,Minimum_property_value__c ,Property_up_to_the_value_of__c 
                    from Valuation_Table__c
                    where Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c order by Price_of_valuation__c ];
            */
            return  [select id,
                            Type_of_valuation__c,
                            Price_of_valuation__c,
                            Minimum_property_value__c ,
                            Property_up_to_the_value_of__c 
                    from Valuation_Table__c
                    where Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c 
                    and Category__c = :Opp.Interested_in__c and Is_Active__c =true
                    order by Price_of_valuation__c ];
            /* C00101 end */        
        }
    }
    
    
    public List<SelectOption> Valuations
    {
        get{
            List<SelectOption> lst = new List<SelectOption>();
            
            /* C00101 start
            List<Valuation_Table__c> valuations = [select id,Type_of_valuation__c,Price_of_valuation__c from Valuation_Table__c
                where Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c order by Price_of_valuation__c  ];
            */
            
            List<Valuation_Table__c> valuations = [select id,
                                                        Type_of_valuation__c,
                                                        Price_of_valuation__c
                                                    from Valuation_Table__c
                                                    where Minimum_property_value__c <=:Opp.Purchase_price_market_value__c 
                                                    and Property_up_to_the_value_of__c >: Opp.Purchase_price_market_value__c 
                                                    and Category__c = :Opp.Interested_in__c and Is_Active__c =true
                                                    order by Price_of_valuation__c ];
            /* C00101 end */                                        
            lst.add(new SelectOption('--','-- Please select --'));
            
            for(Valuation_Table__c v : valuations)
            {
                SelectOption opt = new SelectOption(v.id, '£' + v.Price_of_valuation__c + ' ' +  v.Type_of_valuation__c ); 
                lst.add(opt);              
            }
            return lst;
        }    
    }
    
    
    public PageReference CreateDoc()
    {
        CongaSettings sett = new CongaSettings(prodset.Conga_Application_Form__c);                         
        string body= sett.CallConga(opp.id);   
          
        if(sett.AttachmentId != null)
        {
            Opp.Attachment_App_Form__c = sett.AttachmentId;
            update opp;
            AppFormId = Opp.Attachment_App_Form__c;
        } 

        return null;
    }
    
    public String AppFormId {get;set;}
    
    public String AppDocName
    {
        get{                    
                
                if(prodset.Name == 'Home Purchase Plan' || prodset.Name == 'Home Purchase Plan Premier')
                {
                    return 'HPP Application Form - ' + opp.name + '.pdf';
                }
                
                if(prodset.Name == 'Buy To Let Purchase Plan' )
                {
                    return  'BTLPP Application Form - ' + opp.name + '.pdf';
                }
                
                if(prodset.Name == 'Home Purchase Scotland' )
                {
                    return  'HPS Application Form - ' + opp.name + '.pdf';
                }
                return '';
        }
    }
   
    public string DocLink
    {
        get{    
            if(Opp.Attachment_App_Form__c != null)
                return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + Opp.Attachment_App_Form__c+ '"><b>Application Form</b></a>';   
                
            return 'Could not find document';   
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
            return LiabilitiesHelperFunctions.GetResourceURL(prod.IDD_Document__c);            
        }
    }  
    
    public boolean DocLinkCreated
    {
        get{ 
            return Opp.Attachment_App_Form__c != null;           
        }
    }
    
    public void SetupMinValues()
    {
        MinValues = new Map<String,Decimal>();
        
        Integer noCars = 0;
        for(Account a : Accounts)
        {
            if(a.Number_of_cars__c!= null)
            {
                noCars  += a.Number_of_cars__c.intValue();
            }
        }
        
        HPPUnderwrittingBudgetHelper bpHelper = new HPPUnderwrittingBudgetHelper();
        bpHelper.Load(opp.id,noCars,null,IsBTL);
        
        for(HPPUnderwritingBudgetData d : bpHelper.Items())
        {
            system.debug('Adding item : ' + d.item.id);
            MinValues.put(d.item.budgetplannerconfig__c,d.Minimum);
        }
    }
      
   public Map<String,Decimal> MinValues{get;set;}
    
    /*
    public List<BudgetRow> BudgetPlanner {get;set;}
    
    class BudgetRow
    {
        public Budget_Planner_Item__c Field1{get;set;} 
        
        public Budget_Planner_Item__c Field2{get;set;}
    }
    */
    
    class CardWrapper
    {
        public Card__c card {get; set;}
        public Boolean selected {get; set;}
        
        public CardWrapper(Card__c c)
        {
            card = c;
            selected = false;   
        }
        
        public String getExpiryDate()
        {
            if(card.Expiry_Month__c == null || card.Expiry_Year_Text__c == null)
            return '';
        
            return Integer.valueOf(card.Expiry_Month__c) + '/' + Integer.valueOf(card.Expiry_Year_Text__c); 
        }
    }
}