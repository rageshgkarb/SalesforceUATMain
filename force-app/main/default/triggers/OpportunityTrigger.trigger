/* ----------------------------------------------------------------------------------------------------------- */
/* C0247    FTD ISA                                                                                            */
/* ----------------------------------------------------------------------------------------------------------- */
/* C0728    DSX Standard Expected Documents                                                                    */
/* ----------------------------------------------------------------------------------------------------------- */
/* C0741    DSX fix                                                                                            */
/* ----------------------------------------------------------------------------------------------------------- */


trigger OpportunityTrigger on Opportunity (after insert, after update, before insert, before update) 
{
    if (Trigger_Helper.IgnoreTrigger('Opportunity'))
    {
        system.debug ('Ignoring Trigger ...');
        return;
    }
    /*
    if(trigger.isInsert && trigger.isBefore)
    {
        User externalUser = [Select u.Name, u.Id From User u where name = 'external user'];
        User user = [Select u.Name, u.Id From User u where name = 'ext ext'];
        if(externalUser != null && user != null)
        {
            for (Opportunity opp : trigger.new){        
                if(opp.OwnerId == externalUser.Id)
                {               
                    opp.OwnerId = user.id;
                }
            }           
        }
    }
    */
    /*
    if(trigger.isBefore)
    {
        for (Opportunity opp : trigger.new){
            String val = 'Yes';
        
            if(opp.No_of_Applicants_List__c.toLowerCase().contains(  'new'))        val='';     
            if(opp.Location_of_Lead_Provider__c.toLowerCase().contains('head office'))val='';
            
            IBB_Product__c prod = [Select u.name, u.Id From IBB_Product__c u where id = :opp.IBB_Product__c  ];
            if(!prod.name.toLowerCase().contains(  'current'))val='';           
            
            if(opp.StageName == 'Account Refered')val='';
         
         
         
            if(val == 'Yes')
            {   
            Account acc = [Select u.Ack_Form_Needed__c, u.Id From account u where id = :opp.AccountId  ];
            acc.Ack_Form_Needed__c = 'Yes';
            update acc;
            }                       
        }
    }
    */
    
    
    //LB - disable FORCASTING
    /*
    //  Build up map of Opportunity Stage Forecast mappings
    Map<String, OpportunityStage> oppStagesMap = new Map<String, OpportunityStage>();
    List<OpportunityStage> opportunityStages = [
        SELECT MasterLabel, ForecastCategory
        FROM OpportunityStage
    ];
    for (OpportunityStage stage : opportunityStages) {
        oppStagesMap.put(stage.MasterLabel, stage);
    }
    
    //  A list of all the open Opportunities
    List<Opportunity> openOpportunities = new List<Opportunity>();
    //  A list of all the HPP Statuses
    Set<String> hppStatuses = new Set<String>();
    
    if (Trigger.isBefore) {
        for (Opportunity opp : trigger.new) {
            OpportunityTriggerMethods.setAck(opp);
            
            if (Trigger.isInsert || Trigger.isUpdate) {
                //  Check for open opportunities
                if (!opp.IsClosed) {
                    //  ...which are new or have had the HPP Status updated
                    if (Trigger.isInsert || (opp.Status_HPP_CAA__c != Trigger.oldMap.get(opp.Id).Status_HPP_CAA__c)) {
                        openOpportunities.add(opp);
                        
                        if (String.isNotBlank(opp.Status_HPP_CAA__c)) {
                            hppStatuses.add(opp.Status_HPP_CAA__c);
                            
                            //  Set the Forecast Tolerance Date
                            String hppStatus = (opp.Status_HPP_CAA__c.length() > 38) ? opp.Status_HPP_CAA__c.substring(0, 38) : opp.Status_HPP_CAA__c; 
                            HPPStatusTolerances__c statusTolerance = HPPStatusTolerances__c.getValues(hppStatus);
                            if (statusTolerance != null) {
                                Integer toleranceDays = Integer.valueOf(statusTolerance.ToleranceDuration__c);
                                opp.ForecastToleranceDate__c = Date.today().addDays(toleranceDays);
                                
                                if (opp.ForecastCategoryName == 'Omitted') {
                                    //  Set the Forecast Category
                                    if (oppStagesMap.containsKey(opp.StageName)) {
                                        opp.ForecastCategoryName = oppStagesMap.get(opp.StageName).ForecastCategory;
                                    }
                                }
                            }
                        }
                    }
                    
                    //  Logic moved to batch apex job
                    //  ...which are beyond the Forecast Tolerance Date
                    //if (Trigger.isUpdate && (opp.ForecastToleranceDate__c < Date.today())) {
                    //    opp.ForecastToleranceDateElapsed__c = true;
                    //    opp.ForecastCategoryName = 'Omitted';
                    //}
                    
                }
            }
        }
    }
    
    if (!openOpportunities.isEmpty()) {
        //  Update the open Opportunity records with forecasting data
        OpportunityForecastTriggerHandler forecastHandler = 
            new OpportunityForecastTriggerHandler(openOpportunities, hppStatuses);
    }
    */
    
    /*
    if(trigger.IsBefore)
    {
        if(trigger.IsUpdate)
        {
            try{
                List<String> oppIds = new List<String>();
                
                system.debug('Check ' + trigger.new.size() + ' records');
                for(Integer i = 0; i < trigger.new.size();i++) {
                    
                    String before = trigger.new[i].Stagename;
                    String after = trigger.old[i].Stagename;
                    
                    system.debug('Before ' + before + ' After ' + after);
                    
                    if(!before.equalsIgnoreCase(after))
                    {
                        oppIds.add(trigger.new[i].id);
                    }
                }
                system.debug('updating ' + oppIds.size() + ' records');
                if(oppIds.size() > 0)
                {
                    ForecastingCalculation.Calculate(oppIds);
                }
            }
            catch(Exception e){}
            
        }
    }
    */
    
    if(trigger.isBefore)
    {
        list<opportunity> sellerUpdateList = new list<opportunity>();
        Map <String,Schema.RecordTypeInfo> recordTypes = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName();
        list<Holiday> holidayList = [Select StartTimeInMinutes,Name, activityDate From Holiday];
        
       
        for (Opportunity opp : trigger.new)
        {     
            
            opp.IsEligibleReason__c =  OpportunityTriggerMethods.UpdateEligibility(opp);   
            if(opp.IsEligibleReason__c == '')
            {               
                opp.IsEligible__c = 'Yes';
            }
            else
            {
                opp.IsEligible__c = 'No';
            } 
            dateTime startDate = trigger.isInsert?system.now():opp.createdDate;
            
            if(Trigger.isInsert || (trigger.isUpdate && (opp.X1st_Care_Call__c != trigger.oldMap.get(opp.id).X1st_Care_Call__c || opp.X2nd_Care_Call__c  != trigger.oldMap.get(opp.id).X2nd_Care_Call__c  || opp.X3rd_Care_Call__c != trigger.oldMap.get(opp.id).X3rd_Care_Call__c ))){
            
                opp.X1st_Care_Call__c = date_Utility.addDaysExcludingWeekendsHolidays(startDate,10,holidayList);
                opp.X2nd_Care_Call__c = date_Utility.addDaysExcludingWeekendsHolidays(startDate,20,holidayList);
                opp.X3rd_Care_Call__c = date_Utility.addDaysExcludingWeekendsHolidays(startDate,30,holidayList);
            } 
            
            if(trigger.isInsert){
             try{
                 Id liabilitiesRecordId = recordTypes.get('Liabilities Opportunities').getRecordTypeId();
                 Id caaEligibleRecordId = recordTypes.get('CAA Eligibility').getRecordTypeId();
            
                    
                    if(opp.RecordTypeId == liabilitiesRecordId || opp.RecordTypeId == caaEligibleRecordId ){
                        sellerUpdateList.add(opp);        
                    }
                }catch(exception e){}      
            }              
        }  
        if(sellerUpdateList.size() > 0){
            OpportunityTriggerMethods.updateSellerRoundRobin(sellerUpdateList);
        }
        
    }
    
    
    //Removed rectype finds to bring down SOQL usage
    // RecordType hppRecord = [select r.Id from RecordType r where r.Name = 'HPP Opportunities'];
    // RecordType liabilitiesRecord = [select r.Id from RecordType r where r.Name = 'Liabilities Opportunities'];
    String ProfileId = UserInfo.getProfileId();
    String ProfileName = null;
    if (ProfileId != null)
    {
    //  Profile usrProfile = [SELECT Id, Name from Profile WHERE Id =:ProfileId LIMIT 1];
    //  ProfileName = usrProfile.Name;
    }  
    //if (ProfileName != 'System Administrator')
    //  return;
    Map<Id, IBB_Product__c> productMap = new Map<Id, IBB_Product__c>();
    if(trigger.isUpdate)
        {
            //FieldAuditing.trackField('Opportunity', trigger.oldMap, trigger.newMap);
            productMap = OpportunityTriggerMethods.productMap; //new Map<Id, IBB_Product__c>([select Id, Type_of_Product__c from IBB_Product__c]);
        }
                                                                
    if(trigger.isBefore)
    {
        if(trigger.isUpdate)
        {
            //Trigger_Helper.Audit('Opportunity',trigger.oldMap, trigger.newMap);
            //Map<Id, IBB_Product__c> productMap = new Map<Id, IBB_Product__c>([select Id, Type_of_Product__c 
            //                                                    from IBB_Product__c]);
            
            for (Opportunity opp : trigger.new)
            {
                IBB_Product__c ibbProduct = productMap.get(opp.IBB_Product__c);
                if ('CLOSED WON'.equalsIgnoreCase(opp.StageName)){
                    if (!'FIXED TERM SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProduct.Type_of_Product__c) && !opp.From_Upload__c){
                        OpportunityTriggerMethods.populatePaymentInformation(opp);  
                    }
                }

                /* C0728 */
                system.debug ( 'In C0728 ' );
                Map <String,Schema.RecordTypeInfo> recordTypes = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName();
                Id hppRecordId = recordTypes.get('HPP Opportunities').getRecordTypeId();
                Id hppCAARecordId = recordTypes.get('HPP CAA').getRecordTypeId(); //C0728
                Id liabilitiesRecordId = recordTypes.get('Liabilities Opportunities').getRecordTypeId();
                
                system.debug ( 'hpprecordid ' + hpprecordid + ' - opp.RecordId ' + opp.RecordTypeId);
                
                //case: 01893749 and 01831495; Printing status is not displaying; Start
                system.debug('Trigger.oldMap.get(opp.Id).stagename'+Trigger.oldMap.get(opp.Id).stagename);
                if(opp.RecordTypeId == liabilitiesRecordId && opp.stagename != Trigger.oldMap.get(opp.Id).stagename && 'Next Steps'.equalsIgnoreCase(opp.StageName)){
                    system.debug('Entering update priting status loop');
                    OpportunityTriggerMethods.updatePrintingStatus(opp);
                } 
                //case: 01893749 and 01831495; Printing status is not displaying; End
                
                if (opp.RecordTypeId == hppCAARecordId)
                {
                    system.debug ( 'In C0728 ibb product ' + ibbproduct);
                    
                    if (ibbproduct != null )
                    {
                        //IBB_Product_Set__c productSet = [SELECT DSX_Documents_Expected__c
                            //                          FROM IBB_Product_Set__c

                        system.debug ( 'In C0728 DSX_Docs A ' + opp.DSX_Documents_Expected__c);
                        if (String.IsBlank(opp.DSX_Documents_Expected__c))
                        {
                            system.debug ( 'In C0728 DSX_Docs B ' + ibbproduct.ibb_product_set__r.DSX_Documents_Expected__c);
                            opp.DSX_Documents_Expected__c = ibbproduct.ibb_product_set__r.DSX_Documents_Expected__c;
                            system.debug ( 'In C0728 DSX_Docs C ' + opp.DSX_Documents_Expected__c);
                            List<string> expDocs = opp.DSX_Documents_Expected__c.Split(';');
                            List<string> outstandingDocs = new List<string>();
                            List<string> receivedDocs = new List<string>();
                            List<DSX_Document_Link__c> dsxDocs = [SELECT Document_Name__c 
                                                                        , Document_Status__c // C0741
                                                    FROM DSX_Document_Link__c
                                                    WHERE Opportunity__c = :opp.id
                                                    AND Document_Status__c != 'VERIFIED'];
                            Map<string, DSX_Document_Link__c> dsxMap = new Map<string, DSX_Document_Link__c>();
                            
                            //List<string> recDocs = new List<string> ();
                            //List<string> outDocs = new List<string> ();
                            if (dsxDocs.size() > 0)
                            {
                                for (DSX_Document_Link__c dsx : dsxDocs )
                                {
                                    dsxMap.put (dsx.Document_Name__c, dsx);
                                }

                                string osDocs = '';
                                string recDocs = '';
                                integer i = 0;  //C0741
                                for (string s : expDocs)
                                {
                                    outstandingDocs.Add(s); //C0741
                                    DSX_Document_Link__c dsxDoc = dsxMap.get (s);
                                    if (dsxDoc != null)
                                    {
                                        if (dsxDoc.Document_Status__c == 'Received')
                                        {
                                            receivedDocs.Add(s);
                                            
                                        }
                                        
                                        //C0741
                                        if (dsxDoc.Document_Status__c == 'Verified' )
                                        {
                                            outstandingDocs.Remove (i);
                                        }
                                        // C0741
                                        system.debug ( 's A ' + s );
                                        // C0741 outstandingDocs.Add(s);
                                        system.debug ( 'Outstanding docs A ' + outstandingDocs);
                                        //osDocs = String.isBlank(osDocs) ? s  : osDocs + ';' + s;
                                    }
                                    i++;
                                }

                                if ( outstandingDocs.Size() > 0 )
                                {
                                    outstandingDocs.Sort();
                                    for ( string st : outstandingDocs)
                                    {
                                        system.debug ( 'st B ' + st);
                                        osDocs = String.isBlank(osDocs) ? st  : osDocs + ';' + st;
                                        system.debug ( 'OsDocs B ' + osDocs );
                                    }
                                }

                                if ( receivedDocs.Size() > 0)
                                {
                                    receivedDocs.Sort();
                                    for ( string st : receivedDocs)
                                    {
                                        recDocs = String.isBlank(recDocs) ? st  : recDocs + ';' + st;
                                    }
                                }

                                

                                if (!String.IsBlank(osDocs))
                                {
                                    opp.DSX_Documents_Outstanding__c = osDocs;
                                }

                                if (!String.IsBlank(recDocs))
                                {
                                    opp.DSX_Documents_Received__c = recDocs;
                                }
                                else
                                {
                                    opp.DSX_Documents_Received__c = null;
                                }
                            }
                            else
                            {
                                string osDocs = '';
                                for (string s : expDocs)
                                {
                                    system.debug ( 's D ' + s );
                                    //osDocs = String.isBlank(osDocs) ? s  : osDocs + ';' + s;
                                    system.debug ( 'OsDocs D ' + osDocs );
                                    outstandingDocs.Add(s);
                                    
                                }

                                outstandingDocs.Sort();
                                for ( string st : outstandingDocs)
                                {
                                    osDocs = String.isBlank(osDocs) ? st  : osDocs + ';' + st;
                                }
                                opp.DSX_Documents_Outstanding__c = osDocs;
                                opp.DSX_Documents_Received__c = null;
                            }
                            
                            //integer i = 1/0;
                            //update opp;
                        }
                    }
                }
                /* C0728 */   
            }   
            
           
            
        }
    }
    
    if (trigger.isAfter){
        if (trigger.isUpdate){
            //Map<Id, IBB_Product__c> productMap = new Map<Id, IBB_Product__c>([select Id, Type_of_Product__c 
            //                                                    from IBB_Product__c]);
            //   String hppRecordId = '012D0000000QWmJ';
            //   String liabilitiesRecordId = '012D0000000QWmK';
           
            
            Map <String,Schema.RecordTypeInfo> recordTypes = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName();
            Id hppRecordId = recordTypes.get('HPP Opportunities').getRecordTypeId();
            
            Id liabilitiesRecordId = recordTypes.get('Liabilities Opportunities').getRecordTypeId();
            for (Opportunity opp : trigger.new){
                
                IBB_Product__c ibbProduct = productMap.get(opp.IBB_Product__c);

                if (opp.RecordTypeId == hppRecordId){
                    if ('HPP Completed (WON)'.equalsIgnoreCase(opp.StageName))
                    {
                        OpportunityTriggerMethods.createRLAAccount(opp.Id); 
                    }

                    
                    
                }
                else if (opp.RecordTypeId == liabilitiesRecordId)
                {
                    if ('CLOSED WON'.equalsIgnoreCase(opp.StageName))
                    {
                        system.debug ('Trigger what is the product type ' + ibbProduct.Type_of_Product__c);
                        if ('FIXED TERM SAVINGS ACCOUNT'.equalsIgnoreCase(ibbProduct.Type_of_Product__c) 
                        /* C0247 */
                            ||            
                             '12 Month Fixed Term Deposit ISA'.equalsIgnoreCase(ibbProduct.Type_of_Product__c))
                        /* C0247 */
                        {
                            if(OpportunityTriggerMethods.ignoreRDS == null || !OpportunityTriggerMethods.ignoreRDS)
                                system.debug ('No RDS from here ');
                                // C0551 OpportunityTriggerMethods.createRDSAccount(opp.Id); 
                        }
                        else 
                        {
                            if (!'CASH'.equalsIgnoreCase(opp.Payment_Type_List__c) && !opp.From_Upload__c)
                            {
                                OpportunityTriggerMethods.sendPaymentMessage(opp.Id);
                            }
                        }   
                    }
                }

                
            }
        }
        if (trigger.isInsert){
            Trigger_Helper.UpdateWebFormStatusFromOpportunity(trigger.new);
        }
    }
    
    /*
    if (trigger.isAfter){
        if (trigger.isUpdate){
            for (Opportunity o : trigger.new){
                if ('Setup Account In EBS'.equalsIgnoreCase(o.StageName)){
                    String oppId = o.Id;
                    String webLogId = OpportunityTriggerMethods.createWebIntegrationLog(oppId);
                    OpportunityTriggerMethods.createEBSCustomer(webLogId, oppId);
                    //OpportunityTriggerMethods.openEBSCustomerAccount(webLogId, oppId);
                }   
            }
        }
    }
    */
    // Only for debugging
    if ( Trigger.isInsert )
    {
        system.debug('OPPORTUNITY INSERT OCCURRED! ');
        for ( Opportunity opp : Trigger.new )
        {           
            system.debug('NAME='+opp.Name+' STAGE='+opp.StageName);
        }
    }
}