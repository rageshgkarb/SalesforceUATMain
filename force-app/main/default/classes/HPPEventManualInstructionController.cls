/* -------------------------------------------------------------------------------------- */
/* C00098 New Event                                                                       */
/* -------------------------------------------------------------------------------------- */
/* C00227 Create event logs for adhoc events  - LB                                        */
/* -------------------------------------------------------------------------------------- */


public class HPPEventManualInstructionController extends HPPBaseEventController
{
    public Valuation_Report__c valuationReport
    {
        get
        {
            if ( valuationReport == null )
            {
                //List<Valuation_Report__c> valReps = DataHelper.GetValuationReportFromOpp (opp.Id);    
                //if (valReps.Size() > 0)
                //{
                //    valuationReport = valReps[0];
               // }
                //else
                //{
                    valuationReport = new Valuation_Report__c();
                //}
            }
            
            return valuationReport;
        }
        set;
    }
    
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
    
    public PageReference autoRun() 
    {
        return null;
    }
    
    public PageReference complete() 
    {
        PageReference pageRef = null;
        valuationReport.Opportunity__c = opp.id;
        valuationReport.LenderReference__c = opp.name;
        insert valuationReport;
        
        IBBEvents.CreateAdhocEvent(oppId,'Adhoc Valuation Report'); //CP00227 Start
        return null;
    }
}