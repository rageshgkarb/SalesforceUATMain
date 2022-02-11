import { LightningElement, track, wire, api } from "lwc";
import createForms from "@salesforce/apex/FormDemo.createForms";
import initialise from "@salesforce/apex/FormDemo.initialise";
import newForm from "@salesforce/apex/FormDemo.newForm";
import optionScore from "@salesforce/apex/FormDemo.optionScore";
import getQuestionDetails from "@salesforce/apex/FormDemo.getQuestionDetails";
import dataTypes from "@salesforce/apex/FormDemo.dataTypes";
import saveObservationForm from "@salesforce/apex/FormDemo.saveObservationForm";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


export default class Form_Demo extends NavigationMixin(LightningElement) {
    @track sectionName;
    @track questionName;
    @track questionNumber;
    @track questionType;
    @track tempList =[];
    @track selectedDataType;
    @track options= [];
    @track selectedValue= 'Dropdown';
    @track sameIndex;
    @api formName;
    @api formId;
    @api sectionName;
    @api sectionId;
    @api sectionOrd;
    @track form;
    @track section;
    @track isModalOpen = false;
    @track optionsWithScore= [];
    @track option;
    @track sectionN;
    @track secId;
    @track formmId;
    @track sectionTitle;
    @track showIsChangedRow = false;
    @track fieldList=[];
    @track showRanking = false;
    showCritical = false;
    sectionCriticalScore=0;
    sectionCriticalVal = ''; 
    trueval = true;
    @track deleteList=[];
    showSecCriteria = false;
    @api showCriticals;
    @api sectionCriticalScores;
    @api sectionCriticalVals;
    @api sectionCriticalConditions;
    sectionCriticalCondition = '';
    //@track rankingDetails = [{min:"0", max:"100", value:""}];
    @track rankingDetails = [{value:'',min:0, max:10, minVal:0,maxVal:0,maxMin:0,maxMax:10,showAdd:false,showDel:false}];

    @track options =[

        {"label":"Dropdown","value":"Dropdown"},
        {"label":"Checkbox","value":"Checkbox"},
        {"label":"Text","value":"Text"}
    ];

    connectedCallback() {
        
        console.log('Is this even getting called?');
        //this.dataTypes();     
        
        this.form = this.formName;
        this.sectionN = this.sectionName;
        this.secId = this.sectionId;
        //this.section.Id = this.sectionId;
        this.formmId = this.formId;
        this.sectionOrder = this.sectionOrd;
        this.sectionTitle = 'Question Details';
        this.showCritical = this.showCriticals;
        this.sectionCriticalScore = this.sectionCriticalScores;
        this.sectionCriticalVal = this.sectionCriticalVals;
        this.sectionCriticalCondition = this.sectionCriticalConditions;
        console.log('***this.sectionCriticalCondition :',this.sectionCriticalCondition );
        if(this.sectionCriticalCondition){
            const myObj = JSON.parse(this.sectionCriticalCondition);
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
        
        this.createFormObj();  
        this.initialiseData(); 
       
    }
    @api
    getSectionName(sectionName){

        this.sectionName = sectionName;
        this.sectionTitle = this.sectionName+'-'+'Question Details'
    }

    

    @api
    saveSection(formId,formName){
        this.formId = formId;
        this.formmName = formName;
        this.section.Form_Name__c = formName;
        this.section.Form__c = formId;
         
        this.saveForm();
        //console.log('Save Section ',this.sectionName+'this.sectionOrder',this.sectionOrder);
        //console.log('Save Section this.formId:',this.formId);
        //console.log('Save Section this.formmName:',this.formmName);
        
    }

    createFormObj(){
        newForm()
        .then((result) => {
            console.log('Result',result.Type__c);
            this.section = JSON.parse(JSON.stringify(result));   
            this.section.Section__c = result.Section__c;
            this.section.Type__c = 'Section'; 
            console.log('form:',this.section);          
        })
        .catch((error) => {
        });
    }

    sectionNameHandler(event){
        //this.section.Form_Name__c = this.formmName;
        //this.section.Form__c = this.formmId;
        this.section.Section__c = event.target.value;
        this.section.Type__c = 'Section';
        this.sectionName = event.target.value;
        console.log('this.sectionName',this.sectionName);
        //this.template.querySelector('c-form_-demo').getSectionName(event.target.value);
    }

    sectionOrderHandler(event){
        /*this.form.Form_Name__c = this.formmName;
        this.form.Form__c = this.formmId;
        this.form.Section_Order__c = event.target.value;
        this.form.Section__c = this.sectionName;
        this.form.Type__c = 'Section';*/
        this.sectionOrder = event.target.value;
        this.section.Section_Order__c = event.target.value;
        console.log('this.sectionOrder',this.sectionOrder);

    }

    saveForm(){
        //console.log('check list here ',this.tempList);
        this.section.Section_Critical_Conditions__c  = this.getJsonFor(this.rankingDetails);
        //if(!this.sectionId || this.sectionId.length === 0){
            console.log('Section id:'+this.section.name+'-----'+this.deleteList);
            this.section.Id = this.sectionId
            saveObservationForm({lstForms: this.tempList,section: this.section,deleteList:this.deleteList})
            .then((result) => {
                
                console.log('Result',result);    
                this.tempList = result.forms;
                this.section = result.section;
                const evt = new ShowToastEvent({
                    title: "Section Updated",
                    message: "Sections and Questions Updated",
                    variant: "success"
                });
                this.dispatchEvent(evt);
                //this.navigateToViewPage();
            })
            .catch((error) => {
                console.log('Error'+error)
            });
        //}else{
            

        //}
        
    }

    navigateToViewPage() {
        /*this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://alrayanbank--preprodtes--c.cs110.visual.force.com/apex/observationFormTemplate?id='+this.formId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });*/
        console.log('Navigate',this.formId);
        this.accountHomePageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Observation_Form_Questions__c',
                actionName: 'view',
                recordId:this.formId
            }
        };
        this[NavigationMixin.GenerateUrl](this.accountHomePageRef)
            .then(url => this.url = url);
    }

     dataTypes(){
        dataTypes()
        .then((result) => {
            console.log('data type:',result);
            for(var i=0 ;i<result.length ;i++){
                const option = {
                    label: result[i],
                    value: result[i]
                };
                this.options.push(option);
                
            }
            return this.options;

        })
        .catch((error) => {
        });
    }

    addOptionScoreList(index){
        console.log('addOptionScoreList', index);
        optionScore()
        .then((result) => {
            console.log('result',result);
            
            //this.tempList.push(result);
            
            
            //this.tempList.push(JSON.parse(JSON.stringify(result)));
            console.log('final',this.tempList[index]);
            let optionScore = result;
            
            this.tempList[index].optionScoreList.push(result);
            
            
        })
        .catch((error) => {
        });
    }

    addDummyDataInList(){
        initialise()
            .then((result) => {
                console.log('result',result);
                
                //this.tempList.push(result);
                let quesObj = JSON.parse(JSON.stringify(result));
                quesObj.Form__c = this.formId;
                quesObj.Section1__c = this.sectionId;         
                
                this.tempList.push(quesObj);
                console.log('final',this.tempList);
                for(var i=0;i<this.tempList.length;i++){
                    console.log('optionsList',this.tempList[i].optionScoreList);
                }
                
            })
            .catch((error) => {
            });

    }

    initialiseData(){
       
        if(!this.sectionId || this.sectionId.length === 0){
            console.log('Section Id why',this.sectionId);
            initialise()
            .then((result) => {
                console.log('result',result);
                
                //this.tempList.push(result);
                
                
                this.tempList.push(JSON.parse(JSON.stringify(result)));
                console.log('final',this.tempList);
                for(var i=0;i<this.tempList.length;i++){
                    console.log('optionsList',this.tempList[i].optionScoreList);
                }
                
            })
            .catch((error) => {
            });
        }else{
            console.log('Not Section Id',this.sectionId);
            getQuestionDetails({sectionId: this.sectionId})
                .then((result) => {
                    console.log('result from getquestion:',result);
                    
                    //this.tempList.push(result);
                    
                    
                    this.tempList = JSON.parse(JSON.stringify(result));
                    console.log('final',this.tempList);


                    for(var i=0;i<this.tempList.length;i++){
                        console.log('question Details:'+this.tempList[i].form.Critical__c);
                        console.log('question Details:'+this.tempList[i].form.Critical_Value__c);
                        console.log('optionsList',this.tempList[i].optionScoreList);
                    }
                    
                })
                .catch((error) => {
            });
        }
        
    }

    addquestion(){
        this.addDummyDataInList();        
    }

    checkPaymentType(event) {
        this.sectionName = event.target.value;
        console.log(this.sectionName);
        
        createForms({ sectionName: this.sectionName, questionName : this.questionName, questionNumber : this.questionNumber, questionType : this.questionType })
        .then((result) => {
        
      })
      .catch((error) => {
      });
    }

    removeRow(event){
        console.log('remove',event.target.name);
        var index = event.target.name;
        console.log('index',index);
        console.log('llist ',this.tempList[index].form.Id);

        if(this.tempList[index].form.Id)
            this.deleteList.push(this.tempList[index].form.Id);
        this.tempList.splice(event.target.name, 1);
        
        //delete this.tempList[index];
        /*let tempListForRemoveRow = [];
        for(var i=0;i<this.tempList.length;i++){
            if(i != index){
                tempListForRemoveRow.push(this.tempList[i]);
            }
        }
        this.tempList = tempListForRemoveRow;
        */
    }
    removeScoreRow(event){
        console.log('remove',event.target.name);
        console.log('remove',event.target.dataset.indexc);
        console.log('remove',this.tempList[event.target.name].optionScoreList[event.target.dataset.indexc].optionId);
        if(this.tempList[event.target.name].optionScoreList[event.target.dataset.indexc].optionId)
         this.deleteList.push(this.tempList[event.target.name].optionScoreList[event.target.dataset.indexc].optionId);
        this.tempList[event.target.name].optionScoreList.splice(event.target.dataset.indexc, 1);
        console.log('Delete List',this.deleteList);
        
        
    }
    addScore(event){
        console.log('In Add Score', event.target.name);
        let  index= event.target.name;
        console.log('index in addscore',index);
        this.addOptionScoreList(index);
        
    }

    addRow(event){
        console.log('add',event.target.name);
        this.addDummyDataInList();
    }

    onchangepicklistvalue(event){
        var index = event.target.name;
        if(event.target.value === 'Dropdown'){
            this.sameIndex = event.target.name;
            for(var i=0;i<this.tempList.length;i++){
                if(i == this.sameIndex){
                    this.tempList[i].showPickListField = true;
                }
            }
        }
        else{
            this.sameIndex = event.target.name;
            for(var i=0;i<this.tempList.length;i++){
                if(i == this.sameIndex){
                    this.tempList[i].showPickListField = false;
                }
            }
        }
        this.tempList[index].form.Data_Type__c = event.target.value;       

    }

    

    changeQuestionNumber(event){
        var index = event.target.name;
        console.log('index',index);
        this.tempList[index].form.Question_Number__c = event.target.value;
        
        console.log('this.tempList',this.tempList);
    }

    changeCode(event){
        var index = event.target.name;
        console.log('index',index);
        this.tempList[index].form.Objective__c = event.target.value;
        
        console.log('this.tempList',this.tempList);
    }

    changeGuide(event){
        var index = event.target.name;
        console.log('index',index);
        this.tempList[index].form.Guide__c = event.target.value;
        
        console.log('this.tempList',this.tempList);
    }

    

    changeQuestion(event){
        var index = event.target.name;
        console.log('index',index);
        this.tempList[index].form.Question__c = event.target.value;
        
        console.log('this.tempList',this.tempList);
    }
    changeCriticalValue(event){
        var index = event.target.name;
        console.log('index',index);
        this.tempList[index].form.Critical_Value__c = event.target.value;
        
        console.log('this.tempList',this.tempList);
    }
    secCriticalValChange(event){
        if(this.showCritical)
            this.showCritical = false;
        else
            this.showCritical = true;

        this.section.Critical__c = this.showCritical;

        for(var i=0;i<this.tempList.length;i++){
            this.tempList[i].form.Critical__c = this.showCritical;
            this.tempList[i].showCriticalField = this.showCritical;
        }
        console.log('this.section:',this.section);
    }

    changeSecCriticalValue(event){
        var cValue = event.target.value;
        
        this.section.Critical_Option__c = cValue;
        console.log('this.section:',this.section);
    }

    changeSecCriticalScore(event){
        var cValue = event.target.value;
        
        this.section.Critical_Value__c = cValue;
        console.log('this.section:',this.section);
    }
    criticalValChange(event){
        var index = event.target.name;
        console.log('index',index+' Value:',this.section.Critical__c);
        if(this.tempList[index].showCriticalField)
            this.tempList[index].showCriticalField = false;
        else
            this.tempList[index].showCriticalField = true;


        this.tempList[index].form.Critical__c = this.tempList[index].showCriticalField;

        if(this.section.Critical__c){
            this.tempList[index].showCriticalField = true;
            this.tempList[index].form.Critical__c = true;
        }
            

        

        
        //this.tempList[index].showCriticalField = true;
        
        console.log('this.tempList',this.tempList);

    }
    getdropdown(event){
        var index = event.target.name;
        console.log('index',event.target.value);
        this.tempList[index].form.Picklist_Values__c = event.target.value;
        console.log('this.tempList',this.tempList);
    }
    
    openModal(event) {
        // to open modal set isModalOpen tarck value as true
        console.log('Open New');
        console.log('Open1',event.target.name);
        let index = event.target.name;
        console.log('index',index);
        console.log('Size ',this.tempList[index].optionScoreList.length);
        
        if(this.tempList[index].optionScoreList.length == 0)
            this.addOptionScoreList(index);  
        console.log('Value:',this.tempList[index].optionScoreList[0]);  
        this.tempList[index].showPopup = true;
    }
    closeModal(event) {
        // to close modal set isModalOpen tarck value as false
        console.log('Clsoe');
        let index = event.target.name;
        this.tempList[index].showPopup = false;
        this.isModalOpen = false;
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
        rankingDetails.push({min:"0", max:"100", value:""});

    }

    handleInput(event) {
        this[event.target.name] = event.target.value;
        if (event.target.name === 'minRange' && this.minRange > this.maxRange) { 
            this.minRange = this.maxRange;   
        } else if (event.target.name === 'maxRange' && this.minRange > this.maxRange) {
            this.maxRange = this.minRange;     
        } 
    }
    submitDetails(event) {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        console.log('Submit');
        this.isModalOpen = false;
        let index = event.target.name;
        this.tempList[index].showPopup = false;
    }

    getOptionVal(event){
        //console.log('get option Value');
        //console.log('indexc',event.target.value);
        var index = event.target.name;
        var indexc = event.target.dataset.indexc;
        console.log('indexc',indexc);
        console.log('index',this.tempList[index].length);
        var option =  event.target.value;
        
        

       
        for(var i=0;j<this.tempList[i].optionScoreList.length;j++){
            for(var j=0;j<this.tempList[i].optionScoreList.length;j++){
                console.log('Option Score:',this.tempList[i].optionScoreList[j].option);
                if(this.tempList[i].optionScoreList[j].isCriticalValue){
                    this.tempList[i].form.Critical_Option__c = this.tempList[i].optionScoreList[j].option; 
                    console.log('Right val',this.tempList[index].form.Critical_Option__c);
                }
                    
            }
        }
        this.tempList[index].optionScoreList[indexc].option = option;
        
        
                  
            

        
        for(var i =0;i<this.tempList[index].optionScoreList.length;i++){

            console.log('Value in:',this.tempList[index].optionScoreList[i]);
        }
        
    }

    getcriticalVal(event){
        console.log('get option Value');
        console.log('this.tempList:',this.tempList.length);
        console.log('this.tempList:',this.tempList[0].optionScoreList);
        var index = event.target.name;
        var indexc = event.target.dataset.indexc;
        console.log('indexc',indexc);
        console.log('index',index);
        var option =  event.target.value;

        

        for(var i=0;i<this.tempList.length;i++){
            for(var j=0;j<this.tempList[i].optionScoreList.length;j++){
                console.log('Option Score:',this.tempList[i].optionScoreList[j].option);
                //this.tempList[i].optionScoreList[j].isCriticalValue = false; 
                //this.tempList[index].form.Critical_Option__c = this.tempList[index].optionScoreList[indexc].option;   
            }

        }
        
        if(this.tempList[index].optionScoreList[indexc].isCriticalValue)
            this.tempList[index].optionScoreList[indexc].isCriticalValue = false;
        else{
            this.tempList[index].form.Critical_Option__c = this.tempList[index].optionScoreList[indexc].option;
            this.tempList[index].optionScoreList[indexc].isCriticalValue = true;
        }

        for(var i =0;i<this.tempList[index].optionScoreList.length;i++){

            console.log('Value in:',this.tempList[index].optionScoreList[i]);
        }
        
    }


  
    getScoreVal(event){
        console.log('index',event.target.name);
        console.log('indexc',event.target.value);
        var index = event.target.name;
        var indexc = event.target.dataset.indexc;
        var score =  event.target.value;
        this.tempList[index].optionScoreList[indexc].score = score;
        for(var i =0;i<this.tempList[index].optionScoreList.length;i++){

            console.log('Value in:',this.tempList[index].optionScoreList[i]);
        }
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

     closeRanking(event) {
        // to close modal set isModalOpen tarck value as false
        console.log('Clsoe');
       
        this.showSecCriteria = false;
    }

    openRanking(event) {
        // to open modal set isModalOpen tarck value as true
        console.log('Open New');
        this.showSecCriteria = true;
    }

    addRanking(event){
        console.log('Add Ranking');
        this.rankingDetails[this.rankingDetails.length - 1].showAdd = false;
        this.rankingDetails[this.rankingDetails.length - 1].showDel = false;
        var previousVal = this.rankingDetails[this.rankingDetails.length - 1];
        var nextMin = parseInt(previousVal.maxVal, 10)+parseInt(1,10);  
        this.rankingDetails.push({value:'',min:nextMin, max:10,minVal:nextMin,maxVal:10,maxMin:nextMin,maxMax:10,showAdd:false,showDel:true});

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
            
            if(nextMin != 10){
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


    get fieldStyle(){
        return (this.showIsChangedRow) ? 'width: 10%;padding-left: 20px; !important;' : 'width: 10%; padding-left: 20px; !important;'
      }

      get fieldStyle1(){
        return 'width:5% padding-left: 20px; !important;';

      }

      get largeFieldStyle(){
        return 'width:10% padding-left: 20px; !important;'

      }
    
      get operatorStyle(){
        return (this.showIsChangedRow) ? 'width: 20% !important;' : 'width: 25% !important;'
      }
    
      get valueStyle(){
        console.log(" line 107 ~ RuleCriteriaConfigurations ~ getvalueStyle ~ this.showIsChangedRow", this.showIsChangedRow)
        return (this.showIsChangedRow) ? 'width: 25% !important;' : 'width: 30% !important;'
      }
    
      get deleteStyle(){
        return 'width: 5%;vertical-align: middle;padding-left: 20px; !important;'
      }
    
      get isChangedStyle(){
        return 'width: 15% !important;'
      }
    
      get isChangedChecked(){
        return this.configurationRow['isChanged'];
      }

      
}