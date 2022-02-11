public class HPP_ProductSwitch_Suit extends HPP_ProductSwitch_Core_Controller
{/*
    public HPP_ProductSwitch_Suit ()
    {
        
    }
    
    public PageReference Setup()
    {
        IBBDependentObjectFactory.CreateRCEStubs (DataHelper.GetOpportunity(opp.id)[0]);
        return null;
    }
   */ 
    @RemoteAction
    public static void CreateStubs(string oppId)
    {
        IBBDependentObjectFactory.CreateRCEStubs (DataHelper.GetOpportunity(oppid)[0]);
    }
    
    @RemoteAction
    public static CAA_Data.GenericResponse RunRCE(ID oppId)
    {
        return HPP_ProductSwitch.RunRCE(oppId);
    }

    @RemoteAction
    public static HPP_ProductSwitch.ProductSwitchDataResponse  GetProductData(ID oppId)
    {
        return HPP_ProductSwitch.GetData(oppId);
    }
    
    @RemoteAction
    public static CAA_Data.GenericResponse UpdateProduct(ID oppId, Id productId) 
    {
        return HPP_ProductSwitch.UpdateProduct(oppId,productId,'Advice');
    }
    
    @RemoteAction
    public static HPP_ProductSwitch.CreateDocumentResponse GenerateFIS(ID oppId, ID docugenId)
    {
        return HPP_ProductSwitch.GenerateFIS(oppId,docugenId);
    }
    
    @RemoteAction
    public static CAA_Data.GenericResponse Complete(SuitabilityData data, ID oppId, ID eventLogId)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
    
        Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
        opp.Sharia_compliant_products__c = data.Sharia_compliant_products_c;
        opp.Letter_sharia_compliant__c  = data.Letter_sharia_compliant_c;
        opp.Stability_in_payments__c  = data.Stability_in_payments_c;
        opp.Letter_payment_stability__c = data.Letter_payment_stability_c;
        opp.No_early_repayment_charges__c = data.No_early_repayment_charges_c;
        opp.Letter_Early_Repayment__c = data.Letter_Early_Repayment_c;
        opp.Lump_sum_payments__c = data.Lump_sum_payments_c;
        opp.Letter_lump_sum__c = data.Letter_lump_sum_c;
        opp.Payments_low_as_possible__c = data.Payments_low_as_possible_c;
        opp.Letter_low_payments__c = data.Letter_low_payments_c;
        opp.Income_change__c = data.Income_change_c;
        opp.Letter_income_change__c = data.Letter_income_change_c;
        opp.Payments_increased__c = data.Payments_increased_c;
        opp.Letter_payments_increased__c = data.Letter_payments_increased_c;
        opp.Expenditure_change__c = data.Expenditure_change_c;
        opp.Letter_expenditure_change__c = data.Letter_expenditure_change_c;
        opp.Moving_house_soon__c = data.Moving_house_soon_c;
        opp.Letter_moving_house__c = data.Letter_moving_house_c;
        opp.Term_in_mind__c = data.Term_in_mind_c;
        opp.X1st_priority__c = data.X1st_priority_c;
        opp.X2nd_priority__c = data.X2nd_priority_c;
        opp.X3rd_priority__c = data.X3rd_priority_c;
        opp.Product_recommendation__c = data.Product_recommendation_c;
        opp.Reason__c = data.Reason_c;
        opp.Reason_for_term__c = data.Reason_for_term_c;
        
        update opp;        

        response.URL = CAA_Helper.CompleteEvent(eventLogId);
        response.Success = string.isNotBlank(response.URL);
        
        return response ;
    }

    @RemoteAction
    public static SuitabilityDataResponse GetData(ID oppId)
    {
        SuitabilityDataResponse response = new SuitabilityDataResponse();

        Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
        HPP_extended_opportunity__c exOpp = DataHelper.GetHPPExtendedOpportunityByOpp(opp.id)[0];
        
        response.Data.Balance = opp.finance_required__c;
        response.Data.Term = opp.Term_of_Finance__c;

        response.Data.Sharia_compliant_products_c = opp.Sharia_compliant_products__c;
        response.Data.Letter_sharia_compliant_c  = opp.Letter_sharia_compliant__c;
        response.Data.Stability_in_payments_c  = opp.Stability_in_payments__c;
        response.Data.Letter_payment_stability_c = opp.Letter_payment_stability__c;
        response.Data.No_early_repayment_charges_c = opp.No_early_repayment_charges__c;
        response.Data.Letter_Early_Repayment_c = opp.Letter_Early_Repayment__c;
        response.Data.Lump_sum_payments_c = opp.Lump_sum_payments__c;
        response.Data.Letter_lump_sum_c = opp.Letter_lump_sum__c;
        response.Data.Payments_low_as_possible_c = opp.Payments_low_as_possible__c;
        response.Data.Letter_low_payments_c = opp.Letter_low_payments__c;
        response.Data.Income_change_c = opp.Income_change__c;
        response.Data.Letter_income_change_c = opp.Letter_income_change__c;
        response.Data.Payments_increased_c = opp.Payments_increased__c;
        response.Data.Letter_payments_increased_c = opp.Letter_payments_increased__c;
        response.Data.Expenditure_change_c = opp.Expenditure_change__c;
        response.Data.Letter_expenditure_change_c = opp.Letter_expenditure_change__c;
        response.Data.Moving_house_soon_c = opp.Moving_house_soon__c;
        response.Data.Letter_moving_house_c = opp.Letter_moving_house__c;
        response.Data.Term_in_mind_c = opp.Term_in_mind__c;
        response.Data.X1st_priority_c = opp.X1st_priority__c;
        response.Data.X2nd_priority_c = opp.X2nd_priority__c;
        response.Data.X3rd_priority_c = opp.X3rd_priority__c;
        response.Data.Product_recommendation_c = opp.Product_recommendation__c;
        response.Data.Reason_c = opp.Reason__c;
        response.Data.Reason_for_term_c = opp.Reason_for_term__c;
        
        response.Data.PriorityOptions = Util.GetOptions(Opportunity.X1st_priority__c.getDescribe().getPicklistValues());
        response.Success = true;
        
        return response;
    }

    public class SuitabilityDataResponse extends CAA_Data.GenericResponse
    {
        public SuitabilityData Data {get;set;}

        public SuitabilityDataResponse ()
        {
            Data = new SuitabilityData();          
        }       
    }
    
    public class SuitabilityData
    {
        public Decimal Term {get;set;}
        public Decimal Balance {get;set;}
    
        public String Sharia_compliant_products_c {get;set;}
        public String Letter_sharia_compliant_c {get;set;}
        public String Stability_in_payments_c {get;set;}
        public String Letter_payment_stability_c {get;set;}
        public String No_early_repayment_charges_c {get;set;}
        public String Letter_Early_Repayment_c {get;set;}
        public String Lump_sum_payments_c {get;set;}
        public String Letter_lump_sum_c {get;set;}
        public String Payments_low_as_possible_c {get;set;}
        public String Letter_low_payments_c {get;set;}
        public String Income_change_c {get;set;}
        public String Letter_income_change_c {get;set;}
        public String Payments_increased_c {get;set;}
        public String Letter_payments_increased_c {get;set;}
        public String Expenditure_change_c {get;set;}
        public String Letter_expenditure_change_c {get;set;}
        public String Moving_house_soon_c {get;set;}
        public String Letter_moving_house_c {get;set;}
        public String Term_in_mind_c {get;set;}
        public String X1st_priority_c {get;set;}
        public String X2nd_priority_c {get;set;}
        public String X3rd_priority_c {get;set;}
        public String Product_recommendation_c {get;set;}
        public String Reason_c {get;set;}
        public String Reason_for_term_c {get;set;} 
                
        
        public List<CAA_Data.KeyValue> PriorityOptions {get;set;}
    }
}