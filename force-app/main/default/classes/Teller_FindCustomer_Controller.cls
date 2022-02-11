/* --------------------------------------------------------------------------------------------- */
/* C0560	Possible change for replication changes												 */
/* --------------------------------------------------------------------------------------------- */

global class Teller_FindCustomer_Controller
{       
    //LB - static flag that allows customers without an EBS Id to be returned
    public static Boolean AllCustomers = false;

    //SAJ - Method to get the account holder information by list of account numbers
    global static Map<String, List<CustomerItem>> FindCustomerByAccountNumbers(List<String> accountNumbers)
    {
        Map<String, List<CustomerItem>> customers = new Map<String, List<CustomerItem>>();
       
	    // C0560 
        //String soql = 'select Prospect_Customer__c, Prospect_Customer__r.Name,  Prospect_Customer__r.EBS_ID__c, Account_With_IBB__r.Name, Prospect_Customer__r.BillingStreet, Prospect_Customer__r.BillingCity, Prospect_Customer__r.BillingPostalCode, Prospect_Customer__r.date_of_birth__c  from Asset_Relationship__c where Account_with_IBB_Number__c in (';
		String soql = 'select Prospect_Customer__c, Prospect_Customer__r.Name,  Prospect_Customer__r.EBS_ID__c, Account_With_IBB__r.Name, Prospect_Customer__r.BillingStreet, Prospect_Customer__r.BillingCity, Prospect_Customer__r.BillingPostalCode, Prospect_Customer__r.date_of_birth__c  from Asset_Relationship__c where Is_Active__c = true and Account_with_IBB_Number__c in (';

        String accList = '';
        
        Iterator<String> iterAcc = accountNumbers.iterator();
        while(iterAcc.hasNext())
        {
            accList += '\'' +  iterAcc.Next() + '\'';
            if(iterAcc.hasNext())
            {
                accList += ',';
            }
        }
        
        if(accList != '')
        {
            soql += accList + ')';
        }
        
        List<Asset_Relationship__c> assets = Database.query(soql);
        
        if(assets != null && assets.isEmpty() == false)
        {
            Map<String, String> uniqueCustIds = new Map<String, String>();
                        
            for(Asset_Relationship__c asset : assets)           
            {
                CustomerItem c = BuildCustomerDataFromAssetRelationship(asset);
                
                if(customers.containsKey(c.AccountWithIBBName))
                {
                    customers.get(c.AccountWithIBBName).add(c);
                }
                else
                {
                    customers.put(c.AccountWithIBBName, new List<CustomerItem> {c});
                }
                
                if(!uniqueCustIds.containsKey(c.Id))
                {
                    uniqueCustIds.put(c.Id, c.Id);
                }
            }
            
            if(!uniqueCustIds.isEmpty())
            {               
                CustomerImages ci = new CustomerImages();
                Map<String, String> images = ci.CurrentImageURLs(uniqueCustIds.values());
                
                if(!images.isEmpty())
                {
                    for(List<CustomerItem> accountHolders : customers.values())
                    {
                        for(CustomerItem ah : accountHolders)
                        {
                            String imageUrl = images.get(ah.Id);        
                            if(imageUrl != null)
                            {
                                ah.ImageURL = imageUrl.Replace('"', '');
                            }
                            else
                            {
                                ah.ImageURL = 'null';
                            }
                        }                       
                    }
                }
            }
            
            return customers;
        }
        else
        {
            return customers;
        }
    }
    
    global static CustomerItem BuildCustomerDataFromAssetRelationship(Asset_Relationship__c a)
    {
        CustomerItem item = new CustomerItem();                
        item.name = a.Prospect_Customer__r.Name;            
        item.id = a.Prospect_Customer__c;
        item.Address = '';
        
        if(a.Prospect_Customer__r.BillingStreet != null)
            item.Address = item .Address + a.Prospect_Customer__r.BillingStreet + ', ';
                    
        if(a.Prospect_Customer__r.BillingCity != null)
            item.Address = item .Address + a.Prospect_Customer__r.BillingCity + ', ';
        
        if(a.Prospect_Customer__r.BillingPostalCode != null)
            item.Address = item.Address + a.Prospect_Customer__r.BillingPostalCode + ', ';
                    
        item.Address = item.Address.replace('null',''); 

        if(a.Prospect_Customer__r.date_of_birth__c != null)
        {
            item.dob = string.valueof(a.Prospect_Customer__r.date_of_birth__c) ;
        }
        else
        {
            item.dob = '';
        }       
        
        item.AccountWithIBBName = a.Account_with_IBB__r.Name;
        if(a.Prospect_Customer__r.EBS_ID__c == null)
        {
            item.EBSId = '';
        }
        else
        {
            item.EBSId = a.Prospect_Customer__r.EBS_ID__c;
        }
        
        item.PostCode = a.Prospect_Customer__r.BillingPostalCode;
        
        return item;
    }   
    
    @RemoteAction
    global static CustomerData FindCustomer(String findText)
    {   
        findText = String.escapeSingleQuotes(findText);
        String[] names = findText.split(' ');
        String findName = '';
        
        for(string s : names)
        {
            findName = findName + s + '%';
        }        
        
        system.debug(findName);

        CustomerData data = new CustomerData(); 
        Boolean searchforPostcode = false;

        //checking for A1
        if(findText.length() == 2)
        {
            if(!findText.substring(0,1).IsNumeric())
            {
                if(findText.substring(1,2).IsNumeric())
                {
                    searchforPostcode = true;
                }
            }
        }
        else
        {
            if(findText.length() >= 3)
            {
                if(!findText.substring(0,1).IsNumeric())
                {
                    //A1xxx
                    if(findText.substring(1,2).IsNumeric())
                    {
                        searchforPostcode = true;                       
                    }
                    else
                    {
                        //AA1
                        if(findText.substring(2,3).IsNumeric())
                        {
                            searchforPostcode = true;
                        }
                    }                
                }
            }
        }


        String soql = 'select id, name, EBS_ID__c,BillingStreet,BillingCity,BillingPostalCode, date_of_birth__c from account  ';

        if(searchforPostcode)
        {
            soql += 'where BillingPostalCode like \'' + findText + '%\'';
        
            if(!AllCustomers )
                soql += ' and EBS_ID__c != null ';
            
            data.IsPostcodeSearch = true;
        }
        else
        {
            if(findText.isNumeric())
            {
                boolean MatchFound = false;

                if(findText.length() == 6 )
                {
                    //looking for customer or account numbers
                    soql += 'where EBS_ID__c = \'' + findText +'\''; 
                    data.IsAccountSearch = true;   
                    data.AccountFieldSearched = 'Customer ID';                 
                    MatchFound = true;
                }

                if(findText.length() == 8)
                {
					// C0560 
                    //List<Asset_Relationship__c> assets = [select Prospect_Customer__c from Asset_Relationship__c where Account_with_IBB__r.External_Account_Number__c =: findText ];
					List<Asset_Relationship__c> assets = [select Prospect_Customer__c from Asset_Relationship__c where is_active__c = true and Account_with_IBB__r.External_Account_Number__c =: findText ];

                    if(assets.isEmpty())
                    {
                        //looking for customer or account numbers
                        soql += 'where id in (select Primary_SFDC_Account__c from Account_with_IBB__c where External_Account_Number__c = \'' + findText + '\')'; 
                    }
                    else
                    {
                        //looking for customer or account numbers
                        soql += 'where id in (select Prospect_Customer__c from Asset_Relationship__c where '+
							' Is_Active__c = true and ' +		// C0560
                            'Account_with_IBB__r.External_Account_Number__c = \'' + findText + '\')';  
                    }
                    
                    data.AccountFieldSearched = 'External Account Number'; 
                    MatchFound = true;                         
                }

                if(findText.length() == 13)
                {
                    List<Asset_Relationship__c> assets = [select Prospect_Customer__c from Asset_Relationship__c where Account_with_IBB_Number__c =: findText ];
                    if(assets.isEmpty())
                    {
                        //looking for customer or account numbers
                        soql += 'where id in (select Primary_SFDC_Account__c from Account_with_IBB__c where Name = \'' + findText + '\')'; 
                    }
                    else
                    {
                        //looking for customer or account numbers
                        soql += 'where id in (select Prospect_Customer__c from Asset_Relationship__c where '+
							' Is_Active__c = true and ' +		// C0560
                            'Account_with_IBB_Number__c = \'' + findText + '\')'; 
                    }
                    
                    data.AccountFieldSearched = 'Internal Account Number';   
                    MatchFound = true;               
                }

                if(!MatchFound)
                    soql = null;
                
            }
            else
            {
                //looking for names
                soql += 'where (name like \'' + findText + '%\' or lastname like \'' + findText + '%\' or middle_name__pc like \'' + findText + '%\' )'; 
                
                if(!AllCustomers)
                    soql += ' and EBS_ID__c != null ';
                    
                soql += 'order by lastname, name';
                
                data.IsNameSearch = true;
            }
        }
         

        system.debug('Find Customer:' + soql);
        
        if(soql != null)
        {
            soql += '  limit 25';
            List<Account> accs = Database.query(soql);
            /* [select id, name, EBS_ID__c,BillingStreet,BillingCity,BillingPostalCode, date_of_birth__c from account
            
                                    where ( (BillingPostalCode like: findText + '%')
                                    or( name like:findName) or (EBS_ID__c like: findText + '%') or (Lastname like: findText +'%'  )) and EBS_ID__c != null
                                     limit 50 ];*/
                                     
            System.debug ('The number of accounts ' + accs.size());      
            List<String> accountList = new List<String>();
            for(Account a : accs)
            {
                accountList.add(a.id);
                
                CustomerItem item = new CustomerItem();
                
                item.name = a.name;            
                item.id = a.id;
                item .Address = '';
                
                if(a.BillingStreet != null)
                    item .Address = item .Address + a.BillingStreet + ', ';
                    
                if(a.BillingCity != null)
                    item .Address = item .Address + a.BillingCity + ', ';
                    
            
                    
                if(a.BillingPostalCode != null)
                    item.Address = item.Address + a.BillingPostalCode + ', ';
                    
                item.Address = item.Address.replace('null','');    
                
                if(a.date_of_birth__c != null)
                {
                    item.dob = string.valueof(a.date_of_birth__c) ;
                }
                else
                {
                    item.dob = '';
                }
                
                if(a.EBS_Id__c == null)
                {
                    item.EBSId = '';
                }
                else
                {
                    item.EBSId = a.EBS_Id__c;
                }

                item.PostCode = a.BillingPostalCode;
                
                //CustomerImages ci = new CustomerImages();
                //item.ImageURL = ci.CurrentImageURL(a.id);
                //item.ImageURL = item.ImageURL.Replace('"', '');
                
                //CustomerImages.CustomerIdentityImages images = ci.GetCustomerImages(a.Id);
                //item.ImageURL = images.ImageURL;   
                //item.ImageURL = item.ImageURL.Replace('"', '');

                data.Items.add(item);    
            }    
            
            //SAJ - Logic to get bulk customer images for accounts, to correct SOQL 101 error on account summary call
            CustomerImages ci = new CustomerImages();
            Map<String, String> images = ci.CurrentImageURLs(accountList);  
            for(CustomerItem custItem : data.Items)
            {
                String imageUrl = images.get(custItem.Id);      
                if(imageUrl != null)
                {
                    custItem.ImageURL = imageUrl.Replace('"', '');
                }
                else
                {
                    custItem.ImageURL = 'null';
                }
            }
        }      
        data.total = data.Items.size();       
        return data;               
         
    }
    
    global class CustomerData 
    {
        public List<CustomerItem> Items{get;set;}
        public Integer total{get;set;}
        public Boolean IsPostcodeSearch{get;set;}
        public Boolean IsAccountSearch{get;set;}
        public Boolean IsNameSearch{get;set;}
        public String AccountFieldSearched{get;set;}


        
        public CustomerData()
        {
            Items = new List<CustomerItem>();            
        }
    }
    
    global class CustomerItem
    {
        public String Id{get;set;}
        public String Name{get;set;}
        public String EBSId{get;set;}
        public String PostCode{get;set;}
        public String Address{get;set;}
        public String DOB{get;set;}
        public String AccountSearch{get;set;}
        public String ImageURL;
        public String AccountWithIBBName {get;Set;}        
    }
    
}