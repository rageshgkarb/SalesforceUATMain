public with sharing class ServiceConsole_ActivityListController {
	public String parentObjId {get;set;}	
	public Integer rowLimit {get;set;}
    public FINAL Integer rowIncrementor = 5;
    
    public Integer totalActivities{
        get{
            if(totalActivities == null){
                totalActivities = [SELECT COUNT() FROM Task WHERE AccountId =: parentObjId];
                totalActivities += [SELECT COUNT() FROM Event WHERE AccountId =: parentObjId];
            }
            return totalActivities;
        }set;
    }

    //Constructor
	public ServiceConsole_ActivityListController() {
		parentObjId = ApexPages.currentPage().getParameters().get('id');
        rowLimit = rowIncrementor;
        showMoreValue = 0;
    }

	public list<ActivityWrapper> getRecentActivities(){
    	list<Task> tasks = [SELECT Id, Subject, Who.Name, What.Name, Status, ActivityDate, OwnerId, Owner.Name, CreatedDate FROM Task WHERE AccountId =: parentObjId ORDER BY CreatedDate DESC LIMIT : rowLimit];
    	list<Event> events = [SELECT Id, Subject, Who.Name, What.Name, ActivityDate, StartDateTime, OwnerId, Owner.Name, CreatedDate FROM Event WHERE AccountId =: parentObjId ORDER BY CreatedDate DESC LIMIT : rowLimit];
    	
    	list<ActivityWrapper> activities = new list<ActivityWrapper>();
    	
    	for(Task theTask : tasks){
    		activities.add(new ActivityWrapper(		
    												theTask.Id, 
    												theTask.Subject, 
    												theTask.What.Name,
    												theTask.Who.Name,
    												theTask.WhoId,
    												theTask.WhatId,
    												theTask.Status,
    												true,
    												theTask.ActivityDate,
    												null,
    												theTask.OwnerId,
    												theTask.Owner.Name,
    												theTask.CreatedDate
    											));
    	}

    	for(Event theEvent : events){
    		activities.add(new ActivityWrapper(		
    												theEvent.Id, 
    												theEvent.Subject, 
    												theEvent.What.Name,
    												theEvent.Who.Name,
    												theEvent.WhoId,
    												theEvent.WhatId,
    												null,
    												false,
    												null,
    												theEvent.StartDateTime,
    												theEvent.OwnerId,
    												theEvent.Owner.Name,
    												theEvent.CreatedDate
    											));
    	}

    	activities.sort();

    	list<ActivityWrapper> finalActivityList = new list<ActivityWrapper>();
    	if(activities.size() > 0){
	    	for(Integer i = 0; i < totalActivities && i < rowLimit; i++){
	    		finalActivityList.add(activities[i]);
	    	}
	    }

    	return finalActivityList;
    }

    public Integer showMoreValue{
        get{
            if((totalActivities - rowLimit) > rowIncrementor){
                showMoreValue = rowIncrementor;
            }else{
            
                showMoreValue = totalActivities - rowLimit;
            }
            return showMoreValue;
        }set;
    }

    public void getMoreActivities(){
        if(showMoreValue < rowIncrementor){
            rowLimit += showMoreValue;
        }else{
            rowLimit += rowIncrementor;
        }
    }

    public void showAllActivities(){
        rowLimit = totalActivities;
    }
	

	public Class ActivityWrapper implements Comparable{
		public String activityId {get;set;}
		public String subject {get;set;}
		public String relatedToWhat {get;set;}
		public String relatedToWho {get;set;}
		public String whoId {get;set;}
		public String whatId {get;set;}
		public String status {get;set;}
		public Boolean isTask {get;set;}
		public String activityDate {get;set;}
		public String ownerId {get;set;}
		public String assignedTo {get;set;}
		public DateTime createdDate {get;set;}

		public ActivityWrapper(String inActivityId, String inSubject, String inRelatedToWhat, String inRealtedToWho, String inWhoId, String inWhatId, String inStatus, Boolean inIsTask, Date inActivityDate, DateTime inActivityStartDate, String inOwnerId, String inAssigedTo, DateTime inCreatedDate){
			this.activityId = inActivityId;
			this.subject = inSubject;
			this.relatedToWhat = inRelatedToWhat;
			this.relatedToWho = inRealtedToWho;
			this.whoId = inWhoId;
			this.whatId = inWhatId;
			this.status = inStatus;
			this.isTask = inIsTask;
			if(inActivityDate != null && inActivityStartDate == null){
				if(isTask){
					this.activityDate = inActivityDate.format();
				}
			}else if(inActivityDate == null && inActivityStartDate != null){
				if(!isTask){
					this.activityDate = inActivityStartDate.format('dd/MM/yyyy HH:mm');
				}
			}
			this.ownerId = inOwnerId;
			this.assignedTo = inAssigedTo;
			this.createdDate = inCreatedDate;
		}

		// Compare Activities based on the CreatedDate.
	    public Integer compareTo(Object compareTo) {
	        // Cast argument to ActivityWrapper
	        ActivityWrapper compareToActivites = (ActivityWrapper)compareTo;
	        
	        // The return value of 0 indicates that both elements are equal.
	        Integer returnValue = 0;
	        if (createdDate < compareToActivites.createdDate) {
	            // Set return value to a positive value.
	            returnValue = 1;
	        } else if (createdDate > compareToActivites.createdDate) {
	            // Set return value to a negative value.
	            returnValue = -1;
	        }
	        
	        return returnValue;       
	    }
	}
}