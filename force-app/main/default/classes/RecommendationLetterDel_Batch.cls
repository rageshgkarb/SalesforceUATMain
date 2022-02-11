/**
* @author Mohammed Raiyan
* @date 08-03-2021
*
* @group Risk Calculator Batch
*
* @description Batch job to fetch recommendation letters created by onefinance team and create a document for the same and delete attachments
*/
global class RecommendationLetterDel_Batch implements Database.Batchable<sObject>,Database.Stateful{
    global set<id> batchSetId;

    // **************************************
    // ************ Constructor *************
    // **************************************
    public RecommendationLetterDel_Batch(set<id> deleteId) {
          
        batchSetId = deleteId;
    }

       
    // **************************************
    // ************ START       *************
    // **************************************
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        String query = 'SELECT id,body,name FROM Attachment WHERE '; 
        
        if(batchSetId != null && batchSetId.size() > 0){
            query+= 'id IN:batchSetId';    
        }else{
            string letterName = '%Recommendation%';
            string profileName = 'HPP CAA Intermediary';
            query += ' name Like:letterName AND owner.profile.name =:profileName';
            system.debug('query::' + query);
        }
        
        return Database.getQueryLocator(query);
    }


    // **************************************
    // ************ Execute     *************
    // **************************************
    global void execute(Database.BatchableContext BC, List<Attachment> attachmentList) {
        if(batchSetId != null && batchSetId.size() > 0){
            DELETE attachmentList;
            batchSetId = null;
        }else{
            batchSetId = new set<id>();
            string folderName= 'Recommendation_Letter';
            id folderId = [SELECT AccessType,DeveloperName,Id,Type FROM Folder WHERE DeveloperName=:folderName].id;
            List<Document> dcoumentList = new List<Document>();
            for(Attachment att:attachmentList){
                Document emailDoc = new Document();            
                emailDoc.Name = att.name ;
                emailDoc.Body = att.body;
                emailDoc.FolderId = folderId;
                batchSetId.add(att.id);
                dcoumentList.add(emailDoc);
            }
            insert dcoumentList;
        }
    }

    // **************************************
    // ************ FINISH      *************
    // **************************************
    global void finish(Database.BatchableContext BC){
        if(batchSetId != null && batchSetId.size() > 0)
            database.executeBatch(new RecommendationLetterDel_Batch(batchSetId));   
    }
}