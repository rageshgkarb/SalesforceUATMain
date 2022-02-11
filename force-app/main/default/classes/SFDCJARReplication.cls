/* ---------------------------------------------------------------------------------------------------- */
/* C0559																								*/
/* ---------------------------------------------------------------------------------------------------- */

global class SFDCJARReplication 
{ 
	 webservice static string testComms(String inTestString)
    {
         System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }

	webservice static string UpdateJAR (string inRequest)
    {
		string rtv = '';
        string tryParse = '';
		string decodedRequest;
        XmlStreamReader xsr;
        AccountJARS theAccountJARS = new AccountJARS();
        AccountJARSResponse theResponse = new AccountJARSResponse();
		List<AccountJARS.JARS> theAccountJARSList = new List<AccountJARS.JARS>();
		List<AccountJARS.JAR> theAccountJARList = new List<AccountJARS.JAR>();
		AccountJARS.JARS theJARS ;
		AccountJARS.JAR theJAR;

		List<AccountJARSResponse.AccountJARResponse> theJARResponses = new List<AccountJARSResponse.AccountJARResponse>();
		AccountJARSResponse.AccountJARResponse theJARResponse;
        
		System.debug ('The request ' + inRequest);

        try
        {
            decodedRequest = EncodingUtil.urlDecode(inRequest, 'UTF-8');
        }
        catch (Exception ex1)
        {
			tryParse = 'FAILED';
			theResponse.BatchID = '-UNKNOWN-';
			theJARResponse = new AccountJARSResponse.AccountJARResponse();
			theJARResponse.msgID = '-UNKNOWN-';
			theJARResponse.AccountNUmber = '-UNKNOWN-';
            theJARResponse.ResponseCode = 'FAILED';
            theJARResponse.ResponseMessage = 'Problem decoding request ' + ex1.GetMessage() ;
			theJARResponses.add(theJARResponse);
			theResponse.JARResponses = theJARResponses ;
			return ResponseMessage();
        }
 
		Dom.Document xDoc = new Dom.Document();

		string saveAcctNo = '';
        System.debug ('The decoded request ' + decodedRequest);
        if (String.IsBlank(tryParse))
        {
		    try
            {
				xDoc.Load(decodedRequest);
				DOM.XMLNode root = xDoc.getRootElement();
				for(Dom.XMLNode child: root.getChildElements())
				{
					if (child.getNodeType() == DOM.XmlNodeType.ELEMENT)
					{
						if (child.getName() == 'BatchID')
						{
							theAccountJARS.BatchID = child.getText();
						}
						else if (child.getName() == 'JARS')
						{
							theJARS = new AccountJARS.JARS();
							//Dom.XmlNode acct = child.getChildElements();
							integer primaryCnt = 0;
							integer secondaryCnt = 0;
							for (Dom.XMLNode acct : child.getChildElements())
							{
								system.debug ('Acct ' + acct );
								if (acct.getNodeType() == DOM.XmlNodeType.ELEMENT)
								{
									if (acct.getName() == 'MessageID')
									{
										theJARS.msgID = acct.getText();
									}
									else if (acct.getName() == 'AcctNo')
									{
										theJARS.AcctNo = acct.getText();
									}
									else if (acct.getName() == 'JointRelationship')
									{
										theJAR = new AccountJARS.JAR();
										
										for (Dom.XmlNode jar : acct.getChildElements())
										{
											system.debug ('JAR ' + jar );
											if (jar.getNodeType() == DOM.XmlNodeType.ELEMENT)
											{
												if (jar.getName() == 'CustNo')
												{
													theJAR.EBSID = jar.getText(); 
												}
												else if (jar.getName() == 'CustName')
												{
													theJAR.CustName = jar.getText();
												}
												else if (jar.getName() == 'CustRelationshipToPrimary')
												{
													theJAR.Relationship = jar.getText();
													if (theJAR.Relationship == 'Primary')
													{
														primaryCnt ++;
													}
													else
													{
														secondaryCnt ++;
													}
												}
											}
										}
										
										
										theAccountJARList.add (theJAR);
										
										
									}
									
								}
								
							}

							if (secondaryCnt > 0)
							{
								theJARS.primaryOnly = false;
							}
							else
							{
								theJARS.primaryOnly = true;
							}
							
							theJARS.AcctJAR = theAccountJARList;
							theAccountJARSList.add(theJARS);
							theAccountJARList = new List<AccountJARS.JAR>();
							
						}
						
						
					}
					
					
					theAccountJARS.AcctJARS = theAccountJARSList;
					
				}
			}

			
				
            catch (Exception e)
            {
				tryParse = 'FAILED';
                theResponse.BatchID = '-UNKNOWN-';
				theJARResponse = new AccountJARSResponse.AccountJARResponse();
				theJARResponse.msgID = '-UNKNOWN-';
				theJARResponse.AccountNUmber = '-UNKNOWN-';
				theJARResponse.ResponseCode = 'FAILED';
				theJARResponse.ResponseMessage = 'Problem decoding request ' + e.GetMessage() ;
				theJARResponses.add(theJARResponse);
				theResponse.JARResponses = theJARResponses ;
            }
    
			//system.debug ('THE ACCOUNTS ' + theAccountJARS);

        }
        
		
        if (String.IsBlank(tryParse))
        {
			JARProcessing processJAR = new JARProcessing();
            return processJAR.ProcessJARS (theAccountJARS);

        }
        
        //return ResponseMessage(theResponse);
		return ResponseMessage();
	}

	public static String ResponseMessage ()
	{
		string rtv = '';
		rtv = '<JARUpdateResponses>';
		rtv = rtv + '<JARUpdateResponse>';
        rtv = rtv + '<MessageID>' + 'iUID-2016-11-02-12.22.13.711-70-107652' + '</MessageID>';
        
        rtv = rtv + '<ResponseCode>' + 'SUCCESS' +  '</ResponseCode>';
        rtv = rtv + '<ResponseMsg>' + 'SUCCEEDED' + '</ResponseMsg>';
		rtv = rtv + '</JARUpdateResponse>';
		rtv = rtv + '<JARUpdateResponse>';
        rtv = rtv + '<MessageID>' + 'iUID-2016-11-02-12.22.13.711-70-107653' + '</MessageID>';
        
        rtv = rtv + '<ResponseCode>' + 'SUCCESS' +  '</ResponseCode>';
        rtv = rtv + '<ResponseMsg>' + 'SUCCEEDED' + '</ResponseMsg>';
		rtv = rtv + '</JARUpdateResponse>';
        rtv = rtv + '</JARUpdateResponses>';
        
        
        return rtv;
	}




}