@isTest
public with sharing class KCIReportSelectionTest {

  private static Id setupData()
  {
    Risk__KCI__c theKCI1 = new Risk__KCI__c();
    Risk__KCI__c theKCI2 = new Risk__KCI__c();
    grc__Business_Unit__c bu = new grc__Business_Unit__c();
    List<Risk__KCI__c> KCIs = new List<Risk__KCI__c>();
    User usr = [Select Id from User where Id = :UserInfo.getUserId() LIMIT 1];
    grc__Control__c control1;
    
    System.RunAs(usr)
      {  
      Test.startTest();
      bu.Name = 'TestBU';
      bu.Risk__Sharing_Group_Name__c = 'TestBU';
      
      insert bu;
      
      control1 = new grc__Control__c(Name='name 1', grc__Business_Unit__c= bu.id);
      insert control1;
      
      theKCI1.Name = 'Test KCI1';
      theKCI1.Risk__Business_Unit__c = bu.Id;
      insert theKCI1;
      theKCI2.Name = 'Test KCI2';
      theKCI2.Risk__Business_Unit__c = bu.Id;
      insert theKCI2;
      
      //insert KCIs;
      Test.stopTest();
      }  
    
    Risk__Control_KCI_Lookup__c rki = new Risk__Control_KCI_Lookup__c(Risk__Control__c = control1.id, Risk__KCI__c=theKCI1.Id);
    insert rki;
    
    List<Risk__Metric__c> metrics = new List<Risk__Metric__c>();
    Risk__Metric__c metric = new Risk__Metric__c();
    metric.Name = 'Test Metric';
    metric.Risk__Metric_Type__c = 'Number';
    metric.Risk__Threshold_Type__c = 'Upper';
    metric.Risk__Number_Threshold__c = 100;
    metrics.add(metric);
    
    Risk__Metric__c metric2 = new Risk__Metric__c();
    metric2.Name = 'Test Metric';
    metric2.Risk__Metric_Type__c = 'Currency';
    metric2.Risk__Threshold_Type__c = 'Upper';
    metric2.Risk__Currency_Threshold__c = 200;
    metrics.add(metric2);
    
    Risk__Metric__c metric3 = new Risk__Metric__c();
    metric3.Name = 'Test Metric';
    metric3.Risk__Metric_Type__c = 'Percentage';
    metric3.Risk__Threshold_Type__c = 'Upper';
    metric3.Risk__Percentage_Threshold__c = 80;
    metrics.add(metric3);
    
    Risk__Metric__c metric4 = new Risk__Metric__c();
    metric4.Name = 'Test Metric';
    metric4.Risk__Metric_Type__c = 'Qualitative';
    metric4.Risk__Green_Threshold_Text__c = 'Green';
    metric4.Risk__Amber_Threshold_Text__c = 'Amber';
    metric4.Risk__Red_Threshold_Text__c = 'Red';
    metrics.add(metric4);
    
    insert metrics;
    
    List<Risk__KCI_Metric_Lookup__c> KCIMetrics = new List<Risk__KCI_Metric_Lookup__c>();
    Risk__KCI_Metric_Lookup__c KCIMetric = new Risk__KCI_Metric_Lookup__c();
    KCIMetric.Risk__KCI__c = theKCI1.Id;
    KCIMetric.Risk__Metric__c = metric.Id;
    KCIMetrics.add(KCIMetric);
    
    Risk__KCI_Metric_Lookup__c KCIMetric2 = new Risk__KCI_Metric_Lookup__c();
    KCIMetric2.Risk__KCI__c = theKCI1.Id;
    KCIMetric2.Risk__Metric__c = metric2.Id;
    KCIMetrics.add(KCIMetric2);
    
    Risk__KCI_Metric_Lookup__c KCIMetric3 = new Risk__KCI_Metric_Lookup__c();
    KCIMetric3.Risk__KCI__c = theKCI1.Id;
    KCIMetric3.Risk__Metric__c = metric3.Id;
    KCIMetrics.add(KCIMetric3);
    
    Risk__KCI_Metric_Lookup__c KCIMetric4 = new Risk__KCI_Metric_Lookup__c();
    KCIMetric4.Risk__KCI__c = theKCI1.Id;
    KCIMetric4.Risk__Metric__c = metric4.Id;
    KCIMetrics.add(KCIMetric4);
    
    Risk__KCI_Metric_Lookup__c KCIMetric5 = new Risk__KCI_Metric_Lookup__c();
    KCIMetric5.Risk__KCI__c = theKCI2.Id;
    KCIMetric5.Risk__Metric__c = metric.Id;
    KCIMetrics.add(KCIMetric5);
    
    Risk__KCI_Metric_Lookup__c KCIMetric6 = new Risk__KCI_Metric_Lookup__c();
    KCIMetric6.Risk__KCI__c = theKCI2.Id;
    KCIMetric6.Risk__Metric__c = metric2.Id;
    KCIMetrics.add(KCIMetric6);
    insert KCIMetrics;
    
    KCIs.add(theKCI1);
    KCIs.add(theKCI2);
    
    return bu.id;
  }
  
  static testMethod void testKCIStandardSetController() 
  {
    Id buId = setupData();
    KCIReportSelection krS = new KCIReportSelection();
    List<SelectOption> range = krs.getDateRange();
    system.assert(range.size() == 3);
    PageReference pgwithError = krs.buildReport();
    system.assert(pgwithError == null);
    krs.dateRanges = '3 Months';
    krs.chosenBusinessUnitId = buId;
    krs.getSelection();
    PageReference pgwithoutError = krs.buildReport();
    system.assert(pgwithoutError.geturl().contains('kcireport'));
    krs.dateRanges = '1 Months';
    krs.dateRanges = '6 Months';
    krs.buildReport();
  }
  
  static testMethod void test2KCIStandardSetController() 
  {
    List<String> selCategories = new List<String>{'Strategic','Conduct of Business','Financial','Operational','All'};
    Id buId = setupData();
    KCIReportSelection krS = new KCIReportSelection();
    krs.SelectedCategories.addAll(selCategories);
    krs.buildReport();
    system.assertequals(5,krS.SelectedCategories.size());
  }
}