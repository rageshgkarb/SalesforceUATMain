// C0644
trigger CPF_Relationship on CPF_Relationship__c (after insert,after update, after delete)
{
		Id ParentAccID;
		integer count = 0;

		if(trigger.isDelete)
		{
			ParentAccID = trigger.old[0].Parent_account__c;
			count = trigger.old.size();
		}
		else
		{
			ParentAccID = trigger.new[0].Parent_account__c;
			count = trigger.new.size();
		}
		
		List<Account> ParentAcc = [select id,Total_Director_Shareholding__c from Account where id=:ParentAccID limit 1];
		system.debug('ParentAccID='+ParentAccID+' , ParentAcc.size()='+ ParentAcc.size());
		Boolean changed=false;
		
		
		
		for(integer i=0;i<count;i++)
		{
			if(!trigger.isUpdate || (trigger.new[i].Shareholder_Percentage__c!=trigger.old[i].Shareholder_Percentage__c))
			{
				changed=true;
				break;
			}
		}
		system.debug('changed flag after check='+changed);
		if(changed && ParentAcc.size()>0)
		{
			AggregateResult[] shareholding = [select Sum(Shareholder_Percentage__c) Total from CPF_Relationship__c where Parent_account__c  =: ParentAccID];
			ParentAcc[0].Total_Director_Shareholding__c = (Decimal)shareholding[0].get('Total');
			update ParentAcc;
		}

}