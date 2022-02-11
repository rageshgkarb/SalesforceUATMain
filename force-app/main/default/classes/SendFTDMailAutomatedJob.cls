/*
Createdby: Zensar
Desciption: Schdule class to check last woring day and send email to CFH Team
Change Request Case Number - 01818873
*/
global class SendFTDMailAutomatedJob Implements Schedulable{
    
    public string processType;
    
    public SendFTDMailAutomatedJob (String processName) {
        processType = processName;
        system.debug(processType);        
    }
    
    //Execute Method
    global void execute(SchedulableContext sc){
        //Businesshour query
        BusinessHours bHours = [SELECT Id FROM BusinessHours WHERE Name =: system.label.BusinessHoursName];
        system.debug(bHours.id);
        system.debug(date.today());
        system.debug(BusinessHours.isWithin(bHours.Id, system.now()));
        //Check if today is working day to execute the automated email
        if(BusinessHours.isWithin(bHours.Id, system.now())){
            List<Date> reportDates = new List<Date>();
            //Loop through the dates to get the all days till last working day
            for(integer i=1;i<100;i++){
                //get last n day
                DateTime previousDay = system.now().adddays(-i);
                system.debug('--previousDay--'+previousDay);
                Date previousDate = date.newinstance(previousDay.year(), previousDay.month(), previousDay.day());
                reportDates.add(previousDate);
                //get if last nth day is working day
                Boolean isLastWorkingDay = getIsWorkingDay(previousDay,bHours.Id); 
                //Break the loop if last n day is working day
                if(isLastWorkingDay){
                    break;
                }   
            }
            system.debug('--reportDates--'+reportDates);
            //Execute getOpportunites to send email
            if(reportDates.size()>0){ 
                getOpportunites(reportDates);
            }
        }
    }
    
    public void getOpportunites(List<Date> reportDates){
        List<FTD_CFH_Automation__mdt> mcsList = [SELECT MasterLabel, QualifiedApiName,CSV_File_Name__c,Email_Body__c,Email_List__c,Email_Subject__c,Job_Size__c,Report_Name__c FROM FTD_CFH_Automation__mdt];
        system.debug(mcsList ); 
        Map<String,FTD_CFH_Automation__mdt> ftdMap = new Map<String,FTD_CFH_Automation__mdt>();
        FTD_CFH_Automation__mdt ftdCFHAutomation ;
        for(FTD_CFH_Automation__mdt mcs : mcsList) {
            ftdMap.put(mcs.MasterLabel,mcs);                      
        }
        system.debug(ftdMap);
        ftdCFHAutomation = ftdMap.get(processType);
        system.debug(ftdCFHAutomation );       
        String reportName = ftdCFHAutomation.Report_Name__c;        
        
        //Query the FTD Report
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where Name =: reportName];
        system.debug('');
        //get the report ID
        String reportId = (String)reportList.get(0).get('Id');
        
        //Get the report metadata with the report ID
        Reports.ReportDescribeResult rptDescribe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata rptMetadata = rptDescribe.getReportMetadata();
        
        //get the report date filter and set the laast working date filter
        Reports.StandardDateFilter datefilter = rptMetadata.getStandardDateFilter();
        String lastWorkingDay = String.valueof(reportDates[reportDates.size()-1]);
        Date reportDay =  reportDates[reportDates.size()-1];
        datefilter.setStartDate(String.valueof(reportDates[reportDates.size()-1]));
        datefilter.setEndDate(String.valueof(reportDates[0]));
        rptMetadata.setStandardDateFilter(datefilter);
        system.debug(datefilter);
        
        //run the report
        Reports.ReportResults results = Reports.ReportManager.runReport(reportId, rptMetadata,true);
        // Get the fact map from the report results
        Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
        //create a list of report rows and populate it with the result rows from fact map
        List<Reports.ReportDetailRow> reportRows = factDetails.getRows();
        Integer resultCount = factDetails.getRows().size();
        System.debug('resultCount' +resultCount);
        
        if(resultCount>0){
            //Get the detailed report columns for csv header 
            Reports.ReportExtendedMetadata rmd =   results.getReportExtendedMetadata();
            // Get column details from extended metadata
            Map<String,Reports.DetailColumn> colMap = rmd.getDetailColumnInfo();
            
            String content = '';
            for(String key : colMap.KeySet()){
                content += colMap.get(key).getLabel()+',';
            } 
            content = content.removeEnd(',');
            content += '\n';
            system.debug(content );
            String contentCSV = '';
            List<String> oppIdList = new List<String>();
            
            //Loop through detailed rows and prepare CSV body
            for(Reports.ReportDetailRow reportRow : reportRows){
                //get the detailed cells
                system.debug('reportRow----'+reportRow);
                List<Reports.ReportDataCell> datacells = reportRow.getDataCells(); 
                String dataCellString = '';    
                
                Id oppId = (Id)datacells[0].getvalue();
                dataCellString += oppId+ ',';   
                oppIdList.add(oppId);
                
                String printStatus = (String)datacells[1].getvalue();
                dataCellString += printStatus+ ',';
                
                String salutation = (String)datacells[2].getvalue();
                dataCellString += salutation+ ',';   
                
                String firstName = datacells[3].getLabel();
                dataCellString += firstName+ ',';
                
                String middleName = (String)datacells[4].getvalue();
                if(String.isNotBlank(middleName)){
                    dataCellString += middleName+ ',';
                } else {
                    dataCellString += ',';
                }                
                
                String lastName = datacells[5].getLabel();
                dataCellString += lastName+ ',';   
                
                String shortMailingName = (String)datacells[6].getvalue();
                dataCellString += shortMailingName+ ',';
                
                String address1 = (String)datacells[7].getvalue();
                if(String.isNotBlank(address1)){
                    if(address1.contains(',')){
                        address1= '"'+address1+'"';
                    }
                    dataCellString += address1+ ',';
                } else {
                    dataCellString += ',';
                } 
                
                String district = (String)datacells[8].getvalue();
                if(String.isNotBlank(district)){
                    if(district.contains(',')){
                        district= '"'+district+'"';
                    }
                    dataCellString += district+ ',';
                } else {
                    dataCellString += ',';
                }
                
                String address2 = (String)datacells[9].getvalue();
                if(String.isNotBlank(address2)){
                    if(address2.contains(',')){
                        address2= '"'+address2+'"';
                    }
                    dataCellString += address2+ ',';
                } else {
                    dataCellString += ',';
                }
                
                String address3 = (String)datacells[10].getvalue();
                if(String.isNotBlank(address3)){
                    if(address3.contains(',')){
                        address3= '"'+address3+'"';
                    }
                    dataCellString += address3+ ',';
                } else {
                    dataCellString += ',';
                }   
                
                String city = (String)datacells[11].getvalue();
                if(String.isNotBlank(city)){
                    city= '"'+city+'"';
                    dataCellString += city+ ',';
                } else {
                    dataCellString += ',';
                }
                
                String county = (String)datacells[12].getvalue();
                if(String.isNotBlank(county)){
                    county= '"'+county+'"';
                    dataCellString += county+ ',';
                } else {
                    dataCellString += ',';
                } 
                
                String postcode = (String)datacells[13].getvalue();
                if(String.isNotBlank(postcode)){
                    dataCellString += postcode+ ',';
                } else {
                    dataCellString += ',';
                } 
                
                String country = (String)datacells[14].getvalue();
                if(String.isNotBlank(country)){
                    country= '"'+country+'"';
                    dataCellString += country+ ',';
                } else {
                    dataCellString += ',';
                }   
                
                String primaryContactNo = (String)datacells[15].getvalue();
                if(String.isNotBlank(primaryContactNo)){
                    dataCellString += primaryContactNo+ ',';
                } else {
                    dataCellString += ',';
                }
                
                String mobileNo = (String)datacells[16].getvalue();
                if(String.isNotBlank(mobileNo)){
                    dataCellString += mobileNo+ ',';
                } else {
                    dataCellString += ',';
                }
                
                String emailAddress = (String)datacells[17].getvalue();
                if(String.isNotBlank(emailAddress)){
                    dataCellString += emailAddress+ ',';
                } else {
                    dataCellString += ',';
                } 
                
                String deposit = datacells[18].getlabel();
                deposit = deposit.remove('£'); 
                if(deposit.contains(',')){
                    deposit = deposit.remove(','); 
                }
                dataCellString += deposit+ ',';                
                
                String Product = datacells[19].getLabel();
                dataCellString += Product+ ','; 
                
                Boolean contactbyEmail = (Boolean)datacells[20].getvalue();
                Integer cbyEmail = 0;
                if(contactbyEmail){
                    cbyEmail = 1;
                }
                dataCellString += cbyEmail+ ',';
                
                Boolean contactbyNewsletter = (Boolean)datacells[21].getvalue();
                Integer cbyNewsletter = 0;
                if(contactbyNewsletter){
                    cbyNewsletter = 1;
                }
                dataCellString += cbyNewsletter+ ',';
                
                Boolean contactByTelephone = (Boolean)datacells[22].getvalue();
                Integer conByTelephone = 0;
                if(contactByTelephone){
                    conByTelephone = 1;
                }
                dataCellString += conByTelephone+ ',';
                
                Boolean contactByPost = (Boolean)datacells[23].getvalue();
                Integer conByPost = 0;
                if(contactByPost){
                    conByPost = 1;
                }
                dataCellString += conByPost+ ',';
                
                Boolean contactbySMS = (Boolean)datacells[24].getvalue();
                Integer conbySMS = 0;
                if(contactbySMS){
                    conbySMS = 1;
                }
                dataCellString += conbySMS+ ',';
                
                Decimal applicants = (Decimal)datacells[25].getvalue();
                dataCellString += applicants+ ',';
                
                String applicationNumber = (String)datacells[26].getvalue();
                dataCellString += applicationNumber+ ',';
                
                String fitAccount = (String)datacells[27].getvalue();
                dataCellString += fitAccount+ ',';
                
                String cDate = datacells[28].getLabel();
                dataCellString += cDate+ ',';
                
                String profitOptionWording1 = datacells[29].getLabel();
                if(String.isNotBlank(profitOptionWording1)){
                    if(profitOptionWording1.contains(',')){
                        profitOptionWording1 = '"'+profitOptionWording1+'"';
                    }
                    dataCellString += profitOptionWording1+ ',';
                } else {
                    dataCellString += ',';
                }
                
                
                
                String profitOptionWording2 = datacells[30].getLabel();
                if(String.isNotBlank(profitOptionWording2)){
                    if(profitOptionWording2.contains(',')){
                        profitOptionWording2 = '"'+profitOptionWording2+'"';
                    }
                    dataCellString += profitOptionWording2+ ',';
                } else {
                    dataCellString += ',';
                }
                
                String balanceAfter1yr = datacells[31].getLabel();
                dataCellString += balanceAfter1yr+ ',';
                
                Decimal balanceAfter24Months = (Decimal)datacells[32].getvalue();
                dataCellString += balanceAfter24Months+ ',';
                
                Decimal balanceAfter18Months = (Decimal)datacells[33].getvalue();
                dataCellString += balanceAfter18Months+ ',';
                
                Decimal balanceAfter36Months = (Decimal)datacells[34].getvalue();
                dataCellString += balanceAfter36Months+ ',';
                
                Decimal profitRateletter = (Decimal)datacells[35].getvalue();
                dataCellString += profitRateletter;
                
                dataCellString = dataCellString.removeEnd(',');
                dataCellString += '\n';  
                system.debug(dataCellString );      
                contentCSV += dataCellString;
            }
            system.debug(contentCSV );
            content += contentCSV ;
            
            //encode csv data to escape the special symbole £ issues 
            String urlEncoded = EncodingUtil.urlEncode(content, 'ISO-8859-1');
            String[] chars = urlEncoded.replaceAll('\\+',' ').split('');
            System.debug(urlEncoded);
            for(Integer i = 0; i < chars.size(); i++) {
                if(chars[i] == '%') {
                    chars[i] = EncodingUtil.convertToHex(EncodingUtil.convertFromHex(chars[i+1]+chars[i+2]));
                    chars.remove(i+2);
                    chars.remove(i+1);
                } else {
                    chars[i] = EncodingUtil.convertToHex(Blob.valueOf(chars[i]));
                }
            }            
            Blob body = EncodingUtil.convertFromHex(String.join(chars,''));
            system.debug('oppIdList'+oppIdList);
            if(!oppIdList.isempty()){ 
                sendingEmail(body,reportDay,ftdCFHAutomation);  
                Integer batchSize = integer.valueof(ftdCFHAutomation.Job_Size__c);
                if(!Test.isRunningTest()){
                    FTDCFHAutomationBatch batch = new FTDCFHAutomationBatch(oppIdList);        
                    Database.executebatch(batch,batchSize);         
                }  
            }
        }
    }
    
    //Get the the received date is working day
    public void sendingEmail(Blob body,Date lastWorkingDay,FTD_CFH_Automation__mdt ftdCFHAutomation){          
        
        //Prepare Email attachment
        String dayString = '';
        String monthString = '';
        String yearString = String.valueof(lastWorkingDay.year());
        if(lastWorkingDay.day() <10){
            dayString = '0'+ String.valueof(lastWorkingDay.day());
        }else{
            dayString = String.valueof(lastWorkingDay.day());
        }
        if(lastWorkingDay.month() <10){
            monthString = '0'+ String.valueof(lastWorkingDay.month());
        }else{
            monthString = String.valueof(lastWorkingDay.month());
        }
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        
        string csvname= ftdCFHAutomation.CSV_File_Name__c+' '+dayString+monthString+yearString+'.csv';
        csvAttc.setFileName(csvname);        
        
        csvAttc.setcontenttype('text/csv;charset=ISO-8859-1');
        csvAttc.setBody(body);
        //Get the to email address from the custom label
        List<String> toAddressList = ftdCFHAutomation.Email_List__c.split(',');
        system.debug('toAddressList '+toAddressList );
        //Prepare emails to FTD CFH team
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddressList);
        mail.setCharset('ISO-8859-1');
        mail.setSubject(ftdCFHAutomation.Email_Subject__c+' '+dayString+monthString+yearString);
        mail.setHtmlBody(ftdCFHAutomation.Email_Body__c);
        mail.setFileAttachments( new Messaging.EmailFileAttachment[]{csvAttc} );
        system.debug('mail '+mail );
        //Send email
        if(!Test.isRunningTest()){
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
        }
        
    }   
    
    //Get the the received date is working day
    public Boolean getIsWorkingDay(Datetime lastDay,Id businessHoursId){          
        
        Boolean previousWorkingDay = false;
        system.debug('lastDay'+lastDay);
        //Check if the lastDay is working day
        if(BusinessHours.isWithin(businessHoursId, lastDay)){
            previousWorkingDay = true;            
        }
        system.debug(previousWorkingDay);
        return previousWorkingDay; 
    }  
    
}