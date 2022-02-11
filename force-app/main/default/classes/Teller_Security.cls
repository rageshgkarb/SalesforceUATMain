global class Teller_Security
{
	global static Boolean IsPermitted(String functionName)
	{
		system.debug('Teller_Security.IsPermitted Entry');
		system.debug('functionName: ' + functionName);

		Boolean response = false;

		User u = [select Id, Name, UserRole.Id, UserRole.Name from User where Id=:UserInfo.getUserId()];
		Teller_Role__c tr = [select Id, Name from Teller_Role__c where Name=:u.UserRole.Name];
		String userRoleId = tr.Id;

		List<Teller_Function__c> tf = [select Id from Teller_Function__c where Name=:functionName];
		
		if(tf != null && tf.size() > 0)
		{
			String functionId = tf[0].Id;

			List<Teller_Access__c> taList = [select Id, Name from Teller_Access__c where Teller_Function__r.Id=:functionId and Teller_Role__r.Id=:userRoleId];

			if (taList.size() > 0)
			{
				response = true;
			}
		}

		system.debug('response: ' + response);
		return response;
	}
	
	global static Boolean IsPermitted(Id functionId)
	{
		system.debug('Teller_Security.IsPermitted Entry');
		system.debug('functionName: ' + functionId);

		Boolean response = false;

		User u = [select Id, Name, UserRole.Id, UserRole.Name from User where Id=:UserInfo.getUserId()];
		Teller_Role__c tr = [select Id, Name from Teller_Role__c where Name=:u.UserRole.Name];
		String userRoleId = tr.Id;

			List<Teller_Access__c> taList = [select Id, Name from Teller_Access__c where Teller_Function__r.Id=:functionId and Teller_Role__r.Id=:userRoleId];

			if (taList.size() > 0)
			{
				response = true;
			}
		

		system.debug('response: ' + response);
		return response;
	}
	
	public static void TellerFunctionSecurityCheck(String functionName)
	{
		System.debug('security check: ' + functionName);
		if(!Teller_Security.IsPermitted(functionName))
		{
			System.debug('failed security check: ' + functionName);
			throw new Teller_Exceptions.Teller_Security_Exception('Engage Security: Access to this module is not permitted, please contact your administrator.');
		}
	}
	
	public static void TellerFunctionSecurityCheck(Id functionId)
	{
		System.debug('security check: ' + functionId);
		if(!Teller_Security.IsPermitted(functionId))
		{
			System.debug('failed security check: ' + functionId);
			throw new Teller_Exceptions.Teller_Security_Exception('Engage Security: Access to this module is not permitted, please contact your administrator.');
		}
	}
}