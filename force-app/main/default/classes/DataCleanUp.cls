global class DataCleanUp implements Database.Batchable<sObject>
{  
    global final String Query;

    global Database.QueryLocator start(Database.BatchableContext BC)
    {   
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        delete scope;
        DataBase.emptyRecycleBin(scope);
    }
 
    global void finish(Database.BatchableContext BC)
    {

    }
}