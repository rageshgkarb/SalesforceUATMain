/* ---------------------------------------------------------------------------------------------------	*/
/* C0689 Process HR SML requests web service															*/
/* ---------------------------------------------------------------------------------------------------	*/
/* C0738 Set case woner to 'ReportsTo' if available, other wise leave with queue						*/
/* ---------------------------------------------------------------------------------------------------	*/


public class HRSMLProcessing 
{ 
	public List<String> employeeIds { get ; set ; }
	public Map<String, RecordType> recordTypeMap {get ; set ; }
	public List<Case> casesToInsert { get ; set ; }
	public List<Case> casesToUpdate { get ; set ; }
	public Map<string , Case > checkCaseMap { get ; set ; }
	public Map<String, HRSMLRequestRecord> HRRecordMap {get ; set ; }
	public string messageType { get ; set ; }
	public string theRecordType { get ; set ; }
	public HRSMLRequest theRequest { get ; set ; }
	public List<String> theReportingTos {get ; set ; }
	public Map<String, User> userMap {get ; set ; }
	public string theQueue {get ; set ; }
	public List<String> theNames { get ; set ; }
	public Map<String, User> nameMap { get ; set ; }
	public HRSMLResponse hResponse { get ; set ; }
	
	
	public HRSMLProcessing ()
	{
		//GetRecordTypes ();
	}

	public string ProcessSML (HRSMLRequest req)
	{

		theRequest = req;
		string rtv = '';

		messagetype = theRequest.MessageName;
		RecordType theType = new RecordType();
		System.debug ( 'The Message Name ' + theRequest.MessageName);
		System.debug ( 'The HRRecords ' + theRequest.HRRecords.size());
		if (theRequest.HRRecords.size() > 0)
		{
			System.debug ( 'The Message Name 2 ' + theRequest.MessageName);
			GetLookups ();
			if (theRequest.MessageName.equalsIgnoreCase ('NewStarters'))
			{
				System.debug ( 'The recordTypeMap 2 ' + recordTypeMap);
				theType = recordTypeMap.get ('New_Starters');
				theRecordType = theType.Id;
				rtv = ProcessStarters ();
			}
			else if ( theRequest.MessageName.equalsIgnoreCase ('Movers' ))
			{
				theType = recordTypeMap.get ('Movers');
				theRecordType = theType.Id;
				rtv = ProcessMovers ();
			}
			else if ( theRequest.MessageName.equalsIgnoreCase('Leavers' ))
			{
				System.debug ( 'The Message Name 3 ' + theRequest.MessageName);
				theType = recordTypeMap.get ('Leavers');
				System.debug ( 'The Type  ' + theType);
				System.debug ( 'The Type  ID ' + theType.Id);
				theRecordType = theType.Id;
				rtv = ProcessLeavers ();
			}
		}
		else
		{
			hResponse = new HRSMLResponse ();
			hResponse.JobID = theRequest.JobID;
			hResponse.ResponseCode = '00';
			hResponse.ResponseMessage = 'No HR Records To Process';
			rtv = ResponseMessage();
		}

		return rtv;
	}

	public string ProcessStarters ()
	{
		string rtv;
		CheckCases();
		System.debug ( 'The requestRecords starters ' + theRequest.HRRecords);
		casestoinsert = new List<Case>();
		for (HRSMLRequestRecord rec : theRequest.HRRecords)
		{
			string CaseSubject = 'Starter Request for ' + rec.FirstName + ' ' + rec.LastName + ' ID ' + rec.EmployeeID;
			string CaseDescription;
			System.debug ( 'The CaseSubject starters ' + CaseSubject);
			System.debug ( 'The employeeid starters ' + rec.EmployeeId);
			System.debug ('the checkcasemap starters ' + checkcasemap );
			if (checkCaseMap.size() == 0 || (!checkCaseMap.containsKey(rec.EmployeeId)))
			{
				System.debug ( 'about to create case starters ' + rec.EmployeeId);
				string reportsToID = '';	// C0738
				Case c = new Case ();
				c.recordTypeID = theRecordType;
				if (userMap.ContainsKey (rec.ReportsTo))
				{
					User u = userMap.get (rec.ReportsTo);
					c.SML_Reports_To__c = u.Id;
					reportsToID = u.Id;	// C0738
				}
				System.debug ( 'case reports to starters ' + c.SML_reports_to__c);
				casesubject = caseSubject + ' Reports To ' + rec.ReportsTo;
				CaseDescription = CaseSubject;
				CaseSubject = CaseSubject + ' Start Date ' + Date.parse(rec.StartDate);
				c.subject = CaseSubject;
				System.debug ( 'case subject starters ' + c.subject);
				c.New_Starter_Title__c = rec.Title;
				c.People_Employee_ID__c = rec.EmployeeID;
				System.debug ( 'case People_Employee_ID__c starters ' + c.People_Employee_ID__c);
				//if (nameMap.containsKey(rec.FirstName + ' ' + rec.LastName))
				//{
					//User leaver = nameMap.get(rec.FirstName + ' ' + rec.LastName);
					//string LeaversID = Leaver.id;
					//c.Leavers_Name__c = LeaversID;
				//}
				c.New_Starter_Full_Name__c = rec.FirstName + ' ' + rec.LastName;
				System.debug ( 'case Leavers_Name__c starters ' + c.New_Starter_Full_Name__c);
				c.Job_Role__c = rec.JobRole;
				CaseDescription = CaseDescription + ' Job Role ' + rec.JobRole;
				System.debug ( 'case Job_Role__c starters ' + c.Job_Role__c);
				c.Known_As__c = rec.KnownAs;
				System.debug ( 'case Known_As__c starters ' + c.Known_As__c);
				System.debug ( 'req StartDate starters ' + rec.StartDate);
				CaseDescription = CaseDescription + ' Start Date ' + rec.StartDate;
				c.Start_Date__c = Date.parse(rec.StartDate);
				c.Date_to_Be_Actioned__c = Date.parse(rec.StartDate);
				System.debug ( 'case Start_Date__c starters ' + c.Start_Date__c);
				//c.New_Role__c = rec.JobRole;
				c.Location_1__c = rec.Location;
				//c.SML_Location__c = rec.Location;
				System.debug ( 'case Location_1__c starters ' + c.SML_Location__c);
				CaseDescription = CaseDescription + ' Location ' + rec.Location;
				c.Department__c = rec.Department;
				System.debug ( 'case SML_Department__c starters ' + c.SML_Department__c);
				CaseDescription = CaseDescription + ' Department ' + rec.Department;
				c.SML_Employment_Type__c = rec.EmploymentType;
				System.debug ( 'case SML_Employment_Type__c starters ' + c.SML_Employment_Type__c);
				CaseDescription = CaseDescription + ' Employment Type ' + rec.EmploymentType;
				c.Description = CaseDescription;
				/* C0738 */
				//c.ownerid = theQueue;
				c.ownerid = !String.isBlank(reportsToID) ? reportsToID : theQueue;
				/* C0738 */
				System.debug ( 'case ownerid starters ' + c.ownerid);
				System.debug ( 'Case Insert  starters ' + c);
				c.EBS_Action_Status__c = 'Complete';
				casesToinsert.add (c);
				System.debug ( 'Cases Insert  starters ' + casesToinsert);
			}

		}

		hResponse = new HRSMLResponse ();
		hResponse.ResponseCode = '';
		hResponse.ResponseMessage = '';
		if (casesToInsert.size() > 0)
		{
			List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
			saveResults = Database.Insert (casesToInsert, false );
			if (saveResults.size () > 0 )
			{
				for ( integer i = 0; i < saveResults.Size() ; i++)
				{
					Database.SaveResult ur = saveResults.get (i);
				
					if (ur.IsSuccess ())
					{
						if (String.IsBlank (hResponse.responseCode))
						{
							hResponse.responseCode = '00';
							//resp.responseMessage = 'SUCCEEDED';
						}
					}
					else
					{
						hResponse.responseCode = '21';
						List<Database.Error> errs = ur.getErrors();
						Database.Error err = errs[0];
						hResponse.responseMessage = err.getMessage();
					}
				
				}
			 }
		 }
		 else 
		 {
			hResponse.responseCode = '00';
			hResponse.responseMessage = 'SUCCEEDED';
		 }

		
		hResponse.JobID = theRequest.JobID;
		rtv = ResponseMessage();


		//insert casesToInsert;
		return rtv;
	}

	public string ProcessMovers ()
	{
		string rtv;
		CheckCases();
		System.debug ( 'The requestRecords movers ' + theRequest.HRRecords);
		casestoinsert = new List<Case>();
		for (HRSMLRequestRecord rec : theRequest.HRRecords)
		{
			string CaseSubject = 'Mover Request for ' + rec.FirstName + ' ' + rec.LastName + ' ID ' + rec.EmployeeID;
			string CaseDescription;
			System.debug ( 'The CaseSubject movers ' + CaseSubject);
			System.debug ( 'The employeeid movers ' + rec.EmployeeId);
			System.debug ('the checkcasemap movers ' + checkcasemap );
			if (checkCaseMap.size() == 0 || (!checkCaseMap.containsKey(rec.EmployeeId)))
			{
				System.debug ( 'about to create case movers ' + rec.EmployeeId);
				Case c = new Case ();
				c.recordTypeID = theRecordType;
				string reportsToID = '';	// C0738
				if (userMap.ContainsKey (rec.ReportsTo))
				{
					User u = userMap.get (rec.ReportsTo);
					c.SML_Reports_To__c = u.Id;
					reportsToID = u.Id;	// C0738
				}
				System.debug ( 'case reports to movers ' + c.SML_reports_to__c);
				casesubject = caseSubject + ' Reports To ' + rec.ReportsTo ;
				CaseDescription = CaseSubject;
				CaseSubject = CaseSubject + ' Move Date ' + Date.parse(rec.EffectiveFrom);
				c.subject = CaseSubject;
				System.debug ( 'case subject movers ' + c.subject);
				//c.New_Starter_Title__c = rec.Title;
				c.People_Employee_ID__c = rec.EmployeeID;
				System.debug ( 'case People_Employee_ID__c movers ' + c.People_Employee_ID__c);
				if (nameMap.containsKey(rec.FirstName + ' ' + rec.LastName))
				{
					User mover = nameMap.get(rec.FirstName + ' ' + rec.LastName);
					string MoversID = mover.id;
					c.Movers_Name__c = MoversID;
				}
				//c.Leavers_Name__c = rec.FirstName + ' ' + rec.LastName;
				System.debug ( 'case Movers_Name__c movers ' + c.Movers_Name__c);
				c.Job_Role__c = rec.JobRole;
				CaseDescription = CaseDescription + ' Job Role ' + rec.JobRole;
				System.debug ( 'case Job_Role__c movers ' + c.Job_Role__c);
				c.Known_As__c = rec.KnownAs;
				System.debug ( 'case Known_As__c movers ' + c.Known_As__c);
				System.debug ( 'req EffectiveFrom movers ' + rec.EffectiveFrom);
				CaseDescription = CaseDescription + ' Moving Date ' + rec.EffectiveFrom;
				c.Move_Date__c = Date.parse(rec.EffectiveFrom);
				c.Date_to_Be_Actioned__c = Date.parse(rec.EffectiveFrom);
				System.debug ( 'case Move_Date__c movers ' + c.Move_Date__c);
				//c.New_Role__c = rec.JobRole;
				c.Location_1__c = rec.Location;
				//c.SML_Location__c = rec.Location;
				System.debug ( 'case Location_1__c movers ' + c.SML_Location__c);
				CaseDescription = CaseDescription + ' movers ' + rec.Location;
				c.Department__c = rec.Department;
				System.debug ( 'case SML_Department__c movers ' + c.SML_Department__c);
				CaseDescription = CaseDescription + ' Department ' + rec.Department;
				c.SML_Employment_Type__c = rec.EmploymentType;
				System.debug ( 'case SML_Employment_Type__c movers ' + c.SML_Employment_Type__c);
				CaseDescription = CaseDescription + ' Employment Type ' + rec.EmploymentType;
				c.Description = CaseDescription;
				/* C0738 */
				//c.ownerid = theQueue;
				c.ownerid = !String.isBlank(reportsToID) ? reportsToID : theQueue;
				/* C0738 */
				System.debug ( 'case ownerid movers ' + c.ownerid);
				System.debug ( 'Case Insert  movers ' + c);
				c.EBS_Action_Status__c = 'Complete';
				casesToinsert.add (c);
				System.debug ( 'Cases Insert  movers ' + casesToinsert);
			}

		}
		hResponse = new HRSMLResponse ();
		hResponse.ResponseCode = '';
		hResponse.ResponseMessage = '';
		if (casesToInsert.size() > 0)
		{
			List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
			saveResults = Database.Insert (casesToInsert, false );
			if (saveResults.size () > 0 )
			{
				for ( integer i = 0; i < saveResults.Size() ; i++)
				{
					Database.SaveResult ur = saveResults.get (i);
				
					if (ur.IsSuccess ())
					{
						if (String.IsBlank (hResponse.responseCode))
						{
							hResponse.responseCode = '00';
							//resp.responseMessage = 'SUCCEEDED';
						}
					}
					else
					{
						hResponse.responseCode = '21';
						List<Database.Error> errs = ur.getErrors();
						Database.Error err = errs[0];
						hResponse.responseMessage = err.getMessage();
					}
				
				}
			 }
		 }
		 else 
		 {
			hResponse.responseCode = '00';
			hResponse.responseMessage = 'SUCCEEDED';
		 }

		
		hResponse.JobID = theRequest.JobID;
		rtv = ResponseMessage();


		return rtv;
	}

	public string ProcessLeavers ()
	{
		string rtv;
		CheckCases();

		System.debug ( 'The requestRecords leavers ' + theRequest.HRRecords);
		casestoinsert = new List<Case>();
		for (HRSMLRequestRecord rec : theRequest.HRRecords)
		{
			string CaseSubject = 'Leaver Request for ' + rec.FirstName + ' ' + rec.LastName + ' ID ' + rec.EmployeeID;
			string CaseDescription;
			System.debug ( 'The CaseSubject leavers ' + CaseSubject);
			System.debug ( 'The employeeid leavers ' + rec.EmployeeId);
			System.debug ('the checkcasemap leavers ' + checkcasemap );
			if (checkCaseMap.size() == 0 || (!checkCaseMap.containsKey(rec.EmployeeId)))
			{
				System.debug ( 'about to create case leavers ' + rec.EmployeeId);
				string reportsToID = '';	// C0738
				Case c = new Case ();
				c.recordTypeID = theRecordType;
				if (userMap.ContainsKey (rec.ReportsTo))
				{
					User u = userMap.get (rec.ReportsTo);
					c.SML_Reports_To__c = u.Id;
					reportsToID = u.Id;	// C0738
				}
				System.debug ( 'case reports to leavers ' + c.SML_reports_to__c);
				casesubject = caseSubject + ' Reports To ' + rec.ReportsTo ;
				CaseDescription = CaseSubject;
				CaseSubject = CaseSubject + ' Leave Date ' + Date.parse(rec.FinalDayofEmployment);
				c.subject = CaseSubject;
				System.debug ( 'case subject leavers ' + c.subject);
				//c.New_Starter_Title__c = rec.Title;
				c.People_Employee_ID__c = rec.EmployeeID;
				System.debug ( 'case People_Employee_ID__c leavers ' + c.People_Employee_ID__c);
				if (nameMap.containsKey(rec.FirstName + ' ' + rec.LastName))
				{
					User leaver = nameMap.get(rec.FirstName + ' ' + rec.LastName);
					string LeaversID = Leaver.id;
					c.Leavers_Name__c = LeaversID;
				}
				//c.Leavers_Name__c = rec.FirstName + ' ' + rec.LastName;
				System.debug ( 'case Leavers_Name__c leavers ' + c.Leavers_Name__c);
				c.Job_Role__c = rec.JobRole;
				CaseDescription = CaseDescription + ' Job Role ' + rec.JobRole;
				System.debug ( 'case Job_Role__c leavers ' + c.Job_Role__c);
				c.Known_As__c = rec.KnownAs;
				System.debug ( 'case Known_As__c leavers ' + c.Known_As__c);
				System.debug ( 'req FinalDayofEmployment leavers ' + rec.FinalDayofEmployment);
				CaseDescription = CaseDescription + ' Leaving Date ' + rec.FinalDayofEmployment;
				c.Leaving_Date__c = Date.parse(rec.FinalDayofEmployment);
				c.Date_to_Be_Actioned__c = Date.parse(rec.FinalDayofEmployment);
				System.debug ( 'case Leaving_Date__c leavers ' + c.Leaving_Date__c);
				//c.New_Role__c = rec.JobRole;
				c.Location_1__c = rec.Location;
				//c.SML_Location__c = rec.Location;
				System.debug ( 'case Location_1__c leavers ' + c.SML_Location__c);
				CaseDescription = CaseDescription + ' Location ' + rec.Location;
				c.Department__c = rec.Department;
				System.debug ( 'case SML_Department__c leavers ' + c.SML_Department__c);
				CaseDescription = CaseDescription + ' Department ' + rec.Department;
				c.SML_Employment_Type__c = rec.EmploymentType;
				System.debug ( 'case SML_Employment_Type__c leavers ' + c.SML_Employment_Type__c);
				CaseDescription = CaseDescription + ' Employment Type ' + rec.EmploymentType;
				c.Description = CaseDescription;
				/* C0738 */
				//c.ownerid = theQueue;
				c.ownerid = !String.isBlank(reportsToID) ? reportsToID : theQueue;
				/* C0738 */
				System.debug ( 'case ownerid leavers ' + c.ownerid);
				System.debug ( 'Case Insert  Leavers ' + c);
				c.EBS_Action_Status__c = 'Complete';
				casesToinsert.add (c);
				System.debug ( 'Cases Insert  Leavers ' + casesToinsert);
			}

		}

		hResponse = new HRSMLResponse ();
		hResponse.ResponseCode = '';
		hResponse.ResponseMessage = '';
		if (casesToInsert.size() > 0)
		{
			List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
			saveResults = Database.Insert (casesToInsert, false );
			if (saveResults.size () > 0 )
			{
				for ( integer i = 0; i < saveResults.Size() ; i++)
				{
					Database.SaveResult ur = saveResults.get (i);
				
					if (ur.IsSuccess ())
					{
						if (String.IsBlank (hResponse.responseCode))
						{
							hResponse.responseCode = '00';
							//resp.responseMessage = 'SUCCEEDED';
						}
					}
					else
					{
						hResponse.responseCode = '21';
						List<Database.Error> errs = ur.getErrors();
						Database.Error err = errs[0];
						hResponse.responseMessage = err.getMessage();
					}
				
				}
			 }
		 }
		 else 
		 {
			hResponse.responseCode = '00';
			hResponse.responseMessage = 'SUCCEEDED';
		 }

		
		hResponse.JobID = theRequest.JobID;
		rtv = ResponseMessage();


		return rtv;
		
	}

	public void GetLookups ()
	{
		List<RecordType> recTypes = [select id, 
											name, 
											developername 
										from recordtype 
										where developername in ('New_Starters', 'Leavers', 'Movers')];

		if (recTypes.size() > 0)
		{
			recordTypeMap = new Map<string , RecordType>();
			for (RecordType recType : recTypes)
			{
				recordTypeMap.put (recType.DeveloperName, recType);
			}
		}
		
		HRRecordMap = new Map<string , HRSMLRequestRecord>();
		System.debug ( 'The request records ' + theRequest.HRRecords);
		employeeids = new List<String>();
		theReportingTos = new List<String>();
		theNames = new List<String>();
		for (HRSMLRequestRecord rec : theRequest.HRRecords)
		{
			System.debug ( 'The rec ' + rec);
			System.debug ( 'The rec Employeeid ' + rec.employeeid );
			employeeIds.add(rec.EmployeeId);
			System.debug ( ' The employeeIds ' + employeeIds);
			theReportingTos.add (rec.ReportsTo);
			System.debug ( ' The theReportingTos ' + theReportingTos);
			HRRecordMap.put (rec.EmployeeId, rec);
			System.debug ( 'The HRRecordMap ' + HRRecordMap );
			theNames.add (rec.FirstName + ' ' + rec.LastName );
		}

		string theReportingToList = PrepareReportingToList ();
		System.debug ( 'The reportingto list ' + theReportingToList );
		List<User> reps = [SELECT Id,
									Name
							FROM	User
							WHERE	Name in :theReportingTos];
		System.debug ( 'The reports ' + reps);
		System.debug ( 'The reports size ' + reps.size());
		userMap = new Map<String, user>();
		if (reps.Size() > 0)
		{
			for (User u: reps )
			{
				userMap.put (u.Name , u );
			}
		}
		System.debug ( 'The user map ' + userMap);

		List<User> names = [SELECT Id,
									Name
							FROM	User 
							WHERE	Name in :theNames];
		nameMap = new Map<String, user >();
		if (names.Size() > 0)
		{
			for (User name: names )
			{
				nameMap.put (name.Name , name );
			}
		}

		System.debug ( 'The name map ' + nameMap);

		List<queuesobject> queues = [SELECT id,
											queueid ,
											Queue.name
									FROM QueueSObject
									where Queue.name = 'Helpdesk'];

		if (queues.size() > 0 )
		{
			theQueue = queues [0].queueid;
		}

		System.debug ( 'The queue ' + theQueue );

	}

	public string PrepareReportingToList ()
	{
		string rtv = '';
		 rtv = '(';
        for (string s : theReportingTos)
        {
            rtv = rtv + '\'' + s + '\',';
        }
        rtv = rtv.Substring(0, rtv.lastIndexOf(','));
        rtv= rtv + ')';
		return rtv;
	}

	public void CheckCases ()
	{
		

		List<Case> casesToCheck = [SELECT id,
										People_Employee_id__c,
										Start_Date__c,
										Move_Date__c,
										Leaving_Date__c,
										CaseNumber,
										RecordTypeId,
										Status
									FROM Case 
									WHERE People_Employee_id__c in :employeeIds
									AND recordTypeid = :theRecordType];

		checkCaseMap = new Map<String, Case>();		
		casesToUpdate = new List<Case>();						
		if (casesToCheck.Size() > 0)
		{
			
			for (Case c : casesToCheck)
			{
				checkCaseMap.put (c.People_Employee_id__c, c );
				
				if (HRRecordMap.containsKey (c.People_employee_id__c))
				{
					HRSMLRequestRecord rec1 = new HRSMLRequestRecord ();
					rec1 = HRRecordMap.get (c.People_Employee_id__c);
					if (theRequest.MessageName == 'NewStarters')
					{
						if (c.Start_Date__c != Date.Parse(rec1.StartDate))
						{
							c.Start_Date__c = Date.Parse(rec1.StartDate);
							c.Date_to_Be_Actioned__c = Date.Parse(rec1.StartDate);
							c.Subject = c.Subject + ' New date ' + Date.Parse(rec1.StartDate);
							casesToUpdate.add (c);
						}
					}
					else if (theRequest.MessageName == 'Movers')
					{
						if (c.Move_Date__c != Date.Parse(rec1.EffectiveFrom))
						{
							c.Move_Date__c = Date.Parse(rec1.EffectiveFrom);
							c.Date_to_Be_Actioned__c = Date.Parse(rec1.EffectiveFrom);
							c.Subject = c.Subject + ' New date ' + Date.Parse(rec1.EffectiveFrom);
							casesToUpdate.add (c);
						}
					}
					else if (theRequest.MessageName == 'Leavers')
					{
						if (c.Leaving_Date__c != Date.Parse(rec1.FinalDayOfEmployment))
						{
							c.Leaving_Date__c = Date.Parse(rec1.FinalDayOfEmployment);
							c.Date_to_Be_Actioned__c = Date.Parse(rec1.FinalDayOfEmployment);
							c.Subject = c.Subject + ' New date ' + Date.Parse(rec1.FinalDayOfEmployment);
							casesToUpdate.add (c);
						}
					}
				}
			}

			if (casesToUpdate.size() > 0)
			{
				update casesToUpdate;
			}
		}
		
	}
	public string ResponseMessage (HRSMLResponse ahResponse)
	{
		string rtv = '<SFDCHRJobResponse>';
		rtv = rtv + '<JobID>' + ahResponse.JobID + '</JobID>';
		rtv = rtv + '<ResponseCode>' + ahResponse.responseCode + '</ResponseCode>';
		rtv = rtv + '<ResponseMessage>' + ahResponse.responseMessage + '</ResponseMessage>';
		rtv = rtv + '</SFDCHRJobResponse>';
		return rtv;
	}
	
	public string ResponseMessage ()
	{
		string rtv = '<SFDCHRJobResponse>';
		rtv = rtv + '<JobID>' + hResponse.JobID + '</JobID>';
		rtv = rtv + '<ResponseCode>' + hResponse.responseCode + '</ResponseCode>';
		rtv = rtv + '<ResponseMessage>' + hResponse.responseMessage + '</ResponseMessage>';
		rtv = rtv + '</SFDCHRJobResponse>';
		return rtv;
	}
}