/* ------------------------------------------------------------------------------------- */
/* C00203    Controller for Ad Hoc Re-Issue Offer Letter                                 */
/* ------------------------------------------------------------------------------------- */

public class HPPEventAdHocReIssueOfferController extends HPPBaseEventController
{

    public string PaymentTypeId = '';
    public boolean isValid {get;set;}
    public boolean processedOK {get;set;}
    public string sProcessedOK {get;set;}
    public string foo {get;set;}
    public string theComments {get;set;}
    public string theReason {get;set;}
    public string redirectURL  {get;set;}
    
    public List<EventHelper.ProjectedEvent> Events {get;set;}
    public String SelectedEvent{get;set;}
    //public List<RollbackTo> EventRollbackTo{get;set;}   

    public HPPEventAdHocReIssueOfferController ()
    {
        system.debug ('When is this called - ' + ExOpp );
        isValid = IBB_ReIssueOfferLetterMethods.ValidOpportunity(ExOpp);
        if ( !isValid )
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'An Offer Letter has not yet been sent.'));          
        }
        else
        {
            sProcessedOK= ApexPages.currentPage().getParameters().get('processedOK');
            if (!String.IsBlank(sProcessedOK))
            {
                processedOK = true;
                system.debug ('This is Exopp ' + ExOpp);
                theReason = ExOpp.Reason_for_offer_reissue__c;
                theComments = ExOpp.Comments_for_re_issue__c;
                system.debug ('this is the reason ' + theReason);
            }
            else
            {
                processedOK = false;
                 
            }
        }
    }

    

    
    
    public PageReference GenerateOfferLetter ()
    {
        update ExOpp;
        return new PageReference ( '/apex/HPPAdHocOfferLetter2?oppid=' + Opp.Id );
        //foo = 'Here it is';
            
        
    }
    
    public PageReference autoRun()
    {
        Events = EventHelper.GetEvents(Opp.id, opp.ProductEventDirector__c);
        return null;
    }
    
    public PageReference CompleteTheEvent()
    {
        IBB_ReIssueOfferLetterMethods.UpdateOpportunity (ExOpp);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Proc.')); 
        /*
        PageReference pageRef = new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);
        return pageRef;
        */
        system.debug('Created event - event ctl ' + CreatedEvent );
        
        //GetSpecificEVent ('Offer Letter Returned');
        
        string eventId =  GetSpecificEVent ('Offer Letter Returned');
        
        system.debug ( 'This is the new page ' + redirectURL + '?id=' + eventId);
        
       return new PageReference (redirectURL + '?id=' + eventId);
        
        //return new PageReference (redirectURL + '?oppid=' + opp.id);
    }
    
    /* Offer Letter Page Code */
    
    public Actions.IAction RCEAction{get;set;} 
     
    public PageReference Setup()
    {
        if(exopp.Offer_letter_sent__c == null)
        {
            exopp.Offer_letter_sent__c = Date.today();
            //update exopp;
        }   
         
        try
        {
            ErrorLog.Fatal('Calling stubs');
            IBBDependentObjectFactory.CreateRCEStubs (opp);
            
             //create clause items
            Standard_Clause_Helper helper = new Standard_Clause_Helper(opp.id);
            helper.run();
            
        }
        catch(Exception ex)
        {
          ErrorLog.Fatal(ex.getMessage());
       }
         
         //CallRCE();
        RCEAction = new Actions.ActionRCE2 ();  
        /* C00108 start */ 
        IsProductSwitch = opp.recordtype.Name == 'ProductSwitching' ? true : false;
        /* C00108 end */
        return null;
    }
    
    
    /* C00108 start */
    public boolean IsProductSwitch {get;set;}
    /* C00108 end */
    
    public boolean RCECalled{get;set;}
    public boolean StartRCEPolling{get;set;}
    public boolean RCEFailed{get;set;}
    
    public PageReference CallRCE()
    {
        Opp.Attachment_Offer_Letter__c = null;            
        RCEFailed =false;    
        IBBEvents.CompleteEventArgs args = RCEAction.RunAction(opp.id); 
        
        system.debug ('args ' + args);
        if(args.ReturnValue != 'SUCCESS')
        {
        
            
            RCEFailed = true;        
        }  
        
         system.debug ('RCEfailed ' + RCEfailed);            
      
        return null;
    }
    
    public Boolean RCECompleted
    {
        get
        {
            Opp = DataHelper.GetOpportunity(Opp.id)[0];
            if(opp.IBBQuotation__c == null)
                return false;
            
            IBBQuotation__c ibb  = [select RCERetrieved__c from IBBQuotation__c where id=:opp.IBBQuotation__c ];
            return ibb.RCERetrieved__c;
        }        
    }
    
    public PageReference PoolRCE()
    {
        if (RCECompleted)
        {
            StartRCEPolling = false;            
        }
        return null;
    }

    public PageReference CreateDoc()
    {    
        String congaTemplateId;
        if(opp.purpose_of_finance__c.equalsIgnoreCase('New Purchase'))
        {
            congaTemplateId = prod.Conga_Offer_Letter__c;
        }
        if(opp.purpose_of_finance__c.equalsIgnoreCase('Refinancing'))
        {
            congaTemplateId = prod.CongaOfferLetterRefinance__c;
        }
        if(opp.purpose_of_finance__c.equalsIgnoreCase('Equity Release'))
        {
            congaTemplateId = prod.CongaOfferLetterEquityRelease__c;
        }        
        if(productswitch)
        {
            congaTemplateId = prod.Conga_Offer_Letter_Switch__c;
        }
        
    
        CongaSettings sett = new CongaSettings(congaTemplateId);                         
        string body= sett.CallConga(Opp.id,true);   
        
        if(sett.AttachmentId != null)
        {
        
            system.debug ( 'We here ? ' + sett);
            opp.Attachment_Offer_Letter__c= sett.AttachmentId;
            
            exopp.Offer_letter_sent__c= date.today();
            update exopp;
            update opp;
            system.debug ( 'We still here ? ' + opp.Attachment_Offer_Letter__c);
            NewLetterCreated = true;
            
            
            
        }
        else
        {
            NewLetterCreated = false;
        }      
        return null;
    }
   
    public boolean NewLetterCreated {get;set;}
   
    public integer OfferLetterExpiryThreshold
    {
        get
        {
            HPPConfigSettings setting = new HPPConfigSettings ('OfferLetterExpiry', 'Integer');
            return setting.iConfigValue;
        }
    }
    
    public boolean OfferLetterExpired
    {
        get
        {
            
            return ExOpp.Offer_Letter_sent__c < (Date.Today() - OfferLetterExpiryThreshold);
        }
    }
    
   
    public string DocLink
    {
        get
        {   
            if(DocLinkCreated)
            {                 
                    return '<a target="_blank" href="/servlet/servlet.FileDownload?file=' + opp.Attachment_Offer_Letter__c+ '"><b>Offer Letter</b></a>';
            }
            return '';      
        }
    }    
    
    public boolean DocLinkCreated
    {
        get
        { 
            return opp.Attachment_Offer_Letter__c != null;
        }
    }
    
    public PageReference TakePayment ()
    {
        //update exOpp;
        PaymentTypeId = 're-issue of offer or legal docs';
        return new PageReference ( '/apex/HPPAdHocTakePayment?OppId=' + Opp.Id + '&PaymentTypeId=' + PaymentTypeId );
    }
    
    public PageReference Complete()
    {       
        try
        {
            update exopp;
        }
        catch(Exception ex)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'eRROR ' + ex.getMessage()   );
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        
        // TODO - CPDR in here go back to specific event
        
        //CompleteEvent();
        
        system.debug('Created event - event ctl ' + CreatedEvent );
        
        string eventId =  GetSpecificEVent ('Offer Letter Returned');
        
        system.debug ( 'This is the new page ' + redirectURL + '?id=' + eventId);
        
        //return new PageReference (redirectURL + '?id=' + eventId);
        
        // TODO - CPDR in here go back to specific event
        
        //return GoToNextEvent(); 
        ApexPages.Message newMsg =  new ApexPages.Message(ApexPages.Severity.Info, 'Re-issue Completed and Offer Letter Returned event has been re-opened'   );    
        ApexPages.addMessage (newMsg); 
        return null;  
    }
    
    public string GetSpecificEvent (string eventlogName)
    {
        List<EventLog__c> evtLogs = [SELECT id, 
                                            name, 
                                            Event__c,
                                            Event__r.Name, 
                                            eventstatus__c, 
                                            isexpired__c, 
                                            opportunity__r.name, 
                                            event__r.CustomPageLocation__c, 
                                            CreatedDate__c
                                    FROM eventlog__c 
                                    WHERE opportunity__c = :opp.id
                                    AND    name = :eventlogName
                                    ORDER BY createddate DESC LIMIT 1
                                    //AND    EventStatus__c = 'Open'
                                    ];
         
         string eventId ;
         string eventName;
         
         if (evtLogs.Size() > 0)
         {
            EventLog__c evtLog = evtLogs[0];
            evtLog.eventstatus__c = 'Open';
            evtLog.isexpired__c = false;
            redirectURL = evtLog.event__r.CustomPageLocation__c;
            eventId = evtLogs[0].id;
                 
            system.debug ( 'This is the event log ' + evtLog + ' - ' + evtLog.Event__r.Name + ' - ' + eventId);
            upsert evtLog;
         } 
         
         
         return eventId;
         
         //evtLog.Name = eventlogName;
        
         
         
         
         //integer i = 1 / 0;
                                  
        
    }
    
    /* End of Offer Letter Code */   
}