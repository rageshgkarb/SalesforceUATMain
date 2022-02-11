@isTest
private class KRIReportSelectionTest {

  private static Id setupData()
  {
    Risk__KRI__c theKRI1 = new Risk__KRI__c();
    Risk__KRI__c theKRI2 = new Risk__KRI__c();
    grc__Business_Unit__c bu = new grc__Business_Unit__c();
    List<Risk__KRI__c> KRIs = new List<Risk__KRI__c>();
    User usr = [Select Id from User where Id = :UserInfo.getUserId() LIMIT 1];
    grc__Risk__c risk1;
    
    System.RunAs(usr)
      {  
      Test.startTest();
      bu.Name = 'TestBU';
      bu.Risk__Sharing_Group_Name__c = 'TestBU';
      
      insert bu;
      
      risk1 = new grc__Risk__c(Name='name 1', grc__Business_Unit__c= bu.id);
      insert risk1;
      
      theKRI1.Name = 'Test KRI1';
      theKRI1.Risk__Business_Unit__c = bu.Id;
      insert theKRI1;
      theKRI2.Name = 'Test KRI2';
      theKRI2.Risk__Business_Unit__c = bu.Id;
      insert theKRI2;
      
      //insert KRIs;
      Test.stopTest();
      }  
    
    Risk__Risk_KRI_Lookup__c rki = new Risk__Risk_KRI_Lookup__c(Risk__Risk__c = risk1.id,Risk__KRI__c=theKRI1.Id);
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
    
    List<Risk__KRI_Metric__c> KRIMetrics = new List<Risk__KRI_Metric__c>();
    Risk__KRI_Metric__c kriMetric = new Risk__KRI_Metric__c();
    kriMetric.Risk__KRI__c = theKRI1.Id;
    kriMetric.Risk__Metric__c = metric.Id;
    KRIMetrics.add(kriMetric);
    
    Risk__KRI_Metric__c kriMetric2 = new Risk__KRI_Metric__c();
    kriMetric2.Risk__KRI__c = theKRI1.Id;
    kriMetric2.Risk__Metric__c = metric2.Id;
    KRIMetrics.add(kriMetric2);
    
    Risk__KRI_Metric__c kriMetric3 = new Risk__KRI_Metric__c();
    kriMetric3.Risk__KRI__c = theKRI1.Id;
    kriMetric3.Risk__Metric__c = metric3.Id;
    KRIMetrics.add(kriMetric3);
    
    Risk__KRI_Metric__c kriMetric4 = new Risk__KRI_Metric__c();
    kriMetric4.Risk__KRI__c = theKRI1.Id;
    kriMetric4.Risk__Metric__c = metric4.Id;
    KRIMetrics.add(kriMetric4);
    
    Risk__KRI_Metric__c kriMetric5 = new Risk__KRI_Metric__c();
    kriMetric5.Risk__KRI__c = theKRI2.Id;
    kriMetric5.Risk__Metric__c = metric.Id;
    KRIMetrics.add(kriMetric5);
    
    Risk__KRI_Metric__c kriMetric6 = new Risk__KRI_Metric__c();
    kriMetric6.Risk__KRI__c = theKRI2.Id;
    kriMetric6.Risk__Metric__c = metric2.Id;
    KRIMetrics.add(kriMetric6);
    insert KRIMetrics;
    
    KRIs.add(theKRI1);
    KRIs.add(theKRI2);
    
    return bu.id;
  }
  
  static testMethod void testKRIStandardSetController() 
  {
    Id buId = setupData();
    KRIReportSelection krS = new KRIReportSelection();
    List<SelectOption> range = krs.getDateRange();
    system.assert(range.size() == 3);
    PageReference pgwithError = krs.buildReport();
    system.assert(pgwithError == null);
    krs.dateRanges = '1 Month';
    krs.chosenBusinessUnitId = buId;
    krs.getSelection();
    PageReference pgwithoutError = krs.buildReport();
    system.assert(pgwithoutError.geturl().contains('krireport'));
    krs.dateRanges = '3 Months';
    krs.buildReport();
  }
}