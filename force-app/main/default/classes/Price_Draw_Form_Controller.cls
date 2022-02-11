//C0685
public without sharing class Price_Draw_Form_Controller 
{
    public String Title{get;set;}
    public String FirstName{get;set;}
    public String LastName{get;set;}
        public String Telephonenum{get;set;}
        public String Mobilenum{get;set;}
        public Date DOB{get;set;}
        public String EmailAddr{get;set;}
        public String FullAddress{get;set;}
        public String city{get;set;}
        public String Postcode{get;set;}

        public Boolean HasEmail{get;set;}
        public Boolean HasMail{get;set;}
        public Boolean HasPhone{get;set;}
        public Boolean HasSMS{get;set;}
        public Boolean AnyMethod{get;set;}
        public Boolean HasENewletter{get;set;}
        public Boolean HasPost{get;set;}
        public Boolean HasNoContact{get;set;}
     
        public Boolean CurrentAccount{get;set;}
        public Boolean SavingsAccount{get;set;}
        public Boolean PropertyFinance{get;set;}
        public Boolean AreYouAlRayanBankCustomer{get;set;}
        public Lead leaddob {get; set;}
        public String campaignname{get;set;}
        public Id campaignid{get;set;}
        public string callscript{get;set;}
        public string AdditiolComments{get;set;}


    public List<SelectOption> getTitles() 
         {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Mr','Mr'));
            options.add(new SelectOption('Mrs','Mrs'));
            options.add(new SelectOption('Miss','Miss'));
            options.add(new SelectOption('Ms','Ms'));
            options.add(new SelectOption('Dr','Dr'));
                        options.add(new SelectOption('Master','Master'));            
            options.add(new SelectOption('Other','Other'));
            options.add(new SelectOption('Prof','Prof'));
            options.add(new SelectOption('Sheikh','Sheikh'));
            return options;
    }

    public Price_Draw_Form_Controller () 
        {
                campaignname = apexpages.currentpage().getparameters().get('att');
                leaddob = new Lead();
                Campaign camp = [select id from Campaign where name = :campaignname and type = 'Events' and IsActive= true limit 1];
                campaignid = camp.Id;
                system.debug('Campaign id *****' +campaignid ); 

    }
    
        public RecordType recTypeLead 
    {
        get 
        {
            if (recTypeLead == null){            
                recTypeLead = [select id from recordType where sobjectType = 'lead' and DeveloperName = 'Event' limit 1];
            }
            return recTypeLead ;
        }
        set;
        }

        private Date setStringToDateFormat(String myDate) 
        {
           String[] myDateOnly = myDate.split(' ');
           String[] strDate = myDateOnly[0].split('/');
           Integer myIntDate = integer.valueOf(strDate[1]);
           Integer myIntMonth = integer.valueOf(strDate[0]);
           Integer myIntYear = integer.valueOf(strDate[2]);
           Date d = Date.newInstance(myIntYear, myIntMonth, myIntDate);
           return d;
        }

        public PageReference Setup()
        {
         FirstName = '';
         LastName = '';
         Telephonenum = '';
         Mobilenum = '';
         AreYouAlRayanBankCustomer = false;
         FullAddress = '';
         city = '';
         Postcode = '';
         EmailAddr = '';
         CurrentAccount = false;
         SavingsAccount = false;
         PropertyFinance = false;
         HasENewletter = false;
         HasPost= false;
         HasEmail = false;
         //HasMail = false;
         HasPhone = false;
         HasSMS = false;
         HasNoContact = false;
         
         
        // AnyMethod = false;
         return null;
        }
        
        public Boolean Validate()
        {
                if (String.isBlank(FirstName) || String.isBlank(LastName) || String.isBlank(Telephonenum) || String.isBlank(Mobilenum) || String.isBlank(FullAddress) 
                || String.isBlank(city) || String.isBlank(Postcode) || String.isBlank(EmailAddr) || (leaddob.Date_of_Birth__c == null))
                {
                          String msg = 'Please enter all the mandatory fields highlighted in red.'  ;
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                          ApexPages.addMessage(myMsg);
                          return true;
                }
                else if (Telephonenum.length()<11 || Mobilenum.length()<11)
                {
                          String msg = 'Phone Numbers should be 11 Digits atleast'; 
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                          ApexPages.addMessage(myMsg);
                          return true;
                }
                else if (leaddob.Date_of_Birth__c.year() + 18 > System.Today().year())
                {
                          String msg = 'You should be minimum of 18 Years.'; 
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                          ApexPages.addMessage(myMsg);
                          return true;
                }
                else if (String.isNotBlank(Telephonenum) && (!Telephonenum.isNumeric()))
                {
                          String msg = 'Telephone number must be numeric only.'; 
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                          ApexPages.addMessage(myMsg);
                          return true;
                }               
                else if (String.isNotBlank(Mobilenum) && (!Mobilenum.isNumeric()))
                {
                          String msg = 'Please make sure you have selected a numeric value for the Mobile number. Remove spaces and any special charcters.';// Modify by Zensar
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                          ApexPages.addMessage(myMsg);
                          return true;
                }
                //else if (String.isNotBlank(EmailAddr) && (!Pattern.matches('[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\\.[a-zA-Z]{2,4}', EmailAddr)))
                //C0737
                else if (String.isNotBlank(EmailAddr) && (!Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})', EmailAddr)))
                {
                          String msg = 'Please enter a valid email address.'  ;
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                          ApexPages.addMessage(myMsg);
                          return true;            
                }
                else if (CurrentAccount == false && SavingsAccount == false && PropertyFinance == false)
                {
                          String msg = 'Please select interested in.'  ;
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                          ApexPages.addMessage(myMsg);
                          return true;   
                }
                else if (HasEmail == false && HasMail == false && HasPhone == false && HasSMS == false && AnyMethod == false)
                {
                          String msg = 'Please select methods you do not wish to be contacted by.'  ;
                          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                          ApexPages.addMessage(myMsg);
                          return true;  
                }
        /*else if
                {
                        List<Lead> leads = [select id, lastname,firstname,Date_of_Birth__c  from lead where lastname=:LastNameName and firstname=:FirstName and Date_of_Birth__c =:DOB ];
                        LeadsFound = new List<Lead>();
                        for(Lead a : leads)
                        {
                                        String msg = 'Combination of first name, last name and data of birth already exist.  Id : ' + a.id ;
                                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                                        ApexPages.addMessage(myMsg);
                                        LeadsFound.add(a); 
                        }
                }*/
                // C0737 Start -->
                if(!HasENewletter && !HasEmail && !HasPost && !HasSMS && !HasPhone && !HasNoContact){
                     String msg = 'Please select a marketing preference, we cannot proceed with your application without capturing this information.';
                     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, msg);
                     ApexPages.addMessage(myMsg);
                     return true;
                }
                // C0737 End -->
                        return false;
        }
    public PageReference RedirectFunc(){
         FirstName = '';
                         LastName = '';
                         Telephonenum = '';
                         Mobilenum = '';
                         AreYouAlRayanBankCustomer = false;
                         FullAddress = '';
                         city = '';
                         Postcode = '';
                         EmailAddr = '';
                         leaddob.Date_of_Birth__c = null;
                         CurrentAccount = false;
                         SavingsAccount = false;
                         PropertyFinance = false;
                         HasENewletter = false;
                         HasEmail = false;
                         HasMail = false;
                         HasPhone = false;
                         HasSMS = false;
                         AnyMethod = false;
                         AdditiolComments = '';
    
        system.debug('----->');
        pagereference datacollectionform = new pagereference('/apex/data_collection_form?att='+ campaignname);
        datacollectionform.setRedirect(true);
        system.debug('---===-->'+datacollectionform);
        return datacollectionform;
    }
    public PageReference Save()
    { 
               
                if (!Validate() && campaignid != Null)
                {
                     Lead l = new Lead();
                         l.Salutation = Title;
                         l.firstname = FirstName;
                         l.lastname = LastName;
                         l.Phone = Telephonenum;
                         l.MobilePhone = Mobilenum;
                         l.Date_of_Birth__c = leaddob.Date_of_Birth__c;
                         l.Are_you_Al_Rayan_Bank_customer__c = AreYouAlRayanBankCustomer;
                         l.Street = FullAddress;
                         l.City = city;
                        // l.Postcode__c = Postcode;
                         l.PostalCode = Postcode.touppercase();
                         l.Email = EmailAddr;
                         l.Current_Account__c = CurrentAccount;
                         l.Savings_Account__c = SavingsAccount;
                         l.Property_Finance__c = PropertyFinance;
                         l.E_Newsletter__c = HasENewletter; //Modify by Zensar
                         l.Post__c = HasPost; //Modify by Zensar
                         l.Email_Option__c = HasEmail;
                       //  l.Mail_Option__c = HasMail;
                         l.Telephone_Option__c = HasPhone;
                         l.SMS_Option__c = HasSMS;
                       //  l.Any_Method__c = AnyMethod;
                         l.No_Contact__c = HasNoContact; 
                         l.RecordTypeId = recTypeLead.Id ;
                         l.Primary_Source_Campaign__c = campaignid;
                         l.Additional_Comments__c = AdditiolComments;
                         insert l;
                         
                         callscript='<script> scriptcalling(); </script>';
                         return null;
    /*
                         FirstName = '';
                         LastName = '';
                         Telephonenum = '';
                         Mobilenum = '';
                         AreYouAlRayanBankCustomer = false;
                         FullAddress = '';
                         city = '';
                         Postcode = '';
                         EmailAddr = '';
                         leaddob.Date_of_Birth__c = null;
                         CurrentAccount = false;
                         SavingsAccount = false;
                         PropertyFinance = false;
                         HasENewletter = false;
                         HasEmail = false;
                         HasMail = false;
                         HasPhone = false;
                         HasSMS = false;
                         AnyMethod = false;

                        // return null;  
                
    
                pagereference datacollectionform = new pagereference('/apex/data_collection_form?att='+ campaignname);
                datacollectionform.setRedirect(true);
                return datacollectionform;  */
                 }
                 
                else
                {
                        return null;
                }
               
                
        }
    
    public PageReference back()
        {
        pagereference datacollectionform = new pagereference('/apex/data_collection_form?att='+ campaignname);
                datacollectionform.setRedirect(true);
                return datacollectionform;
    }
}