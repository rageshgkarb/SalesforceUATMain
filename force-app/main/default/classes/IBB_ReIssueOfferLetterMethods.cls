/* -------------------------------------------------------------------------------------- */
/* C00203 Generic Class for Offer Letter Re Issue Methods                                 */
/* -------------------------------------------------------------------------------------- */


public without sharing class IBB_ReIssueOfferLetterMethods
{
    public static boolean isValid {get;set;}

    public IBB_ReIssueOfferLetterMethods()
    {
    }
    
    public static boolean ValidOpportunity (HPP_Extended_Opportunity__c ExOpp)
    {
        if (ExOpp.Offer_letter_sent__c != null)
        {
            return  true;
        }
        else
        {
            return false;
        }
    }
    
    public static void UpdateOpportunity (HPP_Extended_Opportunity__c ExOpp)
    {
        ExOpp.Original_Offer_sent_date__c = ExOpp.Offer_Letter_Sent__c;
        DateTime today = DateTime.Now();
        ExOpp.Offer_Letter_sent__c = Date.ValueOf(today);
        ExOpp.Offer_returned_field__c = null;
        update ExOpp;
    }
    
    
    
    
}