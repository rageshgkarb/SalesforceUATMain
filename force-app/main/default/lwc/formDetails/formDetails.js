import { LightningElement, track, wire, api } from "lwc";
import createForms from "@salesforce/apex/FormDemo.createForms";
import getFormDetails from "@salesforce/apex/FormDemo.getFormDetails";
import dataTypes from "@salesforce/apex/FormDemo.dataTypes";
import saveObservationForm from "@salesforce/apex/FormDemo.saveObservationForm";
import Observation_Form_Questions__OBJECT from '@salesforce/schema/Observation_Form_Questions__c';
import newForm from "@salesforce/apex/FormDemo.newForm";
import saveFormApex from  "@salesforce/apex/FormDemo.saveForm";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Observation_Form_OBJECT from '@salesforce/schema/Observation_Form__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';

import { getPicklistValues, getObjectInfos } from 'lightning/uiObjectInfoApi'; 

import OpptyLiObject from '@salesforce/schema/Observation_Form_Questions__c'; 



export default class FormDetails extends NavigationMixin(LightningElement) {
    @track form;
    @track formId;
    @track formName;
    @track questionName;
    @track section=[];
    @track editMode = true;
    @track showSection = false;
    @track fieldList=[];
    @track mandatoryFieldList=[];
    @track showRanking = false;
    @track totalScore = 0;
    @track selectedValues=[];
    @track selectedMandatoryValues=[];
    @track items =[];
    @track picklistValues;
    visible = false;
    calculationMechanism = 'Reduce scores from total score';
    requiredOptions = [];
    @track sendEmail;
     /** Id of record to display. */
     @api recordId;
     @track active;
    
    
    @track rankingDetails = [{value:'',min:0, max:100, minVal:0,maxVal:0,maxMin:0,maxMax:100,showAdd:false,showDel:false}];
    

    connectedCallback() {
       console.log('CallBack',this.recordId); 
       this.createFormObj();
       if(!this.recordId || this.recordId.length === 0){
            this.section.push(1);
       }
    }

   
    createFormObj(){
        if(!this.recordId || this.recordId.length === 0){
            newForm()
            .then((result) => {
                console.log('CallBack',this.recordId); 
                console.log('Result',result.Type__c);
                this.form = JSON.parse(JSON.stringify(result));   
                this.form.Form_Name__c = result.Form_Name__c;
                this.form.Type__c = result.Type__c; 
                
                console.log('form:',this.form);          
            })
            .catch((error) => {
            });
        }else{
            getFormDetails({formId:this.recordId})
            .then((result) => {
                console.log('CallBack',this.recordId); 
                console.log('Result kya bhai',result);
                this.section = JSON.parse(JSON.stringify(result));  
                console.log('Result section',this.section.length);
                
                if(this.section.length > 0){
                    //this.form.id = this.section[0].Form__c;
                    this.form = this.section[0].Form__r;
                    this.form.Form_Name__c = this.section[0].Form__r.Form_Name__c;
                    this.formName= this.section[0].Form__r.Form_Name__c;
                    console.log('this.section[0].Form__r.Calculation_Type__c***:',this.section[0].Form__r.Calculation_Type__c);
                    if(this.section[0].Form__r.Calculation_Type__c)
                        this.calculationMechanism = this.section[0].Form__r.Calculation_Type__c;
                    this.form.Type__c = 'Form'; 
                    this.totalScore = this.section[0].Form__r.Total_Score__c;
                    
                    const items = [];
                     if(this.section[0].Form__r.Fields_to_display__c){
                        const myArr = this.section[0].Form__r.Fields_to_display__c.split(","); 
                        for(var i=0;i<myArr.length;i++){
                            this.selectedValues.push(myArr[i]);
                        }
                     }
                
                    
                    if(this.section[0].Form__r.Mandatory_Fields__c){
                        const myArr1 = this.section[0].Form__r.Mandatory_Fields__c.split(",");
                         for(var i=0;i<myArr1.length;i++){
                            this.selectedMandatoryValues.push(myArr1[i]);
                    
                        }
                    }

                    this.sendEmail =  this.section[0].Form__r.Send_Email__c;    
                    this.active =  this.section[0].Form__r.Active__c;         
                    //this.fieldList.push(Object.entries(data.fields)[i][1].apiName);
                    
                    for(var i=0;i<this.fieldList.length;i++){
                        if(this.selectedValues.includes(this.fieldList[i].value)){
                        
                            this.mandatoryFieldList.push(this.fieldList[i]);

                        }
                    }
                    

                    
                    const myObj = JSON.parse(this.section[0].Form__r.Form_Result__c);
                    console.log('****',myObj);
                    if(myObj.resultList.length > 0){
                        this.rankingDetails = [];
                        let nextMin =0;
                        for (let i = 0; i < myObj.resultList.length; i++){
                            
                            let robj = myObj.resultList[i];

                            console.log('inside ranking:',nextMin);
                            this.rankingDetails.push({value:robj.value, min:nextMin, max:100, minVal:nextMin,maxVal:robj.max,maxMin:nextMin,maxMax:100,showAdd:false,showDel:false});
                            console.log('inside ranking Details:',this.rankingDetails[0]);

                            if(nextMin != 100)
                            nextMin = parseInt(robj.max, 10)+1;

                        }
                    }
                }
                console.log('Ranking Details:',this.rankingDetails);          
            })
            .catch((error) => {
            });
               
        }
        
    }

    sendEmailChange(event){
        
        if(this.sendEmail){
            this.form.Send_Email__c = false;
          
        }else{
            this.form.Send_Email__c = true;  
        }
    }

    activeChange(event){
        
        if(this.active){
            this.form.Active__c = false;
          
        }else{
            this.form.Active__c = true;  
        }
    }


    handleValueChange(event){

        console.log('handlevaluechange',JSON.stringify(event.details));
    }

    get calculationMechoptions() {
        return [
            { label: 'Reduce scores from total score', value: 'Reduce scores from total score' },
        ];
    }

    handleCalculationChange(event) {
        this.calculationMechanism = event.detail.value;
        //this.form.Calculation_Type__c = event.detail.value;
        console.log('Calculation Mech',event.detail.value);
    }

    @wire(getObjectInfo, { objectApiName: Observation_Form_OBJECT })
    objInfo({ data, error }) {
        console.log('Values===>',data);
        if (data) {
            
            if (data.fields) {
                for (var i = 0; i < Object.entries(data.fields).length; i++) {
                    //console.log('Check Label',Object.entries(data.fields)[i][1].apiName);
                    if(Object.entries(data.fields)[i][1].updateable || Object.entries(data.fields)[i][1].apiName == 'Name'){
                        this.fieldList.push({
                            label: Object.entries(data.fields)[i][1].label,
                            value: Object.entries(data.fields)[i][1].apiName
                        });
                        //this.fieldList.push(Object.entries(data.fields)[i][1].apiName);
                        if(this.selectedValues.includes(Object.entries(data.fields)[i][1].apiName)){
                            
                             this.mandatoryFieldList.push({
                                label: Object.entries(data.fields)[i][1].label,
                                value: Object.entries(data.fields)[i][1].apiName
                            });

                        }

                    }
                   
                }
            }
            //this.requiredOptions.push('Form_Name__c');
            //this.selectedValues.push('Form_Name__c');
            //this.selectedValues = this.items;
            console.log('Values===>',this.mandatoryFieldList);
            
        }



    }
    handleChangeFields(e) {
        console.log('****Questions 2:',this.mandatoryFieldList);
        this.value = e.detail.value;
        this.form.Fields_to_display__c =  ''+e.detail.value;
            console.log('****Questions 2:',this.form.Fields_to_display__c);
            this.mandatoryFieldList = [];
            e.detail.value.forEach(option => {
                let currentOption = this.fieldList.find( o => o.value === option);
                console.log('***',currentOption);
                
                this.mandatoryFieldList.push({
                            label: currentOption.label,
                            value: currentOption.value
                });
            });

       
        console.log('****Questions 2:',this.mandatoryFieldList);
    }

    handleMandatoryChangeFields(e) {
        console.log('****Questions 2:',this.mandatoryFieldList);
        this.value = e.detail.value;
        this.form.Mandatory_Fields__c =  ''+e.detail.value;
    }
    

    formNameHandler(event){
        this.form.Form_Name__c = event.target.value;
        this.form.Type__c = 'Form';
        this.formName = event.target.value;
        console.log('formName',this.form.Form_Name__c);
    }
    scoreHandler(event){
        this.totalScore = event.target.value;
        this.form.Total_Score__c =  this.totalScore;
        console.log('formName',this.form.Form_Name__c);
    }
    
    addsection(event){
        console.log('add',event.target.name);
        console.log('Sections',this.section);
        let sectionObj = {Section_Order__c:"", Form__c:this.formId, Section__c:"",id:""}; 
        this.section.push(sectionObj);    
        
    }
    saveFormtoDatabase() {
        
            this.form.Form_Result__c  = this.getJsonFor(this.rankingDetails);
            console.log('Save Form',this.form);
            saveFormApex({formObj: this.form})
            .then((result) => {
                console.log('SaveForm',result);
                this.form = result; 
                this.form.Id= result.Id; 
                //this.showSection = true;
            // this.editMode = false;  
                this.formId = result.Id; 
                if(this.formId){
                    console.log('Inside FormId');
                    this.template.querySelectorAll('c-form_-demo').forEach(element => {
                        element.saveSection(this.formId,this.formName);
                });
                this.navigateToViewPage(); 
                }
                
            })
            .catch((error) => {
                console.log('Error:',error);
            });
        
    }

    validate(){
        console.log('validate');
        this.toastMessage = '';
        if(!this.form.Form_Name__c){
            this.toastMessage = 'Form Name is Mandatory';
        }else if(!this.form.Total_Score__c || this.form.Total_Score__c <1){
            this.toastMessage = 'Total Score should be greater than 0';
        }else if(this.rankingDetails.length <2){
            this.toastMessage = 'Please fill in overall result details by clicking on Add Result Details Button';

        }
        console.log('Toast Message:',this.toastMessage);
        if(this.toastMessage != ''){
            
            this.visible = true;
            let delay = 1000
            setTimeout(() => {
                this.visible = false;
            }, delay );
                    
            return false;
        }
        return true;

    }

    navigateToViewPage() {
        console.log('Navicgation',this.formId);

        window.location.assign('/apex/observationFormTemplate?id='+this.formId);
        /*this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://alrayanbank--preprodtes.my.salesforce.com/apex/observationFormTemplate?id='+this.formId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });*/
        console.log('Navigate',generatedUrl);
       /*this.accountHomePageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Observation_Form_Questions__c',
                actionName: 'view',
                recordId:this.formId
            }
        };
       this[NavigationMixin.GenerateUrl](this.accountHomePageRef)
            .then(url => this.url = url);*/
            
           /*  this[NavigationMixin.Navigate]({
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__observationFormTemplateComp"
                },
                state: {
                    c__recordId : this.recordId,
                    
                }
            }); */
    }

    getJsonFor(rankList){
        var i =0;
        var jsonFormat =  '{"resultList":[';
        for(i;i<this.rankingDetails.length;i++){
            jsonFormat+= '{"Min":"'+ this.rankingDetails[i].minVal+'","max":"'+this.rankingDetails[i].maxVal+'","value":"'+this.rankingDetails[i].value+'"},';
        }

        jsonFormat = jsonFormat.substring(0, jsonFormat.length - 1);
        jsonFormat +=']}';
        return jsonFormat;
    }
    get sectionClass(){
        if(this.section.length > 0)
            return 'slds-align_absolute-center';
        else
            return 'slds-align_absolute-left'; 

    }
    saveForm(){
        if(this.validate()){
            console.log('Inside Save');
            this.saveFormtoDatabase();
            //this.navigateToViewPage();
        }

    }
    editForm(){
        this.editMode = true;

    }

    closeRanking(event) {
        // to close modal set isModalOpen tarck value as false
        console.log('Clsoe');
       
        this.showRanking = false;
    }

    openRanking(event) {
        // to open modal set isModalOpen tarck value as true
        console.log('Open New');
        this.showRanking = true;
    }

    addRanking(event){
        console.log('Add Ranking');
        this.rankingDetails[this.rankingDetails.length - 1].showAdd = false;
        this.rankingDetails[this.rankingDetails.length - 1].showDel = false;
        var previousVal = this.rankingDetails[this.rankingDetails.length - 1];
        var nextMin = parseInt(previousVal.maxVal, 10)+parseInt(1,10);  
        this.rankingDetails.push({value:'',min:nextMin, max:100,minVal:nextMin,maxVal:100,maxMin:nextMin,maxMax:100,showAdd:false,showDel:true});

    }

    removeRanking(event){

        var index = event.target.id;
        
        index = index.substring(0, index.indexOf('-'));
        console.log('index',index);
        if(index > 0){
            this.rankingDetails.splice(index,1);
            this.rankingDetails[index-1].showAdd = true;
            if(this.rankingDetails.length > 1)
            this.rankingDetails[index-1].showDel = true;
        }
        
    }

    getResultValue(event){
        var val = event.target.value;
        var index = event.target.name;
        //index = index.substring(0, index.indexOf('-'));
        console.log('Val',val);
        this.rankingDetails[index].value = val;

    }

    handleInput(event) {
        var val = event.target.value;
        var index = event.target.id;
        
        index = index.substring(0, index.indexOf('-'));
        console.log('indexval:'+index);
        console.log('val:'+val);
        if (event.target.name === 'minRange') { 
            this.rankingDetails[index].minVal = val;  
            this.rankingDetails[index].maxMin = val;
            if(val > this.rankingDetails[index].maxVal)
            this.rankingDetails[index].maxVal = val;
        } else if (event.target.name === 'maxRange') {
            this.rankingDetails[index].maxVal = val; 
            if(index == (this.rankingDetails.length -1) )
            this.rankingDetails[index].showAdd = true;    
        } 
        var i=parseInt(index, 10)+1;
        console.log('i Val:'+this.rankingDetails[index].maxVal);
        var nextMin = this.rankingDetails[index].maxVal;
        for(i;i<this.rankingDetails.length;i++){
            console.log('i Val:'+i);
            
            if(nextMin != 100){
                this.rankingDetails[i].minVal = parseInt(nextMin, 10)+parseInt(1,10);  
                this.rankingDetails[i].maxMin = parseInt(nextMin, 10)+parseInt(1,10); 
            }else{
                this.rankingDetails[i].minVal = nextMin;
                this.rankingDetails[i].maxMin = nextMin;
            }
            
              
            
            if(this.rankingDetails[i].maxVal  < this.rankingDetails[index].maxVal){
                this.rankingDetails[i].maxVal = this.rankingDetails[index].maxVal;  
                //this.rankingDetails[i].maxMax  = this.rankingDetails[index].maxVal;
            }

            if(this.rankingDetails[i].maxVal  < this.rankingDetails[i].minVal){
                this.rankingDetails[i].maxVal = this.rankingDetails[i].minVal;  
                //this.rankingDetails[i].maxMax  = this.rankingDetails[i].minVal;
            }
            nextMin = this.rankingDetails[i].maxVal;
        }
    }
}