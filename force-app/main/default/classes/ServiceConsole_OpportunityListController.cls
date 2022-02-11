public with sharing class ServiceConsole_OpportunityListController {
	
	public String parentObjId {get;set;}
	public Integer oppRowLimit {get;set;}
	public Integer attachmentRowLimit {get;set;}
	public FINAL Integer rowIncrementor = 5;
    
    public Integer totalOpps{
        get{
            if(totalOpps == null){
                totalOpps = [SELECT COUNT() FROM Opportunity WHERE AccountId =: parentObjId];
            }
            return totalOpps;
        }set;
    }

    public Integer totalOppAttachments{
        get{
            if(totalOppAttachments == null){
                totalOppAttachments = [SELECT COUNT() FROM Attachment WHERE ParentId IN : getRecentOpps()];
            }
            return totalOppAttachments;
        }set;
    }

    //Constructor
	public ServiceConsole_OpportunityListController() {
		parentObjId = ApexPages.currentPage().getParameters().get('id');
        oppRowLimit = rowIncrementor;
        attachmentRowLimit = rowIncrementor;
        showMoreOppsValue = 0;
        showMoreAttachmentsValue = 0;
    }

	public list<Opportunity> getRecentOpps(){
    	list<Opportunity> opps = [SELECT Id, Name, StageName, Amount, Finance_Required__c, Initial_Payment_Amount__c, RecordTypeId, RecordType.DeveloperName FROM Opportunity WHERE AccountId =: parentObjId ORDER BY CreatedDate DESC LIMIT : oppRowLimit];
    	return opps;
    }

    public list<Attachment> getRecentAttachments(){
    	list<Attachment> attachments = [SELECT Id, Name, Parent.Name FROM Attachment WHERE ParentId IN : getRecentOpps() ORDER BY CreatedDate DESC LIMIT : attachmentRowLimit];
    	return attachments;
    }

    public Integer showMoreOppsValue{
    	get{
    		if((totalOpps - oppRowLimit) > rowIncrementor){
    			showMoreOppsValue = rowIncrementor;
    		}else{
            
            	showMoreOppsValue = totalOpps - oppRowLimit;
	        }
	        return showMoreOppsValue;
    	}set;
    }

    public void getMoreOpps(){
    	if(showMoreOppsValue < rowIncrementor){
    		oppRowLimit += showMoreOppsValue;
    	}else{
    		oppRowLimit += rowIncrementor;
    	}
    }

    public void showAllOpps(){
    	oppRowLimit = totalOpps;
    }

    public Integer showMoreAttachmentsValue{
    	get{
    		if((totalOppAttachments - attachmentRowLimit) > rowIncrementor){
    			showMoreAttachmentsValue = rowIncrementor;
    		}else{
            
            	showMoreAttachmentsValue = totalOppAttachments - attachmentRowLimit;
	        }
	        return showMoreAttachmentsValue;
    	}set;
    }

    public void getMoreAttachments(){
    	if(showMoreAttachmentsValue < rowIncrementor){
    		attachmentRowLimit += showMoreAttachmentsValue;
    	}else{
    		attachmentRowLimit += rowIncrementor;
    	}
    }

    public void showAllAttachments(){
    	attachmentRowLimit = totalOppAttachments;
    }
	
}