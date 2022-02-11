public with sharing class CloneGoalMetricsController{

  private final Id goalId; //current goal id
  Date goalStartDate; //current goal start date
  Date goalCloneDueDate;
  Date goalCloneStartDate;
  List<List<String>> reportMetadataChunks;//contains sub-list of reportMetadata 
  List<MetricDataLink> metricDataLinkClones;
  Map<Id, String> oldReportIdToNewReportNameMap; 
  public String errorMsg {get;set;}
  
   public CloneGoalMetricsController(ApexPages.StandardController standardController) {
       
       goalId = standardController.getId();//set the goal id    
   }
      
   public void CloneGoalAndMetrics(){

      if(goalId!=null){
      
          Goal goal = [SELECT name, StartDate, DueDate, (SELECT Metric.name, Metric.Description, Metric.TargetValue, Metric.Weight, Metric.Id, Metric.StartDate, Metric.dueDate, Metric.CompletionDate, Metric.Progress FROM Goal.Metrics) FROM Goal WHERE id =:goalId];
          
          goalStartDate = goal.StartDate;//set current goal start date 
  
          Goal goalClone = new Goal();        
          goalClone.name =  Apexpages.currentPage().getParameters().get('goalName');
          
          //convert string to date 
          goalCloneStartDate = Date.parse(Apexpages.currentPage().getParameters().get('goalStartDate'));
          goalClone.StartDate = goalCloneStartDate;
          
          //convert string to date      
          goalCloneDueDate = Date.parse(Apexpages.currentPage().getParameters().get('goalDueDate'));
          goalClone.DueDate = goalCloneDueDate;


          try {
          
           insert goalClone; //clone existing goal  
           
           List<Metric> metricsToBeCloned = new List<Metric>();
           List<Id> oldMetricIds = new List<Id>();
           
           for(Metric metric : goal.metrics){
           
               oldMetricIds.add(metric.id);
               
               Metric metricClone = metric;
               metricClone.id = null;
               metricClone.name = getCloneName(metric.name);
               metricClone.GoalId = goalClone.id;
               //convert string to date
               String metricStartDate =  Apexpages.currentPage().getParameters().get('metricStartDate');   
               metricClone.startDate = Date.parse(metricStartDate);
               
               //convert string to date
               String metricDueDate =  Apexpages.currentPage().getParameters().get('metricDueDate');   
               metricClone.dueDate = Date.parse(metricDueDate);
               
               metricsToBeCloned.add(metricClone);
           }
 
           insert metricsToBeCloned; //clone metrics and link to newly created goal
           
           setUpReportMetadata(metricsToBeCloned, oldMetricIds);
            
          } catch (DmlException e) {
            // Process exception here
          }
      }        
   }    
   
   //returns the string to be set as the clone metric/report name
   String getCloneName(String currentName){
       
       List<String> currentGoalMonthNames = Util.getMonthNameMap().get(goalStartDate.month()).split(':'); 
         
       //In most cases the current name would contain the same month as the goal start date
       if(currentName.containsIgnoreCase(currentGoalMonthNames.get(1))){//shortName
       
          return replaceMetricNameWithCurrentMonth(currentName,currentGoalMonthNames.get(1),goalCloneStartDate);      
       
       } else if(currentName.containsIgnoreCase(currentGoalMonthNames.get(0))){//longName
       
           return replaceMetricNameWithCurrentMonth(currentName,currentGoalMonthNames.get(0),goalCloneStartDate); 
           
       } else{// If not, we loop through all the months to find the month in current name
       
           for(String month :Util.getMonthNameMap().values()){
           
               List<String> monthShortLongForms = month.split(':'); 
               String monthFullForm = monthShortLongForms.get(0);
               String monthShortForm = monthShortLongForms.get(1);
    
               if(currentName.containsIgnoreCase(monthShortForm)){
               
                   return replaceMetricNameWithCurrentMonth(currentName,monthShortForm,goalCloneStartDate);
                   
               } else if(currentName.containsIgnoreCase(monthFullForm)){
               
                   return replaceMetricNameWithCurrentMonth(currentName,monthFullForm,goalCloneStartDate);
               
               }
           }
       }
       
       //If we can't find a match for month in name we return firstComponent+Clone+NewMonth+Year 
       String firstComponent =  currentName.substringBefore(' ');//in most cases should be first name
       
       return firstComponent+' Clone '+Util.getMonthNameMap().get(goalCloneStartDate.month()).split(':').get(1)
                       +' '+String.valueOf(goalCloneStartDate.year()).substring(2);
   }
   
 
   String replaceMetricNameWithCurrentMonth(String metricName, String month, Date goalCloneStartDate){
   
       String nameWithoutMonth = metricName.substringBefore(month);//get part of the string that does not contain month/year info

       String monthShortForm = Util.getMonthNameMap().get(goalCloneStartDate.month()).split(':').get(1);  

       return nameWithoutMonth+monthShortForm+' '+String.valueOf(goalCloneStartDate.year()).substring(2);
   
   }
   
    //creates a list of reportMetadata chunks required for metadata api callouts
    void setUpReportMetadata(List<Metric> metricsToBeCloned, List<Id> oldMetricIds)
    {
         Map<Id, Id> oldMetricToNewMetricMap = new Map<Id, Id>(); 
         Integer metricIndex =0; 
           
          for(Metric metric : metricsToBeCloned){
           
               oldMetricToNewMetricMap.put(oldMetricIds.get(metricIndex),metric.id);
               metricIndex++;
          } 
           
          Set<Id> reportIds = new  Set<Id>();
          metricDataLinkClones = new List<MetricDataLink>();
          //create the list of metricDataLink that will 
          for (MetricDataLink link :[SELECT DatasourceFieldName, DataSourceId, TargetId FROM MetricDataLink WHERE TargetId IN : oldMetricIds]){
            
                MetricDataLink datalinkClone = new MetricDataLink();
                datalinkClone.TargetId = oldMetricToNewMetricMap.get(link.TargetId);//set new metric id
                datalinkClone.DatasourceFieldName = link.DatasourceFieldName;
                datalinkClone.DataSourceId = link.DataSourceId;
                metricDataLinkClones.add(datalinkClone);
                
                reportIds.add(link.DataSourceId);
          }
           
          List<Report> reports =[SELECT DeveloperName, Name, OwnerId FROM Report WHERE id IN :reportIds];          
           
          Set<Id> folderIds = new  Set<Id>();
          for(Report report :reports){
   
             folderIds.add(report.OwnerId);
          }
          
          //get the folder developer name
          Map<Id, String> folderIdToDevNameMap = new  Map<Id, String>();
          for(Folder folder :[SELECT Id, DeveloperName FROM Folder WHERE id IN:folderIds AND Type ='Report']){
           
             folderIdToDevNameMap.put(folder.Id,folder.DeveloperName); 
          }

          List<String> reportMetadataPaths = new List<String>();
          oldReportIdToNewReportNameMap = new Map<Id, String>();  
          for(Report report :reports){

               String folderDevName = folderIdToDevNameMap.get(report.OwnerId);
             
               If(folderDevName==null){//In case of a report in public folder it doesn't return a developer name
             
                 folderDevName = 'unfiled$public';//devloperName for public folder
             
               }
               reportMetadataPaths.add(folderDevName+'/'+report.DeveloperName);
               //developer names cannot have spaces or special char apart from _ so replace all with underscore
               String newReportDevName = getCloneName(report.name).replaceAll('\\W','_'); 
               oldReportIdToNewReportNameMap.put(report.id, newReportDevName); 
           }
          //chunkSize is set to 10 due to metadata api limit of 10 per callout    
          reportMetadataChunks = Util.splitListIntoChunks(reportMetadataPaths, 10);   
    }

    //clones every report and links it to the associated metric
    public void cloneReports()
    {   
         if(reportMetadataChunks!=null){
         
              MetadataService.MetadataPort service = createService();
              
              for(List<String> metadataList: reportMetadataChunks){
                   
                  readReports(metadataList, service);     
              } 
    
              System.debug('savio '+oldReportIdToNewReportNameMap);  
    
              Map<String, Id> newReportNameToNewReportIdMap = new Map<String, Id>(); 
              for(Report report:[SELECT id, DeveloperName FROM Report WHERE DeveloperName IN :oldReportIdToNewReportNameMap.values()]){
              
                  newReportNameToNewReportIdMap.put(report.DeveloperName,report.id);
              
              }
              
              List<String> errorMsgs = new List<String>();
              errorMsgs.add('Sorry! Report have not been linked to the following metrics:');
              
              //update the new report id for each metricDatalink
              for(MetricDataLink dataLink:metricDataLinkClones){
                  
                   Id newReportId = newReportNameToNewReportIdMap
                  .get(oldReportIdToNewReportNameMap.get(dataLink.DataSourceId));   
                  
                   dataLink.DataSourceId = newReportId;
                   
                   if(newReportId==null){
                   
                       errorMsgs.add(dataLink.TargetId);
                   
                   }
              }
              
              if(errorMsgs.size()>1){
              
                  errorMsg = String.join(errorMsgs, ' ');
                  System.debug('savio errorMsg '+errorMsg);
              
              
              }
              
              try {
              
                  insert metricDataLinkClones;//links the cloned reports & metrics
                  
              } catch (DmlException e) {
                // Process exception here
                
              }
         }
    }
    
    //fetches 10 reportMetadata at once
    void readReports(List<String> reportMetadata, MetadataService.MetadataPort service)
    {
        List<MetadataService.Metadata> reports = service.readMetadata('Report',
                reportMetadata).getRecords();
 
        createReports(reports,service);
    }
    //modifies the fetched reportMetadata batch(size-10) and create clones
    void createReports(List<MetadataService.Metadata> reports, MetadataService.MetadataPort service)
    {
        for(MetadataService.Metadata metadata : reports){
        
            MetadataService.Report report = (MetadataService.Report)metadata;
            report.name = getCloneName(report.name);
            //get the existing folder name
            String folderDevName = report.fullName.substringBefore('/');
            report.fullName = folderDevName+'/'+report.name.replaceAll('\\W','_');// full name = devFolderName/DevReportName
            //set the report dates to the same as goal start and due date
            report.timeFrameFilter.startDate = goalCloneStartDate;
            report.timeFrameFilter.endDate = goalCloneDueDate;
        
        }
        
        List<MetadataService.SaveResult> results = service.createMetadata(reports);
        //system.debug('Create Report: '+handleSaveResult(results[0]));

    }
 
    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = getSessionId();
        return service;
    }
    
    private static String getSessionId(){
       /*cannot have WebServiceMock & HttpCalloutMock in the same test class execution, hence returns 
       session id of loggedIn user while running test*/
       if (Test.isRunningTest()){
           
           return UserInfo.getSessionId();  
       } else {
       
           return SOAPLogin.login(); //login with integration user & return session
       }
    }       
     
    /***NOTE - As we clone report in batches we do not throw excpetions in case of failure, we ignore them & 
    eventually while linking it to the report id if we get a null value we will display the message to user for those metrics     
    //Returns detailed error message when report creation fails, used for debugging
    public static String handleSaveResult(MetadataService.SaveResult saveResult)
    {       
        //No error
        if(saveResult==null || saveResult.success){
        
             return null;   
        }
        
        if(saveResult.errors!=null) {// Construct error message and throw an exception
        
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
                        
            return String.join(messages, ' ');

        }
        
        return 'Request failed with no specified error.'; //No specific error identified
    }***/ 
}