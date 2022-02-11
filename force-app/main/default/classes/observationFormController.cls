public without sharing Class observationFormController{
    @AuraEnabled
    public static ObservationWrapper getFormData(id questionFormId){
        Observation_Form_Questions__c form = new Observation_Form_Questions__c();
        ObservationWrapper obw = new ObservationWrapper();
        List<Observation_Form_Questions__c> questionList = New List<Observation_Form_Questions__c>();
        Observation_Form__c formT = new Observation_Form__c();
        
        if(questionFormId != null && string.valueOf(questionFormId.getSObjectType()) != null && string.valueOf(questionFormId.getSObjectType()) == 'Observation_Form__c'){
            formT = [SELECT id,Overall_Rating__c,Overall_Score__c,Observation_Form_Questions__r.Fields_to_display__c FROM Observation_Form__c WHERE id=:questionFormId];
            
            if(formT.Observation_Form_Questions__r.Fields_to_display__c != null && !formT.Observation_Form_Questions__r.Fields_to_display__c.containsIgnoreCase('Form_Name__c')){
                formT.Observation_Form_Questions__r.Fields_to_display__c = 'Form_Name__c,'+formT.Observation_Form_Questions__r.Fields_to_display__c;
            }
            string defaultFields = 'CreatedById,Form_Submitted__c,Manager_Commentary_for_Appeal__c,Agent_Comment_for_Appeal__c,Appeal__c,Appeal_Approval_Status__c,Assessor_Comment_for_Appeal__c,Manager_Discretion__c,Manager_Discretion_Comments__c,';
            defaultFields = getCorrectedFields(defaultFields,formT.Observation_Form_Questions__r.Fields_to_display__c);
            obw.form = database.query('SELECT '+defaultFields+','+formT.Observation_Form_Questions__r.Fields_to_display__c+' FROM '+'Observation_Form__c WHERE id=:questionFormId'); 
            
            questionList  = getFormDataMethod(questionFormId);
            
        }else{
            questionList  = [SELECT id,Section1__r.Form__r.Form_Result__c,Section1__r.Form__r.Total_Score__c,Section1__r.Form__r.Fields_to_display__c,Fields_to_display__c,Mandatory_Fields__c,Send_Email__c,Form__r.Send_Email__c,Section1__r.Form__r.Send_Email__c,Form__r.Mandatory_Fields__c,Section1__r.Form__r.Mandatory_Fields__c,Form__c,Section1__r.Form__r.Form_Name__c,Section__c,Section1__c,Section1__r.Form__c,Section1__r.Type__c,Section1__r.Section__c,Section1__r.Section_Order__c,Critical__c,Data_Type__c,Question__c,Objective__c,Guide__c,Question_Number__c,Score__c,Type__c,Critical_Value__c,Critical_Option__c,Section1__r.Form__r.Calculation_Type__c,Section1__r.Critical_Value__c,Section1__r.Critical_Option__c,Section1__r.Critical__c,Section1__r.Section_Critical_Conditions__c,
            (SELECT id,Option__c,Score__c,Is_Critical_Value__c,ScoreText__c,Question_Lookup__c,Section1__c,Form__c FROM Options__r ORDER By CreatedDate ASC) FROM Observation_Form_Questions__c WHERE Section1__r.Form__c=:questionFormId AND Type__c ='Question' ORDER By Section1__r.Section_Order__c ASC,Question_Number__c ASC];
        
        } 
        
        
        
        map<id,List<Observation_Form_Questions__c>> sectionWithQuestion = new map<id,List<Observation_Form_Questions__c>>();
        map<id,Observation_Form_Questions__c> idToSection = new map<id,Observation_Form_Questions__c>();
        obw.managersList = getManagersList(obw.form);
        for(Observation_Form_Questions__c ques:questionList){
            system.debug('Question Number:'+ques.Question_Number__c);
            system.debug('Responses:'+ques.Observation_Form_Responses__r);
            Observation_Form_Questions__c formQ = new Observation_Form_Questions__c();
            formQ.id = ques.Section1__r.Form__c;
            formQ.Form_Name__c = ques.Section1__r.Form__r.Form_Name__c;
            obw.formQuestion =  formQ;
            
           
            obw.fieldsToDisplay = ques.Section1__r.Form__r.Fields_to_display__c;
            obw.mandatoryfieldsToDisplay = ques.Section1__r.Form__r.Mandatory_Fields__c;
            obw.doNotSendEmail = ques.Section1__r.Form__r.Send_Email__c;
            obw.resultJson = ques.Section1__r.Form__r.Form_Result__c;
            obw.totalScore = ques.Section1__r.Form__r.Total_Score__c;
            obw.scoringMechanism = ques.Section1__r.Form__r.Calculation_Type__c;
            if(obw.form.Form_Name__c == null){
                obw.form = new Observation_Form__c();
                obw.form.Form_Name__c = ques.Section1__r.Form__r.Form_Name__c;
                obw.form.Observation_Form_Questions__c= ques.Form__c;
            }else{
                obw.form.Overall_Rating__c = formT.Overall_Rating__c;
                obw.form.Overall_Score__c = formT.Overall_Score__c; 
            }
            
            if(!idToSection.containsKey(ques.Section1__c)){
                Observation_Form_Questions__c section = new Observation_Form_Questions__c();
                section.Section_Order__c = ques.Section1__r.Section_Order__c;
                section.Section__c = ques.Section1__r.Section__c;
                section.Form__c = ques.Section1__r.Form__c;
                section.Critical_Value__c = ques.Section1__r.Critical_Value__c;
                section.Critical_Option__c = ques.Section1__r.Critical_Option__c;
                section.Critical__c = ques.Section1__r.Critical__c;
                section.Section_Critical_Conditions__c = ques.Section1__r.Section_Critical_Conditions__c;
                idToSection.put(ques.Section1__c,section );
                
            }
            
           
            if(!sectionWithQuestion.isEmpty() && sectionWithQuestion.containsKey(ques.Section1__c) && sectionWithQuestion.get(ques.Section1__c) != null){
                sectionWithQuestion.get(ques.Section1__c).add(ques);
            }else{
                sectionWithQuestion.put(ques.Section1__c,new list<Observation_Form_Questions__c>{ques});
            }
        }  
        
        obw.sectionList = new List<sectionWrapper>();
        for(string secId:sectionWithQuestion.keySet()){
            obw.sectionList.add(new sectionWrapper(idToSection.get(secId),sectionWithQuestion.get(secId)));    
        
        }  
        
        
        
        return obw;                                                
    }
    
    public static string getCorrectedFields(string defaultVal,string selected){
        string returnString = 'id';
        list<string> stringList = selected.split(',');
        set<string> forComparison = new set<string>();
        forComparison.addAll(stringList);
        for(string str:defaultVal.split(',')){
            if(!forComparison.contains(str)){
                returnString+= ','+str;    
            }    
        }
        system.debug('Return String:'+returnString );
        return returnString;
    }
    
    public static List<Observation_Form_Questions__c> getFormDataMethod(id questionFormId){
        set<id> questionIdSet = new set<id>();
        for(Observation_Form_Response__c ofr:[SELECT id,Commentary__c,Observation_Form_Question__c,Observation_Form_Question_Text__c,Observation_From__c,Response__c FROM Observation_Form_Response__c WHERE Observation_From__c=:questionFormId]){
            questionIdSet.add(ofr.Observation_Form_Question__c);
        }
        List<Observation_Form_Questions__c> questionList =  [SELECT id,Section1__r.Form__r.Form_Result__c,Section1__r.Form__r.Total_Score__c,Section1__r.Form__r.Fields_to_display__c,Fields_to_display__c,Form__c,Section1__r.Form__r.Form_Name__c,Section__c,Section1__c,Section1__r.Form__c,Section1__r.Type__c,Section1__r.Section__c,Section1__r.Section_Order__c,Critical__c,Data_Type__c,Question__c,Objective__c,Guide__c,Question_Number__c,Score__c,Type__c,Critical_Value__c,Critical_Option__c,
        Section1__r.Form__r.Calculation_Type__c,Section1__r.Critical_Value__c,Section1__r.Critical_Option__c,Section1__r.Critical__c,Section1__r.Section_Critical_Conditions__c,Section1__r.Form__r.Mandatory_Fields__c,Section1__r.Form__r.Send_Email__c,
        (SELECT id,Option__c,Score__c,Is_Critical_Value__c,Critical__c,ScoreText__c,Question_Lookup__c,Section1__c,Form__c FROM Options__r ORDER By CreatedDate ASC),(SELECT id,Commentary__c,Observation_Form_Question__c,Observation_Form_Question_Text__c,Observation_From__c,Response__c,Score__c FROM Observation_Form_Responses__r WHERE Observation_From__c=:questionFormId) FROM Observation_Form_Questions__c WHERE Id IN:questionIdSet AND Type__c ='Question' ORDER By Section1__r.Section_Order__c ASC,Question_Number__c ASC];
        
        return questionList;
          
    }
    
     @AuraEnabled
     public static Observation_Form__c submitAppeal(Observation_Form__c  form){
         update form; 
         return form;            
     }
    
    public static string getManagersList(Observation_Form__c form){
        set<string> usersRequired = new set<string>();
        set<string> returnList = new set<string>();
        string returnString ='';
        for(Salesforce_Observation_Form_Access__mdt mdt:[SELECT id,Team__c,Username__c FROM Salesforce_Observation_Form_Access__mdt]){
            usersRequired.add(mdt.Username__c ); 
        }
        
        for(user use:[SELECT id,Name,ManagerId FROM user WHERE username IN:usersRequired]){
            returnList.add(use.id);
            if(use.ManagerId != null){
                returnList.add(use.ManagerId);
            }
        }
        for(string str:returnList){
            returnString += str+',';    
        }
        return returnString ;
    }
    
    @AuraEnabled
    public static ObservationWrapper saveFormData(ObservationWrapper obw){
        system.debug('Save form called:');
        upsert obw.form;
        List<Observation_Form_Response__c> listToUpsert = new List<Observation_Form_Response__c>();
        for(sectionWrapper sw:obw.sectionList){
            for(sectionWrapper.questionAndOptions op:sw.questionAndOptionList){
                if(op.response.Observation_From__c == null)
                    op.response.Observation_From__c = obw.form.id;
                listToUpsert.add(op.response) ; 
            }
              
        }
        
        
        upsert listToUpsert;
        return obw;
             
    }
    
    @AuraEnabled
    public static user getManagerID(string userID){
        return [SELECT id,Name,ManagerId FROM User WHERE id =:userID LIMIT 1];
    }
    
    @AuraEnabled
    public static void sendEmailToController(Observation_Form__c form,string templateType,string toAddressId){
        try{    
            emailAddressObject wrapObj = new emailAddressObject();
            wrapObj = getTargetObjectIdAndEmail(form,templateType,toAddressId);
            system.debug('Email Object:'+wrapObj );
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(wrapObj.targetObjectIdEmail ); 
            //message.setSenderDisplayName('FCU Team'); 
            message.setReplyTo('no-reply@alrayanbank.co.uk');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            //EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Customer Exited to KYC'];
            message.setTemplateID(wrapObj.templateId); 
            message.setWhatId(form.id); //This is important for the merge fields in template to work
            message.toAddresses = wrapObj.toAddress;
            if(!wrapObj.ccAddress.isEmpty())
                message.ccAddresses = wrapObj.ccAddress;
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
         
            if (results[0].success){
                System.debug('The email was sent successfully.');
            }else {
                System.debug('The email failed to send: '+  results[0].errors[0].message);
                throw new AuraHandledException(results[0].errors[0].message);
            }   
        }catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
       
    }
      
    
    public static emailAddressObject getTargetObjectIdAndEmail(Observation_Form__c form,string templateType,string toAddressId){
        system.debug('To Address:'+toAddressId);
        Observation_Form_Email_Templates_Config__mdt  mdt = new Observation_Form_Email_Templates_Config__mdt(); 
        
        // [SELECT Id,Additional_CC__c,Appeal_Agent_Submission__c, Appeal_Assessor_Approval__c, Appeal_Assessor_Reject__c,Appeal_Manager_Approval__c, Appeal_Manager_Rejected__c, Appeal_Manager_Submission__c, 
        //Form_Name__c, Form_Submission_Fail__c, Form_Submission_Pass__c,Form_Submission_PWD__c  FROM Observation_Form_Email_Templates_Config__mdt WHERE MasterLabel ='Default' OR MasterLabel=:form.Form_Name__c LIMIT 1];
        emailAddressObject returnWrap = new emailAddressObject();
        
        Map<String,Observation_Form_Email_Templates_Config__mdt> templateMap= Observation_Form_Email_Templates_Config__mdt.getAll();
        set<id> userId = new set<id>();
        if(!string.isBlank(toAddressId) ){
        system.debug('To Address:'+toAddressId);
            for(string str:toAddressId.split(',')){
                system.debug('To Address:'+str);
                if(!string.isBlank(str) && str.startsWithIgnoreCase('005')){
                system.debug('To Address:'+str);
                    userId.add(str);
                }
            }    
        }
        system.debug('To userId:'+userId);
        
        List<contact> contactList = [SELECT id,User_lookup__c,email FROM Contact WHERE User_lookup__c IN:userId];
        List<user> userList = [SELECT id,email FROM user WHERE id IN:userId];
        returnWrap.toAddress = new list<string>();
        for(user u:userList){
            returnWrap.toAddress.add(u.email);
        }
        
        if(contactList.size() >0 ){
            returnWrap.targetObjectIdEmail = [SELECT id,email FROM Contact WHERE  ID IN:contactList AND Email != null LIMIT 1].id; //contactList[0].id;
        }else{
            returnWrap.targetObjectIdEmail = [SELECT id,email FROM Contact WHERE email = 'quality.assurance@alrayanbank.co.uk' LIMIT 1].id;
        }
        
        mdt = templateMap.get('Default');
        
        for(Observation_Form_Email_Templates_Config__mdt  str:templateMap.values()){
            if(str.label == form.Form_Name__c){
                mdt = str;
            }
        }
        
        if(templateType == 'formSubmissionPass'){  
            returnWrap.templateName = mdt.Form_Submission_Pass__c;
        }
        else if(templateType == 'formSubmissionPwd'){    
            returnWrap.templateName = mdt.Form_Submission_PWD__c;
        }
        else if(templateType == 'formSubmissionFail'){    
            returnWrap.templateName = mdt.Form_Submission_Fail__c;
        }
        else if(templateType == 'formSubmissionFail'){   
            returnWrap.templateName = mdt.Form_Submission_Fail__c;
        }
        else if(templateType == 'AppealAgentSubmission') {   
            returnWrap.templateName = mdt.Appeal_Agent_Submission__c;
        }
        else if(templateType == 'AppealManagerSubmission') {   
            returnWrap.templateName = mdt.Appeal_Manager_Submission__c;
        }
        else if(templateType == 'AppealManagerApprove') {   
            returnWrap.templateName = mdt.Appeal_Manager_Approval__c;
        }
        else if(templateType == 'AppealManagerReject') {   
            returnWrap.templateName = mdt.Appeal_Manager_Rejected__c;
        }
        else if(templateType == 'AppealAssessorApprove') {   
            returnWrap.templateName = mdt.Appeal_Assessor_Approval__c;
        }
        else if(templateType == 'AppealAssessorReject') {   
            returnWrap.templateName = mdt.Appeal_Assessor_Reject__c;
        }else if(templateType == 'Observation_Form_Manager_Discretion'){
            returnWrap.templateName = mdt.Manager_Discretion_Email__c;
        }
        
        if(mdt.Additional_CC__c != null && !string.isBlank(mdt.Additional_CC__c)){
            returnWrap.ccAddress = mdt.Additional_CC__c.split(',');   
        }
        system.debug('Template Name:'+returnWrap.templateName);
        returnWrap.templateId = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName=:returnWrap.templateName].Id;
        
        return returnWrap;
    }
    
    public class emailAddressObject{
        public string targetObjectIdEmail;
        public list<string> toAddress;
        public list<string> ccAddress;
        public string templateName;
        public string templateId;
        
        public emailAddressObject(){
            toAddress = new list<string>();
            ccAddress = new list<string>();
        }
    }
    
    public class ObservationWrapper{
        @AuraEnabled
        public Observation_Form_Questions__c formQuestion{get;set;}
        @AuraEnabled
        public string resultJson{get;set;}
        @AuraEnabled
        public string fieldsToDisplay{get;set;}
        @AuraEnabled
        public string managersList{get;set;}
        @AuraEnabled
        public boolean doNotSendEmail{get;set;}
         
        @AuraEnabled
        public string mandatoryfieldsToDisplay{get;set;}
        @AuraEnabled
        public decimal totalScore{get;set;}
        @AuraEnabled
        public string scoringMechanism{get;set;}
        @AuraEnabled
        public Observation_Form__c form{get;set;}
        @AuraEnabled
        public List<sectionWrapper> sectionList{get;set;}
        
        public ObservationWrapper(){
        
        }
    }
  
}