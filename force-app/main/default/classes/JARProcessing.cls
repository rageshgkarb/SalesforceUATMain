/* ---------------------------------------------------------------------------------------------------- */
/* C0559	Horribly complex due to Salesforce governor limits and avoiding nested SOQL and DML			*/
/* ---------------------------------------------------------------------------------------------------- */

public class JARProcessing 
{
	public AccountJARSResponse theResponse {get ; set ;}
	public AccountJARS theJARS {get ; set ;}

	public List<string> accountNoIDs {get ; set ;}
	public List<string> EBSIDs {get ; set ;}
	public List<string> TheNewEBSIDs {get ; set ;}
	public List<string> TheNewAcctNos {get ; set ;}
	public List<Asset_Relationship__c> arsToInsert {get ; set ;}
	public List<Asset_Relationship__c> arsToUpdate {get ; set ;}
	public List<Asset_Relationship__c> arsToDeactivate {get ; set ;}

	public List<Asset_Relationship__c> arsToUpsert {get ; set ;}
	public List<AccountJARSResponse.AccountJARResponse> respList {get ; set ;}
	public List<AccountJARSResponse.AccountJARResponse> respPrimaryList {get ; set ;}
	public List<AccountJARSResponse.AccountJARResponse> respListToProcess {get ; set ;}
	public List<String> bankAccountJARS {get ; set ;}

	public Map <String, AccountJARS.JARS> theJARMap {get ; set ;}
	public Map <String, String> theAcctToEBSIDMap {get ; set ;}
	public Map <String, AccountJARS.JAR> theEBSAcctEBSIDtoJARSMap {get ; set ;}
	public Map <String, Asset_Relationship__c> theSFDCAcctEBSIDToJARMap {get ; set ;}
	public Map <String, Asset_Relationship__c> theNewAssRelAcctNoMap {get ; set ;}
	public Map <String, Account> theNewEBSIDJARAccounts {get ; set ;}
	public Map <String, Asset_Relationship__c> theNewAssRelMap  {get ; set ;}
	public Map <String, Account_with_IBB__c> TheNewEBSIDJARBankAccounts{get ; set ;}
	public Map <String, List<String>> bankAccountToJARS {get ; set ;}
	

	public string ProcessJARS (AccountJARS incomingJARS )
	{
		theJARS = new AccountJARS();
		theJARS = incomingJARS;
		theResponse = new AccountJARSResponse();
		theResponse.BatchID = theJARs.BatchID;

		respList = new List<AccountJARSResponse.AccountJARResponse>();
		respListToProcess = new List<AccountJARSResponse.AccountJARResponse>();
		respPrimaryList = new List<AccountJARSResponse.AccountJARResponse>();
		 
		/* Break up the incoming object to get lists for queries for the SFDC objects and generate lookup maps */
		GetIncomingJARSAccountNumbersAndLookups (); 
		/* Find and update the JARS on SFDC which match or don't exist on the incoming EBS list */
		GetIncomingJARSSFDCAssRels ();
		/* Identify the JARS on the Incoming List which aren't on the SFDC banbk account */
		GetIncomingJARSNotOnSFDC ();
		/* Try and sort the lists */
		SortOutListsToProcess ();
		/* DO The Upserts and try and map the responses back */
		DoUpdates ();
		/* Generate the reponse message */
		return CreateResponseMessage ();

		
	}

	public void GetIncomingJARSAccountNumbersAndLookups ()
	{
		// Create the bank account and customer id look up maps for the EBS data
		accountNoIDs = new List<String>();
		EBSIDs = new List<String>();
		theJARMap = new Map <String, AccountJARS.JARS>();
		theEBSAcctEBSIDtoJARSMap = new Map <String, AccountJARS.JAR>();
		//System.debug ('The accounts ' + theJARS);
		//System.debug ('The account JARS ' + theJARS.AcctJARS);
		for (AccountJARS.JARS jars : theJARS.AcctJARS )
		{
			//System.debug ('The JARS ' + jars );
			accountNoIDs.add (jars.acctNo);
			theJARMap.put (jars.acctNo, jars);
			bankAccountJARS = new List<String>();
			
			for (AccountJARS.JAR jar : jars.AcctJAR)
			{
				
				//System.debug ( 'The JAR ' + jar);
				AccountJARSResponse.AccountJARResponse jarResp = new AccountJARSResponse.AccountJARResponse();
				jarResp.msgID = jars.msgID;
				jarResp.accountNumber = jars.acctNo;
				jarResp.customerNo = jar.EBSID;

				EBSIDs.add(jar.EBSID);
				bankaccountJARS.add (jar.EBSID);

				theEBSAcctEBSIDtoJARSMap.put (jars.acctno + jar.EBSID, jar);
				if (!jars.primaryOnly)
				{
					respList.add(jarResp) ;
				}
				else 
				{
					AccountJARSResponse.AccountJARResponse jarRespPrim = new AccountJARSResponse.AccountJARResponse();
					jarRespPrim.msgID = jars.msgID;
					jarRespPrim.accountNumber = jars.acctNo;
					jarRespPrim.customerNo = jar.EBSID;
					respPrimaryList.add (jarRespPrim );
				}
			}
			
			bankAccountToJARS = new Map<String, List<String>>();
			bankAccountToJARS.put (jars.acctno , bankAccountJARS );
		}

		//System.debug ( 'The Rep List ' + respList);
		//System.debug ( 'The Prim Resp List ' + respPrimaryList );
	}	

	public void GetIncomingJARSSFDCAssRels ()
	{
		// Get the Salesforce asset_relationship__c records for the EBS Bank accounts

		theSFDCAcctEBSIDToJARMap = new Map <String, Asset_Relationship__c>();
		arsToUpdate = new List<Asset_Relationship__c>();
		arsToDeactivate = new List<Asset_Relationship__c>();
		System.debug ('The Account IDS ' + AccountNoIDs);
		List<Asset_Relationship__c> assrels = [SELECT	ID,
														Name,
														Customer_EBS_ID__c,
														Relationship_To_Primary_Applicant1__c,
														Account_with_IBB__r.EBS_ID__c,
														Account_with_IBB__r.Id,
														Prospect_Customer__r.Name,
														Prospect_Customer__r.EBS_ID__c ,
														Primary_Account_Holder__c,
														Is_Active__c,
														Account_with_IBB_Number__c ,
														Deactivation_Reason__c
												FROM    Asset_Relationship__c	
												WHERE	
														//Primary_Account_Holder__c = false
												//AND		
														Account_with_IBB__r.EBS_ID__c in :accountNoIDs];
		
		//System.debug ( 'The Ass Rels ' + assrels );

		if (assrels.size() > 0)
		{
			// Sort out the the JARS to be updated and deactivated. 
			//string testacct = '';
			//boolean first = true;
			for (Asset_Relationship__c assrel : assrels)
			{
				
				if (!assrel.Primary_Account_Holder__c) 
				{

					//theSFDCAcctEBSIDToJARMap.put(assrel.Account_with_IBB__r.EBS_ID__c + assrel.Customer_EBS_ID__c, assrel);
					theSFDCAcctEBSIDToJARMap.put(assrel.Account_with_IBB__r.EBS_ID__c + assrel.Prospect_Customer__r.EBS_ID__c , assrel);
					// try and find the EBS JAR from the salesforce equivalent
					// if it doesn't exist, it is to be deactivated, if it does it is to be updated
					AccountJARS.JAR testJAR = theEBSAcctEBSIDtoJARSMap.get(assrel.Account_with_IBB__r.EBS_ID__c + assrel.Prospect_Customer__r.EBS_ID__c );
				
					System.debug ( 'The EBS JAR found ? ' + TestJAR) ;
					boolean updateJAR = false;
					if (testJAR != null)
					{
					
						if (assrel.Relationship_To_Primary_Applicant1__c != testJAR.Relationship )
						{
							assrel.Relationship_To_Primary_Applicant1__c = testJAR.Relationship;
							updateJAR = true;
						}

						/* NEW */
						try
						{
							if (assrel.Name != (assrel.Account_with_IBB__r.EBS_ID__c + assrel.Prospect_Customer__r.EBS_ID__c))
							{
								assrel.Name = assrel.Account_with_IBB__r.EBS_ID__c + assrel.Prospect_Customer__r.EBS_ID__c;
							}
						}
						catch (Exception e )
						{
							System.debug ( 'Cannot update name ' + assrel.Account_with_IBB__r.EBS_ID__c + assrel.Prospect_Customer__r.EBS_ID__c + ' - ' + e.getMessage());
						}

						if (!assrel.Is_Active__c)
						{
							assrel.Is_Active__c = true;
							assrel.Deactivation_Reason__c = 'Reactivated as relationship exists on EBS ';
							updateJAR = true;
						}

						if (String.isBlank(assrel.Customer_EBS_ID__c) || assrel.Customer_EBS_ID__c != assrel.Prospect_Customer__r.EBS_ID__c)
						{
							assrel.Customer_EBS_ID__c = assrel.Prospect_Customer__r.EBS_ID__c;
						}


						if (updateJAR)
						{
							arsToUpdate.add(assrel);
						
						}
					}
					else
					{
					
						assrel.Is_Active__c = false;
						assrel.Deactivation_Reason__c = 'Deactivated as relationship does not exist on EBS ';
						arsToDeactivate.add(assrel);
					}
				}
			}
			//System.debug ( 'theSFDCAcctEBSIDToJARMap 1 ' + theSFDCAcctEBSIDToJARMap );
		}
	}

	public void GetIncomingJARSNotOnSFDC ()
	{
		TheNewEBSIDs = new List<String>();
		TheNewAcctNos = new List<String>();
		arsToInsert = new List<Asset_Relationship__c>();

		theAcctToEBSIDMap = new Map <String, String>();
		theNewAssRelAcctNoMap = new Map <String, Asset_Relationship__c>();
		theNewEBSIDJARAccounts = new Map<String, Account>();
		theNewAssRelMap  = new Map <String, Asset_Relationship__c>();
		TheNewEBSIDJARBankAccounts = new Map<String, Account_with_IBB__c>() ;
		
		

		// Get the EBS JARS that don't exist on salesforce

		for (accountJARS.JARS jars : theJARs.AcctJARS)
		{
			for ( AccountJARS.JAR jar : jars.AcctJAR )
			{
				// For the EBS JAR try and find the Salesforce equivalent, if it doesn't exist it is to be potentially added
				// Create as much of the asset_relationship__c record as possible
				Asset_Relationship__c ARel = theSFDCAcctEBSIDToJARMap.get (jars.AcctNo + jar.EBSID);
				if (ARel == null)
				{
					ARel = new Asset_Relationship__c();
					ARel.Customer_EBS_ID__c = jar.EBSID;
					ARel.EBS_ID__c = jars.AcctNo + jar.EBSID ;
					ARel.Is_Active__c = true ;
					ARel.Relationship_To_Primary_Applicant1__c = jar.Relationship;
					ARel.Primary_Account_Holder__c = false;
					ARel.Name = jars.AcctNo + jar.EBSID;
					theNewAssRelAcctNoMap.put (jars.AcctNo + jar.EBSID, ARel);
					theNewAssRelMap.put (jars.AcctNo, ARel);

					arsToInsert.add(ARel) ;
					TheNewEBSIDs.add(jar.EBSID);
					TheNewAcctNos.add(jars.AcctNo);

					//AccountJARSResponse.AccountJARResponse jarResp = new AccountJARSResponse.AccountJARResponse();
					//jarResp.msgID = jars.msgID;
					//jarResp.accountNumber = jars.acctNo;
					//jarResp.customerNo = jar.EBSID;
					
					//respList.add(jarResp) ;
				}
			}
		}

		System.debug ( 'the arsToInsert ' + arsToInsert);
		
		if (arsToInsert.size() > 0 )
		{
			// for the new JARS, need to get the Account ID for the record
			List<Account> accs = [SELECT ID,
										Name,
										EBS_ID__c
								FROM	Account
								WHERE	EBS_ID__c in :TheNewEBSIDs];

			if ( accs.size() > 0 )
			{
				for ( Account acc : accs )
				{
					theNewEBSIDJARAccounts.put(acc.EBS_ID__c, acc);
				}
			}

			System.debug ( 'theNewEBSIDJARAccounts ' + theNewEBSIDJARAccounts );

			// for the new JARS, need to get the Bank Account ID for the record
			List<Account_with_IBB__c> awis = [SELECT ID,
													Name,
													EBS_ID__c
											FROM	Account_with_IBB__c
											WHERE	EBS_ID__c in :TheNewAcctNos];

			if ( awis.size() > 0 )
			{
				for ( Account_with_IBB__c awi : awis )
				{
					TheNewEBSIDJARBankAccounts.put (awi.EBS_ID__c, awi) ;
				}
			}

			System.debug ( 'TheNewEBSIDJARBankAccounts ' + TheNewEBSIDJARBankAccounts );
			System.debug ( 'theSFDCAcctEBSIDToJARMap 2 ' + theSFDCAcctEBSIDToJARMap );
			for (Asset_Relationship__c ar : arsToInsert)
			{
				Account_with_IBB__c awi = TheNewEBSIDJARBankAccounts.get(ar.EBS_ID__c.substring(0, 13));
				Account acc = theNewEBSIDJARAccounts.get (ar.Customer_EBS_ID__c);
				if ( awi != null)
				{
					ar.Account_with_IBB__c = awi.Id;
				}
				if ( acc != null)
				{
					ar.Prospect_Customer__c = acc.Id;
				}
				theSFDCAcctEBSIDToJARMap.put(ar.EBS_ID__c, ar);
				arsToUpdate.Add (ar);
			}
			//System.debug ( 'theSFDCAcctEBSIDToJARMap 3 ' + theSFDCAcctEBSIDToJARMap );
		}
		System.debug ( 'The arsToUpdate 2 ' + arsToUpdate );
	}

	public void SortOutListsToProcess ()
	{
		arsToUpsert = new List<Asset_Relationship__c>();
		for (AccountJARSResponse.AccountJARResponse resp : respList)
		{
			Asset_Relationship__c ar = theSFDCAcctEBSIDToJARMap.get (resp.accountNumber + resp.customerNo) ;
			if (ar != null)
			{
				arsToUpsert.Add (ar);
			}
		}
	}

	public void DoUpdates ()
	{
		//System.debug ('The RespList ' + respList );
		System.debug ( 'The arsToUpdate ' + arsToUpdate );
		System.debug ( 'The arsToUpsert ' + arsToUpsert );
		 List<Database.UpsertResult> saveResults = new List<Database.UpsertResult>();
		 saveResults = Database.Upsert (arsToUpsert, false );
		 if (saveResults.size () > 0 )
		 {
			for ( integer i = 0; i < saveResults.Size() ; i++)
			{
				Database.UpsertResult ur = saveResults.get (i);
				AccountJARSResponse.AccountJARResponse resp = respList.get (i);
				if (ur.IsSuccess ())
				{
					resp.responseCode = 'SUCCESS';
					//resp.responseMessage = 'SUCCEEDED';
				}
				else
				{
					resp.responseCode = 'FAILED';
					List<Database.Error> errs = ur.getErrors();
					Database.Error err = errs[0];
					resp.responseMessage = err.getMessage();
				}
				//respListToProcess.add (resp);
			}
		 }

		 List<Database.SaveResult> deacResults = new List<Database.SaveResult>();
		 deacResults = Database.Update (arsToDeactivate , false );

	}

	public string CreateResponseMessage ()
	{
		string rtv = '';
		rtv = '<JARUpdateResponses>';
		string acctNo = 'foo';
		integer failcnt = 0;
		string failmsg = '';
		boolean first = true;
		string ebsid = '';
		string msgid = '';
		string errmsg = '';

		//for (AccountJARSResponse.AccountJARResponse resp : respListToProcess)
		System.debug ('The respList ' + respList);
		if (respList.Size() > 0)
		{
			for (AccountJARSResponse.AccountJARResponse resp : respList)
			{
				//System.debug ('The respList ' + resp);
				ebsid = resp.customerno;
				//msgid = resp.msgID;
				errmsg = resp.ResponseMessage;
				if ( first )
				{
					acctNo = resp.AccountNumber;
					msgID = resp.msgID;
					//rtv = rtv + '<JARUpdateResponse>';
					//rtv = rtv + '<MessageID>' + resp.msgID + '</MessageID>';
					//System.debug ( 'first ' + acctNo);
					//System.debug ( 'first ' + msgID);
					//rtv = rtv + '<JARUpdateResponse>';
					//rtv = rtv + '<MessageID>' + resp.msgID + '</MessageID>';
				}
				else if (resp.accountNumber != acctNo)
				{
					//rtv = rtv + '</JARUpdateResponse>';
					//System.debug ( 'Newacct ' + acctNo);
					//System.debug ( 'newacct ' + msgID);
					rtv = rtv + '<JARUpdateResponse>';
					rtv = rtv + '<MessageID>' + msgID + '</MessageID>';
					if (failcnt > 0)
					{
						rtv = rtv + '<ResponseCode>' + 'FAILED' +  '</ResponseCode>';
						rtv = rtv + '<ResponseMsg>' + failmsg + '</ResponseMsg>';
					}
					else 
					{
						rtv = rtv + '<ResponseCode>' + 'SUCCESS' +  '</ResponseCode>';
						//rtv = rtv + '<ResponseMsg>' + 'SUCCEEDED' + '</ResponseMsg>';
						rtv = rtv + '<ResponseMsg></ResponseMsg>';
					}
					rtv = rtv + '</JARUpdateResponse>';
					acctNo = resp.AccountNumber;
					msgID = resp.MsgID;
					failmsg = '';
					failcnt = 0;
				}
				if (resp.responseCode == 'FAILED')
				{
					failcnt++;
					failmsg = failmsg +  resp.customerno + ' FAILED - ' + resp.ResponseMessage  + ';';
				}
				first = false;
				//System.debug ('The rtv A ' + rtv);
				//System.debug ('The failcnt A ' + failcnt);
				//System.debug ('The acctno A ' + acctno);
				//System.debug ('The msgID A ' + msgID);
			}

			rtv = rtv + '<JARUpdateResponse>';
			rtv = rtv + '<MessageID>' + msgID + '</MessageID>';
			if (failcnt > 0)
			{
				//System.debug ('The rtv Ba ' + rtv);
				//System.debug ('The failcnt Ba ' + failcnt);
				rtv = rtv + '<ResponseCode>' + 'FAILED' +  '</ResponseCode>';
				rtv = rtv + '<ResponseMsg>' + failmsg + '</ResponseMsg>';
			}
			else 
			{
				//System.debug ('The rtv Bb ' + rtv);
				//System.debug ('The failcnt Bb ' + failcnt);
				rtv = rtv + '<ResponseCode>' + 'SUCCESS' +  '</ResponseCode>';
				//rtv = rtv + '<ResponseMsg>' + 'SUCCEEDED' + '</ResponseMsg>';
				rtv = rtv + '<ResponseMsg></ResponseMsg>';
			}
			rtv = rtv + '</JARUpdateResponse>';
		}

		// Process the primary only
		ebsid = '';
		msgid = '';
		first = true;
		System.debug ('The Primary respList ' + respPrimaryList);
		if ( respPrimaryList.Size() > 0 )
		{
			for (AccountJARSResponse.AccountJARResponse resp : respPrimaryList)
			{
				System.debug ('The respList ' + resp);
				ebsid = resp.customerno;
				//msgid = resp.msgID;
				errmsg = resp.ResponseMessage;
				if ( first )
				{
					acctNo = resp.AccountNumber;
					msgID = resp.msgID;
				
				}
				else if (resp.accountNumber != acctNo)
				{
				
					//System.debug ( 'Newacct ' + acctNo);
					//System.debug ( 'newacct ' + msgID);
					rtv = rtv + '<JARUpdateResponse>';
					rtv = rtv + '<MessageID>' + msgID + '</MessageID>';
				
					rtv = rtv + '<ResponseCode>' + 'SUCCESS' +  '</ResponseCode>';
					//rtv = rtv + '<ResponseMsg>' + 'SUCCEEDED - Primary only' + '</ResponseMsg>';
					rtv = rtv + '<ResponseMsg></ResponseMsg>';
					rtv = rtv + '</JARUpdateResponse>';
					acctNo = resp.AccountNumber;
					msgID = resp.MsgID;
				
				}
			
				first = false;
				//System.debug ('The rtv A ' + rtv);
				//System.debug ('The failcnt A ' + failcnt);
				//System.debug ('The acctno A ' + acctno);
				//System.debug ('The msgID A ' + msgID);
			}

			rtv = rtv + '<JARUpdateResponse>';
			rtv = rtv + '<MessageID>' + msgID + '</MessageID>';
		
				//System.debug ('The rtv Bb ' + rtv);
				//System.debug ('The failcnt Bb ' + failcnt);
			rtv = rtv + '<ResponseCode>' + 'SUCCESS' +  '</ResponseCode>';
			//rtv = rtv + '<ResponseMsg>' + 'SUCCEEDED - Primary only' + '</ResponseMsg>';
			rtv = rtv + '<ResponseMsg></ResponseMsg>';

			//System.debug ('The failcnt C ' + failcnt);
			rtv = rtv + '</JARUpdateResponse>';
		}
		rtv = rtv + '</JARUpdateResponses>';
		//System.debug ('The rtv C ' + rtv);
		return rtv;
	}
}