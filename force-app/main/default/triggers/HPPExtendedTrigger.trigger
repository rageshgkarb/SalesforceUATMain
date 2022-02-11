/* --------------------------------------------------------------------------------- */
/* C00196 28/03/2014    Update region on opportunity from post code of new property  */
/* --------------------------------------------------------------------------------- */    

trigger HPPExtendedTrigger on HPP_extended_opportunity__c (after insert, after update, before insert, before update) {

    //M00030 start
    //Ignore the trigger if needed
    
      if(Trigger_Helper.IgnoreTrigger('HPP_extended_opportunity__c'))
        return;  
    
    
    if(TriggerByPass.IgnoreExOpp!= null)
    {
        if(TriggerByPass.IgnoreExOpp)
            return;
    }
    //M00030 end

if (trigger.isBefore)
    {
        if (trigger.isUpdate)
        {            
        
            //FieldAuditing.trackField('HPP_extended_opportunity__c', trigger.oldMap, trigger.newMap);
            
            Trigger_Helper.Audit('HPP_extended_opportunity__c',trigger.oldMap, trigger.newMap);
           
            
            /* C00196 *
            for (HPP_Extended_Opportunity__c exOpp : trigger.new )
            {
                string region = '';
                region = Trigger_helper.SetRegion (exOpp);
                if (!String.IsBlank(region))
                {
                    exOpp.RegionClass__c = region;
                }
            }
             C00196 */
             
            /* C00196 */
            List<string> OppIds = new List<string>();
            Map<ID, string> opps2PostCode_map = new Map<ID, string>();
            List<string> postcodes = new List<string>();
                 
            for ( HPP_Extended_Opportunity__c extOpp : trigger.new )
            {
                OppIds.Add(extOpp.Opportunity__c);
            }
            
            List<Opportunity> opps = [SELECT Id,
                                         New_property_postcode__c
                                  FROM   Opportunity
                                  WHERE  Id in :OppIds];  
            
            for ( Opportunity opp : opps )
            {
                postcodes.Add (opp.new_property_postcode__c);
                opps2PostCode_map.put (opp.id, opp.new_property_postcode__c);
            } 
            
            PostCodeMethods pcm = new PostCodeMethods (postcodes);   
            
            for ( HPP_Extended_Opportunity__c exOpp : trigger.new )
            {
                string region = '';
                region = pcm.PostCodeToRegions.get(opps2PostCode_map.get(exOpp.Opportunity__c));
                if ( !String.IsBlank(region))
                {
                    exOpp.RegionClass__c = region;
                }
            }
            
            /* C00196 end */ 

        }
    }
}