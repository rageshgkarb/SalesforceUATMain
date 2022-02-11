public class TransactionHistory {

    public String objectID {get; set;}  
    public List<Account_with_IBB__c> retrievedObject {get; set;}
    public String ebsID {get; set;}            
    public List<TransactionHistoryItem> tranList { get; set; }
    public String fromDate {get; set;}
    public String toDate {get; set;} 
    public Decimal startingBalance {get; set;}
    public string startingBalanceDisplay {get; set;}
    public string validation {get; set;} 
    public string ebsIdDisplay {get; set;}    
    public boolean isTestRun{get; set;}  
     
    //public CalendarHelper__c cal = new CalendarHelper__c(); 
    public CalendarHelper__c cal{
        get{
            if (cal == null)
                cal = new CalendarHelper__c();
            return cal;            
        }
        set;        
    }    

        public TransactionHistory() 
        {   
            
                isTestRun = false;
                startingBalance = 0;  
                        
                objectID = ApexPages.currentPage().getParameters().get('id');
                
                // Retrieve the associated Account_with_IBB__c object                
               retrievedObject = [Select EBS_ID__c from Account_with_IBB__c where ID = :objectID limit 1];
               if (retrievedObject != null) {
                  ebsID = retrievedObject[0].EBS_ID__c;
                  ebsIdDisplay = ebsID .substring(0,4) + '-' + ebsID .substring(4,10) + '-' + ebsID .substring(10,13);                   
                  
                        
                  tranList = new List<TransactionHistoryItem>();
                  TransactionHistoryWebService thws = new TransactionHistoryWebService();               
                  thws.isTestRun = false;                  
                  tranList = thws.getTransactionHistory(ebsID ,null,null);       
                  if (tranList != null && tranList.size() > 0)
                     calculateStartingBalance(tranList);
               }
            
     }
  
       public TransactionHistory(boolean isTest) 
        {   
            
                isTestRun = true;
                startingBalance = 0;  
                        
                objectID = ApexPages.currentPage().getParameters().get('id');
                
                // Retrieve the associated Account_with_IBB__c object                
               retrievedObject = [Select EBS_ID__c from Account_with_IBB__c where ID = :objectID limit 1];
               if (retrievedObject != null) {
                  ebsID = retrievedObject[0].EBS_ID__c;
                  ebsIdDisplay = ebsID .substring(0,4) + '-' + ebsID .substring(4,10) + '-' + ebsID .substring(10,13);                   
                  
                        
                  tranList = new List<TransactionHistoryItem>();
                  TransactionHistoryWebService thws = new TransactionHistoryWebService();               
                  thws.isTestRun = true;                  
                  tranList = thws.getTransactionHistory(ebsID ,null,null);       
                  if (tranList != null && tranList.size() > 0)
                      calculateStartingBalance(tranList);
               }
            
     }
   
     
      public PageReference clearDates() {
           PageReference pageRef = null;
           pageRef = new PageReference('/apex/TransactionHistory?id=' + ApexPages.currentPage().getParameters().get('id'));
           pageRef.setredirect(true);
           return PageRef;       
        
     }
      
      public PageReference retrieveTransactionHistory() {
        startingBalance = 0;
        startingBalanceDisplay = ''; 
        tranList = null;       
        string tempFrom = null;
        string tempTo = null;
        boolean passedValidation = true; 
  
 
        // If From Date entered and To Date left blank, default it to today   
        if (cal.Date_From__c != null && cal.Date_To__c == null){
            cal.Date_To__c = Date.today(); 
        }                     
 
        // If To Date entered, From Date must also be entered
        if (cal.Date_From__c == null && cal.Date_To__c != null)  {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Date From must be entered'));
            passedValidation = false;       
        }
                
        // "Date From" must be less than or equal to "Date To"
        if (passedValidation &&(cal.Date_From__c > cal.Date_To__c)){
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Date From cannot be after Date To'));
           passedValidation = false;
           
        }        
        // "Date To" cannot be after today
        if (passedValidation && (cal.Date_To__c > Date.today())) {
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Date To cannot be after today'));
            passedValidation = false;       
        }   
              
        // "Date From" cannot be more than a year ago from today
        if (passedValidation && (cal.Date_From__c < Date.today().addMonths(-12))) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Date From cannot be more than a year ago'));
            passedValidation = false;       
        }              
        
        if (passedValidation){        
            if ((cal.Date_From__c != null) && (cal.Date_To__c != null)){
                 tempFrom= cal.Date_From__c.format();
                 // Switch dates over to ISO format
                 fromDate = tempFrom.substring(6,10) + '-' + tempFrom.substring(3,5) + '-' + tempFrom.substring(0,2);                              
                 tempTo= cal.Date_To__c.format();
                 toDate = tempTo.substring(6,10) + '-' + tempTo.substring(3,5) + '-' + tempTo.substring(0,2); 
            } 

                        
            tranList = new List<TransactionHistoryItem>();
            TransactionHistoryWebService thws = new TransactionHistoryWebService();               
            thws.isTestRun = isTestRun;       
            tranList = thws.getTransactionHistory(ebsId,fromDate,toDate); 
            if (tranList != null && tranList.size() > 0)            
                calculateStartingBalance(tranList);
        } 
     
        return null;
      
    }
        public PageReference redirectAccountWithIBB() {
            PageReference pageRef = null;
            pageRef = new PageReference('/' + objectID);
            return PageRef;      

        }
         
   
        public String calculateStartingBalance(List<TransactionHistoryItem> retrievedList){

                if (retrievedList.size() == 0) {
                    startingBalanceDisplay = '0.00';        
                    return startingBalanceDisplay ;   
                } else {                
                    TransactionHistoryItem firstItem = new TransactionHistoryItem();
                    firstItem = retrievedList.get(0);               
                    if (firstItem.itemCredit != null) {
                        startingBalance = firstItem.itemRunningBalance - firstItem.itemCredit;  
                    } else {
                        if (firstItem.itemDebit != null) { 
                            startingBalance = firstItem.itemRunningBalance - firstItem.itemDebit;
                        }
                    } 

                    startingBalanceDisplay = startingBalance.toPlainString();
                    return startingBalanceDisplay;              
                }            

        
        }   
   }