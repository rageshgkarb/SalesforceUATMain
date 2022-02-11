/* --------------------------------------------------------------------------------------------------- */
/* C0530 DocumentManagement Cases                                                                      */
/* --------------------------------------------------------------------------------------------------- */

public without sharing class CaseDirector
{
    public List<ExternalCase> ExternalCases {get;set;}
    public List<ExternalCaseResponse> ExternalCaseResponses {get;set;}
    public List<ExternalCase> ExternalCasesToProcess {get;set;}
    
    
    public DocumentManagementCase dmc {get;set;}    // C0530

    public IBBCaseDirector__c CaseDirector
    {
        get
        {
            if (CaseDirector == null)
            {
                CaseDirector = new IBBCaseDirector__c();
            }
            return CaseDirector;
        }
        set;
    }
    
    public List<IBBCaseDirector__c> CaseDirectors
    {
        get
        {
            if (CaseDirectors == null)
            {
                CaseDirectors = new List<IBBCaseDirector__c>();
            }
            return CaseDirectors;
        }
        set;
    }
    
    public List<Contact> AccountContacts
    {
        get
        {
            if (AccountContacts == null)
            {
                AccountContacts = new List<Contact>();
            }
            return AccountContacts;
        }
        set;
    }
    
    public List<string> ExternalCaseReasons = new List<string>();
    public List<string> ExternalCustomerIDs = new List<string>();
    public List<string> ExternalUserIds = new List<string>();
    public List<string> ExternalQueueIds = new List<string>();
    
    //private List
    private Opportunity m_opp
    {
        get
        {
            if ( m_opp == null)
            {
                m_opp = new Opportunity();
            }
            return m_opp;
        }
        set;
    }
    private string m_category;
    private string m_recordType;
    private string m_userId;
    private List<string> m_codes;
    private boolean m_writeCase;
    private string m_oppId;
    private string m_theContact;
    private DecisionEngineResponse m_DEResponse;
    
    private List<CaseToDirect> m_casesToDirect
    {
        get
        {
             if(m_casesToDirect == null)
             {   
                  m_casesToDirect = new List<CaseToDirect>();
             }
             return m_casesToDirect;
         }
         set;
         
    }
    
    private List<string> m_queueNames
    {
        get
        {
            if (m_queueNames == null)
            {
                m_queueNames = new List<string>();
            }
            return m_queueNames;
         }
         set;
    }
    
    private List<string> m_userNames
    {
        get
        {
            if (m_userNames== null)
            {
                m_userNames= new List<string>();
            }
            return m_userNames;
         }
         set;
    }
    
    private Map<string, string> m_caseDirectorToqueueName
    {
        get
        {
            if (m_caseDirectorToqueueName == null)
            {
                m_caseDirectorToqueueName = new Map<string, string>();
            }
            return m_caseDirectorToqueueName;
        }
        set;
    }
    
    private Map<string, string> m_caseDirectorToUserName
    {
        get
        {
            if (m_caseDirectorToUserName== null)
            {
                m_caseDirectorToUserName= new Map<string, string>();
            }
            return m_caseDirectorToUserName;
        }
        set;
    }
    
    private Map<string, string> m_queueNameToqueueId 
    {
        get
        {
            if (m_queueNameToqueueId == null)
            {
                m_queueNameToqueueId = new Map<string, string>();
            }
            return m_queueNameToqueueId ;
        }
        set;
    }
    
    private Map<string, string> m_EBSUserIdToUserId 
    {
        get
        {
            if (m_EBSUserIdToUserId  == null)
            {
                m_EBSUserIdToUserId  = new Map<string, string>();
            }
            return m_EBSUserIdToUserId  ;
        }
        set;
    }
    
    private Map<string, string> m_EBSIDToAccountId {get;set;}
    
    private Map<string, string> m_EBSIDToTheAccountId {get;set;}// C0530
    
    
    private Map<string, string> m_MapCodeToRecordTypeName {get;set;}
    private Map<string, string> m_CaseCodeToRecordTypeId {get;set;}
    //private Map<string, string> m_UserNameToUserId {get;set;}
    private List<string> m_RecordTypes {get;set;}

    public CaseDirector(string category, List<string> codes, string theContact, boolean writeCase, Opportunity opp)
    {
        m_category = category;
        m_codes = codes;
        m_writeCase = writeCase;
        m_opp = opp;
        m_theContact = theContact;
        GetCaseDirectors(false);
    }
    
    public CaseDirector(string category, DecisionEngineResponse DEResponse, boolean writeCase, Opportunity opp)
    {
        m_category = category;
        m_DEResponse = new DecisionEngineResponse();
        m_DEResponse = DEResponse;
        m_writeCase = writeCase;
        m_opp = opp;
        GetCaseDirectors(true);
    }
    
    public CaseDirector()
    {
        
    }
    
    public void CreateExternalCases ()
    {
        GetExternalCaseDirectors();
        ProcessExternalCaseDirectors();
    }
    
    private void GetExternalCaseDirectors ()
    {
        system.debug ('In here ' + ExternalCases);
        for (ExternalCase extCase : ExternalCases)
        {
            ExternalCaseReasons.Add (extCase.CaseDirectorCode);
			/* C0530 */
			if (!String.isEmpty(extCase.EBSCustomerID))
			{
				ExternalCustomerIDs.Add (extCase.EBSCustomerID);
			}
            
            system.debug ('ExternaCustomerIDs A ' + ExternalCustomerIDs);
            ExternalUserIDs.Add (extCase.EBSUserID);
            ExternalQueueIDs.Add (extCase.CaseDirectorQueue);
        }
        
        Map<string, IBBCaseDirector__c> mapCodeToDirector = new Map<string, IBBCaseDirector__c>();
        
        List<IBBCaseDirector__c> CaseDirectors = [SELECT   id,
                                                           CaseCode__c,
                                                           Name,
                                                           CaseDescription__c,
                                                           CaseRecordType__c,
                                                           CaseSubject__c,
                                                           CasePriority__c, 
                                                           CaseStatus__c,
                                                           CaseOrigin__c,
                                                           CaseUseQueue__c,
                                                           CaseUser__c,
                                                           CaseQueue__c,
                                                           CaseUseConfigUser__c
                                                    FROM      IBBCaseDirector__c
                                                    WHERE     CaseCode__c in :ExternalCaseReasons ]; 
        
        if ( CaseDirectors.Size() > 0)
        {
            m_RecordTypes = new List<string>();
            m_MapCodeToRecordTypeName = new Map<string, string>();
            for (IBBCaseDirector__c dir : CaseDirectors)
            {
                try
                {
                    mapCodeToDirector.put (dir.CaseCode__c, dir);   
                }
                catch (Exception ex)
                {
                }
                
                try
                {
                    system.debug ( 'The Case Code ' + dir.CaseCode__c + ' - the record type ' + dir.CaseRecordType__c);
                    m_MapCodeToRecordTypeName.put (dir.CaseRecordType__c, dir.CaseCode__c);
                    m_RecordTypes.Add (dir.CaseRecordType__c);
                    ExternalQueueIDs.Add (dir.CaseQueue__c);
                    system.debug ( 'The m_RecordTypes ' + m_RecordTypes);
                }
                catch (Exception e)
                {
                    system.debug ('Why not m_recordTypes ' + e.GetMessage());
                }
            }
            ExternalCasesToProcess = new List<ExternalCase>();
            for (ExternalCase eCase : ExternalCases)
            {
                eCase.CaseDirector = mapCodeToDirector.get (eCase.CaseDirectorCode);
                ExternalCasesToProcess.Add (eCase);
            }
        } 
    }
    
    private void ProcessExternalCaseDirectors ()
    {
        // Look up the various bits and bobs
        m_CaseCodeToRecordTypeId = GetTheRecordTypes ();
        m_queueNameToqueueId = GetTheQueueIds (ExternalQueueIDs);
        
        m_EBSUserIdToUserId = GetUserIDs (); 
        m_EBSIDToAccountId = getCustomerIDs ();
        //m_UserNameToUserId = getUserIds ();
        
        Map<integer, string> MapExternalReferenceToCase = new Map<integer, string>();
        integer i = 0;
        system.debug ('The Case Code to recordType id ' + m_CaseCodeToRecordTypeId);
        system.debug ('The EBS ID to Account id ' + m_EBSIDToAccountId);
        List<Case> casesToInsert = new List<Case>();
        for (ExternalCase extCase : ExternalCasesToProcess)
        {
            Case createCase = new Case();
            createCase.Subject = String.IsEmpty (extCase.CaseDirectorSubject) ? extCase.CaseDirector.CaseSubject__c : extCase.CaseDirectorSubject;
            // This needs sorting out to be real ID
            createCase.RecordTypeId =  m_CaseCodeToRecordTypeId.get(extCase.CaseDirectorCode);
            //
            createCase.Description = String.IsEmpty (extCase.CaseDirectorDescription) ? extCase.CaseDirector.CaseDescription__c : extCase.CaseDirectorDescription;             
            
            //8 C0531
            if (!String.isEmpty(extCase.EBSCustomerID))
            {
                createCase.ContactId = m_EBSIDToAccountId.get (extCase.EBSCustomerID);
                createCase.AccountId = m_EBSIDToTheAccountId.get (extCase.EBSCustomerID);
            }
            
            
            
            
            //createCase.ContactId = m_EBSIDToAccountId.get (extCase.EBSCustomerID);
            
            system.debug ( 'This is the Case object ' + extCase);
            if (!String.IsEmpty (FunctionHelper.StripNull (extCase.CaseDirectorQueue)))
            {
                //createCase.OwnerId = String.IsEmpty (extCase.CaseDirectorQueue) ? m_queueNameToqueueId.get ( extCase.CaseDirector.CaseQueue__c ) : m_queueNameToqueueId.get (extCase.CaseDirectorQueue);
                system.debug ( 'So we have a caseDirectorQueue ' + m_queueNameToqueueId.get (extCase.CaseDirectorQueue));
                createCase.OwnerId = m_queueNameToqueueId.get (extCase.CaseDirectorQueue);
            }
            else if (extCase.CaseDirector.CaseUseQueue__c == true)
            {
                system.debug ( 'So we dont have have a caseDirectorQueue ' + m_queueNameToqueueId.get ( extCase.CaseDirector.CaseQueue__c ));
                createCase.OwnerId = m_queueNameToqueueId.get ( extCase.CaseDirector.CaseQueue__c );
            }
            else
            {    
                system.debug ('The Case User is : ' + extCase.CaseDirector.CaseUser__c);
                createCase.OwnerId = String.IsEmpty (extCase.EBSUserID) ? extCase.CaseDirector.CaseUser__c : m_EBSUserIdToUserId.get(extCase.EBSUserID);
            }
            
            createCase.Origin = extCase.CaseDirector.CaseOrigin__c;
            createCase.Status = String.IsEmpty (extCase.CaseDirectorStatus) ? extCase.CaseDirector.CaseStatus__c : extCase.CaseDirectorStatus;
            createCase.Priority = String.IsEmpty (extCase.CaseDirectorPriority) ? extCase.CaseDirector.CasePriority__c : extCase.CaseDirectorPriority;
        
            /* C0531 start */
            
            if ( dmc != null)
            {
                // The below is predicated on the Document Management only creating one case per call.
                // revisit if need to batch up
                if (!String.isEmpty(dmc.AccountNumber))
				{
					List<Account_with_IBB__c> accs = [select Id, EBS_ID__c from Account_With_IBB__c where EBS_ID__c = :dmc.AccountNumber];
					if (accs.size() > 0)
					{
	                    System.Debug ( 'This is the accs ' + accs[0]);
	                    createCase.Account_relating_to__c = accs[0].id;
	                    createCase.DM_Customer_Account__c = accs[0].id;
					}
				}
                
                createCase.DM_Account_Number__c = dmc.AccountNumber;
                createCase.DM_Action_Status__c = dmc.ActionStatus;
                createCase.DM_Branch__c = dmc.Branch;
                createCase.DM_Buffer_ID__c = dmc.MessageID;
                createCase.DM_Completion_Date__c = dmc.CompletionDate;
                createCase.DM_Customer_Number__c = dmc.CustomerNumber;
                createCase.DM_Definition_Name__c = dmc.DocumentDefinitionName;
                createCase.DM_Document_Date__c = dmc.DocumentDate;
                createCase.DM_Document_Name__c = dmc.DocumentName;
                createCase.DM_Document_Reference__c = dmc.DocumentReference;
                createCase.DM_Document_Time__c = dmc.DocumentTime;
                createCase.DM_Document_UDI__c = dmc.DocumentUDI;
                createCase.DM_DocumentURL__c = 'http://dsxlive1/DSXSearchDisplay/Default.aspx?UDI=' + dmc.DocumentUDI;
                createCase.DM_FirstName__c = dmc.FirstName;
                createCase.DM_LastName__c = dmc.LastName;
                createCase.DM_PostCode__c = dmc.PostCode;
                createCase.DM_Work_Location__c = dmc.WorkLocation;
            }
            /* C0531 */
        
            casesToInsert.Add (createCase);
            
            MapExternalReferenceToCase.put (i, extCase.ExternalCaseReferenceID);
            
            i++;
        
        }
        system.debug ( 'These are the cases to insert ' + casesToInsert);
        Database.SaveResult[] caseInsertResults;
        caseInsertResults = Database.Insert (casesToInsert, false);
        ExternalCaseResponses = new List<ExternalCaseResponse>();
        if (caseInsertResults != null && caseInsertResults.Size() > 0)
        {
            for (integer ix = 0; ix < caseInsertResults.Size(); ix++)
            {
                Database.SaveResult du = caseInsertResults.get(ix);
                ExternalCaseResponse resp = new ExternalCaseResponse();
                resp.CaseMessageID = MapExternalReferenceToCase.get(ix);
                if (du.IsSuccess())
                {
                    resp.CaseInsertResult = 'SUCCESS';
                }
                else
                {
                    resp.CaseInsertResult = 'FAILED';
                    List<Database.Error> dbErr = du.GetErrors();
                    Database.Error e = dbErr[0];
                    resp.CaseInsertResultMessage = e.GetMessage();
                }
                
                ExternalCaseResponses.Add(resp);
            }
        }
    }
    
    
    
    
    private void GetCaseDirectors(boolean useDEObject)
    {
        system.debug('In GetCaseDirectors 1 ' + useDEObject);
        if (useDEObject)
        {
            Map<string, string> contactMap = new Map<string, string>();
            
           
            List<string> reasonCodes = new List<string>();
            system.debug('The person is ' + m_DEResponse.ThePerson);
            //Contact accountContact = [select Id 
            //                           from Contact 
            //                           where AccountId = :m_DEResponse.ThePerson];
                                       
            if ( m_DEResponse.Decision == 'FAILED IN EBS' )
            {
                reasonCodes.Add('SERVICEFAILURE');
            }
            else
            {
                for (DecisionEngineResponse.Reason reason : m_DEResponse.DecisionReasons)
                {
                    reasonCodes.Add(reason.ReasonCode);
                    system.debug('in GetCaseDirectors A');  
                   // applicantContactIds.Add(reason.ThisApplicant.Prospect_Customer__c);
                    
                }
            }
            
           
            
            system.debug('in GetCaseDirectors B ' + reasonCodes + ' ' + m_Category);  
            List<IBBCaseDirector__c> CaseDirectors = [SELECT   id,
                                                               CaseCode__c,
                                                               Name,
                                                               CaseDescription__c,
                                                               CaseRecordType__c,
                                                               CaseSubject__c,
                                                               CasePriority__c, 
                                                               CaseStatus__c,
                                                               CaseOrigin__c,
                                                               CaseUseQueue__c,
                                                               CaseUser__c,
                                                               CaseQueue__c,
                                                               CaseUseConfigUser__c
                                                       FROM      IBBCaseDirector__c
                                                       WHERE     CaseCode__c in :reasonCodes
                                                       AND       CaseCategory__c = :m_Category ]; 
            system.debug('CaseDirectors size ' + CaseDirectors.Size());
            if (CaseDirectors.Size() > 0)
            {
                
            
                List<RecordType> recordTypes = [SELECT    Id,
                                                          Name
                                                FROM      RecordType
                                                WHERE     Name = :CaseDirectors[0].CaseRecordType__c];   
                m_recordType = recordTypes[0].Id; 
                system.debug('Record Type ' + m_recordType );
                Map<string, IBBCaseDirector__c> directorMap = new Map<string, IBBCaseDirector__c>();  
                
                for (IBBCaseDirector__c dir : CaseDirectors)
                {
                    system.debug('Case code :' +dir.CaseCode__c );
                    directorMap.put(dir.CaseCode__c, dir);
                   
                    if (dir.CaseUseQueue__c == true)
                    {
                        m_queueNames.Add(dir.CaseQueue__c);
                        m_caseDirectorToqueueName.put(dir.Id, dir.CaseQueue__c);
                    }
                }    
                             
                m_queueNameToqueueId = GetTheQueueIds(m_queueNames);           
              
                for (  DecisionEngineResponse.Reason reason : m_DEResponse.DecisionReasons)
                {
                    IBBCaseDirector__c cd = directorMap.get(reason.ReasonCode);
                    if (cd != null)
                    {
                        string queueId;
                        //string userId;
                        if (cd.CaseUseQueue__c == true)
                        {
                            queueId = m_queueNameToqueueId.get(m_caseDirectorToqueueName.get(cd.Id));
                        }
 
                        CaseToDirect ctd = new CaseToDirect(cd, 
                                                            reason.ReasonCode, 
                                                            reason.ReasonDescription, 
                                                            m_recordType,
                                                            !String.IsEmpty(queueId) ? queueId : '', 
                                                            reason.ThisApplicant.Prospect_Customer__r.PersonContactId);
                                                            //accountContact.Id);//,
                                                            //!String.IsEmpty(userId) ? userId : '');
                        m_casesToDirect.Add(ctd);
                    }
                }
                system.debug ('Size of CasesToDirect ' + m_casesToDirect.Size());
            }
        }
        else
        {
            List<IBBCaseDirector__c> CaseDirectors = [SELECT   id,
                                                               CaseCode__c,
                                                               Name,
                                                               CaseDescription__c,
                                                               CaseRecordType__c,
                                                               CaseSubject__c,
                                                               CasePriority__c, 
                                                               CaseStatus__c,
                                                               CaseOrigin__c,
                                                               CaseUseQueue__c,
                                                               CaseUser__c,
                                                               CaseQueue__c,
                                                               CaseUseConfigUser__c
                                                       FROM      IBBCaseDirector__c
                                                       WHERE     CaseCode__c in :m_codes
                                                       AND       CaseCategory__c = :m_Category ]; 
            if (CaseDirectors.Size() > 0)
            {
            
                List<RecordType> recordTypes = [SELECT    Id,
                                                          Name
                                                FROM      RecordType
                                                WHERE     Name = :CaseDirectors[0].CaseRecordType__c];   
                m_recordType = recordTypes[0].Id; 
    
                Map<string, IBBCaseDirector__c> directorMap = new Map<string, IBBCaseDirector__c>();  
                
                for (IBBCaseDirector__c dir : CaseDirectors)
                {
                    directorMap.put(dir.CaseCode__c, dir);
                   
                    if (dir.CaseUseQueue__c == true)
                    {
                        m_queueNames.Add(dir.CaseQueue__c);
                        m_caseDirectorToqueueName.put(dir.Id, dir.CaseQueue__c);
                    }
                }    
                             
                m_queueNameToqueueId = GetTheQueueIds(m_queueNames);           
              
                for (  DecisionEngineResponse.Reason reason : m_DEResponse.DecisionReasons)
                {
                    IBBCaseDirector__c cd = directorMap.get(reason.ReasonCode);
                    if (cd != null)
                    {
                        string queueId;
                        //string userId;
                        if (cd.CaseUseQueue__c == true)
                        {
                            queueId = m_queueNameToqueueId.get(m_caseDirectorToqueueName.get(cd.Id));
                        }
 
                        CaseToDirect ctd = new CaseToDirect(cd, 
                                                            reason.ReasonCode, 
                                                            reason.ReasonDescription, 
                                                            m_recordType,
                                                            !String.IsEmpty(queueId) ? queueId : '', 
                                                            m_theContact);//,
                                                            //!String.IsEmpty(userId) ? userId : '');
                        m_casesToDirect.Add(ctd);
                    }
                }
            }    
        }  
        
        
        
        if (caseDirectors.Size() > 0 )
        {
            CaseDirector = caseDirectors[0];
        }  
    }
    
    public Case CreateCase ()
    {
        Case createCase = new Case();
        createCase.RecordTypeId = GetTheRecordTypeId();
        createCase.Subject = CaseDirector.CaseSubject__c;
        createCase.Description = CaseDirector.CaseDescription__c;
        createCase.Opportunity__c = m_oppId;
        if(m_writeCase)
        {
            upsert createCase;
        }
        return createCase;
    }
    
    public Case CreateCase (string subject, string description)
    {
        Case createCase = new Case();
        createCase.RecordTypeId = GetTheRecordTypeId();
        createCase.Subject = subject;
        createCase.Description = description;
        createCase.Opportunity__c = m_oppId;
        if(m_writeCase)
        {
            upsert createCase;
        }
        return createCase;
    }
    
    public void CreateCases ( )
    {
        List<Case> cases = new List<Case>();
        system.debug ('In CreateCases() ');
        for (CaseToDirect ctd : m_CasesToDirect)
        {
            Case createCase = new Case();
            
            createCase.RecordTypeId = ctd.RecordTypeId;
            createCase.Subject = ctd.CDirector.CaseSubject__c;
            createCase.Description = ctd.CDirector.CaseDescription__c;
            createCase.Opportunity__c = m_opp.Id;
            createCase.ContactId = ctd.TheContactId;
            system.debug('This is the Queue Id ' + ctd.TheQueueId + ' the Opportunity User ' + m_opp.OwnerId + ' and the Config User id ' + ctd.CDirector.CaseUser__c);
             //createCase.OwnerId = (ctd.CDirector.CaseUseQueue__c == true ? ctd.TheQueueId : (ctd.CDirector.CaseUseConfigUser__c == 'PASSEDUSER' ? m_opp.OwnerId : ctd.CDirector.CaseUser__c));
            createCase.OwnerId = (ctd.CDirector.CaseUseQueue__c == true ? ctd.TheQueueId : (ctd.CDirector.CaseUseConfigUser__c == 'PASSEDUSER' ? (String.IsEmpty(m_opp.Seller__c) ? m_opp.OwnerId : m_opp.Seller__c) : ctd.CDirector.CaseUser__c));

            system.debug ('this is the ownerid ' + (ctd.CDirector.CaseUseQueue__c == true ? ctd.TheQueueId : (ctd.CDirector.CaseUseConfigUser__c == 'PASSEDUSER' ? m_opp.OwnerId : ctd.CDirector.CaseUser__c)));
            createCase.Origin  = ctd.CDirector.CaseOrigin__c;
            createCase.Status = ctd.CDirector.CaseStatus__c;
            createCase.Priority = ctd.CDirector.CasePriority__c;
            
            cases.Add(createCase);
        }
        
        Upsert cases;        
    }
    
    //public List<Case> 
    
    private string GetTheRecordTypeId()
    {
        List<RecordType> recordTypes = [Select   Id,
                                                 Name,
                                                 DeveloperName
                                        FROM     RecordType
                                        //WHERE    Name = :CaseDirector.CaseRecordType__c];
                                        WHERE    DeveloperName = :CaseDirector.CaseRecordType__c];
        if (recordTypes.Size() > 0)
        {
            return recordTypes[0].Id;
        }
        else
        {
            return '';
        }
    }
    
    private Map<string, string> GetTheRecordTypes ()
    {
        system.debug ( 'This is the recordtypes ' + m_RecordTypes);
        Map<string, string> rtv = new Map<string, string>();
        List<RecordType> recordTypes = [SELECT    Id,
                                                  Name,
                                                  DeveloperName
                                        FROM      RecordType
                                        //WHERE     Name in :m_RecordTypes];
                                        WHERE     DeveloperName in :m_RecordTypes];
        
        system.debug ( 'The sieze of the RecordTypes ' + recordTypes);                                
        if (recordTypes.Size() > 0) 
        {
            for (RecordType recType : recordTypes)
            {
                try
                {
                    system.debug ( 'This is the RecordType Map ' + m_MapCodeToRecordTypeName);
                    string caseCode = m_MapCodeToRecordTypeName.get (recType.DeveloperName);
					System.debug ('The case code ' + caseCode);
					System.debug ('The rec Id ' + recType.Id);
                    rtv.put (caseCode, recType.Id);
                }
                catch (Exception ex)
                {
					System.debug ('There is an Exception here ');
                }
            }
        } 
        return rtv; 
    }
    /*
    private Map<string, string> GetTheUserIds(List<string> userNames)
    {
        system.debug('The user name list ' + userNames);
        List<User> users = [SELECT     Id,
                                        Name
                            FROM        User
                            WHERE      Name in : userNames];
        system.debug('The users ' + users);
        for (User herb :users)
        {
            m_userNameToUserId.put(herb.Name, herb.Id);
        }
        
        return m_userNameToUserId ;
    }
    */
    
    private Map<string, string> GetTheQueueIds (List<string> queueNames)
    {
        system.debug('Looking for queue names ' + queueNames);
        List<QueueSobject> queues = [SELECT QueueId,
                                            Id,
                                            Queue.Name
                                     FROM   QueueSobject
                                     WHERE  Queue.Name in :queueNames];
        
        for(QueueSobject queue:queues)
        {
            m_queueNameToqueueId.put(queue.Queue.Name, queue.QueueId);
        }
        
        return m_queueNameToqueueId;
                                
    }
    
    private Map<string, string> GetCustomerIDs ()
    {
        Map<string, string> rtv = new Map<string, string>();
        m_EBSIDToTheAccountId  = new Map<string, string>();    // C0530
        system.debug ('The externalCustomerids ' + ExternalCustomerIDs);
        List<Account> accounts = [SELECT    Id,
                                            EBS_ID__c,
                                            PersonContactId,
                                            Name
                                  FROM      Account
                                  WHERE     EBS_ID__c in :ExternalCustomerIDs];
                                  
        if (accounts.Size() > 0)
        {
            for (Account acc : accounts)
            {
                try
                {
                    rtv.put (acc.EBS_ID__c, acc.PersonContactId);
                    m_EBSIDToTheAccountId.put (acc.EBS_ID__c, acc.Id);
                }
                catch (Exception ex)
                {
                }
            }
         }
        return rtv;
    }
    
    private Map<string, string> GetUserIDs ()
    {
        Map<string, string> rtv = new Map<string, string>();
        List<User> users = [Select Id, 
                                  EBSUserId__c 
                          FROM User 
                          where EBSUserId__c in :ExternalUserIDs];
       
                                  
        if (users.Size() > 0)
        {
            for (User usr : users)
            {
                try
                {
                    rtv.put (usr.EBSUserId__c, usr.Id);
                }
                catch (Exception ex)
                {
                }
            }
         }
        return rtv;
    }
    
    public class ExternalCase
    {
        public string ExternalCaseReferenceID {get;set;}
        public string CaseDirectorCategory {get;set;}
        public string CaseDirectorCode {get;set;}
        public string CaseDirectorQueue {get;set;}
        public string CaseDirectorStatus {get;set;}
        public string CaseDirectorSubject {get;set;}
        public string CaseDirectorDescription {get;set;}
        public string CaseDirectorPriority {get;set;}
        public string EBSCustomerID {get;set;}
        public string EBSUserID {get;set;}
        public IBBCaseDirector__c CaseDirector {get;set;}
        public ExternalCase ()
        {}
        
    }
    
    public class ExternalCaseResponse
    {
        public string CaseMessageID {get;set;}
        public string CaseInsertResult {get;set;}
        public string CaseInsertResultMessage {get;set;}
        public ExternalCaseResponse ()
        {}
    }
    
    
    public class CaseToDirect
    {
        public IBBCaseDirector__c CDirector
        {
            get
            {
                if (CDirector == null)
                {
                   CDirector = new IBBCaseDirector__c();
                }
                return CDirector;
            }
            set;
        }
        public string Subject{get;set;}
        public string Description{get;set;}
        public string RecordTypeId{get;set;}
        public string TheContactId{get;set;}
        public string TheQueueId{get;set;}
        //public string TheUserId{get;set;}
        public CaseToDirect(IBBCaseDirector__c inDirector, 
                            string inSubject, 
                            string inDescription, 
                            string inRecordTypeId, 
                            string inQueueId, 
                            string inContactId)//--, 
                            //--string inUserId)
        {
            CDirector = inDirector;
            Subject = inSubject;
            Description = inDescription;
            system.debug('HERE is RECORD TYPE ' + inRecordTypeId);
            RecordTypeId = inRecordTypeId;
            TheQueueId = inQueueId;
             system.debug('HERE is RECORD TYPE 2 ' + RecordTypeId);
            TheContactId = inContactId;
            //TheUserId = inUserId;
        }
    }       
}