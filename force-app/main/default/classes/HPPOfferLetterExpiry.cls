/* ------------------------------------------------------------------------------- */
/* C0075 Offer Letter Expiration Schedule                                          */
/* ------------------------------------------------------------------------------- */

public class HPPOfferLetterExpiry
{
    public List<HPPOfferLetterExpiry__c> settings {get;set;}
    public List<Case> casesToCreate {get;set;}
    public string CaseRecordTypeId {get;set;}
    public string CaseQueueId {get;set;}
    
    public HPPOfferLetterExpiry()
    {
        settings = [SELECT    Name,
                              ExpiryNumberOfDays__c,
                              PerformExpiry__c,
                              CaseRecordType__c,
                              CaseCategory__c,
                              CaseDescription__c,
                              CaseOrigin__c,
                              CasePriority__c,
                              CaseSubject__c,
                              CaseQueue__c
                   FROM       HPPOfferLetterExpiry__c];
                   
        if (settings.Size() > 0)
        {
            List<RecordType> recTypes = [SELECT Id
                                        FROM RecordType
                                        WHERE DeveloperName = :settings[0].CaseRecordType__c];
            CaseRecordTypeId = recTypes[0].Id;
            
            List<queueSobject> queues =  [SELECT QueueId
                                           FROM   QueueSobject
                                           WHERE  Queue.Name = :settings[0].CaseQueue__c];                 
            CaseQueueId = queues[0].QueueId;
        }
       
    }
    
    public void Expire ()
    {
        casesToCreate = new List<Case>();
        for (HPPOfferLetterExpiry__c setting : settings)
        {
            system.debug ('The setting ' + setting);
            if (setting.Name == 'NoReturnExpiry' && setting.PerformExpiry__c == true)
            {
                ExpireNoReturn (setting);
            }
            else if (setting.Name == 'NoCompletionExpiry' && setting.PerformExpiry__c == true)
            {
                ExpireNoCompletion (setting);
            }
            else if (setting.Name == 'NoValuationCompletionExpiry' && setting.PerformExpiry__c == true)
            {
                ExpireValuationNoCompletion (setting);
            } 
            system.debug ('The casestocreate now ' + casesToCreate);
        }
        system.debug ('The casesToCreate ' + casesToCreate);
        
        if (casesToCreate.Size() > 0 )
        {
            Database.SaveResult[] saveTheCases = Database.Insert(casesToCreate);
            for (integer i = 0; i < casesToCreate.Size() ; i++)
            {
                Database.SaveResult du = saveTheCases.get(i);
                if (!du.IsSuccess())
                {
                    List<Database.Error> dbErrs = du.getErrors();
                    Database.Error e = dbErrs[0];
                    System.debug ( 'The Case insert has failed ' + e.GetMessage());
                }  
              
            }
        }
    }
    
    public void ExpireNoReturn (HPPOfferLetterExpiry__c theSetting)
    {
        List<Hpp_extended_opportunity__c> theOpps = [select name, 
                                                            opportunity__c, 
                                                            opportunity__r.Account.PersonContactId,
                                                            opportunity__r.name, 
                                                            opportunity__r.Status_HPP_CAA__c,
                                                            Days_Since_Offer_Letter_Sent__c,
                                                            offer_letter_sent__c, 
                                                            actual_completion_date__c, 
                                                            Offer_returned_field__c
                                                     from hpp_extended_opportunity__c
                                                     where (opportunity__r.Status_HPP_CAA__c <>'Completed' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Abandoned' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Welcome Letter' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Affordability declined' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Declined')
                                                     and (opportunity__r.stagename <>'Completed' and 
                                                            opportunity__r.stagename <>'Abandoned' and
                                                            opportunity__r.stagename <>'Declined' and
                                                            opportunity__r.stagename <>'Redeemed' and
                                                            opportunity__r.stagename <>'Pre Val (Declined)' and
                                                            opportunity__r.stagename <>'Post Val (Declined)')
                                                     and actual_completion_date__c = null
                                                     and opportunity__r.recordtype.developername='HPP_CAA'
                                                     and (Days_Since_Offer_Letter_Sent__c > :theSetting.ExpiryNumberOfDays__c.intValue() 
                                                             and Offer_returned_field__c = null)];
                                                 
         if (theOpps.Size() > 0)
         {
             for (Hpp_extended_opportunity__c opp:theOpps)
             {
                 Case cas = new Case();
                 cas.RecordTypeId = CaseRecordTypeId;
                 cas.OwnerId = CaseQueueId;
                 cas.ContactId = Opp.Opportunity__r.Account.PersonContactId;
                 cas.Opportunity__c = Opp.Opportunity__c;
                 cas.Subject = theSetting.CaseSubject__c;
                 cas.Description = theSetting.CaseDescription__c;
                 cas.Origin = theSetting.CaseOrigin__c;
                 cas.Status = 'OPEN';
                 cas.Priority = theSetting.CasePriority__c;
                 
                 //cas.RecordTypeId = 
                 casesToCreate.Add(cas);
             }
         }

    }
    
    public void ExpireNoCompletion (HPPOfferLetterExpiry__c theSetting)
    {
        List<Hpp_extended_opportunity__c> theOpps = [select name, 
                                                            opportunity__c, 
                                                            opportunity__r.Account.PersonContactId,
                                                            opportunity__r.name, 
                                                            opportunity__r.Status_HPP_CAA__c,
                                                            Days_Since_Offer_Letter_Sent__c,
                                                            offer_letter_sent__c, 
                                                            actual_completion_date__c, 
                                                            Offer_returned_field__c
                                                     from hpp_extended_opportunity__c
                                                     where (opportunity__r.Status_HPP_CAA__c <>'Completed' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Abandoned' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Welcome Letter' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Affordability declined' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Declined')
                                                     and (opportunity__r.stagename <>'Completed' and 
                                                            opportunity__r.stagename <>'Abandoned' and
                                                            opportunity__r.stagename <>'Declined' and
                                                            opportunity__r.stagename <>'Redeemed' and
                                                            opportunity__r.stagename <>'Pre Val (Declined)' and
                                                            opportunity__r.stagename <>'Post Val (Declined)')
                                                     and actual_completion_date__c = null
                                                     and opportunity__r.recordtype.developername='HPP_CAA'
                                                     and (Days_Since_offer_letter_sent__c > :theSetting.ExpiryNumberOfDays__c.intValue()
                                                          and Offer_returned_field__c <> null)];

        if (theOpps.Size() > 0)
        {
            for (Hpp_extended_opportunity__c opp:theOpps)
             {
                 Case cas = new Case();
                 cas.RecordTypeId = CaseRecordTypeId;
                 cas.OwnerId = CaseQueueId;
                 cas.ContactId = Opp.Opportunity__r.Account.PersonContactId;
                 cas.Opportunity__c = Opp.Opportunity__c;
                 cas.Subject = theSetting.CaseSubject__c;
                 cas.Description = theSetting.CaseDescription__c;
                 cas.Origin = theSetting.CaseOrigin__c;
                 cas.Status = 'OPEN';
                 cas.Priority = theSetting.CasePriority__c;
                 
                 //cas.RecordTypeId = 
                 casesToCreate.Add(cas);
             }
        }
    }
    
    public void ExpireValuationNoCompletion (HPPOfferLetterExpiry__c theSetting)
    {
        List<Hpp_extended_opportunity__c> theOpps = [select name, 
                                                            opportunity__c, 
                                                             opportunity__r.Account.PersonContactId,
                                                            opportunity__r.name, 
                                                            opportunity__r.Status_HPP_CAA__c,
                                                            Days_Since_Offer_Letter_Sent__c,
                                                            offer_letter_sent__c, 
                                                            actual_completion_date__c, 
                                                            Offer_returned_field__c
                                                     from hpp_extended_opportunity__c
                                                     where (opportunity__r.Status_HPP_CAA__c <>'Completed' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Abandoned' and
                                                                    opportunity__r.Status_HPP_CAA__c <>'Welcome Letter' and 
                                                                    opportunity__r.Status_HPP_CAA__c <>'Affordability declined' and  
                                                                    opportunity__r.Status_HPP_CAA__c <>'Declined')
                                                     and (opportunity__r.stagename <>'Completed' and 
                                                            opportunity__r.stagename <>'Abandoned' and
                                                            opportunity__r.stagename <>'Declined' and
                                                            opportunity__r.stagename <>'Redeemed' and
                                                            opportunity__r.stagename <>'Pre Val (Declined)' and
                                                            opportunity__r.stagename <>'Post Val (Declined)')
                                                     and actual_completion_date__c = null
                                                     and opportunity__r.recordtype.developername='HPP_CAA'
                                                     and (Days_Since_valuation_recieved__c > :theSetting.ExpiryNumberOfDays__c.intValue() )];

        if (theOpps.Size() > 0)
        {
            for (Hpp_extended_opportunity__c opp:theOpps)
             {
                 Case cas = new Case();
                 cas.RecordTypeId = CaseRecordTypeId;
                 cas.OwnerId = CaseQueueId;
                 cas.ContactId = Opp.Opportunity__r.Account.PersonContactId;
                 cas.Opportunity__c = Opp.Opportunity__c;
                 cas.Subject = theSetting.CaseSubject__c;
                 cas.Description = theSetting.CaseDescription__c;
                 cas.Origin = theSetting.CaseOrigin__c;
                 cas.Status = 'OPEN';
                 cas.Priority = theSetting.CasePriority__c;
                 
                 //cas.RecordTypeId = 
                 casesToCreate.Add(cas);
             }
        }
    }
    
    
}