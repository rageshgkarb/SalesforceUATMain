trigger CASEDMUpdateExecute on Case (after update) 
{
    	if(Trigger_Helper.IgnoreTrigger('Case'))
        	return; 
    
        for(Case c : trigger.new)
        {
            System.debug(c.EBS_Action_Status__c);
            //if(c.IsClosed && c.Status == 'Closed' && !String.isEmpty(c.DM_Customer_Number__c))
			if(c.IsClosed && c.Status == 'Closed' && !String.isEmpty(c.DM_EBS_ID__c))
            {                               
                System.debug('EBSAction for Case Number: ' + c.CaseNumber);                        
               // EBSActions actions = new EBSActions();
               // actions.Process(c.Id);
               System.debug('EBSAction for Case Id: ' + c.Id);
               DMCaseMethods.UpdateDSX(c.Id);
                
            }
        }

}