/* ------------------------------------------------------------------------------------------ */
/* C00105 / P00001 New AJE Actions for Product Switching P00001                               */
/* ------------------------------------------------------------------------------------------ */
/* C00107 / P00001 New Product Switch message Action                                          */
/* ------------------------------------------------------------------------------------------ */
/* C00170    Ad Hoc payment AJE                                                               */
/* ------------------------------------------------------------------------------------------ */
/* C00233    Decision Engine for BAA                                                          */
/* ------------------------------------------------------------------------------------------ */
/* C00233    ANC, OCA and JARS for BAA                                                        */
/* ------------------------------------------------------------------------------------------ */
/* C0085    Extra method for rebuild of CAA                                                   */
/* ------------------------------------------------------------------------------------------ */

public class Actions
{
 
   //Interface declaration
    public interface IAction
    {   
        IBBEvents.CompleteEventArgs RunAction(String oppId);
    }
    
    public virtual class FakeAction implements IAction
    {
        public IBBEvents.CompleteEventArgs eventArgs{get;set;}
    
        public virtual  IBBEvents.CompleteEventArgs RunAction(String oppId)
        {
            if(eventArgs ==null)
            {
                return new IBBEvents.CompleteEventArgs();
            }
            return eventArgs;
        }
    }
    
    public virtual class StoreCardAction implements IAction
    {
    
        public virtual IBBEvents.CompleteEventArgs RunAction(String oppid)
        {
            
            
            
    
            Card__c crd = new card__c();
            crd.Contact__c = '003L0000007JNOz'; 
            Crd.Name = '4111111111111111'; 
            Crd.Card_Type__c = 'Visa';
            Crd.Issue_Number__c = 1;
            //Crd.Security_Code__c = '123';
            
            
            
            
            Crd.Expiry_Month__c = 1; 
            Crd.Expiry_Year__c = 2099;
            Crd.Expiry_Year_Text__c = '2099';
           
            Crd.Valid_From_Month__c = 1;
            crd.Valid_From_Year__c = 2001;
            Crd.Valid_From_Year_Text__c = '2001'; 
           
            
            
            String str = stSecureTradingHandler.registerCard(crd);
            system.debug('return card ' + str);
            return null;
        }
    
    }
       
    public virtual class ActionRCE implements IAction
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
                                                    Conga_Fis__c
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
            quote.conga_fis__c= product.conga_fis__c;
            quote.QuoteToBeAIP__c = true; 
            insert quote;
            opp.IBBQuotation__c = quote.id;
            
            update opp;
            //OpportunityTriggerMethods.calcHPPRepayment2(oppId, false);
            OpportunityTriggerMethods.calcHPPQuotation(oppId, quote.Id);
            
            args.ReturnValue = 'Quote Reference: ' + quote.Name;
            return args;
        }
    }
    
    public virtual class ActionRCE2 implements IAction
    {
        public virtual  IBBEvents.CompleteEventArgs RunAction(String oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Logger.Info('Action: Called RCE');
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            // Get a new Quotation and populate what we can
            
            //OpportunityTriggerMethods.calcHPPRepayment2(oppId, false);
            args = HPPOpportunityMiddlewareMethods.sendRCERequest (opp);
            
            //args.ReturnValue = 'Quote Reference: ' + quote.Name;
            return args;
        }
    }
    
    /*
    public virtual class ActionRLA implements IAction
    {
        public virtual  IBBEvents.CompleteEventArgs RunAction(String oppId)
        {        
            //Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            string rtv = OpportunityTriggerMethods.createHPPRLAAccount(oppId);
            args.ReturnValue = rtv;
            return args;
        }
    }
    
    public virtual class ActionCreateAccountWithIBBAndWebLog implements IAction
    {
        public virtual  IBBEvents.CompleteEventArgs RunAction(String oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            Account_with_IBB__c acc = new Account_with_IBB__c();
            List<Account_with_IBB__c> theAccounts = [select Id, Name from Account_with_IBB__c where Id = :opp.Account_with_IBB__c];
            if (theAccounts.Size() > 0)
            {
                acc = theAccounts[0];
            }
            else
            {
                insert acc;
                opp.Account_with_IBB__c = acc.Id;
                update opp;
                
            }
            
            List<Web_Integration_Log__c> accWlList = [select w.Id, 
                                                      w.AccountwithIBBId__c 
                                                      from Web_Integration_Log__c w 
                                                      where w.AccountwithIBBId__c = :opp.Account_with_IBB__c];
        
            Web_Integration_Log__c webLog = new Web_Integration_Log__c();
            if (accWlList.size() > 0)
            {
                webLog = accWlList[0]; 
                
            }
            else
            {
                webLog.AccountwithIBBId__c = acc.Id;
                insert webLog;
            }
            
            List<Debug__c> logs = [Select Id, 
                                    Name, 
                                    Log__c, 
                                    Opportunity__c 
                                    from Debug__c 
                                    where Debug__c.Opportunity__c =: opp.Id];
                                    
            Debug__c log = new Debug__c();
            if (logs.Size() > 0)
            {
                 log = logs[0];
            }
            else
            {
                log.Opportunity__c = opp.Id;
                insert log;
            }
            
            System.debug ('Â£Â£Â£Â£Â£Â£Â£Â£ Created the WebLog, Debug Log and the Account with IBB');
            args.ReturnValue = OpportunityTriggerMethods.createHPPRLAAccount(oppId);
            
            return args;
        }
    } 
    */
    
    public virtual class ActionDecisionEngine implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(String oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            system.debug ('In Decision Engine action ' + oppId);
            //HPPDecisionEngineWebService decisionEngine = new HPPDecisionEngineWebService();
            string overallDecision = 'SUCCESS';
            boolean decline = false;
            boolean refer = false;
            boolean systemerror = false;
            boolean addressMismatch = false;
            //args = decisionEngine.accessDecisionEngine(opp);
            boolean forceCreditCheck = false;
            boolean forceAMLCheck = false;
            args = HPPOpportunityMiddlewareMethods.sendDecisionEngineRequest(opp,
                                                                            forceCreditCheck,
                                                                            forceAMLCheck);

            system.debug('The DecisionEngine Response ' + args.DEResponse);
            for (integer i = 0; i < args.DEResponse.DecisionReasons.Size(); i++)
            {
                system.debug('This is the Reason for this one ' + args.DEResponse.DecisionReasons[i].ReasonDescription);
                system.debug('This is the Code for this one ' + args.DEResponse.DecisionReasons[i].ReasonCode);
                if (String.IsEmpty(args.DEResponse.DecisionReasons[i].ReasonCode) ||
                    args.DEResponse.DecisionReasons[i].ReasonCode == 'SUCCESS')
                {
                    continue;
                }
                else if (args.DEResponse.DecisionReasons[i].ReasonCode.Contains('ADDRESSMISSMATCH'))
                {
                    system.debug ('We in here ? ' + args.DEResponse.DecisionReasons[i].ReasonCode);
                    addressMismatch = true;
                }
                else if (args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0,5) == 'REFER')
                {
                    refer = true;
                }
                
                else if (args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0,7) == 'DECLINE')
                {
                    decline = true;
                }
                
                else if (args.DEResponse.DecisionReasons[i].ReasonCode == 'SYSTEMERROR' ||
                    args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0, 11) == 'SYSTEMERROR' ||
                    args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0,4) == 'FAIL')
                {
                    systemerror = true;
                }
                
                               
                //args.DEResponse.DecisionReasons[i].ReasonCode = args.DEResponse.DecisionReasons[i].ReasonCode.Replace('REFER-' ,'');
            }
            
            if (addressMisMatch)
            {
                args.ReturnValue = 'ADDRESSMISMATCH';
            }
            else if (decline)
            {
                args.ReturnValue = 'DECLINE';
            }
            else if (refer)
            {
                args.ReturnValue = 'REFER';
            }
            else if (systemerror)
            {
                args.ReturnValue = 'SYSTEMERROR';
            }
           
            else
            {
                args.ReturnValue = 'SUCCESS';
            }
           
            args.DEResponse.Decision = args.ReturnValue;
            system.debug('The DecisionEngine Response II ' + args.DEResponse);
            system.debug ('Doing CaseDirector    ' + args.DEResponse);
            CaseDirector director = new CaseDirector('HPP', args.DEResponse, true, opp);
            system.debug ('Doing CaseDirector  CreateCases  ' + args.DEResponse);
            director.CreateCases(); 
            system.debug ('Done cases ' + args);
            return args;

        }
    }
    
    public virtual class ActionSecondDecisionEngine implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(String oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            system.debug ('In Decision Engine action ' + oppId);
            //HPPDecisionEngineWebService decisionEngine = new HPPDecisionEngineWebService();
            string overallDecision = 'SUCCESS';
            boolean decline = false;
            boolean refer = false;
            boolean systemerror = false;
            boolean addressMismatch = false;
            //args = decisionEngine.accessDecisionEngine(opp);
            boolean forceCreditCheck = true;
            boolean forceAMLCheck = true;
            args = HPPOpportunityMiddlewareMethods.sendDecisionEngineRequest(opp, forceCreditCheck, forceAMLCheck);

            system.debug('The DecisionEngine Response ' + args.DEResponse);
             for (integer i = 0; i < args.DEResponse.DecisionReasons.Size(); i++)
            {
                if (String.IsEmpty(args.DEResponse.DecisionReasons[i].ReasonCode) ||
                    args.DEResponse.DecisionReasons[i].ReasonCode == 'SUCCESS')
                {
                    continue;
                }
                
                else if (args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0,5) == 'REFER')
                {
                    refer = true;
                }
                
                else if (args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0,7) == 'DECLINE')
                {
                    decline = true;
                }
                
                else if (args.DEResponse.DecisionReasons[i].ReasonCode == 'SYSTEMERROR' ||
                    args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0, 11) == 'SYSTEMERROR' ||
                    args.DEResponse.DecisionReasons[i].ReasonCode.Substring(0,4) == 'FAIL')
                {
                    systemerror = true;
                }
                else if (args.DEResponse.DecisionReasons[i].ReasonCode.Contains('ADDRESSMISSMATCH'))
                {
                    addressMismatch = true;
                }
                               
                //args.DEResponse.DecisionReasons[i].ReasonCode = args.DEResponse.DecisionReasons[i].ReasonCode.Replace('REFER-' ,'');
            }
            
            if (decline)
            {
                args.ReturnValue = 'DECLINE';
            }
            else if (refer)
            {
                args.ReturnValue = 'REFER';
            }
            else if (systemerror)
            {
                args.ReturnValue = 'SYSTEMERROR';
            }
            else if (addressMisMatch)
            {
                args.ReturnValue = 'ADDRESSMISMATCH';
            }
            else
            {
                args.ReturnValue = 'SUCCESS';
            }
           
            system.debug('The DecisionEngine Response II ' + args.DEResponse);
           
            args.DEResponse.Decision = args.ReturnValue;
            
            return args;

        }
    }
    
    public virtual class ActionBAADecisionEngine implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction (string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            boolean forceCreditCheck = false;
            boolean forceAMLCheck = false;
            args = IBBDecisionEngineMiddlewareMethods.DecisionEngine (opp, 
                                                                        'BAA',
                                                                        forceCreditCheck,
                                                                        forceAMLCheck);
                                                                        
            return args;
        }
    }
    
    /* C0085 Start */
    public virtual class ActionCAADecisionEngine implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction (string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            boolean forceCreditCheck = false;
            boolean forceAMLCheck = false;
            args = IBBDecisionEngineMiddlewareMethods.DecisionEngine (opp, 
                                                                        'CAA',
                                                                        forceCreditCheck,
                                                                        forceAMLCheck);
                                                                        
            return args;
        }
    }
    /* C0085 End */
    
    public virtual class ActionAddJournalEntryValuation implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            args = HPPOpportunityMiddlewareMethods.sendPaymentMessage(opp, 'Valuation');
            return args;
            
        }
    }
    
    public virtual class ActionAddJournalEntryAdminInitial implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            args = HPPOpportunityMiddlewareMethods.sendPaymentMessage(opp, 'AdminInitial');
            system.debug('foo');
            return args;
            
        }
    }
    
    public virtual class ActionAddJournalEntryAdminFull implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            args = HPPOpportunityMiddlewareMethods.sendPaymentMessage(opp, 'AdminFull');
            system.debug('foo');
            return args;
            
        }
    }
    
    /* C00170 start */
    public virtual class ActionAddJournalEntryAdHoc implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            args = HPPOpportunityMiddlewareMethods.sendAdHocPaymentMessage(opp);
            return args;
        }
    }
    /* C00170 end */
    
    /* C00105 */
    public virtual class ActionAddJournalEntryProductSwitch implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            args = HPPOpportunityMiddlewareMethods.sendPaymentMessage(opp, 'ProductSwitchFee');
            system.debug('foo');
            return args;
            
        }
    }
    /* C00105 end */
    
    /* C00107 */
    public virtual class ActionProductSwitch implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            args = HPPOpportunityMiddlewareMethods.sendProductSwitch(opp);
            system.debug('foo');
            return args;
            
        }
    }
    /* C00107 end */
    
    public virtual class ActionAddOutwardPayment implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0]; 
            args = HPPOpportunityMiddlewareMethods.sendAddOutwardPayment(opp);
            return args;
            
        }
    }
    
    public virtual class ActionSurveyorInstruction implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            args = HPPOpportunityMiddlewareMethods.sendSurveyorInstruction (opp);
            return args;
            
        }
    }
    
    public virtual class ActionCreateCustomerRLAAndJARs implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
             Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            args = HPPOpportunityMiddlewareMethods.sendCustomersRLAAndJARs (opp);
            return args;
            
        }
    }
    
    /* C00233 */
    
     public virtual class ActionCreateBusinessOCAAndJARs implements IAction
    {
        public virtual IBBEvents.CompleteEventArgs RunAction(string oppId)
        {
            IBBEvents.CompleteEventArgs args = new IBBEvents.CompleteEventArgs();
            Opportunity opp = DataHelper.GetOpportunity(oppId)[0];
            args = IBBSetUpEBSMiddlewareMethods2.sendCustomersAWIAndJARs (opp, 'OpenCustomerAccount');
            return args;
            
        }
    }
    
}