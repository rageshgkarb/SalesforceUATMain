trigger CashOrderTrigger on Cash_Order__c (before insert, after update) {
	
	if(trigger.isBefore){
		
		if(trigger.isInsert){
			set<string> branchIDs = new set<string>();
			
			for(Cash_Order__c cashOrder : trigger.new){
				branchIDs.add(cashOrder.Branch__c);
			}
			
			map<string, Branch__c> branchesMAP = new map<string, Branch__c>([SELECT Id, OwnerId, Deputy_Branch_Manager__c, Cash_order_Approver__c FROM Branch__c WHERE Id IN: branchIDs]);
			
			for(Cash_Order__c cashOrder : trigger.new){
				if(branchesMAP.get(cashOrder.Branch__c).Cash_order_Approver__c != null && string.IsBlank(cashOrder.Cash_Order_Approver__c)){
					cashOrder.Cash_Order_Approver__c = branchesMAP.get(cashOrder.Branch__c).Cash_order_Approver__c;
				}
				cashOrder.Deputy_Branch_Manager__c = branchesMAP.get(cashOrder.Branch__c).Deputy_Branch_Manager__c;
			}
			
		}else if(trigger.isUpdate){
			
		}
		
	}else if(trigger.isAfter){
	
	
		if(trigger.isInsert){
			
		}else if(trigger.isUpdate){
			
			//Non Bulk Action
			if(trigger.new.size() == 1){
				
				Schema.DescribeSObjectResult d = Schema.SObjectType.Cash_Order__c; 
				Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
				
				Schema.RecordTypeInfo rtById =  rtMapById.get(trigger.new[0].RecordTypeId);
		
				
				if(trigger.old[0].Status__c != 'Accepted' && trigger.new[0].Status__c == 'Accepted' && rtById.getName() == 'Emergency Cash Order'){
					
					Royal_Mail_Cash_Order_Request__c rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c
																FROM Royal_Mail_Cash_Order_Request__c
																WHERE Id =: trigger.new[0].Royal_Mail_Cash_Order_Request__c];
																
					CMSScheduledEmailsHandler.royalMailCashOrderFutureCall(rmOrder.Id, rmOrder.API_Session_ID__c, rmOrder.API_Server_URL__c, trigger.new[0].Branch__c, trigger.new[0].Order_Date__c );
				}
			}
		}
	}
	
}