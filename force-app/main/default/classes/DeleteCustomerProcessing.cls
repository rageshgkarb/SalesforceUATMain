/* ---------------------------------------------------------------------------- */
/* C0633                                                                        */
/* ---------------------------------------------------------------------------- */

public class DeleteCustomerProcessing 
{ 
    public DeleteCustomerResponse dcResponse {get ; set ;}
    public Account theAcc {get ; set ; }
    public boolean InFlightOpportunity {get ; set ;}

    public string ProcessDC (DeleteCustomer dc)
    {

        dcResponse = new DeleteCustomerResponse ();
        dcResponse.msgID = dc.msgID;
        dcResponse.SFDCID = dc.SFDCID;
        dcResponse.EBSID = dc.EBSID;
        dcResponse.PanopticID = dc.PanopticID;
        dcResponse.ResponseMessage = '';

        List<Account> theAccs = [SELECT id ,
                        SFDC_ID__c,
                        Panoptic_ID__c
                    FROM Account
                    WHERE EBS_ID__c = :dc.EBSID];
                    //AND   SFDC_ID__c = :dc.SFDCID];
        
        if (theAccs.size() > 0)
        {
            theAcc = theAccs[0];
            if (String.IsEmpty (dcResponse.SFDCID))
            {
                dcResponse.SFDCID = theAcc.SFDC_ID__c;
            }

            if (String.isEmpty (dcResponse.PanopticID))
            {
                dcResponse.PanopticID = theAcc.Panoptic_ID__c;
            }

            List<DeleteResponse> theResponses = new List<DeleteResponse> ();
            integer respCode = 0;
            try
            {

                theResponses.Add (CheckForInFlightOpportunities());
                if (!InFlightOpportunity)
                {
                    theResponses.add(DeleteDCCases ());
                    theResponses.add(DeleteDCEntitlements ());
                    theResponses.add(DeleteDCOpportunities ());
                    theResponses.add(DeleteDCObservations ());
                    theResponses.add(DeleteDCSignatories ());
                    theResponses.add(DeleteBankAccounts ());
                }
            

                for (DeleteResponse dr : theResponses)
                {
                    System.debug ( 'Response Code -A - ' + dr.ResponseCode);
                    System.debug ( 'Response Code -B - ' + Integer.ValueOf (dr.ResponseCode));
                    respCode = respCode + Integer.ValueOf (dr.ResponseCode);
                    System.debug ( 'Response Code -C - ' + respCode);
                    dcResponse.responseMessage = dcResponse.responseMessage + ' - ' + dr.ResponseMessage;
                    System.debug ( 'Response message -B - ' + dcResponse.responseMessage);

                }
            }
            catch (Exception ex)
            {
                dcResponse.ResponseMessage = dcResponse.ResponseMessage + 'Problem with deleting subordinate records ' + ex.getMessage() ;
            }

        
        
            //responseMsg = responseMsg + DeleteDCEntitlements ();
            System.debug ('The RespCode  ' + respCode);
            if (respCode != 0)
            {
                if (respcode == 11)
                {
                    dcResponse.responseCode = '11';
                }
                else 
                {
                    dcResponse.responseCode = '21';
                }

            }
            else
            {
        
                Database.DeleteResult dr = Database.delete (theAcc, false );
        
                if (dr.IsSuccess ())
                {
                    dcResponse.responseCode = '00';
                    dcResponse.responseMessage = 'SUCCESS - ' + dcResponse.responseMessage ;
                }
                else
                {
                    dcResponse.responseCode = '21';
                    dcResponse.responseMessage = 'FAILED : ';
                    for (Database.Error err : dr.getErrors ())
                    {
                        dcResponse.responseMessage = dcResponse.responseMessage + ' - ' + err.getStatusCode () + ' - ' + err.getMessage ();
                    }
                
                }
            }
        }
        else
        {
            dcResponse.ResponseCode = '00';
            dcResponse.ResponseMessage = 'No Salesforce Customer found';
        }
        return ResponseMessage ();

    }

    public DeleteResponse CheckForInFlightOpportunities ()
    {
        InFlightOpportunity = false ;
        DeleteResponse rtv = new DeleteResponse ();

        //List<Opportunity> opps = [SELECT id, Application_Reference_number__c,  Opportunity_Status__c, Status_HPP_CAA__c , Status__c 
                            //FROM Opportunity 
                            //WHERE AccountId = :theAcc.Id
                            //AND ((Opportunity_Status__c not in ('HPP Close (Declined)','Savings (Closed Lost)'))
                                //AND   (Status_HPP_CAA__c not in ('(Product set) abandoned','Abandoned','Account declined','Affordability declined',
                                                                //'Application declined','Declined','Rejected','Valuation declined','Withdrawn'))
                                //AND   (Status__c <> 'Closed')
                                //AND ( StageName not in ('Account Lost','Account Declined','Application Declined','Retention Call - Not Interested','Applicationdeferred','HPP/BTL Opportunity - Closed Incomplete','Abandoned','Assigned to BDM - Rejected','HPP - Declined','Post Val (Declined)','Application Rejected - BRCC/Board','Application Rejected - Commercial Team','Application Rejected - Credit','Pre Val (Declined)','Postponed','Redeemed','Retention Call - No contact')))];

        List<Opportunity> opps = [SELECT id, 
                                        Application_Reference_number__c,  
                                        Opportunity_Status__c, 
                                        Status_HPP_CAA__c , 
                                        Status__c , 
                                        STAGENAME, 
                                        createddate
                                    FROM Opportunity 
                                    WHERE AccountId = :theAcc.Id
                                    AND createddate = LAST_N_MONTHS:12]; 
                                    //AND ( Opportunity_Status__c not in ('HPP Close (Declined)',
                                                                        //'Savings (Closed Lost)', 
                                                                        //'')
                                            //OR (  Opportunity_status__c = ''
                                                  //AND Status_HPP_CAA__c not in ('(Product set) abandoned',
                                                                                //'Abandoned',
                                                                                //'Account declined',
                                                                                //'Affordability declined',                                                                                          'Application declined',
                                                                                //'Declined',
                                                                                //'Rejected',
                                                                                //'Valuation declined',
                                                                                //'Withdrawn')
                                            //AND  Status__c <> 'Closed'
                                            //AND  StageName not in ('Account Lost',
                                                                   //'Account Declined',
                                                                   //'Application Declined',
                                                                   //'Retention Call - Not Interested',
                                                                   //'Applicationdeferred',
                                                                   //'HPP/BTL Opportunity - Closed Incomplete',
                                                                   //'Abandoned',
                                                                   //'Assigned to BDM - Rejected',
                                                                   //'HPP - Declined',
                                                                   //'Post Val (Declined)',
                                                                   //'Application Rejected - BRCC/Board',
                                                                   //'Application Rejected - Commercial Team',
                                                                   //'Application Rejected - Credit',
                                                                   //'Pre Val (Declined)',
                                                                   //'Postponed',
                                                                   //'Redeemed',
                                                                   //'Retention Call - No contact',
                                                                   //'Closed Won')))];                                                     

        rtv.responseCode = '';
        rtv.responseMessage = '';
        if (opps.size() > 0)
        {
             InFlightOpportunity = true ;
             rtv.ResponseCode = '11';
             for (Opportunity opp :opps)
             {
                rtv.ResponseMessage = rtv.ResponseMessage + ' Opportunity : ' + opp.Application_Reference_Number__c + ' Status : ' + opp.Status__c ;
             }
        }
        else
        {
            rtv.ResponseCode = '00';
            rtv.ResponseMessage = 'No Opportunities to delete';
        }
        
        return rtv;                     
    }

    public DeleteResponse DeleteDCCases ()
    {
        DeleteResponse rtv = new DeleteResponse ();

        List<Case> cases = [SELECT id
                            FROM Case where AccountId = :theAcc.Id];
        rtv.responseCode = '';
        rtv.responseMessage = '';
        if (cases.size() > 0)
        {
             List<Database.DeleteResult> delResults = new List<Database.DeleteResult>();
             delResults = Database.delete (cases, false );
             if (delResults.size () > 0 )
             {
                integer i ;
                for ( i = 0 ; i < delResults.Size() ; i++)
                {
                    Database.DeleteResult ur = delResults.get (i);
                    
                    if (ur.IsSuccess ())
                    {
                        rtv.responseCode = rtv.responseCode + '00';
                        //resp.responseMessage = 'SUCCEEDED';
                    }
                    else
                    {
                        rtv.responseCode = rtv.responseCode + '21';
                        List<Database.Error> errs = ur.getErrors();
                        Database.Error err = errs[0];
                        rtv.responseMessage = rtv.responseMessage + ' - ' + err.getMessage();
                    }
                    //respListToProcess.add (resp);
                }
                if (Integer.valueOf(rtv.responseCode) == 0)
                {
                    rtv.responseMessage = rtv.responseMessage + ' - Deleted  ' + String.valueOf(i) + ' Cases';
                }
            }
        }
        else
        {
            rtv.ResponseCode = '00';
            rtv.ResponseMessage = 'No Cases to delete';
        }
        
        return rtv;                     
    }

    public DeleteResponse DeleteDCEntitlements ()
    {
        DeleteResponse rtv = new DeleteResponse ();

        List<Entitlement> ents = [SELECT id
                            FROM Entitlement where AccountId = :theAcc.Id];
        rtv.responseCode = '';
        rtv.responseMessage = '';
        if (ents.size() > 0)
        {
             List<Database.DeleteResult> delResults = new List<Database.DeleteResult>();
             delResults = Database.delete (ents, false );
             if (delResults.size () > 0 )
             {
                integer i ;
                for ( i = 0 ; i < delResults.Size() ; i++)
                {
                    Database.DeleteResult ur = delResults.get (i);
                    
                    if (ur.IsSuccess ())
                    {
                        rtv.responseCode = rtv.responseCode + '00';
                        //resp.responseMessage = 'SUCCEEDED';
                    }
                    else
                    {
                        rtv.responseCode = rtv.responseCode + '21';
                        List<Database.Error> errs = ur.getErrors();
                        Database.Error err = errs[0];
                        rtv.responseMessage = rtv.responseMessage + ' - ' + err.getMessage();
                    }
                    //respListToProcess.add (resp);
                }
                if (Integer.valueOf(rtv.responseCode) == 0)
                {
                    rtv.responseMessage = rtv.responseMessage + ' - Deleted  ' + String.valueOf(i) + ' Entitlements';
                }
            }
        }
        else
        {
            rtv.ResponseCode = '00';
            rtv.ResponseMessage = 'No Entitlements to delete';
        }
        
        return rtv;                     
    }

    public DeleteResponse DeleteDCOpportunities ()
    {
        DeleteResponse rtv = new DeleteResponse ();

        List<Opportunity> opps = [SELECT id
                            FROM Opportunity where AccountId = :theAcc.Id];
        rtv.responseCode = '';
        rtv.responseMessage = '';
        if (opps.size() > 0)
        {
             List<Database.DeleteResult> delResults = new List<Database.DeleteResult>();
             delResults = Database.delete (opps, false );
             if (delResults.size () > 0 )
             {
                integer i ;
                for ( i = 0 ; i < delResults.Size() ; i++)
                {
                    Database.DeleteResult ur = delResults.get (i);
                    
                    if (ur.IsSuccess ())
                    {
                        rtv.responseCode = rtv.responseCode + '00';
                        
                        //resp.responseMessage = 'SUCCEEDED';
                    }
                    else
                    {
                        rtv.responseCode = rtv.responseCode + '21';
                        List<Database.Error> errs = ur.getErrors();
                        Database.Error err = errs[0];
                        rtv.responseMessage = rtv.responseMessage + ' - ' + err.getMessage();
                    }
                    //respListToProcess.add (resp);
                }
                if (Integer.valueOf(rtv.responseCode) == 0)
                {
                    rtv.responseMessage = rtv.responseMessage + ' - Deleted  ' + String.valueOf(i) + ' Opportunities';
                }
            }
        }
        else
        {
            rtv.ResponseCode = '00';
            rtv.ResponseMessage = 'No Opportunities to delete';
        }
        
        return rtv;                     
    }

    public DeleteResponse DeleteDCObservations ()
    {
        DeleteResponse rtv = new DeleteResponse ();

        List<MMR_observation_form__c> obvs = [SELECT id
                            FROM MMR_observation_form__c where People_record_link__c = :theAcc.Id];
        rtv.responseCode = '';
        rtv.responseMessage = '';
        if (obvs.size() > 0)
        {
             List<Database.DeleteResult> delResults = new List<Database.DeleteResult>();
             delResults = Database.delete (obvs, false );
             if (delResults.size () > 0 )
             {
                integer i ;
                for ( i = 0 ; i < delResults.Size() ; i++)
                {
                    Database.DeleteResult ur = delResults.get (i);
                    
                    if (ur.IsSuccess ())
                    {
                        rtv.responseCode = rtv.responseCode + '00';
                        //resp.responseMessage = 'SUCCEEDED';
                    }
                    else
                    {
                        rtv.responseCode = rtv.responseCode + '21';
                        List<Database.Error> errs = ur.getErrors();
                        Database.Error err = errs[0];
                        rtv.responseMessage = rtv.responseMessage + ' - ' + err.getMessage();
                    }
                    //respListToProcess.add (resp);
                }
                if (Integer.valueOf(rtv.responseCode) == 0)
                {
                    rtv.responseMessage = rtv.responseMessage + ' - Deleted  ' + String.valueOf(i) + ' Observations';
                }
            }
        }
        else
        {
            rtv.ResponseCode = '00';
            rtv.ResponseMessage = 'No Observations to delete';
        }
        
        return rtv;                     
    }

    public DeleteResponse DeleteDCSignatories ()
    {
        DeleteResponse rtv = new DeleteResponse ();

        List<Teller_Transaction_Signatory__c> sigs = [SELECT id
                            FROM Teller_Transaction_Signatory__c where Prospect_Customer__c = :theAcc.Id];
        rtv.responseCode = '';
        rtv.responseMessage = '';
        if (sigs.size() > 0)
        {
             List<Database.DeleteResult> delResults = new List<Database.DeleteResult>();
             delResults = Database.delete (sigs, false );
             if (delResults.size () > 0 )
             {
                integer i ;
                for ( i = 0 ; i < delResults.Size() ; i++)
                {
                    Database.DeleteResult ur = delResults.get (i);
                    
                    if (ur.IsSuccess ())
                    {
                        rtv.responseCode = rtv.responseCode + '00';
                        //resp.responseMessage = 'SUCCEEDED';
                    }
                    else
                    {
                        rtv.responseCode = rtv.responseCode + '21';
                        List<Database.Error> errs = ur.getErrors();
                        Database.Error err = errs[0];
                        rtv.responseMessage = rtv.responseMessage + ' - ' + err.getMessage();
                    }
                    //respListToProcess.add (resp);
                }
                if (Integer.valueOf(rtv.responseCode) == 0)
                {
                    rtv.responseMessage = rtv.responseMessage + ' - Deleted  ' + String.valueOf(i) + ' Signatories';
                }
            }
        }
        else
        {
            rtv.ResponseCode = '00';
            rtv.ResponseMessage = 'No Signatories to delete';
        }
        
        return rtv;                     
    }

    public DeleteResponse DeleteBankAccounts ()
    {
        DeleteResponse rtv = new DeleteResponse ();

        List<Account_with_IBB__c> awis = [SELECT id
                            FROM Account_with_IBB__c where Primary_SFDC_Account__c = :theAcc.Id];
        rtv.responseCode = '';
        rtv.responseMessage = '';
        if (awis.size() > 0)
        {
             List<Database.DeleteResult> delResults = new List<Database.DeleteResult>();
             delResults = Database.delete (awis, false );
             if (delResults.size () > 0 )
             {
                integer i ;
                for ( i = 0 ; i < delResults.Size() ; i++)
                {
                    Database.DeleteResult ur = delResults.get (i);
                    
                    if (ur.IsSuccess ())
                    {
                        rtv.responseCode = rtv.responseCode + '00';
                        //resp.responseMessage = 'SUCCEEDED';
                    }
                    else
                    {
                        rtv.responseCode = rtv.responseCode + '21';
                        List<Database.Error> errs = ur.getErrors();
                        Database.Error err = errs[0];
                        rtv.responseMessage = rtv.responseMessage + ' - ' + err.getMessage();
                    }
                    //respListToProcess.add (resp);
                }
                if (Integer.valueOf(rtv.responseCode) == 0)
                {
                    rtv.responseMessage = rtv.responseMessage + ' - Deleted  ' + String.valueOf(i) + ' Signatories';
                }
            }
        }
        else
        {
            rtv.ResponseCode = '00';
            rtv.ResponseMessage = 'No Bank Accounts to delete';
        }
        
        return rtv;                     
    }

    

    public string ResponseMessage ()
    {
        string rtv = '<SFDCDeleteCustomerResponse>';
        rtv = rtv + '<MsgID>' + dcResponse.msgID + '</MsgID>';
        rtv = rtv + '<SFDCID>' + dcResponse.SFDCID + '</SFDCID>';
        rtv = rtv + '<EBSID>' + dcResponse.EBSID + '</EBSID>';
        rtv = rtv + '<PanopticID>' + dcResponse.PanopticID + '</PanopticID>';
        rtv = rtv + '<ResponseCode>' + dcResponse.responseCode + '</ResponseCode>';
        rtv = rtv + '<ResponseMessage>' + dcResponse.responseMessage + '</ResponseMessage>';
        rtv = rtv + '</SFDCDeleteCustomerResponse>';
        return rtv;
    }

    public string ResponseMessage (DeleteCustomerResponse dResponse)
    {
        string rtv = '<SFDCDeleteCustomerResponse>';
        rtv = rtv + '<MsgID>' + dResponse.msgID + '</MsgID>';
        rtv = rtv + '<SFDCID>' + dResponse.SFDCID + '</SFDCID>';
        rtv = rtv + '<EBSID>' + dResponse.EBSID + '</EBSID>';
        rtv = rtv + '<PanopticID>' + dResponse.PanopticID + '</PanopticID>';
        rtv = rtv + '<ResponseCode>' + dResponse.responseCode + '</ResponseCode>';
        rtv = rtv + '<ResponseMessage>' + dResponse.responseMessage + '</ResponseMessage>';
        rtv = rtv + '</SFDCDeleteCustomerResponse>';
        return rtv;
    }

    public class DeleteResponse 
    {
        public string ResponseCode {get ; set ; }
        public string ResponseMessage {get ; set ; }
    }

}