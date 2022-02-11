global class CAA_ExternalContinue_Controller
{
    public string Error {get;set;}
    public string Session {get;set;}
    public static ID ContinueId {get;set;}
    public Boolean LinkValid {get;set;}

    private static CAA_Data.ContinueQuestionsResponse response{get;set;}

    @RemoteAction
    global static CAA_Data.ContinueQuestionsResponse CheckQuestions(CAA_Data.ContinueQuestions data)
    {
        response = new CAA_Data.ContinueQuestionsResponse();
        
        //Get opportunity Id
        ContinueId = CAA_Helper.DecryptData(data.SessionId);
            
        List<Continue_Application__c> app = [select status__c, opportunity__c,Invalid_Attempt_Date__c 
                                                    from Continue_Application__c
                                                    where id=: ContinueId ];
                                                    
        if(!app[0].status__c.equalsIgnoreCase('Pending')) 
        {    
            response.Error = app[0].status__c;
            return response;
        }
                                                    
        //Get the opportunity details
        Opportunity opp = [select id,name, accountid
                            from Opportunity 
                            where id=:app[0].opportunity__c];
                            
        Account acc;
        
        if(opp.name.containsIgnoreCase('young'))
        {
            //get the details of applicant 2 (primary guardian) if the opportunity is a YPSA
            List<Applicant__c> applicants = [SELECT Prospect_Customer__c 
                                                FROM Applicant__c
                                                WHERE Applicant_Number__c = 2 and Opportunity__c=:opp.id
                                                LIMIT 1];
                                                
            if(applicants.size() == 0) return response; 
        
            acc = [SELECT account.firstname, account.lastname, account.date_of_birth__c, account.billingpostalcode, 
                            account.Mother_s_family_name_security_question__c
                            FROM Account
                            WHERE id=:applicants[0].Prospect_Customer__c];
        }
        else
        {
            //Get the details for the primary applicant
            acc = [SELECT account.firstname, account.lastname, account.date_of_birth__c, account.billingpostalcode, 
                            account.Mother_s_family_name_security_question__c
                            FROM Account
                            WHERE id=:opp.accountid];
        }
        
                            
        
        //Compare agaisnt passed in data
        if(!data.FirstName.trim().equalsIgnoreCase(acc.firstname.trim())
            || !data.LastName.trim().equalsIgnoreCase(acc.LastName.trim())
            || data.DOB.value != acc.date_of_birth__c
            || !data.PostCode.trim().replace(' ','').equalsIgnoreCase(acc.billingpostalcode.trim().replace(' ',''))
            || !data.MothersName.trim().equalsIgnoreCase(acc.Mother_s_family_name_security_question__c.trim())
        ){
            response.success = false;
            response.error = 'NoMatch';
            app[0].Invalid_Attempt_Date__c = DateTime.Now();
            update app;
            return response;
        }        
        
        app[0].Activated_Date__c = datetime.now();
        response.success = true;
        //register the users session, and disable the link   
        SetContinueUrl(app[0].opportunity__c);   
        
        update app;        
    
        return response;
    }
    
    private static void SetContinueUrl(ID opportunityId)
    {
        //Check application stage
        Opportunity opp = [select stagename from opportunity
                            where id =: opportunityId];
                            
        if(!opp.stagename.equalsIgnoreCase('Personal Details') && !opp.stagename.equalsIgnoreCase('Declaration'))
        {
            //can't give them a screen to continue
        } 
        
        //get the correct event screen
        
        //find next event
        List<EventLog__c> openEvents = [select id, Event__r.CustomPageLocation__c
                                         from eventlog__c where EventStatus__c='open' and Opportunity__c=:opp.id
                                         and (Event__r.name = 'CAA Declaration' or Event__r.Name = 'CAA Personal Details' or Event__r.Name = 'CAA Personal Details YPSA')
                                         order by createddate limit  1];
        system.debug('OppID:' + opp.id);                                 
                                         
                                         
        if(openEvents.size() == 1)
        {
            response.Url = openEvents[0].Event__r.CustomPageLocation__c;
            response.Url += '?extid=' + CAA_Helper.EncryptData(string.valueof(openEvents[0].id));

            //Update session to this opp
            External_Session__c session = [select opportunity__c 
                                            from External_Session__c where Continue_Application__c=:ContinueId limit 1];
            session.opportunity__c = opp.id;
            update session;
            
            system.debug('Updated Session:' + session);
        }   
        else
        {
            response.Error = 'Internal';
        }                 
    }    
    
    public PageReference Setup()
    {
        Session = ApexPages.currentPage().getParameters().get('id');
        
        try
        {
            //Decrypt continue id
            ContinueId = CAA_Helper.DecryptData(Session);
            
            List<Continue_Application__c> app = [select status__c 
                                                    from Continue_Application__c
                                                    where id=: ContinueId ];
                                                    
            if(app.size() == 0)
            {
                Error = 'Invalid';
                return null;                                                    
            } 
            
            
            if(app[0].status__c.equalsIgnorecase('Pending')){
                LinkValid = true;  
                
                 External_Session__c session = CAA_Helper.CreateSession(null,null);
                 ApexPages.currentPage().setCookies(new Cookie[]{CAA_Helper.CreateCookie(session)});  
                 
                 //update session with continue link
                 session.Continue_Application__c = app[0].id;
                 update session;                         
            }
            else
            {
                Error = app[0].status__c;
            }
        }
        catch(Exception ex)
        {
            Error = 'Invalid';
        }        
        return null;         
    }
}