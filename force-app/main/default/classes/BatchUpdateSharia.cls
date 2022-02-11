global class BatchUpdateSharia implements Database.Batchable<SObject> 
{
	
	global BatchUpdateSharia() 
	{
		
	}
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) 
	{
		Trigger_Helper.TriggerItem tItem = new Trigger_Helper.TriggerItem();
		tItem.IgnoreAudit = true;
		tItem.IgnoreTrigger = true;
		tItem.Name = 'Opportunity';
		Trigger_Helper.Items = new Trigger_Helper.TriggerItem[] { tItem };
		string sSQL = 'SELECT Id, name, Sharia_compliant_products__c, Letter_sharia_compliant__c, createddate from opportunity where  Letter_sharia_compliant__c != null';
																											
		return Database.getQueryLocator(sSQL );
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<Opportunity> scope) 
	{
		List<Opportunity> oppsUpd = new List<Opportunity>();

		for (Opportunity opp : scope)
		{
			system.debug ( '***** This is the name + Sharia_compliant_products A ' + opp.name + ' - ' + opp.Sharia_compliant_products__c );
			
				system.debug ( 'BBB This is the name + Sharia_compliant_products ' + opp.name + ' - ' + opp.Sharia_compliant_products__c );
				opp.Sharia_compliant_products__c = '';
				oppsUpd.Add (opp);
			
		}
		Trigger_Helper.TriggerItem tItem = new Trigger_Helper.TriggerItem();
				tItem.IgnoreAudit = true;
				tItem.IgnoreTrigger = true;
				tItem.Name = 'Opportunity';
				Trigger_Helper.Items = new Trigger_Helper.TriggerItem[] { tItem };
	    
		Database.Update (oppsUpd, false) ;		
	    		//	update opportunitiesToUpdate;
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) 
	{
		
	}
}