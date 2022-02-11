import {
    LightningElement,
    track,
    wire,
    api
  } from "lwc";
  import formData from "@salesforce/apex/observationFormController.getFormData";
  import saveFormData from "@salesforce/apex/observationFormController.saveFormData";
  import saveAppealForm from "@salesforce/apex/observationFormController.submitAppeal";
  import getManagerID from "@salesforce/apex/observationFormController.getManagerID";
  import sendEmailApex from "@salesforce/apex/observationFormController.sendEmailToController";
  import uId from '@salesforce/user/Id';
  import { ShowToastEvent } from 'lightning/platformShowToastEvent';
  export default class ObservationFormData extends LightningElement {
  
    @track questionFormData;
    @track value;
    @track resultForm;
    @track testForm;
    @track someVal;
    @track showIsChangedRow = false;
    @track score = 0;
    @track recordInfo = [];
    @track resultJsonVal;
    @track result = '';
    @track sendemail = false;
    @track sendmanagerdiscretionEmail = false;
    showAppealSection = false;
    mandatoryFields = '';
    mandatoryFieldsList = [];
    visible = false;
    toastMessage = '';
    form;
    totalScore = 0;
    @track percentage = 0;
    recordIdForm;
    @api recordId;
    @api caseId;
    scoringMech;
    loggedInUSer = uId;
    appealValue = '';
    appealCommentFromAgent = '';
    appealCommentFromManager = '';
    appealCommentFromAssessor = '';
    @track donotSendEmail = false;
   // appealOptions = [];
   @track displayAppealCommentary = false;
   @track hasPermission = false;
   @track appealForm;
   @track showinfo = false;
   @track isLoading = false;
   
   @track loginUserDetail = {agent:false,manager:false,assessor:false,managerComment:false,assessorComment:true,agentComment:true,discretionAccess:false};
   @track appealApprovalStatus = {submitted:false,approved:false,rejected:false,displaySubmit:true,displaySave:false,disableAppeal:false}
   @track managerDiscretion = {showComments:false,disableoverall:true,disabled:true};
   @track pageMessage = '';
    connectedCallback() {
        this.isLoading = true;
        console.log('Hiii');
        this.getformData();
        
        //this.appealOptions.push({ label: 'Yes', value: 'Yes' });
       // this.appealOptions.push({ label: 'No', value: 'No' });
  
    }

    get appealOptions(){
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
           
        ];
    }

    handleAppealChange(event) {
        this.appealValue = event.detail.value;
        this.resultForm.form.Appeal__c = event.detail.value;
        if(this.appealValue == 'Yes'){
            this.displayAppealCommentary = true;
        }else{
            this.displayAppealCommentary = false; 
        }
    }

    sendEmailChange(event){
        
        if(this.donotSendEmail){
            this.donotSendEmail = false;
          
        }else{
            this.donotSendEmail = true;  
        }
    }

    appealCommentHandler(event) {
        console.log('Comment',event.target.value+'--Name:',event.target.name);
        var commentor = event.target.name;
        if(commentor == 'agentComment')
            this.resultForm.form.Agent_Comment_for_Appeal__c = event.target.value;
        else if(commentor == 'managerComment')        
            this.resultForm.form.Manager_Commentary_for_Appeal__c = event.target.value;
        else if(commentor == 'AssessorComment')        
            this.resultForm.form.Assessor_Comment_for_Appeal__c = event.target.value;
        else if(commentor == 'dicretionComments'){
            this.resultForm.form.Manager_Discretion_Comments__c = event.target.value;
        }
    }

    ManagerDiscretionChange(event){
        
        if(this.managerDiscretion.showComments){
            this.managerDiscretion.showComments = false;
            this.managerDiscretion.disableoverall = true;  
            this.resultForm.form.Manager_Discretion__c = false;  
            this.sendmanagerdiscretionEmail = false;
        }else{
            this.managerDiscretion.showComments = true;
            this.managerDiscretion.disableoverall = false;  
            this.resultForm.form.Manager_Discretion__c = true;
            this.sendmanagerdiscretionEmail = true;  
        }
    }

    showTooltip(event){
        const index = event.target.name;
        const qindex = event.target.id;
        const tooltipType = event.target.dataset.type;
		const listIndex = qindex.substring(0, qindex.indexOf('-'));
        this.resultForm.sectionList[index].questionAndOptionList[listIndex][tooltipType] = true;
		console.log('Value:',this.resultForm.sectionList[index].questionAndOptionList[listIndex][tooltipType]);
    }

    hideTooltip(event){
        const index = event.target.name;
        const qindex = event.target.id;
        const tooltipType = event.target.dataset.type;
		const listIndex = qindex.substring(0, qindex.indexOf('-'));
		console.log('Value:',this.resultForm.sectionList[index].questionAndOptionList[listIndex][tooltipType]);
        this.resultForm.sectionList[index].questionAndOptionList[listIndex][tooltipType] = false;
    }

    saveManagerDiscretion(event){
        if(this.loginUserDetail.manager && !this.resultForm.form.Manager_Discretion_Comments__c){
            this.toastMessage = 'Please Provide Manager Discretion Comments';
            this.visible = true;
            let delay = 2000;
            setTimeout(() => {
                this.visible = false;
            }, delay );

            return;
        }else{
            this.saveForm();
        }    
    }

    validateAppeal(type){
        if(this.loginUserDetail.agent && !this.resultForm.form.Agent_Comment_for_Appeal__c){
            this.toastMessage = 'Please Provide Agent Comments';
            this.visible = true;

            return false;
        }

        if(this.loginUserDetail.manager && !this.resultForm.form.Manager_Commentary_for_Appeal__c){
            this.toastMessage = 'Please Provide Manager Comments';
            this.visible = true;
            return false;
        }

        if(this.loginUserDetail.assessor && !this.resultForm.form.Assessor_Comment_for_Appeal__c){
            this.toastMessage = 'Please Provide Assessor Comments';
            this.visible = true;
            return false;
        }
        return true;

    }

    
    approvalSubmission(event){
        
        this.visible = false;
        console.log('name:',event.target.name);
        var type = event.target.name;

        if(this.validateAppeal(type)){
            var templateType;
            var toAddressId;

            if(type == 'submission'){
            
                if(this.loginUserDetail.manager){
                    this.resultForm.form.Appeal_Approval_Status__c = 'Manager Submitted';
                    this.toastMessage = 'Appeal Submitted and auto approved'; 
                    //this.sendEmail(this.resultForm.form,'AppealManagerSubmission',this.resultForm.form.Line_Manager__c+','+this.resultForm.form.Quality_Assessor__c);
                    templateType = 'AppealManagerSubmission';
                    toAddressId =  this.resultForm.form.Line_Manager__c+','+this.resultForm.form.Quality_Assessor__c;
                }else{
                    this.toastMessage = 'Appeal Submitted';
                    this.resultForm.form.Appeal_Approval_Status__c = 'Submitted';
                    //this.sendEmail(this.resultForm.form,'AppealAgentSubmission',this.resultForm.form.Line_Manager__c);
                    templateType = 'AppealAgentSubmission';
                    toAddressId =  this.resultForm.form.Line_Manager__c;
                                
                }
            }
               
            else if(type == 'approve'){
                this.resultForm.form.Appeal_Approval_Status__c = 'Manager Approved';
                this.toastMessage = 'Appeal Approved';
                //this.sendEmail(this.resultForm.form,'AppealManagerApprove',this.resultForm.form.Agent__c+','+this.resultForm.form.Quality_Assessor__c);
                templateType = 'AppealManagerApprove';
                toAddressId =  this.resultForm.form.Agent__c+','+this.resultForm.form.Quality_Assessor__c;
            }
               
            else if(type == 'rejected'){
                this.resultForm.form.Appeal_Approval_Status__c = 'Manager Rejected';
                this.toastMessage = 'Appeal Rejected';
                //this.sendEmail(this.resultForm.form,'AppealManagerReject',this.resultForm.form.Agent__c);
                templateType = 'AppealManagerReject';
                toAddressId =  this.resultForm.form.Agent__c;
            }
            else if(type == 'assessorapprove'){
                this.resultForm.form.Appeal_Approval_Status__c = 'Assessor Approved';
                this.toastMessage = 'Appeal Approved';
                //this.sendEmail(this.resultForm.form,'AppealAssessorApprove',this.resultForm.form.Agent__c+','+this.resultForm.form.Line_Manager__c);
                templateType = 'AppealAssessorApprove';
                toAddressId =  this.resultForm.form.Agent__c+','+this.resultForm.form.Line_Manager__c;
            }
            else if(type == 'assessorrejected'){
                this.resultForm.form.Appeal_Approval_Status__c = 'Assessor Rejected';
                this.toastMessage = 'Appeal Rejected';
                //this.sendEmail(this.resultForm.form,'AppealAssessorReject',this.resultForm.form.Agent__c+','+this.resultForm.form.Line_Manager__c);
                templateType = 'AppealAssessorReject';
                toAddressId =  this.resultForm.form.Agent__c+','+this.resultForm.form.Line_Manager__c;
               
            }
            
                
            this.saveAppeal(type,templateType,toAddressId)


        }
       
    }

    saveAssessorAppeal(){
        if(this.loginUserDetail.assessor && !this.resultForm.form.Assessor_Comment_for_Appeal__c){
            this.toastMessage = 'Please Provide Assessor Comments';
            this.visible = true;           

            return;
        }else{
            this.saveForm();
        }    
    }

   
    saveAppeal(type,templateType,toAddressId){

        saveAppealForm({
            form: this.resultForm.form
           })
           .then((result) => {
                console.log('sucesss:'+result)
                this.sendEmail(this.resultForm.form,templateType,toAddressId);
                this.showinfo = true;
                let delay = 2000;
                  setTimeout(() => {
                      this.showinfo = false;
                  }, delay );
                this.setAppealSection();
           })
           .catch((error) => {
                this.toastMessage = 'Error while processing request:'+JSON.stringify(error);
                this.visible = true;
                return;
               console.log('Error', error);
           });
        
    }
    sendEmail(form,templateType,toAddressId){
        sendEmailApex({
                form: form,templateType:templateType,toAddressId:toAddressId
        })
        .then((result) => {
            console.log('sucesss:'+result)
            this.showinfo = true;
            let delay = 2000;
            setTimeout(() => {
                this.showinfo = false;
            }, delay );
        })
        .catch((error) => {
            this.toastMessage = 'Error while sending email:'+JSON.stringify(error);
            this.visible = true;
            return;
            console.log('Error', error);
        });
            

            
    }
    
    setAppealSection(){
        console.log('set appeal section',this.resultForm.form.Appeal_Approval_Status__c);
        if(this.loginUserDetail.assessor)
        this.appealApprovalStatus.displaySubmit = false; 
        if(this.resultForm.form.Appeal_Approval_Status__c){
            this.appealApprovalStatus.disableAppeal = true;
            this.appealApprovalStatus.displaySubmit = false;
            if(this.resultForm.form.Appeal_Approval_Status__c == 'Submitted' ){
                this.appealApprovalStatus.submitted = true;
               
            }else if(this.resultForm.form.Appeal_Approval_Status__c == 'Manager Approved' ){
                this.appealApprovalStatus.approved = true;
                this.appealApprovalStatus.submitted = false;
                this.appealApprovalStatus.displaySave = true;
            }else if(this.resultForm.form.Appeal_Approval_Status__c == 'Manager Rejected' ){
                this.appealApprovalStatus.rejected = true;
                this.appealApprovalStatus.submitted = false;
                this.appealApprovalStatus.displaySave = false;
            }else if(this.resultForm.form.Appeal_Approval_Status__c == 'Assessor Approved' ){
                this.appealApprovalStatus.Assessorapproved = true;
                this.appealApprovalStatus.submitted = false;
                this.appealApprovalStatus.displaySave = false;
            }else if(this.resultForm.form.Appeal_Approval_Status__c == 'Assessor Rejected' ){
                this.appealApprovalStatus.Assessorrejected = true;
                this.appealApprovalStatus.submitted = false;
                this.appealApprovalStatus.displaySave = false;
            }else if(this.resultForm.form.Appeal_Approval_Status__c == 'Manager Submitted' ){
                this.appealApprovalStatus.Assessorrejected = true;
                this.appealApprovalStatus.submitted = false;
                this.appealApprovalStatus.displaySave = true;
            }
        }
        console.log('****'+JSON.stringify(this.appealApprovalStatus));
    }

    changeOverallResult(event){
        console.log('event.target.value',event.target.value);
        this.resultForm.form.Overall_Rating__c = event.target.value;
    }
    changeOverallPercentage(event){
        console.log('event.target.value',event.target.value);
        var value = 0;
        value = parseInt(event.target.value, 10);
        console.log('value'+value);
        if(value >=0 && value <=100){
            this.percentage = value;
            if(this.percentage > 100){
                this.percentage = 100;
                this.resultForm.form.Overall_Score__c = 100;
            }
            if(this.percentage <0){
                this.percentage = 0;
                this.resultForm.form.Overall_Score__c = 0;    
            }
           
        }else{
            if(value > 0){
                this.percentage = 100;     
            }else
                this.percentage = 0;    
        }
        console.log('event.target.value',event.target.value);
        const myObj = JSON.parse(this.resultJsonVal);
        for (let i = 0; i < myObj.resultList.length; i++) {
            console.log('Min:', myObj.resultList[i].Min, ' Max:', myObj.resultList[i].max, ' Pecentage:', this.percentage);
            if (this.percentage >= myObj.resultList[i].Min && this.percentage <= myObj.resultList[i].max) {
                this.result = myObj.resultList[i].value;
                
            }
        }
        this.resultForm.form.Overall_Score__c = value;
        this.resultForm.form.Overall_Rating__c = this.result;
        
    }

    scoreHandler(event) {
        var value = event.target.value.substring(1, event.target.value.indexOf('-'));
        const index = event.target.name;
        const qindex = event.target.id;
        const selectedVal = event.target.value.split('-')[1];
        const listIndex = qindex.substring(0, qindex.indexOf('-'));
        console.log('*****scoringMech', this.scoringMech);
        //console.log('qindex',event.target.value);
        //console.log('this.totalScore',this.totalScore);
        //console.log('selectedVal',selectedVal);
        //console.log('Critical?',this.resultForm.sectionList[index].questionAndOptionList[listIndex].isCritical);
        //console.log('Critical Value?',this.resultForm.sectionList[index].questionAndOptionList[listIndex].Question.Critical_Value__c);
  
  
  
        this.selectedOption = event.target.value.split('-')[0];
        let nowScore = parseInt(this.selectedOption, 10);
        this.resultForm.sectionList[index].questionAndOptionList[listIndex].response.Score__c = nowScore;
        this.resultForm.sectionList[index].questionAndOptionList[listIndex].response.Response__c = selectedVal;
        if (this.scoringMech == 'Sum up scores to calculate total score') {
            this.score = 0;
            for (var i = 0; i < this.resultForm.sectionList.length; i++) {
                for (var j = 0; j < this.resultForm.sectionList[i].questionAndOptionList.length; j++) {
  
  
                    let responseVal = this.resultForm.sectionList[i].questionAndOptionList[j].response.Response__c;
                    if (responseVal) {
                        responseVal = responseVal.toLocaleLowerCase();
                    }
                    let criticalValue = this.resultForm.sectionList[i].questionAndOptionList[j].Question.Critical_Value__c;
                    let isCritical = this.resultForm.sectionList[index].questionAndOptionList[listIndex].isCritical;
                    let selectedCrticalVal = this.resultForm.sectionList[index].questionAndOptionList[listIndex].Question.Critical_Option__c;
                    if (selectedCrticalVal) {
                        selectedCrticalVal = selectedCrticalVal.toLocaleLowerCase();
                    }
                    const qScore = this.resultForm.sectionList[i].questionAndOptionList[j].response.Score__c;
                    console.log('responseVal:' + responseVal);
                    console.log('criticalValue:' + criticalValue);
                    console.log('isCritical:' + isCritical);
                    console.log('critical Option:' + selectedCrticalVal);
                    console.log('qScore:' + qScore);
  
                    if (responseVal && isCritical && responseVal != selectedCrticalVal) {
                        console.log('Inside Condition:', isCritical + '---', responseVal == selectedCrticalVal);
                        this.score -= criticalValue;
                    } else if (qScore > 0) {
  
                        this.score += qScore;
                    }
                }
  
            }
            console.log('Inside', this.resultJsonVal);
            const myObj = JSON.parse(this.resultJsonVal);
            console.log('Inside', myObj.resultList[0]);
            console.log('Inside', myObj.resultList[0].Min);
  
            this.percentage = (this.score / this.totalScore) * 100;
  
            console.log('Percentage', this.percentage);
            for (let i = 0; i < myObj.resultList.length; i++) {
                console.log('Inside', myObj.resultList[i].Min);
                if (this.percentage >= myObj.resultList[i].Min && this.percentage <= myObj.resultList[i].max) {
                    this.result = myObj.resultList[i].value;
                }
            }
  
            if (this.percentage < 0) {
                this.percentage = 0;
                if (myObj.resultList.length > 0) {
                    this.result = myObj.resultList[0].value;
                }
  
            }
            if (this.score < 0) {
                this.score = 0;
  
            }
        }  else {
          try {
            this.score = this.totalScore;
            this.percentage = 100;
            for (var i = 0; i < this.resultForm.sectionList.length; i++) {
                for (var j = 0; j < this.resultForm.sectionList[i].questionAndOptionList.length; j++) {
  
  
                    let responseVal = this.resultForm.sectionList[i].questionAndOptionList[j].response.Response__c;
                    if (responseVal) {
                        responseVal = responseVal.toLocaleLowerCase();
                    }
                    let criticalValue = this.resultForm.sectionList[i].questionAndOptionList[j].Question.Critical_Value__c;
                    let isCritical = this.resultForm.sectionList[index].questionAndOptionList[listIndex].isCritical;
                    let selectedCrticalVal = this.resultForm.sectionList[index].questionAndOptionList[listIndex].Question.Critical_Option__c;
                    if (selectedCrticalVal) {
                        selectedCrticalVal = selectedCrticalVal.toLocaleLowerCase();
                    }
                    const qScore = this.resultForm.sectionList[i].questionAndOptionList[j].response.Score__c;
                    console.log('responseVal:' + responseVal);
                    console.log('criticalValue:' + criticalValue);
                    console.log('isCritical:' + isCritical);
                    console.log('critical Option:' + selectedCrticalVal);
                    console.log('qScore:' + qScore);
  
                    /*if(responseVal && isCritical && responseVal != selectedCrticalVal){
                      console.log('Inside Condition:',isCritical+'---',responseVal == selectedCrticalVal);
                      this.score -= criticalValue;   
                    }
                    else*/
                    if (qScore > 0) {
  
                        this.score -= qScore;
                    }
                }
  
            }
            console.log('Inside', this.resultJsonVal);
            const myObj = JSON.parse(this.resultJsonVal);
            console.log('Inside', myObj.resultList[0]);
            console.log('Inside', myObj.resultList[0].Min);
  
            this.percentage = (this.score / this.totalScore) * 100;
  
            var difference = (this.totalScore - this.score) / this.totalScore * 100;
  
  
  
  
            console.log('Percentage', this.percentage);
  
  
            this.percentage = Math.round(this.percentage);
      
       for (let i = 0; i < myObj.resultList.length; i++) {
        console.log('Min:', myObj.resultList[i].Min, ' Max:', myObj.resultList[i].max, ' Pecentage:', this.percentage);
        if (this.percentage >= myObj.resultList[i].Min && this.percentage <= myObj.resultList[i].max) {
          this.result = myObj.resultList[i].value;
        }
      }
  
  
  
      if (this.percentage < 0) {
        this.percentage = 0;
        if (myObj.resultList.length > 0) {
          this.result = myObj.resultList[0].value;
        }
  
      }
      if (this.score < 0) {
        this.score = 0;
  
      }
      this.resultForm.form.Overall_Score__c = this.percentage;
      this.resultForm.form.Overall_Rating__c = this.result;
  
            var criticalValFound = false;
            var criticalScoreToreduce = 0;
            //console.log('Section Critical Found1:',criticalValFound);
            //console.log('criticalScoreToreduce1:',this.resultForm.sectionList.length);
            for (var i = 0; i < this.resultForm.sectionList.length; i++) {
                let sectionValue = this.resultForm.sectionList[i].section.Critical_Option__c;
                //let sectionScore = this.resultForm.sectionList[i].section.Critical_Value__c;
                let secCritical = this.resultForm.sectionList[i].section.Critical__c;
                let conditions = this.resultForm.sectionList[i].section.Section_Critical_Conditions__c;
  
                const myObj1 = JSON.parse(conditions);
                var totalResponses = 0;
  
  
                console.log('myObj:', myObj.resultList);
                if (secCritical && sectionValue) {
                    sectionValue = sectionValue.toLocaleLowerCase();
                    console.log('sectionValue Lower:', sectionValue, 'this.resultForm.sectionList[i].questionAndOptionList.length:', this.resultForm.sectionList[i].questionAndOptionList.length);
                    for (var j = 0; this.resultForm.sectionList[i].questionAndOptionList.length; j++) {
                        let responseVal = this.resultForm.sectionList[i].questionAndOptionList[j].response.Response__c;
                        //console.log('responseVal:',responseVal);
                        if (responseVal) {
  
                            responseVal = responseVal.toLocaleLowerCase();
                            console.log('responseValLower::', responseVal, 'sectionValue.includes(responseVal)::', sectionValue.includes(responseVal));
                            if (!sectionValue.includes(responseVal)) {
                                var somepercent = 100;
                                totalResponses += 1;
                                criticalValFound = true;
                                console.log('totalResponses::', totalResponses);
                                for (let i = 0; i < myObj1.resultList.length; i++) {
                                    console.log('Inside', myObj1.resultList[i].Min);
                                    if (totalResponses >= myObj1.resultList[i].Min && totalResponses <= myObj1.resultList[i].max) {
                                        criticalScoreToreduce = parseInt(myObj1.resultList[i].value, 10);
                                    }
                                    console.log('****criticalScoreToreduce:', criticalScoreToreduce);
                                }
                                this.percentage = Math.round((somepercent - difference) - criticalScoreToreduce);
  
  
                            }
  
  
                            console.log('****percentage:', this.percentage);
                            for (let i = 0; i < myObj.resultList.length; i++) {
                                console.log('Min:', myObj.resultList[i].Min, ' Max:', myObj.resultList[i].max, ' Pecentage:', this.percentage);
                                if (this.percentage >= myObj.resultList[i].Min && this.percentage <= myObj.resultList[i].max) {
                                    this.result = myObj.resultList[i].value;
                                    
                                }
                            }
                            this.resultForm.form.Overall_Score__c = this.percentage;
                            this.resultForm.form.Overall_Rating__c = this.result;

  
                            if (this.percentage < 0) {
                                this.percentage = 0;
                                if (myObj.resultList.length > 0) {
                                    this.result = myObj.resultList[0].value;
                                    this.resultForm.form.Overall_Score__c = this.percentage;
                                    this.resultForm.form.Overall_Rating__c = this.result;
                                }
  
                            }
                            if (this.score < 0) {
                                this.score = 0;
  
                            }
                      }
                    }
                }
            }
            if(this.result == 'Fail' || this.result == 'fail'){
                for (var i = 0; i < this.recordInfo.length; i++) {
                    console.log('Inside', this.recordInfo[i].name);
                    if(this.recordInfo[i].name == 'Urgent_feedback_required__c'){
                       
                        this.recordInfo[i].value = 'Yes';
                    }  
                }

            }else{
                for (var i = 0; i < this.recordInfo.length; i++) {
                    console.log('Inside', this.recordInfo[i].name);
                    if(this.recordInfo[i].name == 'Urgent_feedback_required__c'){
                       
                        this.recordInfo[i].value = 'No';
                    }  
                }    
            }
            
          }catch(err) {
            //alert( err.message);
          }
        }
  
    }
  
   
  
    getformData() {
        formData({
                questionFormId: this.recordId
            })
            .then((result) => {
                console.log('result', JSON.stringify(result));
                console.log('ranking Details', result.resultJson);
  
                console.log('Form from', result.fieldsToDisplay);
                console.log('Form', result.sectionList);
                this.resultForm = result;
                this.resultJsonVal = result.resultJson;
                this.recordIdForm = result.form.Id;
  
                var res = result.fieldsToDisplay.split(",");
                if(result.mandatoryfieldsToDisplay)
                this.mandatoryFieldsList = result.mandatoryfieldsToDisplay.split(",");
                this.mandatoryFields = result.mandatoryfieldsToDisplay;
                
                console.log('Appeal Section:',result.form.Form_Submitted__c);
                this.showAppealSection = result.form.Form_Submitted__c;
                this.donotSendEmail = result.doNotSendEmail;
                //this.selectedFields = res;
                this.totalScore = result.totalScore;
                if (this.scoringMech != 'Sum up scores to calculate total score') {
                    this.score = this.totalScore;
                    this.percentage = 100;
                }
  
                if(result.form.Overall_Score__c || result.form.Overall_Score__c == 0){
                  this.percentage = result.form.Overall_Score__c;  
  
                }
  
                if(result.form.Overall_Rating__c){
                  this.result = result.form.Overall_Rating__c;  
  
                }
                if(this.caseId){
                    result.form.Case__c = this.caseId;
                }
                
                console.log('this.resultForm.sectionList.length:--',this.resultForm.sectionList.length);
                console.log('this.resultForm.sectionList[i].length:--',this.resultForm.sectionList[0]);

                for (var i = 0; i < this.resultForm.sectionList.length; i++) {
                    for (var j = 0; j < this.resultForm.sectionList[i].questionAndOptionList.length; j++) {
                        console.log('Option', result.sectionList[i].questionAndOptionList[j].optionsList);
                        if(this.resultForm.sectionList[i].questionAndOptionList[j]){
                            console.log('Guide:',this.resultForm.sectionList[i].questionAndOptionList[j].Question.Guide__c);
                            if(this.resultForm.sectionList[i].questionAndOptionList[j].Question.Guide__c){
                                this.resultForm.sectionList[i].questionAndOptionList[j].showGuide = true;    
                                this.resultForm.sectionList[i].questionAndOptionList[j].guideToolTip = false;
                            }else{
                                this.resultForm.sectionList[i].questionAndOptionList[j].showGuide = false;
                                this.resultForm.sectionList[i].questionAndOptionList[j].guideToolTip = false;
                            }

                            if(this.resultForm.sectionList[i].questionAndOptionList[j].Question.Objective__c){
                                this.resultForm.sectionList[i].questionAndOptionList[j].hasObjective = true
                                this.resultForm.sectionList[i].questionAndOptionList[j].objectiveToolTip = false;        
                            }else{
                                this.resultForm.sectionList[i].questionAndOptionList[j].hasObjective = false;
                                this.resultForm.sectionList[i].questionAndOptionList[j].objectiveToolTip = false; 
                            }
                            
                        }
  
                    }
  
                }
                console.log('this.resultForm.sectionList[i].questionAndOptionList[j]:--',this.resultForm.sectionList[0].questionAndOptionList[0].showGuide);

                console.log('Agent:--',result.form.Agent__c,'---Line Manager:',result.form.Line_Manager__c,'---Assessor:',result.form.Quality_Assessor__c,'--Logged in:',this.loggedInUSer,'--CreatedBy:',result.form.CreatedById);
                
                if(!result.form.CreatedById){
                    this.hasPermission = true

                }
                else{ 
                   
                    if(result.form.Agent__c == this.loggedInUSer){
                        this.loginUserDetail.agent = true;  
                        this.hasPermission = true;  
                        this.loginUserDetail.managerComment = true; 
                        this.loginUserDetail.agentComment = false;   
                                        
                    }

                    if(result.form.Quality_Assessor__c == this.loggedInUSer){
                        this.loginUserDetail.assessor = true;
                        this.hasPermission = true;
                        this.loginUserDetail.managerComment = true;
                        this.loginUserDetail.assessorComment = false;

                    }
                    
                    if(result.form.Line_Manager__c == this.loggedInUSer || (this.resultForm.managersList && this.resultForm.managersList.includes(this.loggedInUSer))){
                        this.loginUserDetail.manager = true;   
                        this.hasPermission = true; 
                        this.managerDiscretion.disabled = false;
                        
                    }

                    
                    //loginUserDetail = {agent:false,manager:false,assessor:false};

                }
                

                

                let qualityAssesor  = result.form.Quality_Assessor__c;
                this.scoringMech = result.scoringMechanism;
                console.log('Total Score', this.totalScore);
                for (var i = 0; i < res.length; i++) {
                    //console.log('Field:'+res[i]+'Condition:'+(result.form.Corrective_actions_required__c == 'No' && (res[i] == 'Corrective_actions_due_date__c' || res[i] == 'Corrective_actions_due_date__c')));
                    if(this.mandatoryFields &&  this.mandatoryFields.includes(res[i])){
                      this.recordInfo.push({
                        name: res[i],
                        required:true,  
                        hide: (result.form.Corrective_actions_required__c == 'No' && (res[i] == 'Corrective_actions_due_date__c' || res[i] == 'Corrective_actions__c' || res[i] == 'Corrective_actions_completed_Date__c'))?true:false,                 
                        value: !result.form[res[i]] && res[i] == 'Quality_Assessor__c'?this.loggedInUSer : result.form[res[i]]
                      });
                    }else{
                        this.recordInfo.push({
                        name: res[i],
                        required:false,
                        hide:(result.form.Corrective_actions_required__c == 'No' && (res[i] == 'Corrective_actions_due_date__c' || res[i] == 'Corrective_actions__c' || res[i] == 'Corrective_actions_completed_Date__c'))?true:false,
                        value:  !result.form[res[i]] && res[i] == 'Quality_Assessor__c'?this.loggedInUSer : result.form[res[i]]
                      });
  
                    }
                    //console.log('Field Details:'+this.recordInfo[i].hide);
                    
                }
                this.appealForm = this.resultForm.form;
                this.resultForm.form.Quality_Assessor__c = !this.resultForm.form.Quality_Assessor__c ? this.loggedInUSer:this.resultForm.form.Quality_Assessor__c;
               

               
                if(this.resultForm.form.Appeal__c == 'Yes'){
                    this.displayAppealCommentary = true;
                    this.appealValue = 'Yes';
                }else{
                    this.displayAppealCommentary = false; 
                }
                console.log('**this.resultForm.form.Manager_Discretion__c**' +this.resultForm.form.Manager_Discretion__c);
                this.managerDiscretion.showComments = this.resultForm.form.Manager_Discretion__c;

                this.setAppealSection();

                
        
                    
               

                
                console.log('**this.managerList**' +JSON.stringify(this.loginUserDetail));
                console.log('**this.this.resultForm.Appeal_Approval_Status__c**-' + this.resultForm.form.Appeal_Approval_Status__c);
                this.isLoading = false;
  
            })
            .catch((error) => {
                console.log('Error', error);
            });
    }
  
    saveForm() {
      if(this.validate()){
             saveFormData({
                obw: this.resultForm
            })
            .then((result) => {
              this.form = result.form;
              console.log('this.form', this.form);
              this.pageMessage = 'Form Saved Successfully';
              this.sendSubmissionEmail(this.form);
              this.toastMessage = '';
              this.visible = true;
              
              let delay = 3000;
              setTimeout(() => {
                  this.visible = false;
                  this.navigateToViewPage();
              }, delay );
               
            })
            .catch((error) => {
                console.log('Error occured:', error);
                this.visible = true;
                this.toastMessage = 'Error while saving:'+JSON.stringify(error);
                  let delay = 3000
                  setTimeout(() => {
                      this.visible = false;
                  }, delay );
            });
        }
    }

    sendSubmissionEmail(form){

        if(!this.showAppealSection && !this.donotSendEmail && this.sendemail){
            const myObj = JSON.parse(this.resultJsonVal);

            if(myObj.resultList.length > 0){
                console.log(form.Overall_Score__c+'-'+myObj.resultList[0].Min+'***'+myObj.resultList[0].max);
                if(form.Overall_Score__c >=0 && form.Overall_Score__c <=myObj.resultList[0].max){
                    
                    this.sendEmail(form,'formSubmissionFail',form.Line_Manager__c+','+form.Agent__c);
                    this.pageMessage = 'Form Submittted Successfully';
                }else if(myObj.resultList.length > 1){
                    var myindex = myObj.resultList.length - 1;
                    console.log(form.Overall_Score__c+'-'+myObj.resultList[myindex].Min+'***'+myObj.resultList[myindex].max);
                    if(form.Overall_Score__c >=myObj.resultList[myindex].Min && form.Overall_Score__c <=myObj.resultList[myindex].max){
                        this.sendEmail(form,'formSubmissionPass',form.Line_Manager__c+','+form.Agent__c);  
                        this.pageMessage = 'Form Submittted Successfully';  
                    }else{
                        this.sendEmail(form,'formSubmissionPwd',form.Line_Manager__c+','+form.Agent__c); 
                        this.pageMessage = 'Form Submittted Successfully';
                    }
                }
            }
            
        }else if(this.sendmanagerdiscretionEmail){
            this.sendEmail(form,'Observation_Form_Manager_Discretion',form.Agent__c);     
        }
    }

    saveFormAndSubmit(){
        this.resultForm.form.Form_Submitted__c = true;
        this.sendemail = true;
        this.saveForm();
    }

    /*sendEmail(){
        sendEmailApex({
            userID: userid
        })
        .then((result) => {
            
        })
        .catch((error) => {
            console.log('Error', error);
        });
        
    }*/
  
      validate(){
          console.log('validate');
          console.log('this.resultForm.form.Corrective_actions_due_date__c',this.resultForm.form.Corrective_actions_due_date__c);
          for (var i = 0; i < this.recordInfo.length; i++) {
              console.log('validate',this.recordInfo[i]+' value',this.resultForm.form[this.recordInfo[i].name]);
              if(this.recordInfo[i].required && this.recordInfo[i].name != 'Name' && !this.resultForm.form[this.recordInfo[i].name]){
                  this.toastMessage = 'Please fill in all the mandatory fields:'+this.recordInfo[i].name;
                  this.visible = true;
                  let delay = 3000
                  setTimeout(() => {
                      this.visible = false;
                  }, delay );
                      
  
                  return false;
              }
              if(this.resultForm.form.Manager_Discretion__c && !this.resultForm.form.Manager_Discretion_Comments__c){
                this.toastMessage = 'Please Provide Manager Discretion Comments';
                this.visible = true;
                let delay = 2000;
                setTimeout(() => {
                    this.visible = false;
                }, delay );
    
                return false;
            }
          }
          return true;
  
      }
  
  
    navigateToViewPage() {
      console.log('Navicgation',this.form);
  
      window.location.assign('/apex/ObservationFormDetails?id='+this.form.Id);
    }
   
    cancelForm(){
        
        window.history.back();
    }

  
    get recordInfoDefined() {
        return this.recordInfo !== undefined && this.recordInfo.fields !== undefined
    }
  
    commentryHandler(event) {
        const index = event.target.name;
        const qindex = event.target.dataset.indexc;
        const comments = event.target.value;
        console.log('index', index);
        console.log('qindex', qindex);
        this.resultForm.sectionList[index].questionAndOptionList[qindex].response.Commentary__c = comments;
        console.log('form Resposne', this.resultForm.sectionList[index].questionAndOptionList[qindex].response);
  
  
    }
  
  
    onchangeField(event) {
        console.log('Field Value', event.target.dataset.fieldname);
        let FieldVal = event.target.dataset.fieldname;
        console.log('this.resultForm.form', this.resultForm.form);
        this.resultForm.form[FieldVal] = event.target.value;
        
        console.log('Form:', this.resultForm.form);
        for (var i = 0; i < this.recordInfo.length; i++) {
            if(FieldVal == this.recordInfo[i].name){
                this.recordInfo[i].value =   event.target.value;  
            }
        }
        if(FieldVal == 'Corrective_actions_required__c'){
            if(event.target.value == 'Yes'){
                for (var i = 0; i < this.recordInfo.length; i++) {
                    console.log('Inside', this.recordInfo[i].name);
                    if(this.recordInfo[i].name == 'Corrective_actions_due_date__c'){
                        this.recordInfo[i].hide = false;
                        this.recordInfo[i].required = true;
                        var someDate = new Date();
                        //var numberOfDaysToAdd = 2;
                        var endDate = "", noOfDaysToAdd = 2, count = 0;
                        while(count < noOfDaysToAdd){
                            endDate = new Date(someDate.setDate(someDate.getDate() + 1));
                            if(endDate.getDay() != 0 && endDate.getDay() != 6){
                            //Date.getDay() gives weekday starting from 0(Sunday) to 6(Saturday)
                                count++;
                            }
                        }
                        //someDate.setDate(someDate.getDate() + numberOfDaysToAdd); 
                        someDate = endDate; 
                        someDate = someDate.toISOString();
                        console.log('Some Date Value',someDate);
                        this.recordInfo[i].value = someDate;
                        this.resultForm.form.Corrective_actions_due_date__c = someDate;
                    }else if(this.recordInfo[i].name == 'Corrective_actions__c' || this.recordInfo[i].name == 'Corrective_actions_completed_Date__c'){
                        this.recordInfo[i].hide = false;
                        if(this.recordInfo[i].name == 'Corrective_actions__c')                        
                            this.recordInfo[i].required = true;
                    }else{
                        this.recordInfo[i].value = this.recordInfo[i].value;


                    }
                    
                }
            }else{
                for (var i = 0; i < this.recordInfo.length; i++) {
                    console.log('Inside', this.recordInfo[i].name);
                    if(this.recordInfo[i].name == 'Corrective_actions_due_date__c'){
                        this.resultForm.form.Corrective_actions_due_date__c = null;
                        this.recordInfo[i].value = null;
                        this.recordInfo[i].required = false;
                        this.recordInfo[i].hide = true;
                        
                    } else if(this.recordInfo[i].name == 'Corrective_actions__c' || this.recordInfo[i].name == 'Corrective_actions_completed_Date__c'){
                        this.recordInfo[i].hide = true;
                        this.recordInfo[i].required = false;
                    } 

                }

            }
            this.refreshValues();
           
            
        }

        if(FieldVal == 'Agent__c'){
            console.log('Getmanager');
          
          this.getDetailsOfUser(event.target.value);
        }
  
    }
  
    getDetailsOfUser(userid){
       getManagerID({
                userID: userid
            })
            .then((result) => {
                console.log('result', JSON.stringify(result));
                //var result = JSON.stringify(result);
                console.log('userId', result);
                this.resultForm.form.Line_Manager__c = result.ManagerId;
                for (var i = 0; i < this.recordInfo.length; i++) {
                  console.log('Inside', this.recordInfo[i].name);
                  if(this.recordInfo[i].name == 'Line_Manager__c'){
                      console.log('Inside', result.ManagerId);
                      this.recordInfo[i].value = result.ManagerId;
                  }
              }
              
              console.log('this.ManagerId', result.ManagerId);
                console.log('this.recordInfo', this.recordInfo);
            })
            .catch((error) => {
                console.log('Error', error);
          });
  
   }

   refreshValues() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach((field) => {
                field.clean();
                console.log('field:'+field.fieldName);
                field.value = this.resultForm.form[field.fieldName];
                
            });
        }
        for(var i = 0; i < this.recordInfo.length; i++){
            console.log('this.recordInfo[i].name'+this.recordInfo[i].name+'---this.recordInfo[i].value'+this.resultForm.form[this.recordInfo[i].name]);
            this.recordInfo[i].value = this.resultForm.form[this.recordInfo[i].name];    
        }
    }
  
    get fieldStyle() {
        return (this.showIsChangedRow) ? 'width: 30% !important;' : 'width: 35% !important;'
    }
  
    get operatorStyle() {
        return (this.showIsChangedRow) ? 'width: 20% !important;' : 'width: 25% !important;'
    }
  
    get valueStyle() {
        console.log(" line 107 ~ RuleCriteriaConfigurations ~ getvalueStyle ~ this.showIsChangedRow", this.showIsChangedRow)
        return (this.showIsChangedRow) ? 'width: 25% !important;' : 'width: 30% !important;'
    }
  
    get deleteStyle() {
        return 'width: 5% !important;'
    }
  
    get isChangedStyle() {
        return 'width: 15% !important;'
    }
  
    get isChangedChecked() {
        return this.configurationRow['isChanged'];
    }
  
  
  
  }