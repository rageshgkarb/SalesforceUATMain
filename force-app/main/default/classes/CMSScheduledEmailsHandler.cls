public without sharing class CMSScheduledEmailsHandler {
    
    public map<string, Branch__c> branches;
    public list<Balance_Entry__c> balanceEntriesToday;
    public list<Balance_Entry__c> balanceEntriesYesterday;
    public list<Balance_Entry__c> balanceEntriesLastWeek;
    public list<Cash_Order__c> cashOrdersToday;
    public list<Cash_Order__c> cashOrdersYesterday;
    public list<Cash_Order__c> cashOrdersLastWeek;
    public list<Messaging.SingleEmailMessage> emailMsgs;
    public map<string, user> usersMap{
        get{
            if(usersMap == null){   
                //  19/05/2014 - Will Goulding (Comol) - Updated to include both active and inactive users
                //  usersMap = new map<string, user>([SELECT Id, Name, UserRoleId, ProfileId, Email FROM User WHERE IsActive = true]);
                usersMap = new map<string, user>([SELECT Id, Name, UserRoleId, ProfileId, Email FROM User]);
            }
            return usersMap;
        }
        set;
    }
    public static list<User> seniorBranchMangers {
        get{
            if(seniorBranchMangers == null){
                seniorBranchMangers = new list<User>();
                // 25/06/2014 - Grant Roessler (Comol)= - Updated to query users within new group CMS - Senior Branch Managers instead of Role
                // seniorBranchMangers = [SELECT Id, Name, Email FROM User WHERE UserRole.Name = 'Senior Branch Manager'];
                seniorBranchMangers = [ SELECT Id, Name, Email 
                                        FROM User 
                                        WHERE Id IN (SELECT UserOrGroupId 
                                                        FROM GroupMember 
                                                        WHERE Group.Name = 'CMS - Senior Branch Managers')];


            }
            return seniorBranchMangers;
        }
        set;
    }
    public static list<User> cmsDistributionList {
        get{
            if(cmsDistributionList == null){
                cmsDistributionList = new list<User>();
                cmsDistributionList = [SELECT Id, Name, Email 
                                FROM User 
                                WHERE Id IN (SELECT UserOrGroupId 
                                                FROM GroupMember 
                                                WHERE Group.Name = 'CMS Distribution List')];
            }
            return cmsDistributionList;
        }
        set;
    }
    public static list<string> royalMailEmails {
        get{
            if(royalMailEmails == null){
                royalMailEmails = new list<string>();
                
                map<string, CMS_Royal_Mail_Emails__c> royalMailEmailsSettingsMAP = CMS_Royal_Mail_Emails__c.getAll();
                
                for(CMS_Royal_Mail_Emails__c rm : royalMailEmailsSettingsMAP.values()){
                    royalMailEmails.add(rm.Email_Address__c);
                }
                
            }
            return royalMailEmails; 
        }
        set;
    }
    public String dayToday {get;set;}
    public String dayYesterday {get;set;}
    
    //CONSTRUCTOR
    public CMSScheduledEmailsHandler(){
    
        /* C0257 *
        branches = new map<string, Branch__c>([SELECT Id, Name, OwnerId, Owner.Email, Deputy_Branch_Manager__c, Deputy_Branch_Manager__r.Email, Branch_Open_Days__c
                                                FROM Branch__c]);
                                                */
        branches = new map<string, Branch__c>([SELECT Id, 
                                                    Name, 
                                                    OwnerId, 
                                                    Owner.Email, 
                                                    Deputy_Branch_Manager__c, 
                                                    Deputy_Branch_Manager__r.Email, 
                                                    Branch_Open_Days__c,
                                                    D_Number__c
                                                FROM Branch__c
                                                WHERE D_number__c <> '']);
        /* C0257 end */          
        emailMsgs = new list<Messaging.SingleEmailMessage>();

        dayToday = datetime.now().format('EEEE');   
        dayYesterday = datetime.now().addDays(-1).format('EEEE');   
        system.debug('*** -- dayToday : ' + dayToday);  
        system.debug('*** -- dayYesterday : ' + dayYesterday);  
    }
    
    
    // 1. Missed balance entries from pervious day
    public void missedDailyBalanceEntries(){
        balanceEntriesYesterday = [SELECT Id, Branch__c, Date__c
                                FROM Balance_Entry__c 
                                WHERE Date__c = YESTERDAY];
        
        list<Branch__c> missedBalanceEntryBranchs = new list<Branch__c>();
        set<string> receivedBalanceEntryBranchIDs = new set<string>();
        
        for(Balance_Entry__c balanceEntry : balanceEntriesYesterday){
            receivedBalanceEntryBranchIDs.add(balanceEntry.Branch__c);
        }
        
        for(Branch__c branch : branches.values()){
            system.debug('*** -- branch.Branch_Open_Days__c : ' + branch.Branch_Open_Days__c);
            if(!receivedBalanceEntryBranchIDs.contains(branch.Id) && branch.Branch_Open_Days__c.contains(dayYesterday)){
                missedBalanceEntryBranchs.add(branch);
            }
        }
        
        EmailTemplate emTemplate = getEmailTemplate('Missed Daily Balance Entry Reminder');
        
        buildEmailMassgesPerBranch(missedBalanceEntryBranchs, emTemplate);
        
    }
    
    
    // 2. Missed balance entries this week
    public void missedDailyBalanceEntriesThisWeek(){
        balanceEntriesLastWeek = [SELECT Id, Branch__c, Date__c
                                    FROM Balance_Entry__c 
                                    WHERE Date__c = LAST_WEEK];
        
        list<date> dates = new list<date>();
        
        //Job Runs every Monday     
        dates.add(date.today().addDays(-7)); //Last Monday
        dates.add(date.today().addDays(-6)); //Last Tuesday
        dates.add(date.today().addDays(-5)); //Last Wednesday
        dates.add(date.today().addDays(-4)); //Last Thursday
        dates.add(date.today().addDays(-3)); //Last Friday
        dates.add(date.today().addDays(-2)); //Last Saturday
        dates.add(date.today().addDays(-1)); //Last Sunday
        
        system.debug('*** -- dates : ' + dates);
        
        list<string> missedBalanceEntriesText = new list<string>();
        map<date, set<string>> receivedBalanceEntriesBranchMAP = new map<date, set<string>>();
        
        for(Balance_Entry__c balanceEntry : balanceEntriesLastWeek){
            
            set<string> branchIDWithBalancesForDate = new set<string>();
            
            if(receivedBalanceEntriesBranchMAP.containskey(balanceEntry.Date__c)){
                branchIDWithBalancesForDate = receivedBalanceEntriesBranchMAP.get(balanceEntry.Date__c);
            }
            
            branchIDWithBalancesForDate.add(balanceEntry.Branch__c);
            receivedBalanceEntriesBranchMAP.put(balanceEntry.Date__c, branchIDWithBalancesForDate);

        }
        
        system.debug('*** -- receivedBalanceEntriesBranchMAP : ' + receivedBalanceEntriesBranchMAP);
        
        for(Branch__c branch : branches.values()){
            
            set<string> branchIDWithBalancesForDate = new set<string>();
            
            for(Date entryDate : dates){
            
                branchIDWithBalancesForDate = receivedBalanceEntriesBranchMAP.get(entryDate);
                datetime entryDateTime = datetime.newInstance(entryDate.year(), entryDate.month(), entryDate.day(), 00, 00, 00);
                
                system.debug('*** -- branchIDWithBalancesForDate : ' + branchIDWithBalancesForDate + ' current date in loop ' + entryDate);

                string entryDateDayValue = datetime.newInstance(entryDate.year(), entryDate.month(), entryDate.day(), 00, 00, 00).format('EEEE');
                system.debug('*** -- branch.Branch_Open_Days__c : ' + branch.Branch_Open_Days__c);
                system.debug('*** -- entryDateDayValue : ' + entryDateDayValue);
            
                if(branchIDWithBalancesForDate != null && branchIDWithBalancesForDate.contains(branch.Id)){
                    
                }else if(branch.Branch_Open_Days__c.contains(entryDateDayValue)){
                    missedBalanceEntriesText.add(Branch.Name + ' ' + entryDateTime.format('E dd MMM yyyy'));
                }
            }
        }
        
        list<string> toAddresses = new list<string>();
        toAddresses.addAll(getToEmailAddresses(null,seniorBranchMangers));
        
        EmailTemplate emTemplate = getEmailTemplate('Weekly Missed Daily Balance Entry Reminder');
        
        buildSingleEmailMassge(missedBalanceEntriesText, toAddresses, emTemplate, null);
        
    }
    
    // 3. Missed Cash Orders previous week
    public void noCashOrderSubmitted(){
        cashOrdersLastWeek = [SELECT Id, Branch__c 
                                FROM Cash_Order__c 
                                WHERE RecordType.Name = 'Standard Cash Order'
                                AND Delivery_Date__c = THIS_WEEK];
        
        list<Branch__c> missedCashOrderBranchs = new list<Branch__c>();
        set<string> receivedCashOrderBranchIDs = new set<string>();
        
        for(Cash_Order__c cashOrder : cashOrdersLastWeek){
            receivedCashOrderBranchIDs.add(cashOrder.Branch__c);
        }
        
        for(Branch__c branch : branches.values()){
            if(!receivedCashOrderBranchIDs.contains(branch.Id)){
                missedCashOrderBranchs.add(branch); 
            }
        }
        
        EmailTemplate emTemplate = getEmailTemplate('Weekly Missed Standard Cash Order Reminder');
        
        buildEmailMassgesPerBranch(missedCashOrderBranchs, emTemplate);
        
    }
    
    // 4. Weekly standard approval email sent to approval distribution list  
    public void weeklyApprovalReminder(){
        cashOrdersLastWeek = [SELECT Id, Branch__c, Status__c 
                                FROM Cash_Order__c 
                                WHERE RecordType.Name = 'Standard Cash Order'
                                AND (Order_Date__c = LAST_WEEK 
                                    OR 
                                    Order_Date__c = TODAY)];
        
        
        Schema.DescribeSObjectResult cashOrderDescribeResult = Cash_Order__c.SObjectType.getDescribe();
        
        list<ProcessInstance> pendingApprovalsLastWeek = [SELECT TargetObjectId, Status, Id, CreatedDate
                                                                FROM ProcessInstance
                                                                WHERE Status = 'Pending'
                                                                AND (CreatedDate = LAST_WEEK
                                                                    OR
                                                                    CreatedDate = TODAY)];
                                                                    
        list<ProcessInstance> cashOrderApprovalsLastWeek = new list<ProcessInstance>();
        
        for(ProcessInstance approval : pendingApprovalsLastWeek){
            
            string approvalRecordID = approval.TargetObjectId;
            
            if(approvalRecordID.startsWith(cashOrderDescribeResult.getKeyPrefix())){
                cashOrderApprovalsLastWeek.add(approval);
            }
        }                                                           
        
        if(cashOrdersLastWeek.size() == branches.size() && cashOrdersLastWeek.size() == cashOrderApprovalsLastWeek.size()){
                
            EmailTemplate emTemplate = getEmailTemplate('Weekly Standard Approval Email Reminder');
            
            list<string> toAddresses = new list<string>();
            toAddresses.addAll(getToEmailAddresses(null,seniorBranchMangers));
            
            buildSingleEmailMassge(null, toAddresses,emTemplate, null);
        }
    }
    
    // 5. Decline status email alert sent to branch
    // SENT VIA APPROVAL PROCESS
    
    // 6. Central cash order request sent to Royal Mail and Internal IBB staff
    public void royalMailCashOrderOld(Royal_Mail_Cash_Order_Request__c rmOrder){


        Docugen_Template__c congaTemplate = [SELECT Id, Name
                                                        FROM Docugen_Template__c
                                                        WHERE Template_Name__c = 'Royal Mail Standard Cash Order' limit 1];
        
        Docugen_Query__c congaQuery = [SELECT Id, Name
                                                        FROM Docugen_Query__c
                                                        WHERE Query_Name__c = 'Royal Mail Standard Cash Orders' limit 1];

        
        string endpoint =   'https://www.appextremes.com/apps/Conga/PM.aspx' +
                            '?sessionId=' + EncodingUtil.urlEncode(rmOrder.API_Session_ID__c, 'UTF-8') +
                            '&serverUrl=' + EncodingUtil.urlEncode(rmOrder.API_Server_URL__c, 'UTF-8') +
                            '&APIMode=1' +
                            '&Id=' + rmOrder.Id +
                            '&TemplateId=' + congaTemplate.Id +
                            '&QueryId=' + congaQuery.Id + '?pv1=' + rmOrder.Id;
                            
        system.debug('*** -- endpoint : ' + endpoint);
        
        Http http = new Http();
        httpRequest httpReq  = new httpRequest();
        httpReq.setMethod('GET');
        httpReq.setTimeout(120000);
        httpReq.setEndpoint(endpoint);
        
        httpResponse httpRes = http.send(httpReq);
        
        system.debug('*** -- httpRes : ' + httpRes);
        system.debug('*** -- httpRes : ' + httpRes.getBody());
        
        if(httpRes.getStatusCode() == 200){
            
            Attachment congaDoc = new Attachment();
            try{
                congaDoc = [SELECT ParentId, OwnerId, Name, Id, ContentType, BodyLength, Body 
                                        FROM Attachment
                                        WHERE IsDeleted = false
                                        AND ParentId =: rmOrder.Id
                                        AND CreatedDate = TODAY
                                        ORDER BY CreatedDate DESC limit 1
                                        ];
            }catch(exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an issue in producing the Excel Attachment.'));
                return;
            }                       
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setBody(congaDoc.Body);
            emailAttachment.setContentType(congaDoc.ContentType);
            emailAttachment.setFileName(congaDoc.Name); 
            
            EmailTemplate emTemplate = getEmailTemplate('Royal Mail - Standard Cash Order Request');
            list<string> toAddresses = new list<string>();
            toAddresses.addAll(getToEmailAddresses(null,seniorBranchMangers));
            toAddresses.addAll(getToEmailAddresses(null,cmsDistributionList));
            toAddresses.addAll(royalMailEmails);
            
            buildSingleEmailMassge(null,toAddresses, emTemplate, emailAttachment);      
            
            rmOrder.Status__c = 'Sent';
            rmOrder.Order_Sent__c = datetime.now();
            update rmOrder;             
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an issue in producing the Excel Attachment.'));
            return;
        }
        
    }
    
    
    //new email document
    public void royalMailCashOrder(Royal_Mail_Cash_Order_Request__c rmOrder){
        List<CongaSettings__c> setting = [select id from congasettings__c where name ='Royal Mail Cash Order Standard' limit 1];
        if(setting.size() == 0){        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an issue in producing the Excel Attachment.'));
            return;
        }
        
        CongaSettings sett = new CongaSettings(setting[0].id);                         
        string body= sett.CallConga(rmOrder.id,true);   

        
        if(string.isNotBlank(body)){
            
            Attachment congaDoc = new Attachment();
            try{
                congaDoc = [SELECT ParentId, OwnerId, Name, Id, ContentType, BodyLength, Body 
                                        FROM Attachment
                                        WHERE IsDeleted = false
                                        AND ParentId =: rmOrder.Id
                                        AND CreatedDate = TODAY
                                        ORDER BY CreatedDate DESC limit 1
                                        ];
            }catch(exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an issue in producing the Excel Attachment.'));
                return;
            }                       
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setBody(congaDoc.Body);
            emailAttachment.setContentType(congaDoc.ContentType);
            emailAttachment.setFileName(congaDoc.Name); 
            
            EmailTemplate emTemplate = getEmailTemplate('Royal Mail - Standard Cash Order Request');
            list<string> toAddresses = new list<string>();
            toAddresses.addAll(getToEmailAddresses(null,seniorBranchMangers));
            toAddresses.addAll(getToEmailAddresses(null,cmsDistributionList));
            toAddresses.addAll(royalMailEmails);
            
            buildSingleEmailMassge(null,toAddresses, emTemplate, emailAttachment);      
            
            rmOrder.Status__c = 'Sent';
            rmOrder.Order_Sent__c = datetime.now();
            update rmOrder;             
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an issue in producing the Excel Attachment.'));
            return;
        }
        
    }
      
    
    
    
    // 7. Cancel delivery email sent to Royal Mail
    public void royalMailCancelDelivery(list<Cash_Order__c> cashOrders){

        EmailTemplate emTemplate = getEmailTemplate('Royal Mail - Cancel delivery email');
            
        list<string> toAddresses = new list<string>();
        toAddresses.addAll(getToEmailAddresses(null,seniorBranchMangers));
        toAddresses.addAll(royalMailEmails);
        
        for(Cash_Order__c cashOrder : cashOrders){
            buildSingleEmailMassge(new list<string>{cashOrder.Branch__r.Name}, toAddresses, emTemplate, null);
        }

    }
    
    // 8. Emergency approval email sent to approval distribution list
    // SENT VIA APPROVAL PROCESS
    
    // 9. Emergency decline status sent to branch
    // SENT VIA APPROVAL PROCESS
    
    // 10. Emergency cash order request send to Royal Mail
    @future(callout=true)
    public static void royalMailCashOrderFutureCall(string rmOrderId, string APISessionID, string APIServerURL, string branchID, date orderDate){
        
        Royal_Mail_Cash_Order_Request__c rmOrder = [SELECT Id, Name, Status__c, Order_Sent__c, API_Session_ID__c, API_Server_URL__c
                                                    FROM Royal_Mail_Cash_Order_Request__c
                                                    WHERE Id =: rmOrderId];
                                                    
        Branch__c branch = [SELECT Id, Name FROM Branch__c WHERE Id =: branchID];
        
        List<CongaSettings__c> setting = [select id from congasettings__c where name ='Royal Mail Cash Order Emergency' limit 1];
        if(setting.size() == 0){        
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'There has been an issue in producing the Excel Attachment.'));
            return;
        }
        
        CongaSettings sett = new CongaSettings(setting[0].id);                         
        string body= sett.CallConga(rmOrder.id,true);   

        
        if(string.isNotBlank(body)){
            Attachment congaDoc = new Attachment();
            try{
                congaDoc = [SELECT ParentId, OwnerId, Name, Id, ContentType, BodyLength, Body 
                                        FROM Attachment
                                        WHERE IsDeleted = false
                                        AND ParentId =: rmOrder.Id
                                        ORDER BY CreatedDate DESC limit 1
                                        ];
            }catch(exception e){
                rmOrder.Status__c = 'Error Send Failed';
                update rmOrder;
                return;
            }                       
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setBody(congaDoc.Body);
            emailAttachment.setContentType(congaDoc.ContentType);
            emailAttachment.setFileName(congaDoc.Name); 
            
            EmailTemplate emTemplate = getEmailTemplate('Royal Mail - Emergency Cash Order Request');
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            string emailSubject = CMSScheduledEmailsHandler.replaceMergeFieldData(branch, null, emTemplate.Subject, orderDate);
            email.setSubject(emailSubject);
            
            string emailBody = CMSScheduledEmailsHandler.replaceMergeFieldData(branch, null, emTemplate.Body, orderDate);
            email.setPlainTextBody(emailBody);
            
            list<string> toAddresses = new list<string>();
            toAddresses.addAll(getToEmailAddresses(null,seniorBranchMangers));
            toAddresses.addAll(getToEmailAddresses(null,cmsDistributionList));
            toAddresses.addAll(royalMailEmails);
            
            email.setToAddresses(toAddresses);
            
            email.setFileAttachments(new list<Messaging.EmailFileAttachment>{emailAttachment});
            
            //Sends the email
            Messaging.sendEmail(new list<Messaging.SingleEmailMessage>{email}); 
            
            rmOrder.Status__c = 'Sent';
            rmOrder.Order_Sent__c = datetime.now();
            update rmOrder; 
                
        }
        
    }   
    
    //Builds the emails for each branch
    public void buildEmailMassgesPerBranch(list<Branch__c> branchesToEmail, EmailTemplate emailTemplate){
        
        for(Branch__c branch : branchesToEmail){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            string emailSubject = replaceMergeFieldData(branch, null, emailTemplate.Subject, null);
            email.setSubject(emailSubject);
            
            string emailBody = replaceMergeFieldData(branch, null, emailTemplate.Body, null);
            email.setPlainTextBody(emailBody);
            
            list<string> toAddresses = new list<string>();
            
            if (usersMap.containsKey(branch.OwnerId)) {
                toAddresses.add(usersMap.get(branch.OwnerId).Email);
            }
            
            if(string.IsNotBlank(Branch.Deputy_Branch_Manager__c) && usersMap.containsKey(branch.Deputy_Branch_Manager__c)){
                toAddresses.add(usersMap.get(branch.Deputy_Branch_Manager__c).Email);
            }
            email.setToAddresses(toAddresses);
            
            emailMsgs.add(email);   
        }
    }
    
    //Builds a single emails embedding string list
    public void buildSingleEmailMassge(list<string> branchesStringContent, list<string> toAddresses, EmailTemplate emailTemplate, Messaging.EmailFileAttachment emailAttachment ){
        
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            string emailSubject = replaceMergeFieldData(null, branchesStringContent, emailTemplate.Subject, null);
            email.setSubject(emailSubject);
            
            string emailBody = replaceMergeFieldData(null, branchesStringContent, emailTemplate.Body, null);
            email.setPlainTextBody(emailBody);
            
            email.setToAddresses(toAddresses);
            
            if(emailAttachment != null){
                email.setFileAttachments(new list<Messaging.EmailFileAttachment>{emailAttachment});
            }
            
            emailMsgs.add(email);   
    }
    
    
    public static string replaceMergeFieldData(Branch__c branchRecord, list<string> branchesStringContent, string strContent, date orderDate){
        
        if(string.isNotBlank(strContent)){
            strContent = strContent.replace('{TODAY}', datetime.now().format('dd/MM/YYYY'));
            strContent = strContent.replace('{YESTERDAY}', datetime.now().addDays(-1).format('dd/MM/YYYY'));
            
            if(branchRecord != null){
                strContent = strContent.replace('{BRANCH}', branchRecord.Name);
            }
            
            if(orderDate != null){
                datetime orderDateTime = datetime.newInstance(orderDate.year(), orderDate.month(), orderDate.day(), 00, 00, 00);
                strContent = strContent.replace('{ORDERDATE}', orderDateTime.format('dd/MM/YYYY'));
            }
            
            if(branchesStringContent != null && branchesStringContent.size() > 0){
                for(string str : branchesStringContent){
                    strContent = strContent.replace('{MISSEDBALANCEDATE}', str + '\n' + '{MISSEDBALANCEDATE}');
                    strContent = strContent.replace('{BRANCH}', str );
                }
                
                strContent = strContent.replace('{MISSEDBALANCEDATE}', '');             
            }

        }
        
        return strContent;
    }
    
    public static EmailTemplate getEmailTemplate(string templateName){
        
        EmailTemplate emTemplate = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE Name = : templateName limit 1];
        
        return emTemplate;
        
    }
    
    public static list<string> getToEmailAddresses(list<string> userIDs, list<User> users){
        
        list<string> emailAddresses = new list<string>();
        list<User> userList = new list<User>();
        
        if(users != null){
            userList = users;
        }else if(userIDs != null){
            userList = [SELECT Id, Name, Email FROM User WHERE Id IN: userIDs];
        }
        
        for(User user : userList){
            emailAddresses.add(user.Email);
        }
        
        return emailAddresses;
    }
    
    //Sends Templated Emails
    public void sendEmail(){
        Messaging.sendEmail(emailMsgs);
    }
}