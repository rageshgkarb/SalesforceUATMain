/* ---------------------------------------------------------------------------------------------------- */
/* C0307																								*/
/* ---------------------------------------------------------------------------------------------------- */


global class BAA_BusinessDetails_Controller extends HPPBaseEventController
{

    public Account Acc {get;set;}
    public Account EditAcc{get;set;}
    public CPF_Relationship__c RelationShip {get;set;}
    public Opportunity Opp{get;set;}
    
    public String Title{get;set;}
    
    public BAA_BusinessDetails_Controller()
    {//
          Acc = [select name, Name_of_entity__c, Organisation_type__c,Business_an_SPV__c,Does_the_SPV_exist__c,TradingAddressStreet__c,TradingAddressCity__c,TradingAddressCountry__c,
                    TradingPostCode__c,Is_trading_address_registered_address__c,Date_moved_to_registered_address__c,Registered_number__c,Registration_date__c,Organisation_domicile__c,Nature_of_Business_NPAA__c,
                    Main_company_activities__c,Frequency_of_overseas_trans_per_annum__c,Company_anticipated_turnover__c,Company_ant_credit_amount_per_month__c,
                    Company_ant_debit_amount_per_month__c,Turnover_made_from_non_compliant_Goods__c,Estimated_running_costs__c,Home_Telephone_No__c,Fax,PersonEmail,
                    VAT_number__c,Company_had_an_IVA__c,Company_had_a_property_reposessed__c,Company_had_a_CCJ__c,Company_has_broken_any_credit_agreements__c ,isPersonAccount ,
                    RegisteredAddressStreet__c, RegisteredAddressCity__c,RegisteredAddressPostCode__c, Contact_Name__c , Position_Held__c , Contact_s_telephone_number__c,  
                    CorrespondenceAddressStreet__c ,CorrespondenceAddressCity__c,CorrespondenceAddressCountry__c,CorrespondenceAddressPostCode__c,
                    Will_there_be_overseas_Credit_and_Debit__c, Overseas_transaction_amount__c, Overseas_transaction_country__c, Overseas_transaction_frequency__c ,
                    Cash_Credit_and_Debits__c,Anticipated_Cash_amount__c,Anticipated_cash_frequency__c,Existing_Business_Bank_Name__c,Existing_Business_Bank_Sort_Code__c,Existing_Business_Bank_Account_Number__c,
                    Number_of_employees__c, Business_email_address__c, Marketing_Consent__c,marketing_preference__c/*C0737 - C to c*/,RegisteredAddressCountry__c,  
                    Apply_for_Online_Banking__c,Overseas_Transaction__c,Anticipated_Cash__c,Is_trading_address_correspondenceaddress__c ,  Business_or_Charity_Size__c,   Size_of_business__c,
                    X2nd_Factor_Email_Address__c,X2nd_Factor_Landline_Number__c,X2nd_Factor_Mobile_Number__c,Date_business_began_operating__c
                    , Organisation_sub_type__c	// C0307
                    , Contact_by_Newsletter_New__c, Contact_by_Email_New__c, Contact_by_Post_New__c, Contact_by_SMS_New__c, Contact_by_Telephone_New__c, No_Contact__c //C0737
                    From Account where id=:BaseOpportunity.AccountId limit 1];
            SetUpBoxes();
            Opp = [select id, Purpose_of_Account__c from opportunity where id=:opportunityId];
           
           system.debug('ACC:' + acc);                             
                    
        EditAcc = new  Account(RecordTypeId = recType.Id, FirstName='', LastName='');
        RelationShip = new CPF_Relationship__c();
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
    
    public List<SelectOption> salutationList {
        get {
            if (salutationList == null){
                salutationList = new List<SelectOption>();
                salutationList.add(new SelectOption('None','--None--'));
                salutationList.add(new SelectOption('Mr','Mr'));
                salutationList.add(new SelectOption('Mrs','Mrs'));
                salutationList.add(new SelectOption('Ms','Ms'));
                salutationList.add(new SelectOption('Dr','Dr'));
                salutationList.add(new SelectOption('Miss','Miss'));
                salutationList.add(new SelectOption('Master','Master'));
                salutationList.add(new SelectOption('Prof','Prof'));
            }
            return salutationList;
        }
        set;
    }
    
    public PageReference Save()
    {
        
        try
        {
             // C0737 Start 
            if(!HasNewsletter && !HasEmail && !HasMail && !HasSMS && !HasPhone && !HasNone){
                IsMarketPrefSelected = 'No';
                return null;
            }else{
                IsMarketPrefSelected = 'Yes';  
            }
            // C0737 End
            UpdateRegistered();
            ProcessCheckBox();
            
            Acc.Customer_Type__c = Acc.Organisation_type__c;
            //Acc.Size_of_business__c = Acc.Business_or_charity_size__c;
            Acc.Business_or_charity_size__c = Acc.Size_of_business__c;
            system.debug ('Size of Business ' + Acc.Size_of_business__c);
            system.debug ('Business Size ' + Acc.Business_or_charity_size__c);
            if(Acc.Apply_for_Online_Banking__c.equalsIgnorecase('yes'))
            {
                acc.Internet_Enabled__c = true;
            }
            
            update Acc;     
            update opp;       
        }
        catch(Exception ex)
        {
            system.debug ('There is an exception ' + ex.getmessage());
            throw ex;
        }
        return null; 
    }
    
    private void UpdateRegistered()
    {
		/* C0307
        if(Acc.Is_trading_address_registered_address__c.equalsIgnoreCase('yes'))
		*/
		if(!String.isBlank(Acc.Is_trading_address_registered_address__c) && Acc.Is_trading_address_registered_address__c.equalsIgnoreCase('yes'))
        {
            Acc.RegisteredAddressStreet__c = Acc.TradingAddressStreet__c;
            Acc.RegisteredAddressCity__c = Acc.TradingAddressCity__c;
            Acc.RegisteredAddressCountry__c = Acc.TradingAddressCountry__c;
            Acc.RegisteredAddressPostCode__c = Acc.TradingPostCode__c;
        }
        
        /* C0307
		if(Acc.Is_trading_address_correspondenceaddress__c.equalsIgnoreCase('yes'))
		*/
		if(!String.isBlank(Acc.Is_trading_address_correspondenceaddress__c) && Acc.Is_trading_address_correspondenceaddress__c.equalsIgnoreCase('yes'))
        {
            Acc.CorrespondenceAddressStreet__c = Acc.TradingAddressStreet__c;
            Acc.CorrespondenceAddressCity__c = Acc.TradingAddressCity__c;
            Acc.CorrespondenceAddressCountry__c = Acc.TradingAddressCountry__c;
            Acc.CorrespondenceAddressPostCode__c = Acc.TradingPostCode__c;
        }
    }
    
    public PageReference Complete()
    {        
        try
        {
            // C0737 Start 
            if(!HasNewsletter && !HasEmail && !HasMail && !HasSMS && !HasPhone && !HasNone){
                IsMarketPrefSelected = 'No';
                return null;
            }else{
                IsMarketPrefSelected = 'Yes';  

            }
            // C0737 End
            ProcessCheckBox();
            UpdateRegistered();
            Acc.Customer_Type__c = Acc.Organisation_type__c;
            //Acc.Size_of_business__c = Acc.Business_or_charity_size__c;
            Acc.Business_or_charity_size__c = Acc.Size_of_business__c;
            
             if(Acc.Apply_for_Online_Banking__c.equalsIgnorecase('yes'))
            {
                acc.Internet_Enabled__c = true;
            }
            update Acc;
            update opp;
            CompleteEvent();           
        }
        catch(Exception ex)
        {
            System.debug ('this is the exc , ' + ex.getMessage());
        }
        return GoToNextEvent(); 
    }    
    
    
     public boolean Email1{
        get{
            if(Email1 == null)
            {
                Email1 = !ContainsOption('Email');
            }
            return Email1;            
        }
        set;
    }
    
    public boolean Mail1{
        get{
            if(Mail1 == null)
            Mail1 = !ContainsOption('Mail');
            return Mail1;
        }
        set;
    }
    
    public boolean Phone1{
        get{
            if(Phone1 == null)
            Phone1 = !ContainsOption('Phone');
            return Phone1;
        }
        set;
    }
    
    public boolean SMS1{
        get{
            if(SMS1 == null)
            SMS1 = !ContainsOption('sms');
            return SMS1;
        }
        set;
    }
	
	/* C0307 */
	public Boolean OrgTypeShowFields
	{
		get
		{
			if (acc.Organisation_Type__c == 'Trust')		
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		set;
	}
	
	public Boolean SubOrgTypeShowFields
	{
		get
		{
			if (acc.Organisation_sub_Type__c == 'Non-Corporated Trust')		
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		set;
	}
	/* C0307 end */
    
    public void SetUpBoxes()
    {  
         if( Acc.marketing_preference__c == null)//C0737
            return;
        //C0737 Start     
        //HasEmail = !ContainsOption('email');
        //HasMail= !ContainsOption('mail');
        //HasPhone= !ContainsOption('phone');
        //HasSMS= !ContainsOption('sms');
        
        HasNewsletter = Acc.Contact_by_Newsletter_New__c;
        HasNone = Acc.No_Contact__c;    
        HasEmail = Acc.Contact_by_Email_New__c;
        HasMail= Acc.Contact_by_Post_New__c;
        HasPhone= Acc.Contact_by_Telephone_New__c;
        HasSMS= Acc.Contact_by_SMS_New__c;
        //C0737 end
        
    }
    
    public Boolean HasEmail{get;set;}
    public Boolean HasMail{get;set;}
    public Boolean HasPhone{get;set;}
    public Boolean HasSMS{get;set;}
    public Boolean HasNone{get;set;}
    public Boolean HasNewsletter{get;set;}//C0737
    public String IsMarketPrefSelected{get;set;}//C0737 
    
    public void ProcessCheckBox()
    {   
        Acc.marketing_preference__c = '';//C0737
        //C0737 start
        if(!HasNewsletter){
            Acc.marketing_preference__c += '"newsletter" ';
            Acc.Contact_by_Newsletter_New__c = false;
        }else{
            Acc.Contact_by_Newsletter_New__c = true;
        }
        
        if(!HasMail){
            Acc.marketing_preference__c += '"mail" ';
            Acc.Contact_by_Post_New__c = false;
        }else{
            Acc.Contact_by_Post_New__c = true;
        }
            
        if(!HasEmail){
            Acc.marketing_preference__c += '"email" ';
            Acc.Contact_by_Email_New__c = false;
        }else{
            Acc.Contact_by_Email_New__c = true;
        }
    
        if(!HasPhone){
            Acc.marketing_preference__c += '"phone" ';
            Acc.Contact_by_Telephone_New__c = false;
        }else{
            Acc.Contact_by_Telephone_New__c = true;
        } 
    
        if(!HasSMS){
            Acc.marketing_preference__c += '"sms" ';
            Acc.Contact_by_SMS_New__c = false;
        }else{
            Acc.Contact_by_SMS_New__c = true;
        }
        
        if(!HasNone){
            Acc.marketing_preference__c += '"none" ';
            Acc.No_Contact__c= false;
        }else{
            Acc.No_Contact__c= true;
        }
        //C0737 end 
    }   
    
    public Boolean ContainsOption(String option)
    {
        system.debug('error:' + acc.marketing_preference__c);//C0737
                
        if(acc.marketing_preference__c == null)//C0737
        {
            acc.marketing_preference__c = '';//C0737
        }
    
        return acc.marketing_preference__c.containsIgnoreCase(option);//C0737
    }    
    
    
    @RemoteAction
    global static List<BAA_BusinessDetails_Controller.AccountData> findAccount(String findText) {
        
        String[] names = findText.split(' ');
        String findName = '';
        
        for(string s : names)
        {
            findName = findName + s + '%';
        }        
        
        system.debug(findName);
        List<Account> accs = [select id, name, EBS_ID__c,BillingStreet,BillingCity,BillingPostalCode, date_of_birth__c from account
        
                                where  (BillingPostalCode like: findText + '%')
                                or( name like:findName) or (EBS_ID__c like: findText + '%') or (Lastname like: findText +'%'  )
                                 limit 50 ];
        
        List<BAA_BusinessDetails_Controller.AccountData> data = new List<BAA_BusinessDetails_Controller.AccountData>();
        for(Account a : accs)
        {
            BAA_BusinessDetails_Controller.AccountData ad = new BAA_BusinessDetails_Controller.AccountData();
            ad.Name = a.Name;
            ad.Id = a.Id;
            
            ad.Address = '';
            
            if(a.BillingStreet != null)
                ad.Address = ad.Address + a.BillingStreet + ', ';
                
            if(a.BillingCity != null)
                ad.Address = ad.Address + a.BillingCity + ', ';
                
        
                
            if(a.BillingPostalCode != null)
                ad.Address = ad.Address + a.BillingPostalCode + ', ';
            
            
            ad.EbsId = a.EBS_ID__c;
            
            ad.Address = ad.Address.replace('null','');
            
            
            if(ad.EBSId == null)
            {
                ad.EBSId = '';
            }
            
            if(ad.dob != null)
            {
                ad.dob = string.valueof(a.date_of_birth__c) ;
            }
            else
            {
                ad.dob = '';
            }
            data.add(ad);
        }
        return data;
    }
    
    global class AccountData
    {
        public string Name{get;set;}
        public string EBSId{get;set;}
        public string Id{get;set;}
        public string Address{get;set;}
        public string DOB {get;set;}
    }
}