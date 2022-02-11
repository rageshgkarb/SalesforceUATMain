/**
 * Created by lbrindle on 15/09/2018.
 */

public without sharing class DotConnect_Opportunity {
    private String jsonRequest;
    private String messageType;

    public DotConnect_Opportunity(String messageType, String json){
        this.jsonRequest = json;
        this.messageType = messageType;
    }


    public Object ProcessMessage(){

        switch on messageType{
            when 'AddDocument'{return AddDocument();}
            when 'GetOpportunities'{return GetOpportunities();}
        }
        return null;
    }


    public Object AddDocument(){
        AddDocumentRequest data = (AddDocumentRequest) Json.deserialize(jsonRequest,AddDocumentRequest.class);

        List<Opportunity> lstOpportunity = [Select id From Opportunity
                                            Where Opportunity_ID__c =: data.opportunityRef];

        if(lstOpportunity.size() == 0){
            lstOpportunity = [Select id From Opportunity
                            Where Name =: data.opportunityRef];
        }

        if(lstOpportunity.size() == 0) return null;//TODO: add some error message here

        Attachment newdocument = new Attachment();
        newdocument.ParentId = lstOpportunity[0].Id;
        newdocument.ContentType = data.fileType;
        newdocument.Name = data.filename;
        newdocument.Body = EncodingUtil.base64Decode(data.fileBody);
        insert newdocument;
        return newdocument.id;
    }

    public Object GetOpportunities(){
        GetOpportunitesRequest request = (GetOpportunitesRequest)JSON.deserialize(jsonRequest,GetOpportunitesRequest.class);
        Set<Id> oppIds = new Set<Id>();

        //Get a list of all the applicant records for this account
        if(!request.primaryApplicantOnly){
            List<Applicant__c> applicants = [Select Opportunity__c From Applicant__c
            Where Prospect_Customer__r.SFDC_ID__c =: request.accountSFDCId];

            for(Applicant__c applicant : applicants){oppIds.add(applicant.Opportunity__c);}
        }

        //Get list of stages to fetch
        Dot_Connect__mdt hppStages = [Select Value__c from Dot_Connect__mdt
                                        Where developername = 'HPP_Stages'];
        List<String> hppStageList = hppStages.value__c.split(',');

        Dot_Connect__mdt eventLogNamesSetting = [Select Value__c from Dot_Connect__mdt
        Where developername = 'EventsToDisplay'];
        List<String> eventLogNames = eventLogNamesSetting.value__c.split(',');



        List<Opportunity> opps = [Select Id, Name, StageName, Status_HPP_CAA__c, Attachment_AIP_Letter__c, Attachment_App_Form__c, Attachment_Offer_Letter__c, Attachment_Welcome_Letter__c,
                                    Opportunity_ID__c, RecordType.Name, Product__r.Name, Term_of_Finance__c, Finance_Required__c
                                    From Opportunity
                                    Where RecordType.Developername = 'HPP_CAA' and StageName in : hppStageList and  (Account.SFDC_ID__c =: request.accountSFDCId
                                    Or Id In: oppIds ) ];

        Map<String,List<EventLog>> eventLogs = new Map<String,List<EventLog>>();
        if(opps.size() > 0){
            for (EventLog__c log : [Select Id, CreatedDate, EventStatus__c, ActualCompletedDate__c, Opportunity__r.Opportunity_ID__c, Name
                                        From EventLog__c
                                        Where Opportunity__c in: (new Map<Id,Opportunity>(opps)).keySet()
                                            And Name in : eventLogNames
                                            order by Opportunity__c,CreatedDate]){

                if(!eventLogs.containsKey(log.Opportunity__r.Opportunity_ID__c)) eventLogs.put(log.Opportunity__r.Opportunity_ID__c, new List<EventLog>());
                List<EventLog> logs = eventLogs.get(log.Opportunity__r.Opportunity_ID__c);

                logs.add(new EventLog(log));
            }



        }




        List<OpportunityData> lstOpportunities = new List<OpportunityData>();
        for(Opportunity opp : opps){
            OpportunityData opportunityData = new OpportunityData(opp);
            if(eventLogs.containsKey(opp.Opportunity_ID__c)){
                opportunityData.eventLogs = eventLogs.get(opp.Opportunity_ID__c);
            }
            lstOpportunities.add(opportunityData);
        }

        return lstOpportunities;
    }

    public class GetOpportunitesRequest{
        public String accountSFDCId {get;set;}
        public Boolean primaryApplicantOnly {get;set;}
        // If this is true, we will only return opps where the primary account holder is this account
    }

    private class EventLog{
        public String name {get;set;}
        public String id {get;set;}
        public String createdDate{get;set;}
        public String closedDate{get;set;}
        public Integer daysElapsed {get;set;}

        public EventLog(EventLog__c log){
            this.name = log.Name;
            this.id = log.Id;
            this.createdDate = log.createdDate.format('YYYY-MM-DD');
            if(log.ActualCompletedDate__c != null){
                this.closedDate = log.ActualCompletedDate__c.format('YYYY-MM-DD');
            }

            Date dateFinished = log.ActualCompletedDate__c == null ? Date.Today() : log.ActualCompletedDate__c.date() ;
            this.daysElapsed = log.createdDate.Date().daysBetween(dateFinished);
        }
    }

    public class AddDocumentRequest{
        public String opportunityRef {get;set;}
        public String fileType {get;set;}
        public String filename {get;set;}
        public String fileBody {get;set;}
    }

    public class OpportunityData{
        public String opportunityId {get;set;}
        public String opportunitySFDCId{get;set;}
        public String opportunityName {get;set;}
        public String stage {get;set;}
        public String status {get;set;}
        public String opportunityType {get;set;}
        public Decimal financerequired {get;set;}
        public Decimal termOfFinance {get;set;}
        public List<EventLog> eventLogs {get;set;}

        public String attachmentIdAip {get;set;}
        public String attachmentIdApplication {get;set;}
        public String attachmentIdOffer {get;set;}
        public String attachmentWelcome {get;set;}

        public OpportunityData(Opportunity opp){
            this.opportunityId = opp.id;
            this.opportunitySFDCId = opp.Opportunity_ID__c;
            this.stage = opp.StageName;
            this.status = opp.Status_HPP_CAA__c;
            this.opportunityType = opp.RecordType.Name;
            this.termOfFinance = opp.Term_of_Finance__c;
            this.financerequired = opp.Finance_Required__c;
            this.attachmentIdAip = opp.Attachment_AIP_Letter__c;
            this.attachmentIdApplication = opp.Attachment_App_Form__c;
            this.attachmentIdOffer = opp.Attachment_Offer_Letter__c;
            this.attachmentWelcome = opp.Attachment_Welcome_Letter__c;
            this.opportunityName = opp.Name;
        }

    }

}