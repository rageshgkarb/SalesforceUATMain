global class Teller_Function_Data
{
    global class Client_CreateCashWithdrawal
    {
        public String CustomerId{get;set;}
        public String AccountId{get;set;}
        public Decimal Value{get;set;}
    }
    
    global virtual class Client_PostCashWithdrawal
    {
        public String PaymentId{get;set;}
    }
    
    global virtual class Client_PostCashWithdrawalAuth extends Client_PostCashWithdrawal
    {
        public String Username{get;set;}
        public String UserId{get;set;}
        public String Password{get;set;}
    }
    
    

    global class Client_CreateCashDeposit
    {
        public String CustomerId{get;set;}
        public String AccountId{get;set;}
        public Decimal Value{get;set;}
        public String Reference{get;set;}
        public String Narrative1{get;set;}
        public String Narrative2{get;set;}
        public String Narrative3{get;set;}
        public String Narrative4{get;set;}
        public String SourceOfFundsType{get;set;}
        public String SourceOfFundsDetail {get;set;}
    }
    
    global class Client_PostCashDeposit
    {
        public String PaymentId{get;set;}
    }

    /*
    global class Client_CreateChequeWithdrawal
    {
        public String CustomerId{get;set;}
        public String AccountId{get;set;}
        public Decimal Value{get;set;}
    }
    
    global class Client_PostChequeWithdrawal
    {
        public String PaymentId{get;set;}
    }

    global class Client_CreateChequeDeposit
    {
        public String CustomerId{get;set;}
        public String AccountId{get;set;}
        public Decimal Value{get;set;}
        public String Reference{get;set;}
        public String Narrative1{get;set;}
        public String Narrative2{get;set;}
        public String Narrative3{get;set;}
        public String Narrative4{get;set;}
    }
    
    global class Client_PostChequeDeposit
    {
        public String PaymentId{get;set;}
    }
*/


    //Cash Deposit
    global class CashDeposit_Create_Result extends IBB_Remoting.GenericResponseBase
    {
        public String PaymentID{get;set;} 
        public String Message{get;set;}      
        public String Stage{get;set;}  
        public CashDeposit_Create_ResultAuth Auth{get;set;}
    }
    
    global class CashDeposit_Create_ResultAuth 
    {
        public String Title{get;set;}
        public Decimal MinValue{get;set;}
        public Decimal MaxValue{get;set;}
        public List<User> AllowedUsers{get;set;}
        public String Error{get;set;}
    }
    
    
    global class CashDeposit_Post_Result extends IBB_Remoting.GenericResponseBase
    {
        public String Message{get;set;}
        public String Error{get;set;}
        public Boolean Success{get;set;}
    }
    
    global class CashDeposit_Post_Request
    {
        public String AccountId{get;set;}
        public String PaymentName{get;set;}
        public Decimal Value{get;set;}
        public ID TransactionId{get;set;}       
    }
    
    
    
    //Cash Withdrawal
    global class CashWithdrawal_Create_Result extends IBB_Remoting.GenericResponseBase
    {
        public String PaymentID{get;set;} 
        public String Message{get;set;}      
        public String Stage{get;set;}  
        public CashWithdraw_Create_ResultAuth Auth{get;set;}
    }
    
    global class CashWithdraw_Create_ResultAuth 
    {
        public String Title{get;set;}
        public Decimal MinValue{get;set;}
        public Decimal MaxValue{get;set;}
        public List<User> AllowedUsers{get;set;}
        public String Error{get;set;}
    }
        
    global class CashWithdrawal_Post_Result extends IBB_Remoting.GenericResponseBase
    {
        public Boolean PaymentSuccessful{get;set;}
        public Boolean PaymentSuccessUnknown{get;set;}   
        public Boolean MangerRequired{get;set;} 
        public String WarningMessage{get;set;}  
        public String InfoMessage{get;set;}

        public Boolean AskForManagerApproval{get;set;}
        public String Message{get;set;}      
        public String Stage{get;set;} 
    }
    
    global class CashWithdrawal_Post_Request
    {
        public String AccountId{get;set;}
        public String PaymentName{get;set;}
        public Decimal Value{get;set;}  
        public String TransactionId{get;set;}      
    }
    
    global class Client_CreateChequeWithdrawal
    {
        public String CustomerId{get;set;}
        public String AccountId{get;set;}
        public Decimal Value{get;set;}
    }
    
    global class Client_PostChequeWithdrawal
    {
        public String PaymentId{get;set;}
    }

    global class Client_CreateChequeDeposit
    {
        public String CustomerId{get;set;}
        public String AccountId{get;set;}
        public Decimal Value{get;set;}
        public String Reference{get;set;}
        public String Narrative1{get;set;}
        public String Narrative2{get;set;}
        public String Narrative3{get;set;}
        public String Narrative4{get;set;}
    }
    
    global class Client_PostChequeDeposit
    {
        public String PaymentId{get;set;}
    }
   
    //Cheque Deposit
    global class ChequeDeposit_Create_Result extends IBB_Remoting.GenericResponseBase
    {
        public String PaymentID{get;set;} 
        public String Message{get;set;}      
        public String Stage{get;set;}  
    }
    
    global class ChequeDeposit_Post_Result extends IBB_Remoting.GenericResponseBase
    {
        public String Message{get;set;}
        public String Error{get;set;}
        public Boolean Success{get;set;}
    }
    
    global class ChequeDeposit_Post_Request
    {
        public String AccountId{get;set;}
        public String PaymentName{get;set;}
        public Decimal Value{get;set;}
        public ID TransactionId{get;set;}       
    }
    
    
    
    //Cheque Withdrawal
    global class ChequeWithdrawal_Create_Result extends IBB_Remoting.GenericResponseBase
    {
        public String PaymentID{get;set;} 
        public String Message{get;set;}      
        public String Stage{get;set;}  
    }
    
    global class ChequeWithdrawal_Post_Result extends IBB_Remoting.GenericResponseBase
    {
        public Boolean PaymentSuccessful{get;set;}
        public Boolean PaymentSuccessUnknown{get;set;}   
        public Boolean MangerRequired{get;set;} 
        public String WarningMessage{get;set;}  
        public String InfoMessage{get;set;}

        public Boolean AskForManagerApproval{get;set;}
        public String Message{get;set;}      
        public String Stage{get;set;} 
    }
    
    global class ChequeWithdrawal_Post_Request
    {
        public String AccountId{get;set;}
        public String PaymentName{get;set;}
        public Decimal Value{get;set;}  
        public String TransactionId{get;set;}      
    }

}