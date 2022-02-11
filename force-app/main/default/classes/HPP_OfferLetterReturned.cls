public class HPP_OfferLetterReturned extends HPP_ProductSwitch_Core_Controller 
{
    public String DateSigned {get;set;}
    public String SwitchDate {get;set;}
    
    public PageReference Setup()
    {
        HPP_extended_opportunity__c exOpp = [SELECT Offer_returned_field__c, Opportunity__r.Product_Switch_Date__c 
                                                FROM  HPP_extended_opportunity__c 
                                                WHERE opportunity__c=:oppId];
    
        DateSigned = StringDate(exOpp.Offer_returned_field__c);
        SwitchDate = StringDate(exOpp.Opportunity__r.Product_Switch_Date__c);
    
        return null;
    }
    
    public static String StringDate(Date d)
    {
        return d.day() + '/' + d.month() + '/' + d.year();
    }
    
    @RemoteAction
    public static CAA_Data.GenericResponse Complete(ID eventLogId,ID oppId, string dateSigned, string switchDate)
    {
        CAA_Data.GenericResponse response = new CAA_Data.GenericResponse();
        
        try
        {
            HPP_extended_opportunity__c exOpp = [SELECT Offer_returned_field__c
                                                FROM  HPP_extended_opportunity__c 
                                                WHERE opportunity__c=:oppId];
                                                
            Opportunity opp = [SELECT Product_Switch_Date__c
                                    FROM Opportunity 
                                    WHERE id=:oppId];
                                    
            opp.Product_Switch_Date__c = date.parse(switchDate);
            exOpp.Offer_returned_field__c = date.parse(dateSigned);
         
            update exOpp;
            update opp;
         
            response.URL = CAA_Helper.CompleteEvent(eventLogId);
            response.Success = string.isNotBlank(response.URL);
        }
        catch(Exception ex)
        {
            system.debug(ex);
            response.Error = ex.getMessage();
        }        
        return response;
    }
}