/* --------------------------------------------------------------------------------------------------------	*/
/* C0684	MCD Tax																							*/
/* --------------------------------------------------------------------------------------------------------	*/

trigger Web_Integration_Log on Web_Integration_Log__c (after insert)  
{
	if (trigger.IsAfter)
	{
		if(trigger.new[0].FromTrigger__c == true )
		{
			AccountTriggerMethods.DoTax(trigger.new[0].AccountID__c, trigger.new[0].id);
		}
	}
}