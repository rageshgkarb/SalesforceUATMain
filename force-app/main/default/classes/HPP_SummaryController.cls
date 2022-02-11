public class HPP_SummaryController extends HPP_ProductSwitch_Core_Controller 
{
    public string WelcomeLetterId {get;set;}
    public string OfferLetterId {get;set;}
    public string FisId {get;set;}
    public string Risk {get;set;}
    
    public PageReference Setup()
    {
        Opportunity o = [SELECT Ibb_product__r.Risk_Features_Document__c,IBBQuotation__r.Attachment_FIS__c,
                            Attachment_Offer_Letter__c, Attachment_Welcome_Letter__c
                            FROM Opportunity
                            WHERE id=:opp.Id];
                            
          
    
        if(string.isNotBlank(o.ibb_product__r.Risk_Features_Document__c))
            Risk = LiabilitiesHelperFunctions.GetResourceURL(o.ibb_product__r.Risk_Features_Document__c);
            
        WelcomeLetterId = o.Attachment_Welcome_Letter__c;
        OfferLetterId = o.Attachment_Offer_Letter__c;
        FisId = o.IBBQuotation__r.Attachment_FIS__c;
        
        return null;        
    }
}