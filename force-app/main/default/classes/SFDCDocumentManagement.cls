/* ---------------------------------------------------------------------------------------  */
/* C0530    New web service for Document Management Cases                                   */
/* ---------------------------------------------------------------------------------------  */
/* C0727    Check DocumentName, write to Opportunity child object DSX_Document_Link__c      */
/*          if document name is in the list from DM_OpportunityDocumentNames__c             */
/* ---------------------------------------------------------------------------------------- */

global class SFDCDocumentManagement
{

    webservice static string testComms(String inTestString)
    {
         System.debug('*** -- Into testComms with ' + inTestString + ' -- ***');
        
        return 'WE RECEIVED ' + inTestString;
    }
    
    webservice static string DocumentManagementCase ( string inRequest)
    {
        string decodedRequest;
        XmlStreamReader xsr;
        DocumentManagementCase theDocumentCase = new DocumentManagementCase();
        DocumentManagementCaseResponse theResponse = new DocumentManagementCaseResponse();
        
        try
        {
            decodedRequest = EncodingUtil.urlDecode(inRequest, 'UTF-8');
        }
        catch (Exception ex1)
        {
            theResponse.ResponseCode = 'FAILED';
            theResponse.ResponseMsg = 'Problem decoding request ' + ex1.GetMessage() ;
        }
 
        
        if (String.IsBlank(theResponse.ResponseCode))
        {
            try
            {
                xsr = new XmlStreamReader (decodedRequest);
                while (xsr.HasNext())
                {
                 if (xsr.getEventType() == XmlTag.START_ELEMENT)
                    {
                        if ('MessageID'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.MessageID = xsr.getText();
                            }
                        }
                        else if ('MessageType'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.MessageType = xsr.getText();
                            }
                        }
                        else if ('ReplicationType'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.ReplicationType = xsr.getText();
                            }
                        }
                        else if ('CustNo'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CustNo = xsr.getText();
                            }
                        }
                        else if ('CaseDirectorCode'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseDirectorCode = xsr.getText();
                            }
                        }
                        else if ('CaseDescription'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseDescription = xsr.getText();
                            }
                        }
                        else if ('CaseSubject'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseSubject = xsr.getText();
                            }
                        }
                        else if ('CaseUser'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseUser = xsr.getText();
                            }
                        }
                        else if ('CaseStatus'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseStatus = xsr.getText();
                            }
                        }
                        else if ('CaseQueue'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CaseQueue = xsr.getText();
                            }
                        }
                        else if ('DocumentDefinitionName'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentDefinitionName = xsr.getText();
                            }
                        }
                        else if ('DocumentName'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentName = xsr.getText();
                            }
                        }
                        else if ('DocumentUDI'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentUDI = xsr.getText();
                            }
                        }
                        else if ('ProcessStatus '.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.ProcessStatus  = xsr.getText();
                            }
                        }
                        else if ('CustomerNumber'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CustomerNumber = xsr.getText();
                            }
                        }
                        else if ('AccountNumber'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.AccountNumber = xsr.getText();
                            }
                        }
                        else if ('Branch'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.Branch = xsr.getText();
                            }
                        }
                        else if ('FirstName'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.FirstName = xsr.getText();
                            }
                        }
                        else if ('LastName'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.LastName = xsr.getText();
                            }
                        }
                        else if ('PostCode'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.PostCode = xsr.getText();
                            }
                        }
                        else if ('DocumentReference'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentReference = xsr.getText();
                            }
                        }
                        else if ('CompletionDate'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.CompletionDate = xsr.getText();
                            }
                        }
                        else if ('DocumentDate'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentDate = xsr.getText();
                            }
                        }
                        
                        else if ('DocumentTime'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.DocumentTime = xsr.getText();
                            }
                        }
                        
                        else if ('ActionStatus'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.ActionStatus  = xsr.getText();
                            }
                        }
                        
                        else if ('WorkLocation'.equalsIgnoreCase (xsr.getLocalName()))
                        {
                            system.debug ( 'AccountNo ' + xsr.getLocalName());
                            xsr.next();
                            if (xsr.IsCharacters())
                            {
                                theDocumentCase.WorkLocation  = xsr.getText();
                            }
                        }
                     }
                    xsr.next();
                }
            }
            catch (Exception e)
            {
                theResponse.ResponseCode = 'FAILED';
                theResponse.ResponseMsg = theResponse.ResponseMsg + ' - ' + e.getMessage();
            }

            /* C0727 */
            List<DM_OpportunityDocumentNames__c> docNames = [SELECT Document_Name__c
                                                            FROM    DM_OpportunityDocumentNames__c
                                                            WHERE Document_Name__c = :theDocumentCase.DocumentName];
            //
            if (docNames.Size() > 0)
            {
                List<Opportunity> opps = [SELECT Id,
                                            Opportunity_Reference__c,
                                            DSX_Documents_Expected__c,      /* C0728 */
                                            DSX_Documents_Received__c,      /* C0728 */
                                            DSX_Documents_Outstanding__c    /* C0728 */
                                   FROM Opportunity
                                   WHERE Opportunity_Reference__c = :theDocumentCase.DocumentReference];
                if (opps.Size() > 0)
                {
                    theResponse = ProcessOpps (opps, theDocumentCase);

                }
                else
                {
                    theResponse.ResponseMsg = 'The Opportunity ' + theDocumentCase.DocumentReference + ' was not found ';
                    theResponse.ResponseCode = 'FAILED';
                    theResponse.messageID = theDocumentCase.MessageID;
                    theResponse.DocumentUDI = theDocumentCase.DocumentUDI;
                }

            }
            else
            {  
            /* C0727 */          
                CaseDirector caseDir = new CaseDirector();
                List<CaseDirector.ExternalCase> cases = new List<CaseDirector.ExternalCase>();
                CaseDirector.ExternalCase extCase = new CaseDirector.ExternalCase();
                caseDir.dmc = theDocumentCase;
                extCase.ExternalCaseReferenceID = theDocumentCase.MessageID;
                extCase.EBSCustomerID = theDocumentCase.CustNo;
                extCase.CaseDirectorCode = theDocumentCase.CaseDirectorCode;
                extCase.CaseDirectorDescription = theDocumentCase.CaseDescription;
                extCase.CaseDirectorSubject = theDocumentCase.CaseSubject;
                extCase.EBSUserID = '000';
                extCase.CaseDirectorPriority = theDocumentCase.CasePriority;
                extCase.CaseDirectorStatus = theDocumentCase.CaseStatus;
                extCase.CaseDirectorQueue = theDocumentCase.CaseQueue;
            
                cases.add(extCase);
                caseDir.ExternalCases = cases;
                caseDir.CreateExternalCases();
            
                for(CaseDirector.ExternalCaseResponse resp : caseDir.ExternalCaseResponses)
                {
                    theResponse.messageID = resp.CaseMessageID;
                    theResponse.DocumentUDI = theDocumentCase.DocumentUDI;
                    theResponse.ResponseCode = resp.CaseInsertResult;
                    theResponse.ResponseMsg = resp.CaseInsertResultMessage;
                }
                /* C0727 */
            }
            /* C0727 */

        }
        return ResponseMessage(theResponse);
    }

    public static string ResponseMessage (DocumentManagementCaseResponse resp)
    {
        string rtv = '';
        
        rtv = '<DMCaseResponse>';
        rtv = rtv + '<MessageID>' + resp.messageId + '</MessageID>';
        rtv = rtv + '<DocumentUDI>' + resp.DocumentUDI + '</DocumentUDI>';
        rtv = rtv + '<ResponseCode>' + resp.ResponseCode + '</ResponseCode>';
        rtv = rtv + '<ResponseMsg>' + resp.ResponseMsg + '</ResponseMsg>';
        rtv = rtv + '</DMCaseResponse>';
        
        return rtv;
    }

    public static DocumentManagementCaseResponse ProcessOpps (List<Opportunity> opps, DocumentManagementCase theDocumentCase)
    {
        DocumentManagementCaseResponse theResponse = new DocumentManagementCaseResponse();

        List<Opportunity> oppsToUpdate = new List<Opportunity> ();  /* C0728 */

        List<DSX_Document_Link__c> dsxToInsert = new List<DSX_Document_Link__c>();
        DSX_Document_Link__c dsxLink = new DSX_Document_Link__c ();
        dsxLink.Document_Link__c = 'http://dsxlive1/DSXSearchDisplay/Default.aspx?UDI=' + theDocumentCase.DocumentUDI;
        dsxLink.Document_Name__c = theDocumentCase.DocumentName;
        dsxLink.Opportunity__c = opps[0].id;

        System.debug ( 'The value of opps[0].DSX_Documents_Received__c ' + opps[0].DSX_Documents_Received__c);
        System.debug ( 'The Document Name ' + theDocumentCase.DocumentName);
        /* C0728 * now done in trigger
        if (String.IsBlank(opps[0].DSX_Documents_Received__c))
        {
            opps[0].DSX_Documents_Received__c = theDocumentCase.DocumentName;
            System.debug ( 'The value A of opps[0].DSX_Documents_Received__c ' + opps[0].DSX_Documents_Received__c);
        }
        else
        {
            if (!opps[0].DSX_Documents_Received__c.Contains (theDocumentCase.DocumentName))
            {
                opps[0].DSX_Documents_Received__c = opps[0].DSX_Documents_Received__c + ';' + theDocumentCase.DocumentName;
            }
            System.debug ( 'The value B of opps[0].DSX_Documents_Received__c ' + opps[0].DSX_Documents_Received__c);
        }

        // Update outstanding docs field
        List<DSX_Document_Link__c> existingDocs = [SELECT Document_Name__c
                                                    FROM DSX_Document_Link__c
                                                    WHERE Opportunity__c = :opps[0].id
                                                    AND Document_Status__c = 'VERIFIED'];

        String receivedDocs = '';
        if (existingDocs.size() > 0)
        {
            for (DSX_Document_Link__c dsx : existingDocs)
            {
                receivedDocs = receivedDocs + ';' + dsx.Document_Name__c;
            }
            receivedDocs = receivedDocs + ';' + theDocumentCase.DocumentName;
        }
        else
        {
            receivedDocs = theDocumentCase.DocumentName;
        }
        
        if (!String.isBlank(opps[0].DSX_Documents_Expected__c))
        {
            List<String> expectedDocs = new List<String>();
            if (opps[0].DSX_Documents_Expected__c.Contains (';'))
            {
                expectedDocs = opps[0].DSX_Documents_Expected__c.Split(';');
            }
            else
            {
                expectedDocs.Add (opps[0].DSX_Documents_Expected__c);
            }
            String outstandingDocs = '';
            if (!String.IsBlank (receivedDocs))
            {
                for (string s : expectedDocs )
                {
                    if (!receivedDocs.Contains (s) || s == theDocumentCase.DocumentName)
                    {
                        outstandingDocs = String.isBlank(outstandingDocs) ? s  : outstandingDocs + ';' + s;
                    }
                }

                opps[0].DSX_Documents_Outstanding__c = outstandingDocs ;
            }
        }
        
        oppsToUpdate.Add (opps[0]);
        * C0728 */
        

        dsxToInsert.Add(dsxLink);

        Database.SaveResult[] dsxInsertResults;
        dsxInsertResults = Database.Insert (dsxToInsert, false);
                    
        if (dsxInsertResults != null && dsxInsertResults.Size() > 0)
        {
            for (integer ix = 0; ix < dsxInsertResults.Size(); ix++)
            {
                Database.SaveResult du = dsxInsertResults.get(ix);
                            
                if (du.IsSuccess())
                {
                    theResponse.ResponseCode  = 'SUCCESS';
                }
                else
                {
                    theResponse.ResponseCode = 'FAILED';
                    List<Database.Error> dbErr = du.GetErrors();
                    Database.Error e = dbErr[0];
                    theResponse.ResponseMsg = e.GetMessage();
                }
                
                        
                //ExternalCaseResponses.Add(resp);
            }
            theResponse.messageID = theDocumentCase.MessageID;
            theResponse.DocumentUDI = theDocumentCase.DocumentUDI;
                        
        }

        /* C0728 *

        Database.SaveResult[] oppUpdateResults;
        oppUpdateResults = Database.Update (oppsToUpdate, false);
                    
        if (oppUpdateResults != null && oppUpdateResults.Size() > 0)
        {
            for (integer i = 0; i < oppUpdateResults.Size(); i++)
            {
                Database.SaveResult du = oppUpdateResults.get(i);
                            
                if (du.IsSuccess())
                {
                    theResponse.ResponseCode  = 'SUCCESS';
                }
                else
                {
                    theResponse.ResponseCode = 'FAILED';
                    List<Database.Error> dbErr = du.GetErrors();
                    Database.Error e = dbErr[0];
                    theResponse.ResponseMsg = e.GetMessage();
                }
                
                        
                //ExternalCaseResponses.Add(resp);
            }
            theResponse.messageID = theDocumentCase.MessageID;
            theResponse.DocumentUDI = theDocumentCase.DocumentUDI;
                        
        }

        * C0728 */

        return theResponse;
    }


}