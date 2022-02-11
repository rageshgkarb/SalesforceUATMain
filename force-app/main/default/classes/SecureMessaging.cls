global class SecureMessaging
{
    public static ID AddComment(AddCommentData data)
    {
        //check that the case belongs to this customer
        List<Case> c = [SELECT id from Case WHERE id=:data.CaseId and Account.EBS_Id__c=:data.EBSId limit 1];
        if(c.size() == 0) return null;
    
        //Add comment
        CaseComment comment = new CaseComment();
        comment.parentId = data.CaseId;
        comment.CommentBody = data.Description;
        comment.IsPublished = true;        
        insert comment;
        return comment.id;
    }
    
    public static List<MessageCategory> GetMessageTypes()
    {
        List<MessageCategory> messages = new List<MessageCategory>();
		// C0RJL Changed sort order to new field
        List<Secure_Message_Type__c> lstMessages = [SELECT Category__c, SubCategory__c, Show_Account_Box__c, Description__c 
                                                    FROM Secure_Message_Type__c
                                                    ORDER by CategorySortOrder__c, SubCategory__c];
                                                    
        MessageCategory category;
        
        for(Secure_Message_Type__c smt : lstMessages)
        {
            if(category == null || category.Name != smt.Category__c) 
            {
                if(category != null) messages.add(category);            
                category = new MessageCategory(smt.Category__c);                
            }
            
            //add item
            category.Items.add(new MessageSubCategory(smt.SubCategory__c,smt.Show_Account_Box__c,smt.Description__c));
        }
        messages.add(category);   
        
        return messages;                                               
    }    
    
    public static ID AddInternalComment(String message, ID caseId, Boolean makePublic)
    {
        List<Case> c = [SELECT id from Case WHERE id=: caseId limit 1];
        if(c.size() == 0) return null;
        
        CaseComment comment = new CaseComment();
        comment.parentId = caseId;
        comment.CommentBody = message;
        comment.IsPublished = makePublic;        
        insert comment;
        
        if(makePublic) SendCommentEmail(caseId);
        
        return comment.id;
    }
    
    public static void SendCommentEmail(ID caseId)
    {
        Case c = [SELECT ContactId, Contact.Email 
                    FROM Case
                    WHERE id= : caseId];
                    
        system.debug('Email:' + c.contact.email);            
        system.debug(c.contact);
    
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName='Al Rayan Bank' limit 1];
        EmailTemplate template = [Select id,HtmlValue from EmailTemplate where developername= 'SecureMessage'];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
 
        //mail.setSaveAsActivity(false);
        mail.setOrgWideEmailAddressId(owa.id);

        system.debug(template.HtmlValue);

        mail.setHtmlBody(template.HtmlValue); 
        mail.subject = 'New secure message';
        
        String[] toAddresses = new String[] {c.contact.email};
        mail.setToAddresses(toAddresses);        
        
        allmsg.add(mail);
        Messaging.sendEmail(allmsg,false);
    }
    
    public static boolean DeleteCase(ID caseId, String ebsId)
    {
        //check that the case belongs to this customer
        List<Case> c = [SELECT id from Case WHERE id=:CaseId and Account.EBS_Id__c=:EBSId limit 1];
        if(c.size() == 0) return null;
    
        //Add comment
        c[0].Deleted_by_customer__c = true;
        update c;
        
        return true;
    }
    
    public static boolean ChangeCaseComment(ID commentId, Boolean isPublic)
    {
        //check that the case belongs to this customer
        List<CaseComment> c = [SELECT id from CaseComment WHERE id=:commentId limit 1];
        if(c.size() == 0) return null;
    
        //Add comment
        c[0].IsPublished = isPublic;
        update c;
        
        return true;
    }
    

    public static ID AddCase (AddCaseData data)
    {
        Case c = new Case();
        c.Subject = data.Category;
        if(string.isNotBlank(data.SubCategory))
            c.Subject += ' - ' + data.SubCategory;
        
        if(string.isNotBlank(data.AccountNo))
            c.subject += '- ' + data.AccountNo;    
        
        c.Category_revised__c = data.Category;
        c.Sub_category_revised__c = data.SubCategory;
        
        c.Description = data.Description;
        c.last_viewed_by_customer__c = datetime.now();
        
        c.Origin = 'IFM Secure Message';
        c.Location_of_submitter__c = 'Online';
        
        system.debug(data);
        
        //Lookup account
        List<Account> acc = [SELECT id FROM Account where ebs_id__c=:data.EBSId];
        if(acc.size() > 0)
        { 
            c.AccountId = acc[0].id;
            
            List<Contact> con = [SELECT id from Contact where AccountID=:acc[0].id];
            
            if(con.size() == 1)
            {            
                c.contactid = con[0].id;
            }
        }
        
        RecordType rt = [SELECT id 
                            FROM RecordType
                            WHERE developername = 'Secure_Message'
                            LIMIT 1];
                            
        c.recordtypeid = rt.id;
        
        List<Secure_Message_Type__c> mType = [SELECT Queue_Name__c from Secure_Message_Type__c where category__c=:data.Category and subcategory__c =:data.SubCategory];
        if(mType.Size() == 1)
        {
            List<Group > q = [Select Id, Name, DeveloperName, Type from Group where Type = 'Queue' and name=:mType[0].Queue_Name__c ];
            if(q.size() == 1) c.OwnerId = q[0].id;
        }
        
        
        
        insert c;
        
        //Add comment
        CaseComment comment = new CaseComment();
        comment.parentId = c.id;
        comment.CommentBody = data.Description;
        comment.IsPublished = true;
        
        insert comment;
        
        
        return c.id;        
    }

    public static String CustomerName {get;set;}

    public static List<SecureMessage> GetMessages(String ebsID)
    {
        List<Case> cases = [SELECT subject, description, CaseNumber, CreatedDate, status, IsClosed, Last_Viewed_By_Customer__c   
                            FROM Case
                            WHERE recordtype.developername = 'Secure_Message' 
                                AND account.ebs_id__c=:ebsId 
                                AND Deleted_by_customer__c = false                                
                            ORDER BY createddate desc];
                            
        List<SecureMessage> messages = new List<SecureMessage>();
        
        Account acc = [SELECT name 
                        FROM Account
                        WHERE ebs_id__c=:ebsID]; 
        
        CustomerName = acc.name;        
        
        for(Case c : cases)
        {
            messages.add(new SecureMessage(c,false));
        }
                            
        return messages ;                    
    }    
    
    
    public static SecureMessage GetMessagesByCase(ID caseID)
    {
        List<Case> cases = [SELECT subject, description, CaseNumber, CreatedDate, status, IsClosed, Last_Viewed_By_Customer__c   
                            FROM Case
                            WHERE recordtype.developername = 'Secure_Message' 
                                AND id =: caseId];
                                
        if(cases.size() == 0) return null;
                                    
        return new SecureMessage(cases[0], true);                   
    }

    global class SecureMessage
    {   
        public ID Id {get;set;}             
        public String Subject {get;set;}
        public String Description {get;set;}
        public String CreatedDate {get;set;}
        public String CaseNumber {get;set;}
        public String Status {get;set;}
        public Integer NewMessages {get;set;}        
        
        public List<SecureMessageComment > Comments {get;set;}      
        
          
        public SecureMessage(Case c, Boolean getAllComments)
        {
            Id = c.Id;
            Subject = c.subject;
            Description = c.description; 
            CaseNumber = c.CaseNumber; 
            
            if(CAA_Helper.IsGuestUser())
            {            
                CreatedDate = c.CreatedDate.day() + ' ' + GetMonthName(c.CreatedDate.month()) + ' ' + c.CreatedDate.year() + ' ' + c.CreatedDate.Hour() + ':' + c.CreatedDate.Minute();                
            }
            else
            {
                CreatedDate = c.CreatedDate.day() + '/' + c.CreatedDate.month() + '/' + c.CreatedDate.year() + ' ' + c.CreatedDate.Hour() + ':' + c.CreatedDate.Minute();
            }            
            
            Status = c.IsClosed ? 'Closed' : 'Open' ;
            NewMessages = 0;
            
            List<CaseComment> lst;
            
            if(getAllComments)
            {
                lst = [SELECT id, CommentBody, createdby.name, createddate, IsPublished 
                                    FROM CaseComment
                                    WHERE ParentId =: c.id ORDER BY createddate DESC]; 
            }  
            else
            {
                lst = [SELECT id, CommentBody, createdby.name, createddate, IsPublished 
                                    FROM CaseComment
                                    WHERE IsPublished = true AND  ParentId =: c.id order by createddate desc];
            }                                  
                                    
            //Calculate the number of new messages
                                    
                                    
                                    
            Comments  = new List<SecureMessageComment >();
            
            for(CaseComment f : lst)
            {
               Comments.add(new SecureMessageComment (f));
               
               //check for new comment
               if(f.createddate > c.Last_Viewed_By_Customer__c && !f.createdby.name.equalsIgnoreCase('External CAA Site Guest User')) NewMessages += 1;
               
            }                      
        }
        
        public String GetMonthName(integer month)
        {
            if(month == 1) return 'January';
            if(month == 2) return 'February';
            if(month == 3) return 'March';
            if(month == 4) return 'April';
            if(month == 5) return 'May';
            if(month == 6) return 'June';
            if(month == 7) return 'July';
            if(month == 8) return 'August';
            if(month == 9) return 'September';
            if(month == 10) return 'October';
            if(month == 11) return 'November';
            if(month == 12) return 'December';
            return string.valueof(month);
        }
    }
    
    global class AddCommentData
    {
        public ID CaseId {get;set;}
        public String Description {get;set;}
        public String EBSId {get;set;}
    }
    
    global class AddCaseData
    {
        public String Account {get;set;}
        public String AccountNo {get;set;}
        public String Description {get;set;}
        public String Subject {get;set;}
        public String EBSId {get;set;}
        public String Category {get;set;}
        public String SubCategory {get;set;}
    }
    
    global class MessageCategory
    {
        public String Name {get;set;}        
        public List<MessageSubCategory> Items {get;set;}
        
        public MessageCategory(String name)
        {
            this.Name = name;            
            this.Items = new List<MessageSubCategory>();
        }
    }
    
    global class MessageSubCategory 
    {
        public String Name {get;set;}
        public String Description {get;set;}
        public Boolean ShowAccount {get;set;}
        
        public MessageSubCategory (String name, Boolean showAccount, String description)
        {
            this.Name = name;
            this.ShowAccount = showAccount;
            this.Description = description;
        }
    }
    
    public class SecureMessageComment 
    {
        public String Body{get;set;}
        public String UserName {get;set;}
        public String CreatedDate {get;set;}
        public String CreatedTime {get;set;}
        public Boolean IsPublic {get;set;}
        public ID Id {get;set;}
        
        public SecureMessageComment(CaseComment c)
        {
            system.debug(c);
        
            Body = c.CommentBody;
            UserName = c.createdby.name; 
            IsPublic = c.IsPublished;
            if(CAA_Helper.IsGuestUser())
            {            
                CreatedDate = c.CreatedDate.day() + ' ' + GetMonthName(c.CreatedDate.month()) + ' ' + c.CreatedDate.year() + ' ' + c.CreatedDate.Hour() + ':' + c.CreatedDate.Minute();                
            }
            else
            {
                CreatedDate = c.CreatedDate.day() + '/' + c.CreatedDate.month() + '/' + c.CreatedDate.year() + ' ' + c.CreatedDate.Hour() + ':' + c.CreatedDate.Minute();
            } 
            //CreatedDate = c.CreatedDate.day() + '/' + c.CreatedDate.month() + '/' + c.CreatedDate.year() + ' ' + c.CreatedDate.Hour() + ':' + c.CreatedDate.Minute();          
            
            if(!CAA_Helper.IsGuestUser())
            {
                Id = c.id;
                if(UserName.equalsIgnoreCase('External CAA Site Guest User')) UserName = 'Customer';
            }
            else
            {
                //Guest user
                UserName = UserName.equalsIgnoreCase('External CAA Site Guest User') ? 'You' : 'Al Rayan Bank';
            }
            
            /*
            if(UserName.equalsIgnoreCase('External CAA Site Guest User') && CAA_Helper.IsGuestUser()) UserName = 'You';
            
            system.debug(UserName + ':' + CAA_Helper.IsGuestUser());
            
            if(!UserName.equalsIgnoreCase('External CAA Site Guest User') && CAA_Helper.IsGuestUser()) UserName = 'Al Rayan Bank';
            
            if(UserName.equalsIgnoreCase('External CAA Site Guest User') && !CAA_Helper.IsGuestUser()) UserName = 'Customer';
            */
            
            
           
        }
        
        public String GetMonthName(integer month)
        {
            if(month == 1) return 'January';
            if(month == 2) return 'February';
            if(month == 3) return 'March';
            if(month == 4) return 'April';
            if(month == 5) return 'May';
            if(month == 6) return 'June';
            if(month == 7) return 'July';
            if(month == 8) return 'August';
            if(month == 9) return 'September';
            if(month == 10) return 'October';
            if(month == 11) return 'November';
            if(month == 12) return 'December';
            return string.valueof(month);
        }
    }
}