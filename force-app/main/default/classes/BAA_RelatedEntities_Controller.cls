/**
 * Created by lbrindle on 03/06/2020.
 */

public with sharing class BAA_RelatedEntities_Controller extends HPPBaseEventController{
    public String RemoveUBORelationshipId{get;set;}
    public String EditUBORelationshipId{get;set;}
    public String AddEntityId{get;set;}
    public boolean ShowUBOPopup{get;set;}
    public boolean ShowSearchPopup{get;set;}
    public String currentEntityType{get;set;}

    public List<Related_Customer_Entity_Relationship__c> relatedEntities{get;set;}
    public Related_Customer_Entity_Relationship__c EditRelationship{get;set;}
    //public Related_Customer_Entity__c EditEntity{get;set;}


    public List<SelectOption> relationShipTypes {get;set;}
    public List<SelectOption> countryOptions {get;set;}
    public List<SelectOption> positionHeldOptions {get;set;}
    public List<String> nationalityNames{get;set;}
    public List<String> otherCountryFieldNames{get;set;}
    public List<Related_Customer_Entity__c> searchResults {get;set;}
    public List<Account> searchResultsAccount {get;set;}
    public String searchText {get;set;}
    public Boolean tooManyResults {get;set;}

    public PageReference Setup()
    {


        RelationShipTypes = new List<SelectOption>{new SelectOption('','-- Select --')};
        for(Schema.PicklistEntry pickListVal : Related_Customer_Entity_Relationship__c.Relationship_Type__c.getDescribe().getPicklistValues()){
            relationShipTypes.add( new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
        }
        countryOptions = new List<SelectOption>{new SelectOption('','-- Select --')};
        for(Schema.PicklistEntry pickListVal : Related_Customer_Entity__c.Nationality__c.getDescribe().getPicklistValues()){
            countryOptions.add( new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
        }

        positionHeldOptions = new List<SelectOption>{new SelectOption('','-- Select --')};
        for(Schema.PicklistEntry pickListVal : Related_Customer_Entity_Relationship__c.Position_Held__c.getDescribe().getPicklistValues()){
            positionHeldOptions.add( new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
        }

        loadEntities();

        return null;
    }

    private void loadEntities(){
        relatedEntities = [SELECT Percent_Ownership__c, Position_Held__c, Relationship_Type__c, Related_Customer_Entity__r.First_Name__c,
                Related_Customer_Entity__r.Post_Code__c,Related_Customer_Entity__r.Middle_Name__c,
                Related_Customer_Entity__r.Address_Street__c, Related_Customer_Entity__r.Address_State__c,Related_Customer_Entity__r.Last_name__c,
                Related_Customer_Entity__r.Address_City__c,Related_Customer_Entity__r.Date_of_Birth__c,Related_Customer_Entity__r.EBS_Id__c,
                Related_Customer_Entity__r.RecordType.DeveloperName,Related_Customer_Entity__r.Name__c,
                Related_Customer_Entity__r.Company_Registration_Number__c,Related_Customer_Entity__r.Date_of_incorporation__c,Related_Customer_Entity__r.Country_of_Residence__c,
                Related_Customer_Entity__r.Nationality__c,Related_Customer_Entity__r.Country_Of_Incorporation__c,Related_Customer_Entity__r.Account__c
        FROM Related_Customer_Entity_Relationship__c
        WHERE Account__c =: BaseOpportunity.AccountId];

        nationalityNames = new List<String>();
        //Set friendly country names
        for(Related_Customer_Entity_Relationship__c r : relatedEntities){
            String countryName = '';
            for(SelectOption opt : countryOptions){
                if(opt.getValue() == r.Related_Customer_Entity__r.Nationality__c){
                    countryName = opt.getLabel();
                    break;
                }
            }
            nationalityNames.add(countryName);
        }



        otherCountryFieldNames = new List<String>();
        //Set friendly country names
        for(Related_Customer_Entity_Relationship__c r : relatedEntities){
            String countryName = '';
            String toFind = r.Related_Customer_Entity__r.RecordType.DeveloperName == 'Person' ?
                    r.Related_Customer_Entity__r.Country_of_Residence__c :
                    r.Related_Customer_Entity__r.Country_Of_Incorporation__c;
            for(SelectOption opt : countryOptions){
                if(opt.getValue() == toFind){
                    countryName = opt.getLabel();
                    break;
                }
            }
            otherCountryFieldNames.add(countryName);
        }




    }


    public PageReference EditUBORelationship(){
        ShowUBOPopup = false;

        List<Related_Customer_Entity_Relationship__c> relationships = [SELECT Percent_Ownership__c,Position_Held__c, Relationship_Type__c, Related_Customer_Entity__r.First_Name__c,
                Related_Customer_Entity__r.Post_Code__c,Related_Customer_Entity__r.Middle_Name__c,
                Related_Customer_Entity__r.Address_Street__c, Related_Customer_Entity__r.Address_State__c,Related_Customer_Entity__r.Last_name__c,
                Related_Customer_Entity__r.Address_City__c,Related_Customer_Entity__r.Date_of_Birth__c,Related_Customer_Entity__r.EBS_Id__c,
                Related_Customer_Entity__r.RecordType.DeveloperName,Related_Customer_Entity__r.Name__c,Related_Customer_Entity__r.Business_Name__c,Related_Customer_Entity__r.Country_of_Residence__c,
                Related_Customer_Entity__r.Company_Registration_Number__c,Related_Customer_Entity__r.Date_of_incorporation__c,    Related_Customer_Entity__r.Nationality__c,
                Related_Customer_Entity__r.Country_Of_Incorporation__c
        FROM Related_Customer_Entity_Relationship__c
        WHERE Id=:EditUBORelationshipId];

        if(relationships.isEmpty()){return null;}
        ShowUBOPopup = true;
        EditRelationship = relationships[0];

        currentEntityType = EditRelationship.Related_Customer_Entity__r.RecordType.DeveloperName;

        loadEntities();

        return null;
    }

    public PageReference AddRelationship(){
        List<Related_Customer_Entity_Relationship__c> existRelationships = [Select Id FROM Related_Customer_Entity_Relationship__c
                                                                            WHERE Account__c=:BaseOpportunity.AccountId AND
                                                                            Related_Customer_Entity__c=:AddEntityId];

        if(!existRelationships.isEmpty()){return null;}

        List<Related_Customer_Entity__c> relatedCustomerEntities = [Select ID FROM Related_Customer_Entity__c WHERE Id=:AddEntityId];
        Account existingAccount;
        if(relatedCustomerEntities.isEmpty()){
            List<Account> existAccounts = [SELECT Id, RecordType.DeveloperName, FirstName, Middle_Name__pc, LastName, Date_of_Birth__c,
                                            BillingStreet, BillingCity, BillingPostalCode, Name

                                            FROM Account WHERE Id=: AddEntityId ];
            system.debug('LRB ' + AddEntityId);
            if(existAccounts.isEmpty()){return null;}
            //create account relationship
            existingAccount = existAccounts[0];
                Related_Customer_Entity__c newEntity = new Related_Customer_Entity__c();
                if(existingAccount.RecordType.DeveloperName == 'Business_Account' ){
                    newEntity.RecordTypeId =
                            Schema.SObjectType.Related_Customer_Entity__c.getRecordTypeInfosByDeveloperName()
                                .get('Business').getRecordTypeId();
                    newEntity.Business_Name__c = existingAccount.Name;
                }else{
                    newEntity.RecordTypeId =
                            Schema.SObjectType.Related_Customer_Entity__c.getRecordTypeInfosByDeveloperName()
                                    .get('Person').getRecordTypeId();
                    newEntity.Date_of_Birth__c = existingAccount.Date_of_Birth__c;
                    newEntity.First_Name__c = existingAccount.FirstName;
                    newEntity.Last_name__c = existingAccount.LastName;
                    newEntity.Middle_Name__c = existingAccount.Middle_Name__pc;


                }

            newEntity.Post_Code__c = existingAccount.BillingPostalCode;
            newEntity.Address_Street__c = existingAccount.BillingStreet;
            newEntity.Address_City__c = existingAccount.BillingCity;
            newEntity.Account__c = existingAccount.Id;
            insert newEntity;



                Related_Customer_Entity_Relationship__c relationship = new Related_Customer_Entity_Relationship__c();
                relationship.Account__c = BaseOpportunity.AccountId;
                relationship.Related_Customer_Entity__c = newEntity.Id;
            insert relationship;

        }else{
            //create relationship
            Related_Customer_Entity_Relationship__c relationship = new Related_Customer_Entity_Relationship__c();
            relationship.Account__c = BaseOpportunity.AccountId;
            relationship.Related_Customer_Entity__c = relatedCustomerEntities[0].Id;
            insert relationship;

        }



        ShowSearchPopup = false;

        loadEntities();
        return null;
    }

    public PageReference SaveAccount(){

        system.debug(EditRelationship.Id);

        if(String.isNotBlank(EditRelationship.Id )) {
            update EditRelationship.Related_Customer_Entity__r;
            update EditRelationship;
        }else{
            Related_Customer_Entity__c ent = new Related_Customer_Entity__c();
            ent.First_Name__c = EditRelationship.Related_Customer_Entity__r.First_Name__c;
            ent.Middle_Name__c = EditRelationship.Related_Customer_Entity__r.Middle_Name__c;
            ent.Last_Name__c = EditRelationship.Related_Customer_Entity__r.Last_Name__c;
            ent.Date_of_Birth__c = EditRelationship.Related_Customer_Entity__r.Date_of_Birth__c;
            ent.Address_Street__c = EditRelationship.Related_Customer_Entity__r.Address_Street__c;
            ent.Address_City__c = EditRelationship.Related_Customer_Entity__r.Address_City__c;
            ent.Business_Name__c = EditRelationship.Related_Customer_Entity__r.Business_Name__c;
            ent.Company_Registration_Number__c = EditRelationship.Related_Customer_Entity__r.Company_Registration_Number__c;
            ent.Country_Of_Incorporation__c = EditRelationship.Related_Customer_Entity__r.Country_Of_Incorporation__c;
            ent.Country_of_Residence__c = EditRelationship.Related_Customer_Entity__r.Country_of_Residence__c;
            ent.Date_of_incorporation__c = EditRelationship.Related_Customer_Entity__r.Date_of_incorporation__c;
            ent.Nationality__c = EditRelationship.Related_Customer_Entity__r.Nationality__c;
            ent.Post_Code__c = EditRelationship.Related_Customer_Entity__r.Post_Code__c;
            ent.Address_Country__c = EditRelationship.Related_Customer_Entity__r.Address_Country__c;
            ent.RecordTypeId = EditRelationship.Related_Customer_Entity__r.RecordTypeId;

            insert ent;

            Related_Customer_Entity_Relationship__c rel = new Related_Customer_Entity_Relationship__c();
            rel.Relationship_Type__c = EditRelationship.Relationship_Type__c;
            rel.Percent_Ownership__c = EditRelationship.Percent_Ownership__c;
            rel.Position_Held__c = EditRelationship.Position_Held__c;

            rel.Related_Customer_Entity__c = ent.Id;
            rel.Account__c = BaseOpportunity.AccountId;

            insert rel;
        }

        //EditRelationship.Related_Customer_Entity__c = EditRelationship.Related_Customer_Entity__r.Id;



        //Integer j = 1/0;
        ShowUBOPopup = false;
        loadEntities();
        return null;
    }

    public PageReference DeleteUBORelationship(){
        ShowUBOPopup = false;
        ShowSearchPopup = false;

        List<Related_Customer_Entity_Relationship__c> relationship = [Select Id FROM  Related_Customer_Entity_Relationship__c
        WHERE Id=:RemoveUBORelationshipId];

        if(!relationship.isEmpty()){
            delete relationship;
        }
        loadEntities();
        return null;
    }

    public PageReference Complete(){

        try{
            CompleteEvent();
            return GoToNextEvent();
        }
        catch(Exception ex) {
            System.debug ('this is the exc , ' + ex.getMessage());
        }
        return null;
    }

    public PageReference AddNewIndividual(){
        ShowUBOPopup = true;
        ShowSearchPopup = false;
        currentEntityType = 'Person';
        EditRelationship = new Related_Customer_Entity_Relationship__c();
        EditRelationship.Related_Customer_Entity__r = new Related_Customer_Entity__c();
        EditRelationship.Related_Customer_Entity__r.RecordTypeId =
                Schema.SObjectType.Related_Customer_Entity__c.getRecordTypeInfosByDeveloperName()
                        .get('Person').getRecordTypeId();
        return null;
    }

    public PageReference AddNewCompany(){
        ShowUBOPopup = true;
        ShowSearchPopup = false;
        currentEntityType = 'Business';
        EditRelationship = new Related_Customer_Entity_Relationship__c();
        EditRelationship.Related_Customer_Entity__r = new Related_Customer_Entity__c();
        EditRelationship.Related_Customer_Entity__r.RecordTypeId =
                Schema.SObjectType.Related_Customer_Entity__c.getRecordTypeInfosByDeveloperName()
                        .get('Business').getRecordTypeId();
        return null;
    }

    public PageReference searchForEntity(){
        ShowUBOPopup = false;

        Set<ID> entitiesToIgnore = new Set<Id>();
        Set<String> ebsIdsToIgnore = new Set<String>();
        Set<Id> accountIdsToIgnore = new Set<Id>();

        for(Related_Customer_Entity_Relationship__c relationship : relatedEntities){
            entitiesToIgnore.add(relationship.Related_Customer_Entity__c);
            if(String.isNotBlank(relationship.Related_Customer_Entity__r.Ebs_id__c)){
                ebsIdsToIgnore.add(relationship.Related_Customer_Entity__r.Ebs_id__c);
            }
            if(relationship.Related_Customer_Entity__r.Account__c != null){
                accountIdsToIgnore.add(relationship.Related_Customer_Entity__r.Account__c);
            }
        }


        String nameSearch = searchText + '%';

        searchResults = [Select Id, Name__c,EBS_Id__c,Address_Street__c,Address_City__c,Post_Code__c,RecordTypeId,Account__c,
                            RecordType.Name, Date_of_Birth__c, Date_of_incorporation__c, RecordType.DeveloperName
        From Related_Customer_Entity__c
                                                    WHERE (Name__c like :nameSearch OR EBS_Id__c=:searchText
                                                        OR Post_Code__c like:searchText
                                                        OR Address_Street__c like:nameSearch) AND Id not in:entitiesToIgnore limit 20 ];

        for(Related_Customer_Entity__c customerEntity : searchResults){
            if(customerEntity.Account__c != null){accountIdsToIgnore.add(customerEntity.Account__c);}
        }


        tooManyResults = searchResults.size() == 20;

        searchResultsAccount = [SELECT Id, Name,RecordTypeId,RecordType.Name,RecordType.DeveloperName, BillingStreet, BillingCity, BillingPostalCode, EBS_ID__c,
                                Date_of_Birth__c
                                FROM Account
                                        WHERE (Name like : nameSearch OR EBS_ID__c =:searchText)
                                        AND EBS_ID__c not in : ebsIdsToIgnore AND Id not in: accountIdsToIgnore
                                        limit 20];



        ShowSearchPopup = !searchResults.isEmpty() || !searchResultsAccount.isEmpty();

        system.debug(entitiesToIgnore);
        system.debug(ebsIdsToIgnore);
        system.debug(accountIdsToIgnore);


        return null;

    }
}