public class HPP_OnlyAssesment extends HPP_ProductSwitch_Core_Controller
{
    
    
    @RemoteAction
    public static CAA_Data.GenericResponse Complete(AssesmentData data, ID oppId )
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        response.Success = true;
        
        return response;
    }
    
    
    
    @RemoteAction
    public static AssesmentDataResponse GetData(ID oppId)
    {
        Opportunity opp = [SELECT id, Customer_prompt_for_execution_only__c,Debt_Consolidation_main_purpose__c, Mortgage_professional__c,
                                                Income_exceed_300k__c, Execution_Only_Reason__c, Require_advice__c, Assets_over_3m__c                             
                            FROM Opportunity
                            WHERE id=: oppId];
                            
        AssesmentDataResponse response = new AssesmentDataResponse();        
        response.Data.Customer_prompt_for_execution_only_c = Opp.Customer_prompt_for_execution_only__c;  
        response.Data.Debt_Consolidation_main_purpose_c = Opp.Debt_Consolidation_main_purpose__c;
        response.Data.Mortgage_professional_c = Opp.Mortgage_professional__c;
        response.Data.Income_exceed_300k_c = Opp.Income_exceed_300k__c;
        response.Data.Assets_over_3m_c = Opp.Assets_over_3m__c;
        response.Data.Execution_Only_Reason_c = Opp.Execution_Only_Reason__c;
        response.Data.Require_advice_c = Opp.Require_advice__c;
        
        response.Success = true;
        return response;
    }
    
    
    public class AssesmentDataResponse extends CAA_Data.GenericResponse
    {
        public AssesmentData Data {get;set;}

        public AssesmentDataResponse ()
        {
            Data = new AssesmentData ();          
        }       
    }
    
    public class AssesmentData
    {
        public String Customer_prompt_for_execution_only_c {get;set;}
        public String Debt_Consolidation_main_purpose_c {get;set;}
        public String Mortgage_professional_c {get;set;}
        public String Income_exceed_300k_c {get;set;}
        public String Assets_over_3m_c {get;set;}
        public String Execution_Only_Reason_c {get;set;}
        public String Require_advice_c {get;set;}
        
        
    }
    
}