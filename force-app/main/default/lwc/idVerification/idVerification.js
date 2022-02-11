import {
    LightningElement,
    track,
    wire,
    api
  } from "lwc";
  import fetchData from "@salesforce/apex/idVerification_Controller.returnData";
  import fetchAccountData from "@salesforce/apex/idVerification_Controller.returnAccount";
  import createAlert from "@salesforce/apex/idVerification_Controller.createAlert";

export default class IdVerification extends LightningElement {
    siteURL;
    displayDetails = false;
    @api recordId;
    @api outbound;
    securityType;
    questions = [];

    section1 = [];

    section2 = [];
    accountdetails;
    @track outbounddisplay =false;
    securityMessage = '';

    @track overallResult = {red:false,value:'Pass',secuityStatus:''}
    
    @track accountSpecific = {available:false,question:'Account Specific Question',value:'',showButton:false};

    // datatable columns with row actions
    @track columns = [
        {
            label: 'Name',
            fieldName: 'url',
            sortable: "true",
            type:"url",
            typeAttributes:{
                label:{fieldName:'Name'},
                target:'_blank',
                tooltip:'Click here to open opportunity in new tab'
            }

        }, {
            label: 'Seller',
            fieldName: 'seller',
            sortable: "true"
        }, {
            label: 'Division',
            fieldName: 'User_IBB_Division__c',
           
            sortable: "true"
        }, {
            label: 'Branch',
            fieldName: 'User_Branch__c',
            sortable: "true"
        },
    ];
    @track data = [];
    @track sortBy;
    @track sortDirection;

    connectedCallback() {
        
        this.siteURL = '/apex/IdVerification?recId=' + this.recordId;
        console.log('Record Id',this.recordId);
        console.log('outbound',this.outbound);
        this.outbounddisplay =  (this.outbound === 'true');
        console.log('outbounddisplay',this.outbounddisplay);
        
        this.fetchDataFromClass();
        this.fetchAccountDetails();

    }
    get appealOptions(){
        return [
            { label: 'Pass', value: 'Pass' },
            { label: 'Fail', value: 'Fail' },
            { label: 'Authourized', value: 'Authourized' }
           
        ];
    }

    fetchDataFromClass() {
        fetchData({})
            .then((result) => {
                console.log('result', JSON.stringify(result));
                this.questions = result;

                for (var i = 0; i < this.questions.length; i++) {
                    if(this.outbounddisplay){
                        if(this.questions[i].Available_for_Outbound__c){
                            this.section1.push(this.questions[i]);
                        }
                    }else{
                        if(this.questions[i].Section_2__c)
                            this.section2.push(this.questions[i]);
                        else
                        this.section1.push(this.questions[i]);
                    }
                    
                }
                
            }).catch((error) => {
                console.log('Error', error);
            });
    }

    fetchAccountDetails() {
        fetchAccountData({accountId: this.recordId})
            .then((result) => {
                console.log('result', JSON.stringify(result));
                this.accountdetails = result;
                var oppList = [];
                oppList = this.accountdetails[0].Opportunities;
                if(this.accountdetails && oppList){
                    for (var index in oppList) {
                        for(var key in oppList[index]){
                            if(key == 'Seller__r'){
                                oppList[index].seller = oppList[index][key].Name;
                            }if(key == 'Id'){
                                oppList[index].url = '/'+oppList[index].Id;    
                            }
                            console.log('Key:',key);
                            console.log('Value:',oppList[index][key]);
                        }
                        this.data.push(oppList[index]);
                    }
                }
                
                
                
            }).catch((error) => {
                console.log('Error', error);
            });
    }

     
      handleSection1Change(event){
          console.log('****',event.target.name);
          console.log('****',event.target.value);
          var index = event.target.name;
          this.section1[index].value = event.target.value;
          console.log('**this.section1[index].value**',this.section1[index].value);
          this.scoreCalculator();
      }

      handleSection2Change(event){
        console.log('****',event.target.name);
        var index = event.target.name;

        this.section2[index].value = event.target.value;
        this.scoreCalculator();
        
    }
    handleAccountSpecificChange(event){
        this.accountSpecific.value = event.target.value;
        this.scoreCalculator();    
    }

    scoreCalculator(){
        var d = new Date();
        this.accountSpecific.available = false;
         this.securityMessage = 'Security Failed on '+d.toLocaleString()+' for questions: ';
         console.log('**Score Calculator**');
          var count = 0;
          var answerCount = 0;
          var requiredAnswer = 0;
          this.overallResult.secuityStatus = 'Provide Outcome for available question'
          console.log('****Length:',this.section1.length);

          for (var i = 0; i < this.section1.length; i++) {
              console.log(count);
            if(this.section1[i].available){
                requiredAnswer = requiredAnswer+1;    
            

                if(this.section1[i].value != '' && this.section1[i].value != null){
                    answerCount =  answerCount+1;    
                }
                console.log('****Inside Loop:',this.section1[i].value+'****',this.section1[i].Question__c);

                if(this.section1[i].value == 'Fail'){
                    count = count+1;
                    this.overallResult.red = true;
                    this.overallResult.value = 'Fail';
                    this.overallResult.secuityStatus = 'Security Fail';
                    this.securityMessage += this.section1[i].Question__c+','; 
                }
            }
          }

          console.log('count:',count);
          console.log('answerCount:',answerCount);
          console.log('requiredAnswer:',requiredAnswer);
          
          if(this.overallResult.secuityStatus != 'Security Fail'){
            this.overallResult.red = false;
            this.overallResult.value = 'Pass';
            if(requiredAnswer > answerCount){
                this.overallResult.secuityStatus = 'Provide Outcome for available question';
            }else{
                this.overallResult.secuityStatus = 'Security Pass'; 
            }       
          }
          console.log('this.overallResult:',this.overallResult);

        count = 0;
        answerCount = 0;
        requiredAnswer = 0;
        
            console.log('Inside section 2');
            for (var i = 0; i < this.section2.length; i++) {
                console.log('****Inside Loop Section 2:',this.section2[i].value+'****',this.section2[i].Question__c);
                if(this.section2[i].available){
                    requiredAnswer = requiredAnswer+1;    
               
    
                    if(this.section2[i].value != '' && this.section2[i].value != null){
                        answerCount =  answerCount+1;    
                    }
        
                    if(this.section2[i].value == 'Fail'){
                        count = count+1;
                        this.securityMessage += this.section2[i].Question__c+',';
                    
                    }
                }
            }
            if(answerCount == 2){
                for (var i = 0; i < this.section2.length; i++) {
                    if(!(this.section2[i].value != '' && this.section2[i].value != null)){
                        this.section2[i].available = false;
                    }    
                }
            }
        if(this.overallResult.secuityStatus == 'Security Pass'){
            console.log('count:',count);
            console.log('answerCount:',answerCount);
            console.log('requiredAnswer:',requiredAnswer);
            if(count >=1){
              
                this.overallResult.red = true;
                this.overallResult.value = 'Pass';
                this.overallResult.secuityStatus = 'Proceed with Account Specific Question';
                this.accountSpecific.available = true;
                
            }else{
                console.log('this.accountSpecific.value Before:',this.accountSpecific.value);
                this.accountSpecific.value =''; 
                console.log('this.accountSpecific.value Before:',this.accountSpecific.value);   
            }
    
            if(count <1){
                this.overallResult.red = false;
                this.overallResult.value = 'Pass';
                if(requiredAnswer > answerCount){
                    this.overallResult.secuityStatus = 'Provide Outcome for available question';
                }else{
                    this.overallResult.secuityStatus = 'Security Pass'; 
                }              
            }
            if(this.accountSpecific.available){
                console.log('this.accountSpecific.value:',this.accountSpecific.value);
            
                if(this.accountSpecific.value == 'Fail'){
                    this.overallResult.red = true;
                    this.overallResult.value = 'Fail';
                    this.overallResult.secuityStatus = 'Security Fail';
                    this.securityMessage += 'Account Specific Question';    
                }else if(this.accountSpecific.value && this.accountSpecific.value != 'Fail'){
                    this.overallResult.red = false;
                    this.overallResult.value = 'Pass'; 
                    this.overallResult.secuityStatus = 'Security Pass';    
                }
            }
        }
        

        if(this.securityMessage.endsWith(',')){
            this.securityMessage = this.securityMessage.slice(0, -1); 
        }

        if(this.overallResult.secuityStatus == 'Security Fail' || this.overallResult.secuityStatus == 'Security Pass'){
            this.overallResult.showButton = true;
        }else{
            this.overallResult.showButton = false;
        }
    
        
    }

    saveForm(){
        if(this.overallResult.secuityStatus == 'Security Fail'){
            createAlert({accountId: this.recordId,alertmessage:this.securityMessage})
                .then((result) => {
                    this.navigateToViewPage();  
                }).catch((error) => {
                    console.log('Error', error);
                });
        }else{
            this.navigateToViewPage();
        }

    }

    navigateToViewPage() {
        console.log('Navicgation',this.form);
        if(this.overallResult.secuityStatus == 'Security Fail')
            window.location.assign('/apex/AccountViewingReason?id='+this.recordId+'&sfdc.override=1&securitycheck=fail');
        else    
            window.location.assign('/apex/AccountViewingReason?id='+this.recordId+'&sfdc.override=1&securitycheck=Pass');  
      }

      setsecurity(event){
        var verificationType =  event.target.id;
        var verificationType1 = verificationType.substr(0, verificationType.indexOf('-')); 
        console.log('Secuirty Called'+verificationType1);
        var name = event.target.value;
        console.log('Name:'+name);
        this.displayDetails = true;

        if(verificationType1 == 'ApplicationVerification'){
            this.securityType = 'Application Security';
        }else if(verificationType1 == 'PSNVerified'){
            this.securityType = 'PSN Verifed';
        }else if(verificationType1 == 'ManualPSN'){
            this.securityType = 'Manual PSN';
        }else if(verificationType1 == 'ManualVerification'){
            this.securityType = 'Manual Security';
            this.accountSpecific.available = false;
        }else if(verificationType1 == 'Outbound'){
            this.securityType = 'Outbound Verification';
            //this.accountSpecific.available = true;
        }

        for (var i = 0; i < this.section1.length; i++) {
            console.log('this.section1[i].Field_Api__c:',this.section1[i].Field_Api__c);
            console.log('this.accountdetails:',this.accountdetails[0][this.section1[i].Field_Api__c]);

            if(this.accountdetails && this.accountdetails[0] && this.section1[i].Field_Api__c){
                if(this.section1[i].Field_Api__c && this.section1[i].Field_Api__c.includes(',')){
                    var splitList = this.section1[i].Field_Api__c.split(',')
                    if(splitList.length > 0){
                        this.section1[i].fieldValue = '';
                        for (var j = 0; j < splitList.length; j++) {
                            if(this.accountdetails[0][splitList[j]])
                            this.section1[i].fieldValue += this.accountdetails[0][splitList[j]] + '\n';
                        }
                            
                    }
                }else if( this.accountdetails[0][this.section1[i].Field_Api__c]){
                    this.section1[i].fieldValue =   this.accountdetails[0][this.section1[i].Field_Api__c]; 
                }
                
            }
            if(this.section1[i].Available_for_Manual_PSN__c && verificationType1 == 'ManualPSN'){
                this.section1[i].available = true; 
            }

            else if(this.section1[i].Available_for_Manual_Security__c && verificationType1 == 'ManualVerification'){
                this.section1[i].available = true; 
            }
            else if(this.section1[i].Available_for_PSN_Verified__c  && verificationType1 == 'PSNVerified'){
                this.section1[i].available = true; 
            }
            else if(this.section1[i].Available_for_Application_Security__c  && verificationType1 == 'ApplicationVerification'){
                this.section1[i].available = true; 
            }else if(this.section1[i].Available_for_Outbound__c   && verificationType1 == 'outbound'){
                this.section1[i].available = true; 
            }else{
                this.section1[i].available = false;
            } 
        }
        for (var i = 0; i < this.section2.length; i++) {
            console.log('this.section2[i].Field_Api__c:',this.section2[i].Field_Api__c);
            console.log('this.accountdetails:',this.accountdetails[0][this.section2[i].Field_Api__c]);

            if(this.accountdetails && this.accountdetails[0] && this.section2[i].Field_Api__c){
                if(this.section2[i].Field_Api__c && this.section2[i].Field_Api__c.includes(',')){
                    var splitList = this.section2[i].Field_Api__c.split(',')
                    if(splitList.length > 0){
                        this.section2[i].fieldValue = '';
                        for (var j = 0; j < splitList.length; j++) {
                            if(this.accountdetails[0][splitList[j]])
                                this.section2[i].fieldValue += this.accountdetails[0][splitList[j]] + '\n';
                        }
                            
                    }
                }else if( this.accountdetails[0][this.section2[i].Field_Api__c]){
                    this.section2[i].fieldValue =   this.accountdetails[0][this.section2[i].Field_Api__c]; 
                }
                
            }
            if(this.section2[i].Available_for_Manual_PSN__c && verificationType1 == 'ManualPSN'){
                this.section2[i].available = true; 
            }

            else if(this.section2[i].Available_for_Manual_Security__c && verificationType1 == 'ManualVerification'){
                this.section2[i].available = true; 
            }
            else if(this.section2[i].Available_for_PSN_Verified__c  && verificationType1 == 'PSNVerified'){
                this.section2[i].available = true; 
            }
            else if(this.section2[i].Available_for_Application_Security__c  && verificationType1 == 'ApplicationVerification'){
                this.section2[i].available = true; 
            }else if(this.section1[i].Available_for_Outbound__c   && verificationType2 == 'outbound'){
                this.section1[i].available = true; 
            }else{
                this.section2[i].available = false;
            } 
        }
        this.scoreCalculator();
      }

      handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        // serialize the data before calling sort function
        let parseData = JSON.parse(JSON.stringify(this.data));

        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };

        // cheking reverse direction 
        let isReverse = direction === 'asc' ? 1: -1;

        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.data = parseData;

    }
}