/* ---------------------------------------------------------------------------------------- */
/* C0693 endpoint for UpdateFinanceAccount                                                  */
/* ---------------------------------------------------------------------------------------- */



global class SFDCFinanceUpdateAccountProcessing 
{
	public static Schema.SobjectField externalIdField {get ; set ; }
	public static XML_Message__c xmlMessage {get ; set ; }
	public static List<XML_Message_Tag__c> tagList {get ; set ; }
	public static Map<String, String> fieldMap {get ; Set ;}
	public static Map<String, String> fieldToTypeMap {get ; Set ;}
	public static Map<String, String> fieldToValuesMap {get ; Set ;}
	public static Map<String, Schema.SObjectField> objectMap {get ; set; }
	public static List<String> Accnos {get ; set ; }
	public static Dom.Document xDoc { get ; set ; }
	public static Map<String, String> accNosToMessageIDsMap { get ; set ; }
	public static Map<String, Account_with_IBB__c> accMap {get ; set ; }
	public static List<Account_with_IBB__c> accList { get ; set ; }
	public static List<SObject> objectsToUpsert { get ; set ; }
	public static List<FinanceAccountUpdateResponse> TheResponses { get ; set ; }
	public static List<FinanceAccountUpdateResponse> TheResponsesToRespond { get ; set ; }


	webservice static string testComms(String inTestString)
    {
		
         System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }

	webservice static string UpdateFinanceAccount (string inRequest)
	{
		GetTheMessageStructure ();
		
		String decodedString;
        try 
		{
            decodedString = EncodingUtil.urlDecode(inRequest, 'UTF-8');
            System.debug('*** -- DECODED STRING -- ***');
            System.debug('*** -- ' + decodedString + ' -- ***');
        }
		catch (Exception decodeEx)
		{
            System.debug('*** -- Error in processCustomers decoding string -- ***');
            System.debug('*** -- Error: ' + decodeEx + ' at line ' + decodeEx.getLineNumber() + ' -- ***');
            return 'FAILED TO DECODE WITH ' + decodeEx;
        }

		xDoc = new Dom.Document();
		xDoc.Load (decodedString );
		getAccountNumbers (xDoc);
		getAccountsWithIBB (accNos);

		TheResponsesToRespond = new List<FinanceAccountUpdateResponse>();
		/* Create Response for account numbers not found */
		System.debug ('The accMap ' + accMap );
		for (string accno : accnos )
		{
			
			if (!accMap.ContainsKey ( accno ))
			{
				FinanceAccountUpdateResponse resp = new FinanceAccountUpdateResponse ();
				resp.MessageID = accNosToMessageIDsMap.get (accno);
				resp.AccNo =accno;
				resp.ResponseCode = '00';
				resp.responseMessage = 'Account not found';
				TheResponsesToRespond.add (resp);
				 
			}
		}

		if (accList.size() > 0)
		{
			String targetField;
			String targetValue;
			String fieldDataType;
			String strTargetValue;
			integer intTargetValue;
			Date dtTargetValue;
			double dblTargetValue;
			objectsToUpsert = new List<SObject>();
			SObject theObject;
			FinanceAccountUpdateResponse response;
			TheResponses = new List<FinanceAccountUpdateResponse>();

			DOM.XMLNode root = xDoc.getRootElement();
			for (Dom.XmlNode child : root.getChildElements ())
			{
				if (child.getNodeType () == Dom.XmlNodeType.ELEMENT)
				{
					if (child.GetName () == 'SFDCFinanceUpdateRequest')
					{
						boolean accFound = false ;
						for (Dom.XMLNode upd : child.getChildElements())
						{
							if (upd.getNodeType () == Dom.XmlNodeType.ELEMENT)
							{
								if (upd.getName () == 'DealAccountNo')
								{
									if (accMap.containsKey (upd.getText()))
									{
										theObject = (Account_with_IBB__c)accMap.get(upd.getText());
										response = new FinanceAccountUpdateResponse ();
										response.MessageID = accNosToMessageIDsMap.get (upd.getText());
										response.accno = upd.getText();
										System.debug ('The response - ' + response );
										accFound = true ;
									}
								}
								else 
								{
									if (accFound )
									{
										string nodeName = upd.getName ();
										targetField = fieldMap.get (nodeName);
										fieldDataType = fieldToTypeMap.get (nodeName);
										if (targetField != null && fieldDataType != null)
										{
											if ('STRING'.equalsIgnoreCase(fieldDataType))
											{
												theObject.put (targetField, upd.getText());
											}
											else if ('INTEGER'.equalsIgnoreCase(fieldDataType))
											{
												intTargetValue = Integer.valueOf (upd.getText ());
												theObject.put (targetField, intTargetValue);
											}
											else if ('DOUBLE'.equalsIgnoreCase(fieldDataType))
											{
												dblTargetValue = Double.valueof (upd.getText ());
												theObject.put (targetField , dblTargetValue );
											}
											else if ('DATE'.equalsIgnoreCase(fieldDataType))
											{
												dtTargetValue = Date.Parse (upd.getText ());
												theObject.put (targetField , dtTargetValue );
											}

										}
									}

								}
							}
						}

						
						if (accFound )
						{
							System.debug ('The sobject ' + theObject );
							objectsToUpsert.add (theObject );
							TheResponses.add (response);
						}
					}
				}
			}
			System.debug ('ObjectsToUpsert ' + objectsToupsert);
			//update objectsToUpsert;

			List<Database.SaveResult>   upResults = Database.update(objectsToupsert, false);

			if (upResults.size() > 0)
			{
				for (integer i = 0 ; i < upResults.size() ; i++)
				{
					Database.Saveresult sr = upResults.get(i);
					FinanceAccountUpdateResponse repMsg = TheResponses.get(i);
					System.debug ('The RespMsg ' + repMsg );
					if (sr.isSuccess())
					{
						repMsg.responseCode = '00';
						repMsg.responseMessage = 'SUCCEEDED';
					}
					else 
					{
						repMsg.responseCode = '21';
						List<Database.Error> dbErr = sr.getErrors();
						Database.Error e = dbErr[0];
						repMsg.responseMessage = e.getMessage();  
					}
					TheResponsesToRespond.add(repMsg);
					System.debug ('The repMsg 2 ' + repMsg);
				}
			}
			System.debug ( 'The Responses ' + TheResponsesToRespond );
		}
		return ResponseMessage(TheResponsesToRespond);
	}

	public static void getAccountNumbers ( Dom.Document xDoc )
	{
		AccNos = new List<String>();
		accNosToMessageIDsMap = new Map<string , String>();
		string accNo;
		string msgID;
		DOM.XMLNode root = xDoc.getRootElement();
		for (Dom.XmlNode child : root.getChildElements ())
		{
			if (child.getNodeType () == Dom.XmlNodeType.ELEMENT)
			{
				if (child.GetName () == 'SFDCFinanceUpdateRequest')
				{
					for (Dom.XMLNode upd : child.getChildElements())
					{
						if (upd.getNodeType () == Dom.XmlNodeType.ELEMENT)
						{
							if (upd.getName () == 'DealAccountNo' )
							{
								System.debug ( 'The accNo  '  + upd.getText());
								accNo = upd.getText();
								accNos.Add(accNo);
							}
							else if (upd.getName () == 'MessageID' )
							{
								System.debug ( 'The  MID  ' + accNo + ' - ' + upd.getText());
								msgid = upd.getText();
							}
							

						}
						
					}
					System.debug ( 'The  accno & MID  ' + accNo + ' - ' + msgid);
					accNosToMessageIDsMap.put (accNo, msgId);
				}
			}
		}

		System.debug ( 'The accNos to MID map ' + accNosToMessageIDsMap);
	}

	public static void getAccountsWithIBB (List<String> inEBSIdList)
    {
         accList = [Select a.SystemModstamp,
                            a.Status_Balance__c,
                            a.Shadow_Debit__c,
                            a.Shadow_Credit__c,
                            a.Reserved_Balance__c,
                            a.RepDealAccountType__c,
                            a.RepAccountType__c,
                            a.Primary_SFDC_Account__c,
                            a.Primary_Customer_EBS_ID__c,
                            a.Primary_Customer_Default_Branch__c,
                            a.OwnerId,
                            a.Name,
                            a.Ledger_Balance__c,
                            a.LastModifiedDate,
                            a.LastModifiedById,
                            a.IsDeleted,
                            a.Id,
                            a.IBB_Product__c,
                            a.IBB_Product_Name__c,
                            a.External_Account_Number__c,
                            a.EBS_ID__c,
                            a.EBS_Deal_Account_Type__c,
                            a.Direct_Debit_Sort_Code__c,
                            a.Direct_Debit_Bank_Account__c,
                            a.Date_of_Last_Transaction__c,
                            a.Created_in_EBS__c,
                            a.CreatedDate,
                            a.CreatedById,
                            a.Cleared_Balance__c,
                            a.Available_Balance__c,
                            a.Account_Type__c,
                            a.Account_Suffix__c,
                            a.Account_Status__c,
                            a.Account_Is_Joint__c,
                            a.Account_Inactive__c,
                            a.Account_Currency__c,
                            a.Account_Closed__c,
                            a.Account_Blocked__c ,
							a.CurrentRate__c,
							a.Single_Payment_Amount__c
                    From Account_with_IBB__c a 
                    where a.EBS_ID__c in :inEBSIdList];

        accMap = new Map<String, Account_with_IBB__c>();

        if (accList.size() > 0)
		{
            for (Account_with_IBB__c acc : accList)
			{
                accMap.put(acc.Name, acc);

            }
        } 
        System.debug ( 'Accmap ' + accMap);
    }

	public static void GetTheMessageStructure ()
	{
		fieldMap = new Map<String, String>();
		fieldToTypeMap = new Map<String, String>();
		xmlMessage = [Select x.Type__c, x.Start_Tag__c, x.Name, x.Id, x.End_Tag__c, 
                                        x.Element_Name__c, x.Active__c, Service_Name_Element__c,
                                        Service_Namespace__c, Element_Namespace__c, Buffered__c, 
                                        (Select Name, Field_Label__c, Field_API_Name__c, Start_Tag__c, End_Tag__c, Message_Order__c, Data_Type__c  
                                        From XML_Message_Tags__r Order By Message_Order__c ASC) 
                                        From XML_Message__c x where x.Type__c = 'Inbound' and x.Name = 'UpdateFinanceAccount' 
                                        and x.Active__c = true];
		tagList = xmlMessage.XML_Message_Tags__r;
		for (XML_Message_Tag__c xmlTag : tagList)
		{
            fieldMap.put(xmlTag.Name, xmlTag.Field_API_Name__c);
            fieldToTypeMap.put(xmlTag.Name, xmlTag.Data_Type__c);
        }
	}

	public static String ResponseMessage ()
	{
		string rtv = '';
		rtv = '<UpdateFinanceAccountResponses>';
		rtv = rtv + '<UpdateFinanceAccountResponse>';
        rtv = rtv + '<MessageID>' + 'iUID-2018-04-09-09.54.11.742-1-281229' + '</MessageID>';
        
        rtv = rtv + '<ResponseCode>' + '00' +  '</ResponseCode>';
        rtv = rtv + '<ResponseMsg>' + 'SUCCEEDED' + '</ResponseMsg>';
		rtv = rtv + '</UpdateFinanceAccountResponse>';
		rtv = rtv + '<UpdateFinanceAccountResponse>';
        rtv = rtv + '<MessageID>' + 'iUID-2018-04-09-09.54.11.742-1-281230' + '</MessageID>';
        
        rtv = rtv + '<ResponseCode>' + '00' +  '</ResponseCode>';
        rtv = rtv + '<ResponseMsg>' + 'SUCCEEDED' + '</ResponseMsg>';
		rtv = rtv + '</UpdateFinanceAccountResponse>';
        rtv = rtv + '</UpdateFinanceAccountResponses>';
        
        
        return rtv;
	}

	public static String ResponseMessage (List<FinanceAccountUpdateResponse> resps)
	{
		string rtv = '';
		rtv = '<UpdateFinanceAccountResponses>';
		for (FinanceAccountUpdateResponse resp : resps)
		{
			system.debug ( 'The resp ' + resp );
			rtv = rtv + '<UpdateFinanceAccountResponse>';
			rtv = rtv + '<MessageID>' + resp.messageID + '</MessageID>';
			rtv = rtv + '<ResponseCode>' + resp.responseCode +  '</ResponseCode>';
			rtv = rtv + '<ResponseMsg>' + resp.responseMessage + '</ResponseMsg>';
			rtv = rtv + '</UpdateFinanceAccountResponse>';
			
		}
        rtv = rtv + '</UpdateFinanceAccountResponses>';
        
        
        return rtv;
	}
	public class FinanceAccountUpdateResponse
	{
		public string messageID {get ; set ; }
		public string accNo {get ; set ; }
		public string responseCode {get ; set ; }
		public string responseMessage {get ; set ; }
		//public Account_With_IBB__c AWI {get ; set }
	}
}