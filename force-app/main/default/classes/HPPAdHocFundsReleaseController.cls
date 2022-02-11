/* -------------------------------------------------------------------------------------------------------------- */
/* C00179    New controller for Ad Hoc event based on flow event                                                  */
/* -------------------------------------------------------------------------------------------------------------- */
/* C00222    Set OutwardPaymentOverride__c to true to allow the subsequent AOP to progress                        */
/* -------------------------------------------------------------------------------------------------------------- */
/* C0635    Removed common functions to BaseEventController class                                                */
/* -------------------------------------------------------------------------------------------------------------- */

public class HPPAdHocFundsReleaseController extends HPPBaseEventController 
{
    public String pageMessage { get; private set; }
    public String approverComments { get; set; }
    public Boolean haveFundsBeenReleased { get; private set; }
    public List<EventHelper.ProjectedEvent> Events {get;set;}
    public List<RollbackTo> EventRollbackTo{get;set;} 
    public Event_rewind__c rewind {get;set;}
    public String SelectedEvent{get;set;}
    public string EventToRewindToName 
    {
        get
        {
            return 'Payment keyed for completion';
        }
    }
    
    public Boolean showOriginalFundsSent {get;set;}
    
    
    public HPPAdHocFundsReleaseController() 
    {
        if (String.isBlank(exOpp.Payment_Reference__c)) 
        {
            haveFundsBeenReleased = false;
        }
        else 
        {
            haveFundsBeenReleased = true;
        }
        
        if (String.isBlank(exOpp.IBB_Solicitor__c)) 
        {
            if (String.isBlank(prodSet.Name)) 
            {
                exOpp.IBB_Solicitor__c = null;
            }
            else if (prodSet.Name == 'Home Purchase Plan Scotland' || prodSet.Name == 'Buy To Let Purchase Plan Scotland' ) 
            {
                //C0662 - set Shepherd and Wedderburn to default
                //exOpp.IBB_Solicitor__c = 'Todds Murray';
                //exOpp.IBB_Solicitor__c = 'Shepherd and Wedderburn'; 
                //C0730 - Set Optima Legal (Scotland) Limited to default
                exOpp.IBB_Solicitor__c = 'Optima Legal (Scotland) Limited';
                
            }
            else if (prodSet.Name == 'Home Purchase Plan' || prodSet.Name == 'Home Purchase Plan Premier' || prodSet.Name.startsWith('Buy To Let Purchase Plan') || prodSet.Name.startsWith('Buy To Let Limited Company')) 
            {
               //C0662 - set Shakespeare Martineau LLP to default
                //exOpp.IBB_Solicitor__c = 'SGH Martineau';
                exOpp.IBB_Solicitor__c = 'Shakespeare Martineau LLP';
            }            
            else 
            {
                exOpp.IBB_Solicitor__c = null;
            }
        }
        
        if ( exOpp.Original_funds_sent_date__c != null)
        {
            showOriginalFundsSent = true;
        }
        else
        {
            showOriginalFundsSent = false;
        }
        
        exOpp.Funds_returned_to_IBB__c = Date.Today();
    }
    
    private void PaymentKeyedForCompletionEvent ()
    {
        List<Event__c> evnts = [SELECT Id,
                                      Name
                               FROM   Event__c
                               WHERE  Name = :EventToRewindToName];
        if (evnts.size() > 0 )
        {
            SelectedEvent = evnts[0].Id;
        }
    }
   
    private User currentUser 
    {
        get 
        {
            if (currentUser == null) 
            {
                currentUser = 
                [
                    SELECT Name, HPPAuthorityLevel__c
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    LIMIT 1
                ];
            }
            return currentUser;
        }
        private set;
    }
    
    private List<User> existingApprovers 
    {
        get 
        {
            if (existingApprovers == null) 
            {
                List<Id> approverIDs = new List<Id>();
                approverIDs.add(exOpp.ApproverName1__c);
                approverIDs.add(exOpp.ApproverName2__c);
                approverIDs.add(exOpp.ApproverName3__c);
                approverIDs.add(exOpp.ApproverName4__c);
                
                existingApprovers = [
                    SELECT Name, HPPAuthorityLevel__c
                    FROM User
                    WHERE Id IN :approverIDs
                ];
            }
            return existingApprovers;
        }
        set;
    }
    
    private Set<Id> existingApproverIDs 
    { 
        get 
        {
            existingApproverIDs = new Set<Id>();
            existingApproverIDs.add(exOpp.ApproverName1__c);
            existingApproverIDs.add(exOpp.ApproverName2__c);
            existingApproverIDs.add(exOpp.ApproverName3__c);
            existingApproverIDs.add(exOpp.ApproverName4__c);
            
            return existingApproverIDs;
        } 
        private set; 
    }
    
     public Boolean IsPremier
    {
        get{
            return prodSet.ProductSetType__c.equalsIgnoreCase('Premier'); 
        }
    }
    
    
    public PageReference resetPayment ()
    {
        PageReference pageRef = null;
        system.debug ( 'What is exOpp id ? - ' + exOpp.Id );
        
        if (Opp.StageName.EqualsIgnoreCase('completed')
         || String.IsBlank(ExOpp.payment_reference__c))
        {
            system.debug ('Should be here A ' + Opp.StageName + ' - ' + ExOpp.payment_reference__c);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You are not able to reset the payment as the payment has not been sent through HPP CAA or the case is completed.'));  
        }
        else
        { 
            if ((exOpp.Reason_for_funds_return__c != '--None--' && String.IsNotBlank(exOpp.Reason_for_funds_return__c)) &&
                exOpp.Funds_returned_to_IBB__c <= Date.today())
            {
                system.debug ( 'the date funds sent ' + exopp.date_funds_sent__c);
                exOpp.Previous_Approver1__c = exOpp.ApproverName1__c;
                exOpp.Previous_Approver2__c = exOpp.ApproverName2__c;
                exOpp.Previous_Approver3__c = exOpp.ApproverName3__c;
                exOpp.ApproverName1__c = null;
                exOpp.ApproverName2__c = null;
                exOpp.ApproverName3__c = null;
                exOpp.CommentsApprover1__c = '';
                exOpp.CommentsApprover2__c = '';
                exOpp.CommentsApprover3__c = '';
                exOpp.Payment_Reference__c = '';
                exOpp.DateApprover1__c = null;
                exOpp.DateApprover2__c = null;
                exOpp.DateApprover3__c = null;
                exOpp.Original_funds_sent_date__c = exOpp.Date_funds_sent__c;
                exOpp.Date_funds_sent__c = null;
                
                system.debug ( 'This is the exopp ' + exOpp );
                
                update exOpp;
                
                /* C00222 start */
                Opp.OutwardPaymentOverride__c = true;
                update Opp;
                /* C00222 end */
                
                PaymentKeyedForCompletionEvent();
                CalculateRollbackEvent();
                RollbackOpp();
                CompleteWebLogs();
                //CompleteEvent();
                pageRef = new PageReference('/apex/HPPEventRedirect?oppid=' + opp.id);
                IBBEvents.CreateAdhocEvent(oppId,'Adhoc Reset Funds Release');
            }
            else
            {
                system.debug ('Should be here C ' + Opp.StageName + ' - ' + ExOpp.payment_reference__c);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Funds returned date or funds return reason are invalid.'));  
                
            }
        }
        
       // integer i = 1 / 0;
        return pageRef;
    }
    
    //LB
    //Mark any open weblogs for AOP as completed, this will then cause a new weblog to be created when the release funds event is run again
    private void CompleteWebLogs()
    {
        List<Web_Integration_Log__c> WebIntegrationLogs = [select w.Id, 
                                                                 w.AccountId__c
                                                          from Web_Integration_Log__c w 
                                                          where w.OpportunityId__c = :Opp.Id
                                                          and w.Request_Action__c = 'AddOutwardPayment'
                                                          and w.IntegrationTaskPerformed__c = false
                                                          order by w.CreatedDate DESC];
                                                          
        for(Web_Integration_Log__c log : WebIntegrationLogs)
        {
            log.IntegrationTaskPerformed__c = true;
        }
        update WebIntegrationLogs;
    }
    
    private void CalculateRollbackEvent()
    {  
        Boolean first = false;
        
        for(EventHelper.ProjectedEvent pe : Events )
        {
            if(first)
            {
                if(pe.IsCreated & !pe.IsExpired )
                {
                    RollbackTo rto = new RollbackTo();
                    rto.name = pe.Title;
                    rto.id = pe.eventid;
                    rto.IsRollback = false;
                    EventRollbackTo.add(rto);
                }
                else
                {
                    break;
                }  
            }
        
            if(first == false)
            {
                if(pe.EventId == SelectedEvent)
                {
                    first = true;
                }  
            }
        }
    }
    
    public void RollbackOpp()
    {
       rewind.Rewound_From_Stage__c =  Opp.stagename;
       rewind.Rewound_From_Status__c = Opp.Status_HPP_CAA__c;
       rewind.Events_Opened__c='';
          
        
       system.debug ( 'We in here ? ');
       for(RollbackTo e : EventRollbackTo )
       {
           if(e.IsRollback)
           {
               List<Eventlog__c> ev = [select id, IsExpired__c, EventStatus__c  from Eventlog__c where opportunity__c=:opp.id and event__c=: e.id];
               for(Eventlog__c log : ev)
               {
                   if(!log.IsExpired__c)
                   {
                       rewind.Events_Opened__c +=  log.id + ' - ' + e.name + '\n';
                       log.IsExpired__c = true;
                       log.EventStatus__c = 'Closed';
                   }
               }
               update ev;
           }
       }
       List<Eventlog__c> ev = [select id, IsExpired__c, EventStatus__c  from Eventlog__c where opportunity__c=:opp.id and event__c=: selectedevent];
       for(Eventlog__c log : ev)
       {
           log.IsExpired__c = true;
           log.EventStatus__c = 'Closed';
       }
       update ev;
    
       system.debug ( 'What is Selected Event ? ' + SelectedEvent);
    
       Event__c event = DataHelper.GetEvent(SelectedEvent)[0];
       IBBEvents ibb = new IBBEvents(Opp.ProductEventDirector__c);        
       ibb.CreateEvent(event,opp.id);
            
       rewind.opportunity__c = opp.id;
       rewind.RewoundDate__c = datetime.now();
       rewind.RewoundBy__c = UserInfo.getUserId();
       rewind.Rewound_to__c = SelectedEvent;
            
       Opportunity o = [select Ready_for_credit__c,stagename,Status_HPP_CAA__c,IsPostRewind__c,IsPreRewind__c from opportunity where id=:opp.id];
            
       if(o.Ready_for_credit__c != null && !o.IsPostRewind__c )
       {
           o.IsPostRewind__c =true;
           update o;
       }
       if(o.Ready_for_credit__c == null && !o.IsPreRewind__c)
       {
           o.IsPreRewind__c = true;
           update o;
       }
            
       if(o.Ready_for_credit__c == null)
       {
           rewind.RewindType__c = 'Pre Submission';
       }
       else
       {
           rewind.RewindType__c = 'Post Submission';
       }
            
       rewind.Rewound_To_Stage__c =  o.stagename;
       rewind.Rewound_To_Status__c = o.Status_HPP_CAA__c;
            
       insert rewind;
       rewind = new Event_rewind__c();
       Opp = DataHelper.GetOpportunity(Opp.id)[0];
            
    }
        
    
    
    public PageReference autoRun() 
    {
        IBBDependentObjectFactory.CreateAOPStubs(Opp);
        Events = EventHelper.GetEvents(Opp.id, opp.ProductEventDirector__c);
        EventRollbackTo = new List<RollbackTo>();
        rewind = new Event_rewind__c();
        return null;
    }
    
    public class RollbackTo
    {
        public String Name{get;set;}
        public String Id{get;set;}
        public Boolean IsRollback{get;set;}
    }
}