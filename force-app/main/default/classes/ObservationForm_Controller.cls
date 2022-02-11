public without sharing class ObservationForm_Controller{
   
    public List<SelectOption> forToSelect{get;set;}
    public string  formId{get;set;}
    public string  caseId{get;set;}
    
    public ObservationForm_Controller(){
         if(Apexpages.currentPage().getParameters().get('caseId') != null && !string.isBlank(Apexpages.currentPage().getParameters().get('caseId'))){
             caseId = Apexpages.currentPage().getParameters().get('caseId');
         }
    }
    
    public List<SelectOption> getFormDetails(){
    List<SelectOption> formToSelect = new List<SelectOption>();
    for(Observation_Form_Questions__c pro:[SELECT Id,Name,Form_Name__c FROM Observation_Form_Questions__c WHERE Type__c ='Form' AND Active__c = False ORDER By Form_Name__c  ASC]){
           
                //proList.add(pro);
            formToSelect.add(new selectoption(pro.id,pro.Form_Name__c ));
            
        }  
        return formToSelect;
    } 
    
    
    public Pagereference continueToForm(){
       //let's say your aura component is called "TestEditRecord"
        Pagereference pageRef;
        if(!string.isBlank(caseId)){
            pageRef = new PageReference('/apex/ObservationFormDetails?id='+formId+'&caseId='+caseId);  
        }else{
            pageRef = new PageReference('/apex/ObservationFormDetails?id='+formId);  
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}