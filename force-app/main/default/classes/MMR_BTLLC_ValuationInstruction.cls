/***************/
/*  C0644      */
/***************/
public class MMR_BTLLC_ValuationInstruction extends HPPBaseEventController {
    public Boolean successfulCallout { get; private set; }
    public Boolean unsuccessfulCallout { get; private set; }
    public static List<string> WebCallUpErrors = new List<string>();    //C00199
    public String calloutResponse { get; private set; }
    
    public Valuation_Table__c valuationTable {
        get {
            if (valuationTable == null) {
                List<Valuation_Table__c> valuationTables = [
                    SELECT Name, Price_of_Valuation__c
                    FROM Valuation_Table__c
                    WHERE Id = :exOpp.Valuation_Table__c 
                    LIMIT 1
                ];
                
                if (valuationTables.size() == 1) {
                    valuationTable = valuationTables[0];
                }
            }
            return valuationTable;
        }
        set;
    }
    
    // Second Applicant of a BTLLC Product is the first director
	public Account secondApplicant {
        get {
            if (secondApplicant == null) {
                Id secondApplicantID = null;
                for (Applicant__c applicant : applicants) {
                    if (applicant.Applicant_Number__c == 2) {
                        secondApplicantID = applicant.Prospect_Customer__c;
                    }
                }
                
                for (Account account : accounts) {
                    if (account.Id == secondApplicantID) {
                        secondApplicant = account;
                    }
                }
            }
            return secondApplicant;
        }
        set;
    }
    
    public PageReference updateTypeOfValuation() {
        valuationTable = null;
        return null;
    }
    
    public Boolean validateFields() {
        Boolean isValid = true;
        
        
        
        if (opp.Finance_Required__c == null) {
            isValid = false;
            opp.Finance_Required__c.addError('Please enter a value');
        }
        
        if (opp.Purchase_price_market_value__c == null) {
            isValid = false;
            opp.Purchase_price_market_value__c.addError('Please enter a value');
        }
        
        if (String.isBlank(opp.New_property_street__c)) {
            isValid = false;
            opp.New_property_street__c.addError('Please enter a value');
        }
        
        if (String.isBlank(opp.New_property_city__c)) {
            isValid = false;
            opp.New_property_city__c.addError('Please enter a value');
        }
        
        if (String.isBlank(opp.New_property_postcode__c)) {
            isValid = false;
            opp.New_property_postcode__c.addError('Please enter a value');
        }
        
        if (String.isBlank(exOpp.Estate_agent_contact_name__c)) {
            isValid = false;
            exOpp.Estate_agent_contact_name__c.addError('Please enter a value');
        }
        
        if (String.isBlank(exOpp.Estate_agent_contact_telephone_number__c)) {
            isValid = false;
            exOpp.Estate_agent_contact_telephone_number__c.addError('Please enter a value');
        }
        
        if (String.isBlank(exOpp.Property_Type__c)) {
            isValid = false;
            exOpp.Property_Type__c.addError('Please enter a value');
        }
        
        if (String.isBlank(exOpp.Tenure__c)) {
            isValid = false;
            exOpp.Tenure__c.addError('Please enter a value');
        }
        
        if (String.isBlank(exOpp.Property_details__c)) {
            isValid = false;
            exOpp.Property_details__c.addError('Please enter a value');
        }
        
        
        if (String.isBlank(acc.TradingAddressStreet__c)) {
            isValid = false;
            acc.TradingAddressStreet__c.addError('Please enter a value');
        }
        
        
        if (String.isBlank(acc.TradingAddressCity__c)) {
            isValid = false;
            acc.TradingAddressCity__c.addError('Please enter a value');
        }
        
        if (String.isBlank(acc.TradingPostCode__c)) {
            isValid = false;
            acc.TradingPostCode__c.addError('Please enter a value');
        }
        
        if (String.isBlank(acc.Home_Telephone_No__c)) {
            isValid = false;
            acc.Home_Telephone_No__c.addError('Please enter a value');
        }
        
        return isValid;
    }
    
    public PageReference instructValuation() 
    {
    
        system.debug( 'IsValid ' + validateFields());
        if (validateFields()) 
        {
            Actions.ActionSurveyorInstruction surveyorInstruction = new Actions.ActionSurveyorInstruction();
            IBBEvents.CompleteEventArgs action = surveyorInstruction.RunAction(opp.Id);
            
            if (action.ReturnValue == 'FAILED') 
            {
                //  Unsuccessful
                successfulCallout = false;
                unsuccessfulCallout = true;
                calloutResponse = 'Instruction Failed - ' + action.ErrorMessage;
            }
            else 
            {
                //  Successful
                successfulCallout = true;
                unsuccessfulCallout = false;
                calloutResponse = 'Instruction Completed';
                IBBEvents.CreateAdhocEvent(oppId,'Adhoc Valuation Instructed'); //CP00227
                try 
                {
                    //  Update the records
                    update exOpp;
                    update opp;
                    update acc;
                    if (secondApplicant != null) 
                    {
                        update secondApplicant;
                    }
                    // M00023
                    if (eventLog != null)
                    {
                        return complete();
                    }
                    // M00023 end
                }
                catch (Exception ex) 
                {
                    System.debug('## Exception Thrown ## => ' + ex);
                    calloutResponse = 'Instruction Failed - ' + ex;
                }
            }
            ApexPages.addMessage ( new ApexPages.Message (ApexPages.Severity.Warning, 'Please note the following possible problems with the Opportunity : ' + Action.ErrorMessage));
        }
        
        return null;
    }
    
    public PageReference autoRun() 
    
    {
        /* C00199 start *
        SetUpErrors = IBBDependentObjectFactory.CreateSurveyorInstructionStubs(Opp);
        System.debug ( 'SEt up 2 ' + SetUpErrors);
        if ( SetUpErrors.Size() > 0 )
        {
            string msg = '';
            for ( string s: SetUpErrors )
            {
                msg = msg + s + ' ; ';
            }
            ApexPages.addMessage ( new ApexPages.Message (ApexPages.Severity.Warning, 'Please note the following possible problems with the Opportunity : ' + msg));
        }
        */
        IBBDependentObjectFactory.CreateSurveyorInstructionStubs(opp);
        /* C00199 end */
        
        return null;
    }
    
    public PageReference complete() {
        CompleteEvent();
        
        //PageReference pageRef = null;
        
        Exopp.Valuation_instructed__c = date.today();
        update Exopp;

		return GoToNextEvent();
    }
    
}