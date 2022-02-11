global with sharing class Teller_Signatory_Controller {


	global static SignatoryGroups LoadSignatoriesAndGroups (String AccountNo)
	{
		SignatoryGroups response = new SignatoryGroups();
		response.SignatoryGroupList = new List<SignatoryGroupType>();

		try{
	        List<Signatory_Group__c> signatoryGroupList = [SELECT Id, Code__c, Description__c FROM Signatory_Group__c ORDER BY Code__c];
	        for (Signatory_Group__c sg : signatoryGroupList)
	        {
	        	SignatoryGroupType sgt = new SignatoryGroupType();

	            sgt.Label = sg.Description__c;
	            sgt.Value = sg.Code__c;
	            response.SignatoryGroupList.add(sgt);
	        }

	        Teller_Mandates_Controller.MandateSignatories mandateSignatories = Teller_Mandates_Controller.getSignatories(AccountNo);
	        response.SignatoryList = mandateSignatories.signatories;
	        response.Success = true;
		}
		catch (Exception ex)
		{
			response.Success = false;
			response.ErrorCode = 'S001';
			response.ErrorMessage = response.ErrorCode + ' - ' + ex;
		}
		return response;
	}

	global static SaveSignatoriesResponse SaveSignatories (List<Teller_Mandates_Controller.Signatory> request)
	{
		SaveSignatoriesResponse response = new SaveSignatoriesResponse();

		try
		{
			List<Asset_Relationship__c> assetRelationshipList = new List<Asset_Relationship__c>();
	        List<Signatory_Group__c> signatoryGroupList = [SELECT Id, Code__c, Description__c
	        											   FROM Signatory_Group__c];
	   		system.debug('signatoryGroupList: ' + signatoryGroupList);

	   		Map<String, Id> signatoryGroupMap = new Map<String, Id>();
	   		for(Signatory_Group__c sg : signatoryGroupList)
	   		{
	   			signatoryGroupMap.put(sg.Code__c, sg.Id);
	   		}

	   		for(Teller_Mandates_Controller.Signatory sig : request)
	   		{
	   			Asset_Relationship__c ar = new Asset_Relationship__c();
	   			ar.Id = sig.AccountHolderId;
	   			ar.Signatory_Group__c = signatoryGroupMap.get(sig.SignatoryGroup);

	   			assetRelationshipList.add(ar);
	   		}

	   		update (assetRelationshipList);

	   		response.Success = true;
		}
		catch (Exception ex)
		{
			response.Success = false;
			response.ErrorCode = 'S002';
			response.ErrorMessage = response.ErrorCode + ' - ' + ex;
		}

		return response;
	}


	global class SignatoryGroups
	{
		public List<Teller_Mandates_Controller.Signatory> SignatoryList {get;set;}
		public List<SignatoryGroupType> SignatoryGroupList {get;set;}
        public Boolean Success {get;set;}
        public String ErrorCode{get;set;}
        public String ErrorMessage{get;set;}
	}

	global class SignatoryGroupType{
        public String Label{get;set;}
        public String Value{get;set;}
    }

    global class SaveSignatoriesResponse
    {
        public Boolean Success {get;set;}
        public String ErrorCode{get;set;}
        public String ErrorMessage{get;set;}
    }
}