/* ---------------------------------------------------------------------------------------------------	*/
/* C0689 Process HR SML requests web service															*/
/* ---------------------------------------------------------------------------------------------------	*/

global class SFDCProcessHR 
{ 
	
	webservice static string processHRSMLRequests (string inRequest)
	{
		string returnMessage = '';
		System.debug ('This is the request ' + inRequest);
		string decodedRequest;
		string tryParse = '';
		HRSMLRequest theRequest = new HRSMLRequest(); 
		HRSMLResponse theResponse = new HRSMLResponse ();
		HRSMLProcessing processSML = new HRSMLProcessing ();
		try
		{
			try
			{
				decodedRequest = EncodingUtil.urlDecode(inRequest, 'UTF-8');
			}
			catch (Exception ex1)
			{
				tryParse = 'FAILED';
	
				theResponse.JobID = '-UNKNOWN-';
				theResponse.ResponseCode = '66';
				theResponse.ResponseMessage = 'Problem decoding request ' + ex1.GetMessage() ;
			
				returnMessage = processSML.ResponseMessage (theResponse);
			}
 
			Dom.Document xDoc = new Dom.Document();

			if (String.IsBlank(tryParse))
			{
				try
				{
					List<HRSMLRequestRecord> theRecords = new List<HRSMLRequestRecord>();
					xDoc.Load(decodedRequest);
					DOM.XMLNode root = xDoc.getRootElement();
					for(Dom.XMLNode child: root.getChildElements())
					{
						if (child.getNodeType() == DOM.XmlNodeType.ELEMENT)
						{
							if (child.getName() == 'JobID')
							{
								theRequest.JobID = child.getText();
							}
							else if ( child.getName() == 'MessageName' )
							{
								theRequest.MessageName = child.getText();
							}
							else if ( child.getName() == 'Result' )
							{
								System.debug ( '**** The Result Node **** ' + child);						
								HRSMLRequestRecord theRecord = new HRSMLRequestRecord();
								boolean hasRecords = false;
								for (Dom.XMLNode resultType : child.getChildElements())
								{
									System.debug ( '*** The XMLNODE *** ' + resultType);
									if (resultType.getNodeType() == DOM.XmlNodeType.ELEMENT)
									{
										if (resultType.getName() == 'EmployeeID') 
										{
											if (!String.isBlank(resultType.getText()))
											{
												theRecord.EmployeeId = resultType.getText() ;
												hasRecords = true ;
											}
											else
											{
												break;
											}
										}
										else if (resultType.getName() == 'Title') 
										{
											theRecord.Title = resultType.getText() ;
										}
										else if (resultType.getName() == 'FirstName') 
										{
											theRecord.FirstName = resultType.getText() ;
										}
										else if (resultType.getName() == 'LastName') 
										{
											theRecord.LastName = resultType.getText() ;
										}
										else if (resultType.getName() == 'KnownAs') 
										{
											theRecord.KnownAs = resultType.getText() ;
										}
										else if (resultType.getName() == 'WorkEmail') 
										{
											theRecord.WorkEmail = resultType.getText() ;
										}
										else if (resultType.getName() == 'StartDate') 
										{
											theRecord.StartDate = resultType.getText() ;
										}
										else if (resultType.getName() == 'JobRole') 
										{
											theRecord.JobRole = resultType.getText() ;
										}
										else if (resultType.getName() == 'Location') 
										{
											theRecord.Location = resultType.getText() ;
										}
										else if (resultType.getName() == 'Department') 
										{
											theRecord.Department = resultType.getText() ;
										}
										else if (resultType.getName() == 'ReportsTo') 
										{
											theRecord.ReportsTo = resultType.getText() ;
										}
										else if (resultType.getName() == 'EmploymentType') 
										{
											theRecord.EmploymentType = resultType.getText() ;
										}
										else if (resultType.getName() == 'FinalDayofEmployment') 
										{
											theRecord.FinalDayofEmployment = resultType.getText() ;
										}
										else if (resultType.getName() == 'FinalDayinOffice') 
										{
											theRecord.FinalDayinOffice = resultType.getText() ;
										}
										else if (resultType.getName() == 'EffectiveFrom') 
										{
											theRecord.EffectiveFrom = resultType.getText() ;
										}
									}
								}	
								if (hasRecords) 
								{							
									theRecords.add(theRecord);
								}
							}	
															
						}
					}
				
					theRequest.HRRecords = theRecords;

					system.debug ( 'The Request ' + theRequest);
				}
				catch (Exception e2)
				{
					tryParse = 'FAILED';

					theResponse.JobID = '-UNKNOWN-';
					theResponse.ResponseCode = '77';
					theResponse.ResponseMessage = 'Problem parsing request ' + e2.GetMessage() ;
			
					returnMessage = processSML.ResponseMessage (theResponse);
				}
			}

			if (String.IsBlank(tryParse))
			{
			
				returnMessage = processSML.ProcessSML (theRequest);

			}
			else
			{
				returnMessage = processSML.ResponseMessage (theResponse);
			}
		}
		
		catch (Exception e1)
		{
			theResponse.JobID = '-UNKNOWN-';
			theResponse.ResponseCode = '88';
			theResponse.ResponseMessage = 'Problem parsing request ' + e1.GetMessage() ;
			returnMessage = processSML.ResponseMessage (theResponse);
		}

		//return returnMessage;
		return returnMessage;

	}

	public static String ResponseMessage ()
	{
		string rtv = '';
		rtv = '<processHRSMLRequestsResponse>';
		
        rtv = rtv + '<JobID>' + '123' + '</JobID>';
        
        rtv = rtv + '<ResponseCode>' + 'SUCCESS' +  '</ResponseCode>';
        rtv = rtv + '<ResponseMessage>' + 'SUCCEEDED' + '</ResponseMessage>';
		
        	
        rtv = rtv + '</processHRSMLRequestsResponse>';
        
        
        return rtv;
	}
}