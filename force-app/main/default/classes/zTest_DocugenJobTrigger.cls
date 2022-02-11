@isTest
private class zTest_DocugenJobTrigger
{
    private Docugen_Job__c job;
    
    private void Tests1(){
        
            /*job=new Docugen_Job__c();
        
            job.Status__c='Pending';
            
            insert job;*/
            Docugen_Job__c firstJob;
            List<Docugen_Job__c> lstJobs=[select id from Docugen_Job__c];
            
            if (lstJobs.Size() > 0)
            {
            
            
                firstJob=lstJobs[0];
            }
            else 
            {
                Docugen_EBS_template__c foo = new Docugen_EBS_template__c ();
                insert foo;
                firstJob = new Docugen_Job__c ();
                firstJob.Docugen_EBS_template__c = foo.Id;
                insert firstJob;
            }
            
            firstjob.Status__c='deleted';
            
            update firstJob;
            
            delete firstJob;
            
            
        

    }
    
    static testMethod void testOne()
    {
        zTest_DocugenJobTrigger testable = new zTest_DocugenJobTrigger();
       testable.Tests1();
        
    }
    
    static testMethod void Test_IgnoreTrigger()
    {
        Trigger_Helper.TriggerItem t = new Trigger_Helper.TriggerItem();
        t.IgnoreTrigger = true;
        t.name = 'Docugen_Job__c';
        
        Trigger_Helper.Items.add(t);
        
        Boolean b = Trigger_Helper.IgnoreTrigger('Docugen_Job__c');
        system.assertequals(true,b);
    
        zTest_DocugenJobTrigger testable = new zTest_DocugenJobTrigger();
        testable.Tests1();
        
    }
}