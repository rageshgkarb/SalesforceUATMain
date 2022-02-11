public with sharing class ServiceConsole_CaseListController {
	
	public String parentObjId {get;set;}
	public Integer rowLimit {get;set;}
    public FINAL Integer rowIncrementor = 5;
    
    public Integer totalCases{
        get{
            if(totalCases == null){
                totalCases = [SELECT COUNT() FROM Case WHERE AccountId =: parentObjId];
            }
            return totalCases;
        }set;
    }

    //Constructor
	public ServiceConsole_CaseListController() {
        parentObjId = ApexPages.currentPage().getParameters().get('id');
        rowLimit = rowIncrementor;
        showMoreValue = 0;
    }

	public list<Case> getRecentCases(){
    	list<Case> cases = [SELECT Id, CaseNumber, Subject, Status, RecordTypeId, RecordType.Name, CreatedDate FROM Case WHERE AccountId =: parentObjId ORDER BY CreatedDate DESC LIMIT : rowLimit];
    	return cases;
    }

    public Integer showMoreValue{
        get{
            if((totalCases - rowLimit) > rowIncrementor){
                showMoreValue = rowIncrementor;
            }else{
            
                showMoreValue = totalCases - rowLimit;
            }
            return showMoreValue;
        }set;
    }

    public void getMoreCases(){
        if(showMoreValue < rowIncrementor){
            rowLimit += showMoreValue;
        }else{
            rowLimit += rowIncrementor;
        }
    }

    public void showAllCases(){
        rowLimit = totalCases;
    }
	
}