/* ---------------------------------------------------------------------------------------------------	*/
/* C0633 Delete Customer web service																	*/
/* ---------------------------------------------------------------------------------------------------	*/



global class SFDCDeleteCustomer 
{
	public string tryParse = '';
	webservice static string deleteCustomer (string inCustomer)
	{
		string returnMessage = '';
		System.debug ('This is the request ' + inCustomer);
		string decodedRequest;
		string tryParse = '';
		DeleteCustomer theDeleteCustomer = new DeleteCustomer ();
		DeleteCustomerResponse theDeleteCustomerResponse = new DeleteCustomerResponse ();
		DeleteCustomerProcessing processDC = new DeleteCustomerProcessing();

		try
		{
			try
			{
				decodedRequest = EncodingUtil.urlDecode(inCustomer, 'UTF-8');
			}
			catch (Exception ex1)
			{
				tryParse = 'FAILED';
			
			
				theDeleteCustomerResponse.msgID = '-UNKNOWN-';
				theDeleteCustomerResponse.EBSID = '-UNKNOWN-';
				theDeleteCustomerResponse.SFDCID = '-UNKNOWN-';
				theDeleteCustomerResponse.PanopticID = '-UNKNOWN-';
				theDeleteCustomerResponse.ResponseCode = '66';
				theDeleteCustomerResponse.ResponseMessage = 'Problem decoding request ' + ex1.GetMessage() ;
			
				returnMessage = processDC.ResponseMessage (theDeleteCustomerResponse);
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
							if (child.getName() == 'EBSID')
							{
								theDeleteCustomer.EBSID = child.getText();
							}
							else if ( child.getName() == 'MsgID' )
							{
								theDeleteCustomer.MsgID = child.getText();
							}
							else if ( child.getName() == 'SFDCID' )
							{
								theDeleteCustomer.SFDCID = child.getText();
							}	
							else if ( child.getName() == 'PanopticID' )
							{
								theDeleteCustomer.PanopticID = child.getText();
							}									
						}
					}
				}

				catch (Exception e)
				{
					tryParse = 'FAILED';

					theDeleteCustomerResponse.msgID = '-UNKNOWN-';
					theDeleteCustomerResponse.EBSID = '-UNKNOWN-';
					theDeleteCustomerResponse.SFDCID = '-UNKNOWN-';
					theDeleteCustomerResponse.PanopticID = '-UNKNOWN-';
					theDeleteCustomerResponse.ResponseCode = '77';
					theDeleteCustomerResponse.ResponseMessage = 'Problem parsing request ' + e.GetMessage() ;
					returnMessage = processDC.ResponseMessage (theDeleteCustomerResponse);
				}
    
				//system.debug ('THE ACCOUNTS ' + theAccountJARS);

			}
        
		
			if (String.IsBlank(tryParse))
			{
			
				returnMessage = processDC.ProcessDC (theDeleteCustomer);

			}
			else
			{
				returnMessage = processDC.ResponseMessage (theDeleteCustomerResponse);
			}
		}
		catch (Exception exc)
		{
			theDeleteCustomerResponse.msgID = '-UNKNOWN-';
			theDeleteCustomerResponse.EBSID = '-UNKNOWN-';
			theDeleteCustomerResponse.SFDCID = '-UNKNOWN-';
			theDeleteCustomerResponse.PanopticID = '-UNKNOWN-';
			theDeleteCustomerResponse.ResponseCode = '88';
			theDeleteCustomerResponse.ResponseMessage = 'Problem processing request ' + exc.GetMessage() ;
			returnMessage = processDC.ResponseMessage (theDeleteCustomerResponse);
		}
        
        //return ResponseMessage(theResponse);
		return returnMessage;
	}

	public static String ResponseMessage ()
	{
		string rtv = '';
		rtv = '<SFDCDeleteCustomerResponse>';
		
        rtv = rtv + '<MessageID>' + 'iUID-2016-11-02-12.22.13.711-70-107652' + '</MessageID>';
        
        rtv = rtv + '<ResponseCode>' + 'SUCCESS' +  '</ResponseCode>';
        rtv = rtv + '<ResponseMessage>' + 'SUCCEEDED' + '</ResponseMessage>';
		
        	
        rtv = rtv + '</SFDCDeleteCustomerResponse>';
        
        
        return rtv;
	}


}