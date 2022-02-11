/* ---------------------------------------------------------------------------------------- */
/* C0550 endpoint for UpdateFTDOpportunity                                                  */
/* ---------------------------------------------------------------------------------------- */

public class UpdateFTDOpportunity
{
    public string MessageID {get;set;}
    public string MessageType {get;set;}
    public string OpportunityID {get;set;}
    public string OpportunityName {get;set;}
    public string OpportunityStatus {get;set;}
    public string InitialDepositAmount {get;set;}
    public string FTDStartDate {get;set;}
    public string Spare1 {get;set;}
    public string Spare2 {get;set;}
    public string Spare3 {get;set;}
    public string Spare4 {get;set;}
    public string Spare5 {get;set;}
    
    public UpdateFTDOpportunity()
    {}
}