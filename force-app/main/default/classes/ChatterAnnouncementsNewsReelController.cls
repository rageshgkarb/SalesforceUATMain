public class ChatterAnnouncementsNewsReelController {
	
	public Id currentUserId{
		get{
			if(currentUserId == null){
				currentUserId = UserInfo.getUserId();
			}
			return currentUserId;
		}set;
	}

	public Integer scrollInterval{
		get{
			if(scrollInterval == null){
				ChatterAnnoucementNewsReelSettings__c newsReelSetting = ChatterAnnoucementNewsReelSettings__c.getInstance('Default');
				scrollInterval = (newsReelSetting == null) ? 10000 : newsReelSetting.Scroll_Interval__c.intValue();
			}
			return scrollInterval;
		}set;
	}

	public Integer scrollSpeed{
		get{
			if(scrollSpeed == null){
				ChatterAnnoucementNewsReelSettings__c newsReelSetting = ChatterAnnoucementNewsReelSettings__c.getInstance('Default');
				scrollSpeed = (newsReelSetting == null) ? 1200 : newsReelSetting.Scroll_Speed__c.intValue();
			}
			return scrollSpeed;
		}set;
	}

	public List<Announcement> announcements {get;set;}
	public Boolean itemsToDisplay{get;set;}

	//CONSTUCTOR
	public ChatterAnnouncementsNewsReelController() {
		try{
			list<CollaborationGroup> chatterGroups = [	
														SELECT CollaborationType, Description, Id, Name 
														FROM CollaborationGroup
														WHERE Id IN
															(SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId =: currentUserId)
													];

			announcements = [SELECT ExpirationDate, FeedItemId, FeedItem.Body, FeedItem.CreatedDate, Parent.Name FROM Announcement WHERE ParentId IN: chatterGroups AND ExpirationDate >= TODAY]; 										
			itemsToDisplay = (announcements.size() > 0) ? true : false;
		}catch(exception e){ itemsToDisplay = false; }
	} 
}