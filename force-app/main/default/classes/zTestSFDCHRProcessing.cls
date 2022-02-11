/* ---------------------------------------------------------------------------------------------------	*/
/* C0689 Process HR SML requests web service															*/
/* ---------------------------------------------------------------------------------------------------	*/

@isTest
private class zTestSFDCHRProcessing 
{
	static testmethod void processHRLeavers ()
	{
		Profile p = [Select id from profile LIMIT 1];
		

	
		User u = new User ();
		u.FirstName = 'Kowsar';
		u.LastName = 'Chowdhury';
		u.username = 'foo@blah.com';
		u.email = 'foo@blah.com';
		u.CommunityNickname = 'foo ';
		u.TimeZoneSidKey = 'Europe/London';
		u.LocaleSidKey = 'en_GB';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.ProfileId = p.id;
		u.LanguageLocaleKey = 'en_US';
		u.alias = 'foo';
		insert u ;

		User u2 = new User ();
		u2.firstname = 'Sanjay';
		u2.lastname = 'Rajagopal';
		u2.username = 'foo2@blah.com';
		u2.email = 'foo@blah.com';
		u2.CommunityNickname = 'foo2';
		u2.TimeZoneSidKey = 'Europe/London';
		u2.LocaleSidKey = 'en_GB';
		u2.EmailEncodingKey = 'ISO-8859-1';
		u2.ProfileId = p.id;
		u2.LanguageLocaleKey = 'en_US';
		u2.alias = 'foo';
		insert u2;


		string inxml = '<processHRSMLRequests><JobID>3</JobID><MessageName>Leavers</MessageName><Result><EmployeeId>006620</EmployeeId><Title>Mr</Title><FirstName>Kowsar</FirstName><LastName>Chowdhury</LastName><KnownAs /><StartDate>09/11/2015</StartDate><JobRole>Project Manager</JobRole><Location>Birmingham - Calthorpe Rd</Location><Department>Transformation</Department><ReportsTo>Sanjay Rajagopal</ReportsTo><EmploymentType>Employee - Permanent - Full time</EmploymentType><FinalDayofEmployment>06/04/2018</FinalDayofEmployment><FinalDayinOffice>06/04/2018</FinalDayinOffice><EffectiveFrom /></Result></processHRSMLRequests>';

		string testResponse = SFDCProcessHR.processHRSMLRequests (inxml);

	}

	static testmethod void processHRStarters ()
	{
		Profile p = [Select id from profile LIMIT 1];
		
	
		User u = new User ();
		u.FirstName = 'Kowsar';
		u.LastName = 'Chowdhury';
		u.username = 'foo@blah.com';
		u.email = 'foo@blah.com';
		u.CommunityNickname = 'foo ';
		u.TimeZoneSidKey = 'Europe/London';
		u.LocaleSidKey = 'en_GB';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.ProfileId = p.id;
		u.LanguageLocaleKey = 'en_US';
		u.alias = 'foo';
		insert u ;

		User u2 = new User ();
		u2.firstname = 'Sanjay';
		u2.lastname = 'Rajagopal';
		u2.username = 'foo2@blah.com';
		u2.email = 'foo@blah.com';
		u2.CommunityNickname = 'foo2';
		u2.TimeZoneSidKey = 'Europe/London';
		u2.LocaleSidKey = 'en_GB';
		u2.EmailEncodingKey = 'ISO-8859-1';
		u2.ProfileId = p.id;
		u2.LanguageLocaleKey = 'en_US';
		u2.alias = 'foo';
		insert u2;

		string inxml = '<processHRSMLRequests><JobID>3</JobID><MessageName>NewStarters</MessageName><Result><EmployeeId>006620</EmployeeId><Title>Mr</Title><FirstName>Kowsar</FirstName><LastName>Chowdhury</LastName><KnownAs /><StartDate>06/04/2018</StartDate><JobRole>Project Manager</JobRole><Location>Birmingham - Calthorpe Rd</Location><Department>Transformation</Department><ReportsTo>Sanjay Rajagopal</ReportsTo><EmploymentType>Employee - Permanent - Full time</EmploymentType><FinalDayofEmployment></FinalDayofEmployment><FinalDayinOffice>06/04/2018</FinalDayinOffice><EffectiveFrom /></Result></processHRSMLRequests>';

		string testResponse = SFDCProcessHR.processHRSMLRequests (inxml);

	}

	static testmethod void processHRMovers ()
	{
		Profile p = [Select id from profile LIMIT 1];
		

		User u = new User ();
		u.FirstName = 'Kowsar';
		u.LastName = 'Chowdhury';
		u.username = 'foo@blah.com';
		u.email = 'foo@blah.com';
		u.CommunityNickname = 'foo ';
		u.TimeZoneSidKey = 'Europe/London';
		u.LocaleSidKey = 'en_GB';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.ProfileId = p.id;
		u.LanguageLocaleKey = 'en_US';
		u.alias = 'foo';
		insert u ;

		User u2 = new User ();
		u2.firstname = 'Sanjay';
		u2.lastname = 'Rajagopal';
		u2.username = 'foo2@blah.com';
		u2.email = 'foo@blah.com';
		u2.CommunityNickname = 'foo2';
		u2.TimeZoneSidKey = 'Europe/London';
		u2.LocaleSidKey = 'en_GB';
		u2.EmailEncodingKey = 'ISO-8859-1';
		u2.ProfileId = p.id;
		u2.LanguageLocaleKey = 'en_US';
		u2.alias = 'foo';
		insert u2;


		string inxml = '<processHRSMLRequests><JobID>3</JobID><MessageName>Movers</MessageName><Result><EmployeeId>006620</EmployeeId><Title>Mr</Title><FirstName>Kowsar</FirstName><LastName>Chowdhury</LastName><KnownAs /><StartDate>09/11/2015</StartDate><JobRole>Project Manager</JobRole><Location>Birmingham - Calthorpe Rd</Location><Department>Transformation</Department><ReportsTo>Sanjay Rajagopal</ReportsTo><EmploymentType>Employee - Permanent - Full time</EmploymentType><FinalDayofEmployment></FinalDayofEmployment><FinalDayinOffice>06/04/2018</FinalDayinOffice><EffectiveFrom>06/04/2018</EffectiveFrom></Result></processHRSMLRequests>';

		string testResponse = SFDCProcessHR.processHRSMLRequests (inxml);

	}

	static testmethod void processHRStarters1 ()
	{
		

		string inxml = '<processHRSMLRequests><JobID>3</JobID><MessageName>NewStarters</MessageName><Result></Result></processHRSMLRequests>';

		string testResponse = SFDCProcessHR.processHRSMLRequests (inxml);

	}

	static testmethod void processHRSMovers1 ()
	{
		

		string inxml = '<processHRSMLRequests><JobID>3</JobID><MessageName>Movers</MessageName><Result></Result></processHRSMLRequests>';

		string testResponse = SFDCProcessHR.processHRSMLRequests (inxml);

	}

	static testmethod void processHRSLeavers1 ()
	{
		

		string inxml = '<processHRSMLRequests><JobID>3</JobID><MessageName>Leavers</MessageName><Result></Result></processHRSMLRequests>';

		string testResponse = SFDCProcessHR.processHRSMLRequests (inxml);

	}

	static testmethod void processDuff1 ()
	{
		

		string inxml = '<processHRSMLRequests><JobID>3</JobID><MessageName>Leavers</MessageName><Result></Result>/processHRSMLRequests>';

		string testResponse = SFDCProcessHR.processHRSMLRequests (inxml);

	}
	//static testmethod void processHRLeavers ()
	//{
		//string inxml = '<processHRSMLRequests><JobID>3</JobID><MessageName>Leavers</MessageName><Result><EmployeeId>006620</EmployeeId><Title>Mr</Title><FirstName>Kowsar</FirstName><LastName>Chowdhury</LastName><KnownAs /><StartDate>09/11/2015</StartDate><JobRole>Project Manager</JobRole><Location>Birmingham - Calthorpe Rd</Location><Department>Transformation</Department><ReportsTo>Abdul-Majid Ashraf</ReportsTo><EmploymentType>Employee - Permanent - Full time</EmploymentType><FinalDayofEmployment>06/04/2018</FinalDayofEmployment><FinalDayinOffice>06/04/2018</FinalDayinOffice><EffectiveFrom /></Result><processHRSMLRequests>';

		//string testResponse = SFDCProcessHR.processHRSMLRequests (inxml);

	//}
}