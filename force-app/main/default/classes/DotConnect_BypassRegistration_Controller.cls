/**
 * Created by lbrindle on 05/11/2019.
 */

public with sharing class DotConnect_BypassRegistration_Controller {

    public Datetime bypassDate {get;set;}
    public Datetime bypassExpire {get;set;}
    public String currentBypassPeriod {get;set;}
    public Account acc {get;set;}

    public DotConnect_BypassRegistration_Controller(ApexPages.StandardController stdController) {
        this.acc = [SELECT Id, Bypass_Registration_Security_Until__c, Bypass_Registration_Started__c,Registration_Bypass_Active__c FROM Account
                   WHERE Id =: stdController.getRecord().Id];

    }


    public PageReference bypass(){
        acc.Bypass_Registration_Started__c = DateTime.Now();
        update acc;

        acc = [SELECT Id, Bypass_Registration_Security_Until__c, Bypass_Registration_Started__c,Registration_Bypass_Active__c FROM Account
        WHERE Id =: acc.Id];
        return null;
    }
}