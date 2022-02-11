@isTest (SeeAllData=true)
public class TransactionHistoryWebService_Test {

    static testMethod void TestOne()
    
        {
           List<TransactionHistoryItem> itemList = new List<TransactionHistoryItem>();
           String accountId = '1100401304001';
           String fromDate = '2012-01-01';
           String toDate = '2012-04-27';  
           TransactionHistoryWebService thws = new TransactionHistoryWebService(); 
           thws.isTestRun = true;      
           itemList =  thws.getTransactionHistory(accountId , fromDate, toDate);
           
        }

    static testMethod void TestTwo()
    
        {
           List<TransactionHistoryItem> itemList = new List<TransactionHistoryItem>();
           String accountId = '11004000000001';  // non-existent account
           String fromDate = '2012-01-01';
           String toDate = '2012-04-27';  
           TransactionHistoryWebService thws = new TransactionHistoryWebService(); 
           thws.isTestRun = true;                                
           itemList =  thws.getTransactionHistory(accountId , fromDate, toDate);
           
        }
 
   static testMethod void TestThree()
    
        {
           List<TransactionHistoryItem> itemList = new List<TransactionHistoryItem>();
           String accountId = '1100401304001';  // valid account but no data for these dates
           String fromDate = '2012-03-03';    
           String toDate = '2012-03-03';  
           TransactionHistoryWebService thws = new TransactionHistoryWebService(); 
           thws.isTestRun = true;                                
           itemList =  thws.getTransactionHistory(accountId , fromDate, toDate);
           
        }



}