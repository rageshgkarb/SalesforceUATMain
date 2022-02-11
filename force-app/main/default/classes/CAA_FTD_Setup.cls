/* ------------------------------------------------------------------------------------	*/
/* C0551	FIT																			*/
/* ------------------------------------------------------------------------------------	*/


public class CAA_FTD_Setup
{
    public static CAA_Data.SetupFTDInitData SetupFTD(Id eventLogId )
    {
        if(CAA_Helper.IsGuestUser())
            return null;
            
        ID oppId = CAA_Helper.GetOppId(eventLogId);
        
        if(oppId == null) return null;
        
        Opportunity opp = [select id,stagename,Initial_Deposit_Received__c  from opportunity 
                            where id=:oppId]; 
                            
                            
        OpportunityTriggerMethods.createRDSAccountSync(opp.id);     
        
        
        //look for account with ibb
        
        Opportunity updatedOpp = [select id,account_with_IBB__r.EBS_ID__c ,  name, Payment_Type_List__c,IBB_Product_Code__c, 
                           Initial_Payment_Amount__c
                                    from opportunity 
                                  where id=:oppId];
                                  
        system.debug('OppData:' + updatedOpp);
                                  
        CAA_Data.SetupFTDInitData returnValue = new CAA_Data.SetupFTDInitData();   
                               
        system.debug('opened account:' + updatedOpp.account_with_IBB__r.EBS_ID__c);                          
        if(string.isNotBlank(updatedOpp.account_with_IBB__r.EBS_ID__c))
        {
            returnValue.FTDCompleted = true;
        
        
            //check to see if we are on next steps
            EventLog__c eventLog = [select id, event__r.name from eventlog__c where id=:eventLogId];
            
            if(eventLog.event__r.name.equalsIgnoreCase('CAA Next Steps'))
            {
                CAA_Helper.CompleteEvent(eventlogId); 
            }
        
            opp.StageName = 'Closed Won';
            opp.Initial_Deposit_Received__c = true;   
            
            OpportunityTriggerMethods.ignoreRDS = true;
            
            update opp;                    
        }                          
        else
        {
            returnValue.FTDCompleted = false;           
        }                                  
                                  
        return returnValue;                               
    
    }

	 // C0551
    public static CAA_Data.SetupFTDInitData SetupFTD(Id eventLogId, UpdateFTDOpportunity theFTDOpp)
                                                    
    {
        if(CAA_Helper.IsGuestUser())
            return null;
            
        ID oppId = CAA_Helper.GetOppId(eventLogId);
        
        if(oppId == null) return null;
        
        Opportunity opp = [select id,stagename,Initial_Deposit_Received__c  from opportunity 
                            where id=:oppId]; 
                            
        //if (callRDS)
        //{                  
            OpportunityTriggerMethods.createRDSAccountSync(opp.id, theFTDOpp);     
        //}
        
        
        //look for account with ibb
        
        Opportunity updatedOpp = [select id,account_with_IBB__r.EBS_ID__c ,  name, Payment_Type_List__c,IBB_Product_Code__c, 
                           Initial_Payment_Amount__c
                                    from opportunity 
                                  where id=:oppId];
                                  
        system.debug('OppData:' + updatedOpp);
                                  
        CAA_Data.SetupFTDInitData returnValue = new CAA_Data.SetupFTDInitData();   
                               
        system.debug('opened account:' + updatedOpp.account_with_IBB__r.EBS_ID__c);                          
        if(string.isNotBlank(updatedOpp.account_with_IBB__r.EBS_ID__c))
        {
            returnValue.FTDCompleted = true;
        
        
            //check to see if we are on next steps
            EventLog__c eventLog = [select id, event__r.name from eventlog__c where id=:eventLogId];
            
            if(eventLog.event__r.name.equalsIgnoreCase('CAA Next Steps'))
            {
                CAA_Helper.CompleteEvent(eventlogId); 
            }
        
            opp.StageName = 'Closed Won';
            opp.Initial_Deposit_Received__c = true;   
            
            OpportunityTriggerMethods.ignoreRDS = true;
            
            update opp;                    
        }                          
        else
        {
            returnValue.FTDCompleted = false;           
        }                                  
                                  
        return returnValue;                               
    
    }
    
    
    public static void UpdateOppDetails(ID eventLogId, CAA_Data.SetupFTDInitData data)
    {
        Opportunity opp = [select id, Initial_payment_date__c, Initial_Payment_Amount__c 
                            from opportunity where id=: CAA_Helper.GetOppId(eventLogId)];
                            
        opp.Initial_Payment_Amount__c = data.PaymentAmount ;
        opp.Initial_payment_date__c = data.PaymentDate.value;
        update opp;
    }
    
    public static List<CAA_Data.SetupFTDInitData> SetupFTDInit(string eventLogId)
    {
        List<CAA_Data.SetupFTDInitData> lst = new List<CAA_Data.SetupFTDInitData>();
    
        Opportunity opp = [select id, Initial_payment_date__c, Initial_Payment_Amount__c ,name, Payment_Type_List__c,IBB_Product_Code__c 
                            from opportunity where id=: CAA_Helper.GetOppId(eventLogId)];    
        
        CAA_Data.SetupFTDInitData data = new CAA_Data.SetupFTDInitData();
        data.PaymentAmount = opp.Initial_Payment_Amount__c ;
        data.PaymentDate = new CAA_Data.MyDate(opp.Initial_payment_date__c);        

        lst.add(data); 
        return lst;
    }
    
    
}