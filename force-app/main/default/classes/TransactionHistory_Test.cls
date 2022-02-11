@isTest (SeeAllData=true)
public class TransactionHistory_Test {


    static testMethod void TestOne()                                         // Test retrieveTransactionHistory() 
    
        {
           Account_with_IBB__c acc = [Select Id, EBS_ID__c from Account_with_IBB__c where EBS_ID__c = '1100401304001' limit 1]; 
           ApexPages.StandardController std = new ApexPages.StandardController(acc);
           PageReference ref = Page.TransactionHistory;
           Test.setCurrentPage(ref);
           
           Apexpages.currentPage().getParameters().put('id',acc.Id);               
           String objectID = ApexPages.currentPage().getParameters().get('id');
           
           List<Account_with_IBB__c> retrievedObject = [Select EBS_ID__c from Account_with_IBB__c where ID = :objectID limit 1];
           String ebsID = retrievedObject[0].EBS_ID__c; 
           String ebsIdDisplay = ebsID .substring(0,4) + '-' + ebsID .substring(4,10) + '-' + ebsID .substring(10,13);                   
                
                        
           List<TransactionHistoryItem> tranList = new List<TransactionHistoryItem>();                     
           TransactionHistory th = new TransactionHistory(true);
           CalendarHelper__c cal = new CalendarHelper__c();           
           cal.Date_From__c = Date.NewInstance(2012,1,1);
           cal.Date_To__c = Date.NewInstance(2012,2,1);       
           ref = th.retrieveTransactionHistory(); 
           
          
        }
        

    static testMethod void TestTwo()  
                                            // Test calculateStartingBalance()  
   {   
 
        Account_with_IBB__c acc = [Select Id, EBS_ID__c from Account_with_IBB__c where EBS_ID__c = '1100401304001' limit 1]; 
        ApexPages.StandardController std = new ApexPages.StandardController(acc);
        PageReference ref = Page.TransactionHistory;
        Test.setCurrentPage(ref);
           
        Apexpages.currentPage().getParameters().put('id',acc.Id);               
        String objectID = ApexPages.currentPage().getParameters().get('id');
           
        List<Account_with_IBB__c> retrievedObject = [Select EBS_ID__c from Account_with_IBB__c where ID = :objectID limit 1];
        String ebsID = retrievedObject[0].EBS_ID__c; 
        String ebsIdDisplay = ebsID .substring(0,4) + '-' + ebsID .substring(4,10) + '-' + ebsID .substring(10,13); 
 
        TransactionHistory th = new TransactionHistory(true);     
        List<TransactionHistoryItem> tranList = new List<TransactionHistoryItem>();
        TransactionHistoryItem item1 = new TransactionHistoryItem();    
        item1.itemDebit = -50.00;
        item1.itemRunningBalance = 400.00;
        tranList.add(item1);
        String result = th.calculateStartingBalance(tranList);
        
        List<TransactionHistoryItem> tranList2 = new List<TransactionHistoryItem>(); 
        TransactionHistoryItem item2 = new TransactionHistoryItem();
        item2.itemCredit = 50.00;
        item2.itemRunningBalance = 400.00;
        tranList2.add(item2);
        result = th.calculateStartingBalance(tranList2);

}

   static testMethod void TestThree()                                         // Test Validation 
    
        {
           Account_with_IBB__c acc = [Select Id, EBS_ID__c from Account_with_IBB__c where EBS_ID__c = '1100401304001' limit 1]; 
           ApexPages.StandardController std = new ApexPages.StandardController(acc);
           PageReference ref = Page.TransactionHistory;
           Test.setCurrentPage(ref);
           
           Apexpages.currentPage().getParameters().put('id',acc.Id);               
           String objectID = ApexPages.currentPage().getParameters().get('id');
           
           List<Account_with_IBB__c> retrievedObject = [Select EBS_ID__c from Account_with_IBB__c where ID = :objectID limit 1];
           String ebsID = retrievedObject[0].EBS_ID__c; 
           String ebsIdDisplay = ebsID .substring(0,4) + '-' + ebsID .substring(4,10) + '-' + ebsID .substring(10,13);                   
                
                        
           // From Date entered, To Date not entered
           List<TransactionHistoryItem> tranList = new List<TransactionHistoryItem>();                     
           TransactionHistory th = new TransactionHistory(true);
           //CalendarHelper__c cal = new CalendarHelper__c();           
           th.cal.Date_From__c = Date.NewInstance(2012,1,1);
           th.cal.Date_To__c = null;       
           ref = th.retrieveTransactionHistory(); 
 
           // From Date not entered, To Date entered
           List<TransactionHistoryItem> tranList2 = new List<TransactionHistoryItem>();                     
           TransactionHistory th2 = new TransactionHistory(true);
           th2.cal.Date_From__c = null;
           th2.cal.Date_To__c = Date.NewInstance(2012,3,1);       
           ref = th2.retrieveTransactionHistory(); 

          // From Date > To Date 
           List<TransactionHistoryItem> tranList3 = new List<TransactionHistoryItem>();                     
           TransactionHistory th3 = new TransactionHistory(true);
           th3.cal.Date_From__c = Date.NewInstance(2012,5,1); 
           th3.cal.Date_To__c = Date.NewInstance(2012,3,1);       
           ref = th3.retrieveTransactionHistory(); 

        // To Date > Today 
           List<TransactionHistoryItem> tranList4 = new List<TransactionHistoryItem>();                     
           TransactionHistory th4 = new TransactionHistory(true);
           th4.cal.Date_From__c = Date.NewInstance(2012,5,1); 
           th4.cal.Date_To__c = Date.Today().AddMonths(1);
           ref = th4.retrieveTransactionHistory(); 

       // From Date over a Year ago 
           List<TransactionHistoryItem> tranList5 = new List<TransactionHistoryItem>();                     
           TransactionHistory th5 = new TransactionHistory(true);
           th5.cal.Date_From__c = Date.Today().AddMonths(-13); 
           th5.cal.Date_To__c = Date.Today();
           ref = th5.retrieveTransactionHistory(); 

         
          
        }


  static testMethod void TestFour()                                         // Test redirectAccountWithIBB
    
        {
           Account_with_IBB__c acc = [Select Id, EBS_ID__c from Account_with_IBB__c where EBS_ID__c = '1100401304001' limit 1]; 
           ApexPages.StandardController std = new ApexPages.StandardController(acc);
           PageReference ref = Page.TransactionHistory;
           Test.setCurrentPage(ref);
           
           Apexpages.currentPage().getParameters().put('id',acc.Id);               
           String objectID = ApexPages.currentPage().getParameters().get('id');
           List<TransactionHistoryItem> tranList = new List<TransactionHistoryItem>();  
           TransactionHistory th = new TransactionHistory(true);
           PageReference pageRef = th.redirectAccountWithIBB();            
        }
}