/* ----------------------------------------------------------------------------------------------------------------	*/
/* C0728	Update Documents received field on Opportunity if status set to rejected								*/
/* ----------------------------------------------------------------------------------------------------------------	*/

trigger DSX_Document_Link_trigger on DSX_Document_Link__c (before update, before insert, after update, after insert)  
{
	if ( trigger.isBefore )
	{
		//if(trigger.IsUpdate)
		//{
			DSX_Document_Link__c a = trigger.new[0];
			//DSX_Document_Link__c b = trigger.old[0];

			//if(a.Document_Returned_To_Customer__c == true && b.Document_Returned_To_Customer__c != true)
			if(a.Document_Returned_To_Customer__c == true)
			{
				a.Document_Returned_Date__c = system.Now();
				a.Document_Returned_User__c = UserInfo.getUserId();
			}
		//}
	}
	if (trigger.isAfter)
    {
		/*
		if (trigger.isInsert)
		{
			Opportunity opp = [SELECT Id,
									Name,
											Opportunity_Reference__c		// C0728
								   FROM Opportunity
								   WHERE id = :trigger.new[0].Opportunity__c];

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage() ;
			String[] toAddresses;              
                
            toAddresses = new String[] {'carl.reynolds@alrayanbank.co.uk'} ;  
			mail.setToAddresses (toAddresses);
			mail.setsubject ( 'Document ' + trigger.new[0].Document_Name__c + ' received for Opportunity ' + opp.Name );
			mail.setPlainTextbody ( 'Document ' + trigger.new[0].Document_Name__c + ' received for Opportunity ' + opp.Name );
			system.debug ( 'In trigger about to send email ' + mail );
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			system.debug ( 'In trigger sent email ' + mail );
		}
		*/
		//if(trigger.IsUpdate)
		//{
			
			DSX_Document_Link__c a = trigger.new[0];
			DSX_Document_Link__c b = null;
			DSXDocumentMethods dsxMethods = null;
			if (trigger.isUpdate)
			{
				b = new DSX_Document_Link__c();
				b = trigger.old[0];
				if (a.Document_status__c != b.Document_Status__c)
				{
					dsxMethods = new DSXDocumentMethods (a, b);
					dsxMethods.ProcessUpdates();	
					
				}
			}
			
			
			
			if ( trigger.IsInsert)
			{	
				dsxMethods = new DSXDocumentMethods (a, b);
				dsxMethods.ProcessInserts();
			}
			
				/* C0728 */
				/*
				Trigger_Helper.TriggerItem itemOpp = new Trigger_Helper.TriggerItem();
				itemOpp.Name = 'Opportunity';
				itemOpp.IgnoreAudit = true;
				itemOpp.IgnoreTrigger = true;
				*/
			

				
		
	}
}