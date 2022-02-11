public without sharing class FormDemo {
    
    @AuraEnabled
    public static Observation_Form_Questions__c createForms(String sectionName, String questionName, String questionNumber,String questionType){
        Observation_Form_Questions__c form = new Observation_Form_Questions__c();
        //form.Section__c = 'section';
        return form;                                                     
    }

    @AuraEnabled
    public static ObservationWrapper initialise(){
        List<ObservationWrapper> lstForms = new List<ObservationWrapper>();        
        Observation_Form_Questions__c form = new Observation_Form_Questions__c();        
        form.Question__c = '';
        form.Data_Type__c = 'Dropdown';
        form.Type__c = 'Question';
        ObservationWrapper ow = new ObservationWrapper();
        ow.form = form;
        ow.showPickListField = true;
        ow.showCriticalField = false;
        ow.optionScoreList = new list<optionsScoreClass>();
        optionsScoreClass opsObj = new optionsScoreClass();
        opsObj.option = '';
        opsObj.score = 0;
        opsObj.isCriticalValue = false;
        ow.optionScoreList.add(opsObj);
        //lstForms.add(ow);
        //return lstForms;
        return ow;
    }
    
    @AuraEnabled
    public static list<ObservationWrapper> getQuestionDetails(string sectionId){
        if(!string.isBlank(sectionId)){
            List<ObservationWrapper> lstForms = new List<ObservationWrapper>();  
            
            for(Observation_Form_Questions__c quest: [SELECT id,Critical_Value__c,Section1__r.Form__r.Form_Result__c,Section1__r.Form__r.Total_Score__c,Section1__r.Form__r.Fields_to_display__c,Section1__r.Form__r.Mandatory_Fields__c,Section1__r.Form__r.Send_Email__c,Section1__r.Form__r.Active__c,
            Mandatory_Fields__c,Fields_to_display__c,Form__c,Section1__r.Form__r.Form_Name__c,Section__c,Section1__c,Section1__r.Form__c,Section1__r.Type__c,Section1__r.Form__r.Calculation_Type__c,
            Section1__r.Section__c,Section1__r.Section_Order__c,Critical__c,Data_Type__c,Question__c,Objective__c,Guide__c,Question_Number__c,Score__c,Type__c,Critical_Option__c,Is_Critical_Value__c,  
            (SELECT id,Option__c,Score__c,ScoreText__c,Question_Lookup__c,Section1__c,Form__c,Is_Critical_Value__c FROM Options__r ORDER By CreatedDate ASC) 
            FROM Observation_Form_Questions__c WHERE Section1__c=:sectionId AND Type__c ='Question' ORDER BY Section1__r.Section_Order__c ASC,Question_Number__c ASC]){
                
                Observation_Form_Questions__c form =quest;// new Observation_Form_Questions__c();        
                /*form.Question__c = quest.Question__c;
                form.Data_Type__c = quest.Data_Type__c;
                form.Critical_Value__c = quest.Critical_Value__c;
                form.Critical__c = quest.Critical__c;
                form.Question_Number__c = quest.Question_Number__c;*/
                ObservationWrapper ow = new ObservationWrapper();
                ow.form = form;
                
                if(quest.Critical__c){
                    ow.showCriticalField = True;    
                }
                if(quest.Data_Type__c == 'Dropdown'){
                    ow.showPickListField =  true;
                }
                ow.optionScoreList = new list<optionsScoreClass>();
                
                for(Observation_Form_Questions__c ops:quest.Options__r){
                    optionsScoreClass opsObj = new optionsScoreClass();
                    opsObj.option = ops.Option__c;
                    opsObj.score = ops.Score__c;
                    opsObj.isCriticalValue = ops.Is_Critical_Value__c;
                    opsObj.optionId = ops.id;
                    ow.optionScoreList.add(opsObj);
                }
                
                lstForms.add(ow);
                
            }
                  
            return lstForms;
           
        }
        return null;
    }

    @AuraEnabled
    public static List<String> dataTypes(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult =
        Observation_Form_Questions__c.Data_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
        for( Schema.PicklistEntry f : ple){
            options.add(f.getValue());
        }       
        return options;
    }

    @AuraEnabled
    public static returnSectionClass saveObservationForm(List<ObservationWrapper> lstForms,Observation_Form_Questions__c section,List<string> deleteList){
        system.debug('deleteList :'+deleteList);
        if(deleteList != null){
            DELETE [SELECT id FROM Observation_Form_Questions__c WHERE id IN:deleteList];
        }
        map<string,List<optionsScoreClass>> quesToOptions = new map<string,List<optionsScoreClass>>();
        list<Observation_Form_Questions__c> listToUpsert = new List<Observation_Form_Questions__c>();
        map<string,Observation_Form_Questions__c > questionOrder = new  map<string,Observation_Form_Questions__c >();
        map<string,Observation_Form_Questions__c > optionMap= new  map<string,Observation_Form_Questions__c >();
        string sectionId;
        string sectionName;
        
            upsert section;
            
        
        sectionId = section.id;
        sectionName = section.Section__c;
        string formId = section.Form__c;
        string formName = section.Form_Name__c;
        /*List<Observation_Form_Questions__c> deleteList = [SELECT id FROM Observation_Form_Questions__c WHERE Section1__c=:sectionId];
        if(deleteList.size() > 0)
            DELETE deleteList;*/
        
        for(ObservationWrapper obw:lstForms){
            system.debug('****'+obw.form);
            
                //listToUpsert.add(obw.form);
            
                obw.form.Section1__c = sectionId;
                obw.form.Section__c = sectionName;
                obw.form.Type__c = 'Question';
                obw.form.Form__c = formId;
                obw.form.Form_Name__c = formName;
                
            
            string key = obw.form.Question__c +  obw.form.Question_Number__c;
            listToUpsert.add(obw.form);   
            quesToOptions.put(obw.form.Question__c,obw.optionScoreList);
            questionOrder.put(key,obw.form); 
            
        }
        upsert questionOrder.values();
        system.debug('questionOrder Map'+questionOrder);
        
        list<Observation_Form_Questions__c> OptionsToUpsert = new List<Observation_Form_Questions__c>();
        
        for(Observation_Form_Questions__c ques:questionOrder.values()){
            system.debug('Question:'+ques.Question__c );
            for(optionsScoreClass ops:quesToOptions.get(ques.Question__c)){
            
                Observation_Form_Questions__c obw = new Observation_Form_Questions__c();
                
                system.debug('ops.optionId:'+ops.optionId+'obw.Option__c:'+obw.Option__c+'---ops.score:'+ops.score);
                obw.id = ops.optionId ;
                obw.Section1__c = sectionId;
                obw.Section__c = sectionName;
                obw.Type__c = 'Option';
                obw.Form__c = formId;
                obw.Form_Name__c = formName;
                obw.Question_Lookup__c = ques.id;
                obw.Question__c = ques.Question__c;
                obw.Option__c = ops.option;
                obw.Score__c = ops.score; 
                obw.Is_Critical_Value__c = ops.isCriticalValue;
                if(obw.id != null){
                    optionMap.put(obw.id,obw);
                }else{
                    string key = ques.id+ops.option+ops.score;
                    optionMap.put(key,obw);
                }
                //optionMap.put(key,obw);
                //OptionsToUpsert.add(obw);       
            }
        }
        OptionsToUpsert.AddAll(optionMap.values());
        if(OptionsToUpsert.size() > 0)
            upsert OptionsToUpsert;
            
        system.debug('Option Map'+optionMap);
        
        /*for(ObservationWrapper obw:lstForms){
        
            string key = obw.form.Question__c +  obw.form.Question_Number__c;   
            if(questionOrder.containsKey(key) && questionOrder.get(key) != null && obw.form.id == null)
                obw.form.id =  questionOrder.get(key).id;  
                
            for(optionsScoreClass ops:obw.optionScoreList){
                string key2 = obw.form.id+ops.option+ops.score;
                if(optionMap.containsKey(key2) && optionMap.get(key2) != null && (ops.optionId == null || string.isBlank(ops.optionId))){
                    ops.optionId = optionMap.get(key).id;
                }        
            }  
        }*/
        returnSectionClass returnValues = new returnSectionClass();
        returnValues.section = section;
        returnValues.forms = lstForms;
        return returnValues;
    }
    
    @AuraEnabled static 
        public Observation_Form_Questions__c saveForm(Observation_Form_Questions__c formObj){
        system.debug('Form to Save:'+formObj);
        upsert formObj;
        return formObj;    
    }
    
     @AuraEnabled static 
        public Observation_Form_Questions__c newForm(){
            
            Observation_Form_Questions__c form = new Observation_Form_Questions__c ();
            form.Form_Name__c = '';
            form.Type__c = 'Form';
            return form;
            
            
        }
        
     @AuraEnabled static 
        public list<Observation_Form_Questions__c> getFormDetails(string formId){
            if(!string.isBlank(formId)){
                system.debug('******'+formId);
                 return  [SELECT id,Form__r.Form_Result__c,Section_Order__c,Form__r.Total_Score__c,Form__r.Send_Email__c,Form__r.Active__c,Form__r.Fields_to_display__c,Form__r.Mandatory_Fields__c,Mandatory_Fields__c,Fields_to_display__c,Form__c,Form__r.Form_Name__c,Section__c,Section1__c,Type__c,Critical_Value__c,Critical_Option__c,Critical__c,Section_Critical_Conditions__c,Form__r.Calculation_Type__c FROM Observation_Form_Questions__c WHERE Form__c=:formId AND Type__c ='Section' ORDER BY Section_Order__c ASC];   
            }
            return null;
            
        }
    
    
    
    @AuraEnabled
    public static optionsScoreClass optionScore(){
        optionsScoreClass options = new optionsScoreClass();
        options.option = '';
        options.score = 0;
        options.isCriticalValue = false;
        return options;
    }

    public class ObservationWrapper{
        @AuraEnabled
        public boolean showPickListField{get;set;}
        @AuraEnabled
        public boolean showCriticalField{get;set;}
        @AuraEnabled
        public Observation_Form_Questions__c form{get;set;}
        @AuraEnabled
        public List<optionsScoreClass> optionScoreList{get;set;}
    }
    
    public class returnSectionClass{
        @AuraEnabled
        public Observation_Form_Questions__c section{get;set;}
        @AuraEnabled
        public List<ObservationWrapper> forms{get;set;}
        
    }
}