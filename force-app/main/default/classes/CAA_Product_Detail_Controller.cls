global class CAA_Product_Detail_Controller extends CAA_Core_Controller
{
    /*
    Get the current opportunity and the selected product
    */
    public Integer TermMonths{get;set;}    
    public List<String> ISAYears{get;set;}
    
    public Boolean LessThanOr12Months
    {
        get{
            return termMonths < 12;
        }
    }    
    
    public List<Opportunity> opp{get;set;}
    public PageReference ISASetup()
    {
        ISAYears = new List<String>();
        
        //load opp
         opp = [select id, IBB_Product__r.FTD_Term_Months__c from opportunity where id=: CAA_Helper.GetOppId(m_EventLogId)];
        
        if(opp.size() == 0) return null;
        
        If(opp[0].IBB_Product__r.FTD_Term_Months__c != null)
        TermMonths = integer.valueof(opp[0].IBB_Product__r.FTD_Term_Months__c);
        
        Schema.DescribeFieldResult fieldResult =
             Opportunity.Tax_year_applying_for__c.getDescribe();
               List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    
               for( Schema.PicklistEntry f : ple)
               {
                  ISAYears.add(f.getValue());
               }       
        
        return null;
    }
    
    
    
    @RemoteAction
    global static CAA_Data.GenericResponse FTDISA(string eventLogId,CAA_Data.FTD data )
    {               
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {           
            //TODO SECurity for external
            //DECRYPT DATA
            if(CAA_Helper.IsGuestUser())
            {
                 eventLogId = CAA_Helper.DecryptData(eventLogId);
            }
        
            //PROCESS REQUEST    
            CAA_ProductDetail product = new CAA_ProductDetail(eventLogId,data);
            
            response.Url = product.CompleteFTDISA();           
            response.Success = response.Url != null;
        }
        catch(Exception ex)
        {
            response.Error = ex.getMessage();
            response.Success = false;
        }        
        return response;
    }
    
    @RemoteAction
    global static CAA_Data.GenericResponse ISATerms(string eventLogId,CAA_Data.ISATerms data )
    {               
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {           
            //TODO SECurity for external
            //DECRYPT DATA
            if(CAA_Helper.IsGuestUser())
            {
                 eventLogId = CAA_Helper.DecryptData(eventLogId);
            }
        
            //PROCESS REQUEST    
            CAA_ProductDetail product = new CAA_ProductDetail(eventLogId);
            response.Url = product.CompleteISATerms(data);           
            response.Success = response.Url != null;
        }
        catch(Exception ex)
        {
            response.Error = ex.getMessage();
            response.Success = false;
        }        
        return response;
    }
    
    @RemoteAction
    global static CAA_Data.GenericResponse FTD(string eventLogId,CAA_Data.FTD data )
    {               
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        try
        {           
            //TODO SECurity for external
            //DECRYPT DATA
            if(CAA_Helper.IsGuestUser())
            {
                 eventLogId = CAA_Helper.DecryptData(eventLogId);
            }
        
            //PROCESS REQUEST 
            CAA_ProductDetail product = new CAA_ProductDetail(eventLogId,data);   
            response.Url = product.CompleteFTD();           
            response.Success = response.Url != null;
        }
        catch(Exception ex)
        {
            response.Error = ex.getMessage();
            response.Success = false;
        }        
        return response;
    }
    

}