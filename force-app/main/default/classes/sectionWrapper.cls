public class sectionWrapper{
    @AuraEnabled
        public Observation_Form_Questions__c section{get;set;}
    @AuraEnabled
        public List<questionAndOptions> questionAndOptionList{get;set;}
     
        public sectionWrapper(){}
        public sectionWrapper(Observation_Form_Questions__c section1,List<Observation_Form_Questions__c> questions){
            section = section1;
            questionAndOptionList = new List<questionAndOptions>();
            for(Observation_Form_Questions__c ques:questions){
                questionAndOptionList.add(new questionAndOptions(ques,ques.Options__r,ques.Observation_Form_Responses__r));
            }
        }
        
    public class questionAndOptions{
        @AuraEnabled
        public Observation_Form_Questions__c Question{get;set;}
        @AuraEnabled
        public List<Observation_Form_Questions__c> optionsList{get;set;}
        @AuraEnabled
        public Observation_Form_Response__c response{get;set;}
        @AuraEnabled
        public boolean isDropdown{get;set;}
        @AuraEnabled
        public boolean isText{get;set;}
        @AuraEnabled
        public boolean hasObjective{get;set;}
        @AuraEnabled
        public boolean isCheckbox{get;set;}
        @AuraEnabled
        public boolean isCritical{get;set;}
         public questionAndOptions(){}
        public questionAndOptions(Observation_Form_Questions__c quest,List<Observation_Form_Questions__c> obList,List<Observation_Form_Response__c> reponseRecieved){
            response = new Observation_Form_Response__c();
            response.Observation_Form_Question__c = quest.id;
            response.Observation_Form_Question_Text__c = quest.Question__c;
            if(reponseRecieved.size() > 0){
                response = reponseRecieved[0];
                for(Observation_Form_Questions__c opt:obList){
                    system.debug('****opt:'+opt);
                    
                    if(reponseRecieved.size() > 0 && reponseRecieved[0].Response__c == opt.Option__c){
                        opt.Critical__c =  true;   
                    }
                }
            }
            optionsList = obList;
            Question =  quest;
            
               
            
            hasObjective = True;    
            
            if(quest.Critical__c || quest.Section1__r.Critical__c){
                isCritical = True;    
            }
            if(quest.Data_Type__c == 'Dropdown'){
                isDropdown =  true;
            }/*else if(quest.Data_Type__c == 'Checkbox'){
                isCheckbox = true;
            }else if(quest.Data_Type__c == 'Text'){
                isText= true;
            }*/
        }
        
    }
}