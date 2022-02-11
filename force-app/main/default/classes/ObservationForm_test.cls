/*******************************************************************
* Class Name: ObservationForm_test
* Created By: Raiyan
* Purpose : Test Class for Observation Form related classes            
********************************************************************/
@isTest
public class ObservationForm_test{
  static testMethod void testForms(){
        
       FormDemo.createForms('Section','question','1','type'); 
       FormDemo.initialise(); 
       FormDemo.dataTypes(); 
       
       Observation_Form_Questions__c form = new Observation_Form_Questions__c();
       form.Calculation_Type__c = 'Reduce scores from total score';
       form.Fields_to_display__c = 'Call_link__c,Agent__c,Quality_Assessor__c,Case__c,Complaint_Ref__c,Contact__c,Corrective_actions__c,Corrective_actions_completed_Date__c,Corrective_actions_required__c,Date_complaint_closed__c,Date_of_Check__c,Date_complaint_logged__c,Date_of_Observation__c,Corrective_actions_due_date__c,Opportunity__c,Overall_Rating__c,Overall_Score__c,Overall_commentary__c,Incorrect_Customer_Outcome__c,Customer_Type__c,KYC_Task_Name__c,Business_Area__c,TM_Task_list__c,QC_Staff_Name__c';
       form.Form_Name__c = 'KYC Other Task QC forms';
       form.Mandatory_Fields__c = 'Agent__c,TM_Task_list__c';
       form.Form_Result__c = '{"resultList":[{"Min":"0","max":"69","value":"Fail"},{"Min":"70","max":"80","value":"PWD"},{"Min":"81","max":"100","value":"Pass"}]}';
       form.Type__c = 'Form';
       form.Total_Score__c  = 100;
       insert form;
       
       Observation_Form_Questions__c section = new Observation_Form_Questions__c();
       section.Form__c = form.id;
       section.Form_Name__c = 'KYC Other Task QC forms';
       section.Type__c  = 'Section';
       section.Section_Order__c = 1;
       section.Section_Critical_Conditions__c  = '{"resultList":[{"Min":"0","max":"0","value":""}]}';
       section.Section__c = 'AML';
       insert section;
       
       Observation_Form_Questions__c question = new Observation_Form_Questions__c();
       question.Form__c = form.id;
       question.Form_Name__c = 'KYC Other Task QC forms';       
       question.Section_Order__c = 1;
       question.Section1__c = section.id;
       question.Section_Critical_Conditions__c  = '{"resultList":[{"Min":"0","max":"0","value":""}]}';
       question.Section__c = 'AML';
       question.Data_Type__c = 'Dropdown';
       //question.Objective__c = 'Each alert to be adequately discounted, with an appropriate rationale recorded.';
       question.Question__c = 'Customer identification screening alert investigations meet Policy standards (Finscan customer screening ONLY)';
       question.Question_Number__c  = 1;
       question.Type__c = 'Question';
       question.Critical__c = true;
       insert question;
       
       Observation_Form_Questions__c question2 = new Observation_Form_Questions__c();
       question2.Form__c = form.id;
       question2.Form_Name__c = 'KYC Other Task QC forms';       
       question2.Section_Order__c = 1;
       question2.Section1__c = section.id;
       question2.Section_Critical_Conditions__c  = '{"resultList":[{"Min":"0","max":"0","value":""}]}';
       question2.Section__c = 'AML';
       question2.Data_Type__c = 'Checkbox';
       //question2.Objective__c = 'Each alert to be adequately discounted, with an appropriate rationale recorded.';
       question2.Question__c = 'Customer identification screening alert investigations meet Policy standards (Finscan customer screening ONLY)';
       question2.Question_Number__c  = 1;
       question2.Type__c = 'Question';
       insert question2;
       
       Observation_Form_Questions__c question3 = new Observation_Form_Questions__c();
       question3.Form__c = form.id;
       question3.Form_Name__c = 'KYC Other Task QC forms';       
       question3.Section_Order__c = 1;
       question3.Section1__c = section.id;
       question3.Section_Critical_Conditions__c  = '{"resultList":[{"Min":"0","max":"0","value":""}]}';
       question3.Section__c = 'AML';
       question3.Data_Type__c = 'Checkbox';
       //question3.Objective__c = 'Each alert to be adequately discounted, with an appropriate rationale recorded.';
       question3.Question__c = 'Customer identification screening alert investigations meet Policy standards (Finscan customer screening ONLY)';
       question3.Question_Number__c  = 1;
       question3.Type__c = 'Question';
       insert question3;
       
       Observation_Form_Questions__c option = new Observation_Form_Questions__c();
       option.Form__c = form.id;
       option.Form_Name__c = 'KYC Other Task QC forms';       
       option.Section_Order__c = 1;
       option.Section1__c = section.id;
       option.Section_Critical_Conditions__c  = '{"resultList":[{"Min":"0","max":"0","value":""}]}';
       option.Section__c = 'AML';
       option.Data_Type__c = 'Dropdown';
       //option.Objective__c = 'Each alert to be adequately discounted, with an appropriate rationale recorded.';
       option.Question__c = 'Customer identification screening alert investigations meet Policy standards (Finscan customer screening ONLY)';
       option.Question_Number__c  = 1;
       option.Type__c = 'Option';
       option.Question_Lookup__c = question.id;
       option.Option__c = 'Pass';
       option.Score__c = 0;
       insert option;
       
        Account acc = new Account();
        acc.Name = 'test1 Force26';           
        acc.Previously_Exited_or_Declined__c = 'True Match';
        insert acc;
        acc.Previously_Exited_or_Declined__c = 'True Match Account Activity';
        update acc;
        
        contact con = new Contact();
        con.LastName = 'Raiyan';
        con.email = 'test@test.com';
        con.AccountId = acc.id;
        con.User_lookup__c = UserInfo.getUserId();
        insert con;
       
       FormDemo.newForm();
       FormDemo.saveForm(form);       
       list<FormDemo.ObservationWrapper> wrapperList = FormDemo.getQuestionDetails(section.id);
       FormDemo.saveObservationForm(wrapperList,section,new list<string>());
       FormDemo.getFormDetails(form.id);
       FormDemo.optionScore();
       
       
       Observation_Form__c aForm = new Observation_Form__c();
       aForm.Observation_Form_Questions__c = form.id;
       aForm.Form_Name__c = form.Form_Name__c;
       insert aForm;
       
       
       Observation_Form_Response__c res = new Observation_Form_Response__c();
       res.Observation_Form_Question__c = question.id;
       res.Observation_From__c = aForm.id;
       res.Response__c = 'Yes';
       insert res;
       
       observationFormController.getFormData(question.id);
       observationFormController.ObservationWrapper wrapperv = observationFormController.getFormData(aForm.id);
       observationFormController.getFormDataMethod(aForm.id);
       observationFormController.saveFormData(wrapperv );
       
       ObservationForm_Controller obc = new ObservationForm_Controller();
       obc.getFormDetails();
       obc.continueToForm();
       
       test.starttest();
       observationFormController.sendEmailToController(aForm,'formSubmissionPass',UserInfo.getUserId()+',');
       observationFormController.sendEmailToController(aForm,'formSubmissionPwd',UserInfo.getUserId()+',');
       observationFormController.sendEmailToController(aForm,'formSubmissionFail',UserInfo.getUserId()+',');
       observationFormController.sendEmailToController(aForm,'AppealAgentSubmission',UserInfo.getUserId()+',');
       observationFormController.sendEmailToController(aForm,'AppealManagerSubmission',UserInfo.getUserId()+',');
       observationFormController.sendEmailToController(aForm,'AppealManagerApprove',UserInfo.getUserId()+',');
       observationFormController.sendEmailToController(aForm,'AppealManagerReject',UserInfo.getUserId()+',');
        observationFormController.sendEmailToController(aForm,'AppealAssessorApprove',UserInfo.getUserId()+',');
         observationFormController.sendEmailToController(aForm,'AppealAssessorReject',UserInfo.getUserId()+',');
         observationFormController.sendEmailToController(aForm,'Observation_Form_Manager_Discretion',UserInfo.getUserId()+',');
       FormDemo.saveObservationForm(wrapperList,section,new list<string>{option.id});
       test.stoptest();
       
    }
}