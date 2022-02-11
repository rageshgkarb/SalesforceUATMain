trigger CaseEBSActionExecute on Case (after insert) 
{
        System.debug('CaseEBSActionExecute');
        for(Case c : trigger.new)
        {
            System.debug(c.EBS_Action_Status__c);
            if(c.EBS_Action_Status__c == 'Open')
            {                               
                System.debug('EBSAction for Case Number: ' + c.CaseNumber);                        
               // EBSActions actions = new EBSActions();
               // actions.Process(c.Id);
               System.debug('EBSAction for Case Id: ' + c.Id);
               IBBEBSActionMethods.ExecuteRequest(c.Id);
                
            }
        }
}