public class ActionsFake
{
    public class FakeAction implements Actions.IAction
    {
        public IBBEvents.CompleteEventArgs args{get;set;}
    
        public virtual  IBBEvents.CompleteEventArgs RunAction(String oppId)
        {
             return args;       
        }
    }


    public class FakeIBBEvent implements I_IBBEvents
    {
        public String ErrorMessage()
        {
            return '';
        }
    
        public boolean returnValue{get;set;}
        public boolean CompleteEvent(EventLog__c evtLog, Opportunity opp)
        {
            if(returnValue == null)
            return false;

            return returnValue;
        }
      public EventLog__c GetCreatedEvent()
    {
        return CreatedEvent;
    }
    public String GetCreatedEventLocation() 
    {
        return CreatedEventLocation;
    }


    public EventLog__c CreatedEvent
    {get;set;}
    
    public String CreatedEventLocation
    {get;set;}

        
    }

    public class RCE implements Actions.IAction
    {
        public virtual  IBBEvents.CompleteEventArgs RunAction(String oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            system.debug('Action: Called RCE');
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            // Get a new Quotation and populate what we can
            IBBQuotation__c quote = new IBBQuotation__c();
            decimal seqno = 0;
            List<IBBQuotation__c> prevQuotes = DataHelper.GetQuotations(oppId);
            if (prevQuotes.Size() > 0)
            {
                system.debug('No quotes for ' + opp.Name);
                IBBQuotation__c prevQuote = prevQuotes[0];
                seqno = prevQuote.Sequence__c + 1;
                
                for(IBBQuotation__c pQuote : prevQuotes)
                {
                    pQuote .QuoteToBeAIP__c = false;
                }
                update prevQuotes;
                
            }
            else
            {
                seqno = 1;
            }
            
            string seqno_s = string.valueof(seqno);
            if(seqno_s.Contains('.'))
            {
                integer i = seqno_s.lastIndexOf('.');
                seqno_s = seqno_s.Substring(0, i);
            }
            
            List<IBB_Product__c> products = [Select id,
                                                    Conga_fis__c
                                             From   IBB_Product__c
                                             where  id = :opp.IBB_Product__c];
            IBB_Product__c product = new IBB_Product__c();
            if (products.Size() > 0 )
            {
                product = products[0];
            }
                                                    
            
            seqno_s = seqno_s.leftPad(4);
            seqno_s = seqno_s.Replace(' ', '0');
            system.debug('Quote Name ' + opp.Name + '/' + seqno_s);
            quote.Name = opp.Name + '/' + seqno_s;
            quote.Sequence__c = seqno;
            quote.QuoteDate__c = Datetime.now();
            quote.Opportunity__c = opp.Id;
            quote.term_of_finance__c = opp.Term_of_Finance__c;
            quote.IBBProduct__c = opp.IBB_Product__c;
            quote.DealType__c = opp.Deal_Type__c;
            quote.QuoteReference__c = quote.Name;
            quote.Conga_fis__c= product.Conga_fis__c;
            quote.RCERetrieved__c = true;
            
            quote.QuoteToBeAIP__c = true;
            insert quote;
            update opp;
            //OpportunityTriggerMethods.calcHPPRepayment2(oppId, false);
            OpportunityTriggerMethods.calcHPPQuotation(oppId, quote.Id);
            
            //create conga doc
            Blob b = Blob.valueOf('Dummy document to simulate a quotation being created by RCE and Conga.');  
      
            Attachment attachment = new Attachment();  
            attachment.ParentId = quote.id;  
            attachment.Name = 'Test Attachment for RCE.txt';  
            attachment.Body = b;  
      
            insert(attachment);  
            
            
            args.ReturnValue = 'Quote Reference: ' + quote.Name;
            return args;            
        }
    }

}