/* ---------------------------------------------------------------------------------------- */
/* C0550 endpoint for UpdateFTDOpportunity                                                  */
/* ---------------------------------------------------------------------------------------- */

global class SFDCFITProcessing
{
    webservice static string testComms(String inTestString)
    {
         System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }
    
    webservice static string UpdateFTDOpportunity (string inRequest)
    {
        string decodedRequest;
        XmlStreamReader xsr;
        UpdateFTDOpportunity theFTDOpportunity = new UpdateFTDOpportunity();
        UpdateFTDOpportunityResponse theResponse = new UpdateFTDOpportunityResponse();
        
		System.debug ('The request ' + inRequest);

        try
        {
            decodedRequest = EncodingUtil.urlDecode(inRequest, 'UTF-8');
        }
        catch (Exception ex1)
        {
            theResponse.MessageID = theFTDOpportunity.MessageID;
            theResponse.ResponseCode = 'FAILED';
            theResponse.ResponseMsg = 'Problem decoding request ' + ex1.GetMessage() ;
        }
 
        System.debug ('The decoded request ' + decodedRequest);
        if (String.IsBlank(theResponse.ResponseCode))
        {
            try
            {
                xsr = new XmlStreamReader (decodedRequest);
                while (xsr.HasNext())
                {
					if (xsr.getEventType() == XmlTag.START_ELEMENT)
                    {
						System.debug ('Tag ' + xsr.getLocalName());
                        if ('MessageID'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.MessageID = xsr.getText();
                            }
                        }
                        else if ('MessageType'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.MessageType = xsr.getText();
                            }
                        }
                        
                        else if ('OpportunityID'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            System.debug ('The Opportunity ID ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.OpportunityID  = xsr.getText();
                            }
							System.debug ('The Opportunity ID ' + theFTDOpportunity.OpportunityID);
                        }

                        else if ('OpportunityName'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.OpportunityName  = xsr.getText();
                            }
                        }
                        else if ('OpportunityStatus'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.OpportunityStatus  = xsr.getText();
                            }
                        }
                        else if ('InitialDepositAmount'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.InitialDepositAmount  = xsr.getText();
                            }
                        }
                        else if ('FTDStartDate'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.FTDStartDate  = xsr.getText();
                            }
                        }
                        else if ('Spare1'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.Spare1  = xsr.getText();
                            }
                        }
                        else if ('Spare2'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.Spare2  = xsr.getText();
                            }
                        }
                        else if ('Spare3'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.Spare3  = xsr.getText();
                            }
                        }
                        else if ('Spare4'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.Spare4  = xsr.getText();
                            }
                        }
                        else if ('Spare5'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theFTDOpportunity.Spare5  = xsr.getText();
                            }
                        }
                        
                     }
                    xsr.next();
                }
            }
            catch (Exception e)
            {
                theResponse.MessageID = theFTDOpportunity.MessageID;
                theResponse.ResponseCode = 'FAILED';
                theResponse.ResponseMsg = theResponse.ResponseMsg + ' - ' + e.getMessage();
            }
    
        }
        
        if (String.IsBlank(theResponse.ResponseCode))
        {
            theResponse = UpdateTheOpportunity (theFTDOpportunity);

            /*Temp code to test service */
            //theResponse.MessageID = theFTDOpportunity.MessageID;
            if (String.IsBlank(theResponse.ResponseCode))
            {
                theResponse.ResponseCode = 'SUCCESS';
                theResponse.ResponseMsg = 'SUCCEEDED';
            }
        }
        
        return ResponseMessage(theResponse);
    }
    
    public static string ResponseMessage (UpdateFTDOpportunityResponse resp)
    {
        string rtv = '';
        
        rtv = '<UpdateFTDOpportunityResponse>';
        rtv = rtv + '<MessageID>' + resp.messageId + '</MessageID>';
        
        rtv = rtv + '<ResponseCode>' + resp.ResponseCode + '</ResponseCode>';
        rtv = rtv + '<ResponseMsg>' + resp.ResponseMsg + '</ResponseMsg>';
        rtv = rtv + '</UpdateFTDOpportunityResponse>';
        
        return rtv;
    }

    public static UpdateFTDOpportunityResponse UpdateTheOpportunity (UpdateFTDOpportunity theFTDOpp)
    {
        UpdateFTDOpportunityResponse rtv = new UpdateFTDOpportunityResponse();
		System.debug ( 'The Opp ID ' + theFTDOpp.OpportunityID);
        rtv.MessageID = theFTDOpp.MessageID;
        try 
        {

            List<Opportunity> theOpps = [SELECT Id,
                                        Name ,
                                        Initial_Deposit_received__c ,
                                        Initial_Payment_Amount__c ,
                                        Initial_Payment_Date__c ,
                                        Application_reference_number__c ,
                                        StageName,
										New_Money__c
                                 FROM Opportunity
                                 WHERE  Application_Reference_number__c = :theFTDOpp.OpportunityId 
                                ];
			System.debug ( 'The opps ' + theOpps );
			System.debug ('The oppid ' + theFTDOpp.OpportunityId );
            Opportunity theOpp = new Opportunity();
            if (theOpps.size() > 0)
            {
                theOpp = theOpps[0];

                if ( theOpp.StageName.equalsIgnoreCase('CLOSED WON') )
                {
                    rtv.ResponseCode = 'FAILED';
                    rtv.ResponseMsg = 'FIT Opportunity is already processed : ' + theFTDOpp.OpportunityId;
                }
                else
                {
                    List<EventLog__c> openEvents = [select id, Event__r.CustomPageLocation__c
                                             from eventlog__c where EventStatus__c='open' and Opportunity__c=:theopp.id
                                             order by createddate limit  1];

                    CAA_Data.SetupFTDInitData theData = CAA_FTD_Setup.SetupFTD (openEvents[0].id, theFTDOpp);
					
					string bankAccount;
					List<Account_with_IBB__c> awis = [SELECT Name
											   FROM Account_with_IBB__c
											   Where Opportunity__c = :theOpp.Id];


				    if (awis.size() > 0)
					{
						bankAccount = awis[0].Name ;
					}

					if (bankAccount.length() == 13)
					{

					//Opportunity
                
						theOpp.Initial_Deposit_Received__c = true ;
						//if (String.isNotBlank (theFTDOpp.InitialDepositAmount))
						//{
							//theOpp.Initial_Payment_Amount__c = Double.valueOf(theFTDOpp.InitialDepositAmount);
						//}
						if (String.isNotBlank(theFTDOpp.FTDStartDate))
						{
							//theOpp.Initial_Payment_Date__c = Date.valueOf(Date.parse(theFTDOpp.FTDStartDate));
							theOpp.Initial_Payment_Date__c = Date.valueOf(theFTDOpp.FTDStartDate);
						}
						if (String.isNotBlank(theFTDOpp.Spare1))
						{
							theOpp.New_Money__c = Double.valueOf(theFTDOpp.Spare1 );
						}

						theOpp.StageName = 'Closed Won';
						

						Trigger_Helper.TriggerItem item = new Trigger_Helper.TriggerItem();
						item.name = 'Opportunity';
						item.IgnoreTrigger = true;        
						Trigger_Helper.Items.add(item);

						Database.SaveResult result = Database.update(theOpp);
            
						if (!result.isSuccess ())
						{
							List<Database.Error> dbErr = result.GetErrors ();
							Database.Error e = dbErr [0];
							rtv.ResponseCode = 'FAILED';
							rtv.ResponseMsg = e.getMessage ();
							System.debug ( 'This is DB exception ' + e.getMessage());
						}
					}
					else
					{
						rtv.ResponseCode = 'FAILED';
						rtv.ResponseMsg = 'RDS failed for opportunity : ' + theFTDOpp.OpportunityId;
					}
                }
            }
            else 
            {
                rtv.ResponseCode = 'FAILED';
                rtv.ResponseMsg = 'Cannot find opportunity : ' + theFTDOpp.OpportunityId;
            }

            
        
        }
        catch (Exception ex )
        {
			System.debug ( 'This is the general exception ' + ex.getMessage());
            rtv.ResponseCode = 'FAILED';
            rtv.ResponseMsg = ex.getMessage ();
        }

        return rtv;
    }
}