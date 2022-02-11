public with sharing class IBBMembersAdd {

	public List<User> selectionUsers {get;set;}
	
	public List<User> userMembers {get;set;}
	
	public grc__Business_Unit__c theBusinessUnit {get; private set;}
	
	Id theBusinessUnitId {get; private set;}
	
	public ApexPages.StandardSetController userPageData {get;set;}
	
	public ApexPages.StandardSetController memberPageData {get;set;}
	
	public Integer currentUserPageNumber {get;set;}
	
	public Integer nextUserPageNumber {get;set;}
	
	public Integer previousUserPageNumber {get;set;}
	
	
	public Integer currentMemberPageNumber {get;set;}
	
	public Integer nextMemberPageNumber {get;set;}
	
	public Integer previousMemberPageNumber {get;set;}
	
	public Group theGroupReadWrite  {get; private set;}
	
	public List<GroupMember> theGroupMembersReadWrite {get; private set;}


	/*
        @description Retrieves both User and Member lists and also sets the current page number of each collection
        @param con The Business Unit which it being used
    */
	public IBBMembersAdd(ApexPages.StandardController con)
	{
		theBusinessUnitId = con.getId();
		
		theBusinessUnit = [select Id, Name, OwnerId, Risk__Sharing_Group_Name__c, Risk__Read_Write_Access_to_Child_BUs__c
		                   from grc__Business_Unit__c
		                   where Id =: theBusinessUnitId
		                   limit 1];
		
		selectionUsers = new List<User>();
		userMembers = new List<User>();
		
		currentUserPageNumber = 1;
		currentMemberPageNumber = 1;
		
		if(Apexpages.currentPage().getParameters().get('currentUserPageNumber') != null && Apexpages.currentPage().getParameters().get('currentUserPageNumber') != '')
		{
			currentUserPageNumber = Integer.valueOf(Apexpages.currentPage().getParameters().get('currentUserPageNumber'));
		}
		
		if(Apexpages.currentPage().getParameters().get('currentMemberPageNumber') != null && Apexpages.currentPage().getParameters().get('currentMemberPageNumber') != '')
		{
			currentMemberPageNumber = Integer.valueOf(Apexpages.currentPage().getParameters().get('currentMemberPageNumber'));
		}
		
		previousUserPageNumber = 0;
		previousMemberPageNumber = 0;
		
		if(currentUserPageNumber > 1)
		{
			previousUserPageNumber = (currentUserPageNumber - 1);
		}
		
		if(currentMemberPageNumber > 1)
		{
			previousMemberPageNumber = (currentMemberPageNumber - 1);
		}
		
		nextUserPageNumber = (currentUserPageNumber + 1);
		nextMemberPageNumber = (currentMemberPageNumber + 1);
		
		String groupNameReadWrite = theBusinessUnit.Risk__Sharing_Group_Name__c + '-' + theBusinessUnit.Id + '-' + 'R/W';
		String groupNameReadOnly = theBusinessUnit.Risk__Sharing_Group_Name__c + '-' + theBusinessUnit.Id + '-' + 'R';
		
		theGroupReadWrite = [select Id, Name
		                     from Group
		                     where Name = :groupNameReadWrite
		                     limit 1];
		
		theGroupMembersReadWrite = [select Id, GroupId, UserOrGroupId
		                            from GroupMember
		                            where GroupId = :theGroupReadWrite.Id];

		Set<Id> groupMembers = new Set<Id>();
		   
		for(GroupMember gm : theGroupMembersReadWrite)
		{
			groupMembers.add(gm.UserOrGroupId);
		}
		
		List<String> nonValidLicenses = new List<String>();
		
		nonValidLicenses.add('CSPLitePortal');
		nonValidLicenses.add('CsnOnly');
		
		selectionUsers = [select UserRole.Name, Profile.Name, LastName, 
		                         IsActive, FirstName, UserType, Risk__Selected__c
		                  from User
		                  where Id != : theBusinessUnit.OwnerId
		                  and Id not in : groupMembers
		                  and UserType not in : nonValidLicenses
		                  order by LastName];
		
		userMembers = [select UserRole.Name, Profile.Name, LastName, 
		                      IsActive, FirstName, UserType, Risk__Selected__c
		               from User
		               where Id = : theBusinessUnit.OwnerId
		               or Id in : groupMembers
		               order by LastName];

	}	
	
	/*
        @description Changes the level of Access of the current Business Unit on the immediate child Business Unit 
    */
	public void changeAccess()
	{
		if(theBusinessUnit.Risk__Read_Write_Access_to_Child_BUs__c == true)
		{
			theBusinessUnit.Risk__Read_Write_Access_to_Child_BUs__c = false;
		}
		else
		{
			theBusinessUnit.Risk__Read_Write_Access_to_Child_BUs__c = true;
		}
		
		update theBusinessUnit;
	}
	
	/*
        @description Gets the data for the Users and paginates the results ready for display
    */
	public void getUserData()
	{	
		if(userPageData == null) 
		{
			userPageData = new ApexPages.StandardSetController(selectionUsers);
			
			// sets the number of records in each page set
			
			userPageData.setPageSize(100);
			
			userPageData.setPageNumber(currentUserPageNumber);
		}
	}
	
	/*
        @description Gets the data for the Members and paginates the results ready for display
    */
	public void getMemberData()
	{	
		if(memberPageData == null) 
		{
			memberPageData = new ApexPages.StandardSetController(userMembers);
			
			// sets the number of records in each page set
			
			memberPageData.setPageSize(100);
			
			memberPageData.setPageNumber(currentMemberPageNumber);
		}
	}
	
	/*
        @description Removes Users (Group Members) from the Business Unit (group)
    */
	public void multipleRemoveMember()
	{
		Set<Id> userIds = new Set<Id>();
		
		for(User user : userMembers)
		{
			if(user.Risk__Selected__c == true)
			{
				userIds.add(user.Id);
			}
		}
		
		List<GroupMember> theMembers = [select Id, GroupId, UserOrGroupId
			                            from GroupMember
			                            where UserOrGroupId in : userIds
			                            and GroupId = : theGroupReadWrite.Id];
			                         
		delete theMembers;	
	}
	
	/*
        @description Adds Users (Group Members) to the Business Unit (group)
    */
	public void multipleAddMember()
	{
		List<GroupMember> theGroupMembers = new List<GroupMember>();
		
		for(User user : selectionUsers)
		{
			if(user.Risk__Selected__c == true)
			{
				GroupMember theMember = new GroupMember();
				theMember.GroupId = theGroupReadWrite.Id;
				theMember.UserOrGroupId = user.Id;
			
				theGroupMembers.add(theMember);
			}
		}
		
		insert theGroupMembers;
	}
	
	/*
        @description Retrieves the Paginated Users for displaying
        @return List<User> The collection of Users
    */	
	public List<User> getPaginatedUsers()
	{	
		getUserData();
		
		List<User> paginated = new List<User>();
		
		for(User theUser : (List<User>)userPageData.getRecords())
		{
			paginated.add(theUser);
		}
		
		return paginated;
	}
	
	/*
        @description Retrieves the Paginated Members for displaying
        @return List<User> The collection of Users
    */
	public List<User> getPaginatedMembers()
	{	
		getMemberData();
		
		List<User> paginated = new List<User>();
		
		for(User theUser : (List<User>)memberPageData.getRecords())
		{
			paginated.add(theUser);
		}
		
		return paginated;
	}
}