/* -------------------------------------------------------------------------------------------------------- */
/* C0684    MCD Tax                                                                                         */
/* -------------------------------------------------------------------------------------------------------- */

trigger AccountTrigger on Account  (
    before insert,
    before update,
    after insert,
    after update,
    before delete,
    after delete,
    after undelete
) {
    //aLog.Logger logger = new aLog.Logger('AccountTrigger');

    if(Trigger_Helper.IgnoreTrigger('Account'))
        return;   

    if (Trigger.isBefore) {
        
        if (Trigger.isInsert) {
            AccountTriggerMethods.beforeInsert(Trigger.New, Trigger.NewMap);
        } else if (Trigger.isUpdate) {
            AccountTriggerMethods.beforeUpdate(Trigger.Old, Trigger.OldMap, Trigger.New, Trigger.NewMap);
        } else if (Trigger.isDelete) {
            AccountTriggerMethods.beforeDelete(Trigger.Old, Trigger.OldMap);
        }
        
    } else if (Trigger.isAfter) {
        
        if (Trigger.isInsert) {
            AccountTriggerMethods.afterInsert(Trigger.New, Trigger.NewMap);
        } else if (Trigger.isUpdate) {
            AccountTriggerMethods.afterUpdate(Trigger.Old, Trigger.OldMap, Trigger.New, Trigger.NewMap);
        } else if (Trigger.isDelete) {
            AccountTriggerMethods.afterDelete(Trigger.Old, Trigger.OldMap);
        } else if (Trigger.isUndelete) {
            AccountTriggerMethods.afterUndelete(Trigger.New, Trigger.NewMap);
        }
        
    }

        /*
        String ProfileId = UserInfo.getProfileId();
        String ProfileName = null;
        if (ProfileId != null)
        {
          //Profile usrProfile = [SELECT Id, Name from Profile WHERE Id =:ProfileId LIMIT 1];
          //ProfileName = usrProfile.Name;
        } 
        */ 
        //if (ProfileName != 'System Administrator')
        //  return;
          
    //    if (trigger.isBefore)
    //    {
            
    //        if (trigger.isInsert)
    //        {
                
            
    //            logger.Trace('Trigger: Before Insert for Account :' + trigger.new[0].id);
    //            logger.Trace('Calling Capitalize Account');
    //            AccountTriggerMethods.Capitalize(trigger.new);
    //            logger.Trace('Populating District');
    //            AccountTriggerMethods.populateDistrict(trigger.new);
                
    //            DuplicateAccount__c mcs = DuplicateAccount__c.getValues('Default'); 
    //            if(mcs != null  )
    //            {
    //                logger.Trace('Duplicate account record type :' + mcs.ExternalRecordType__c);
    //                system.debug('Record type compare : trigger=' + trigger.new[0].recordtypeId + ' config=' +  mcs.ExternalRecordType__c);
                
                
    //                //Only check for duplicates if the system is turned on, and the account record type is not the external HPPCAA record type                
    //                Boolean checkDuplicate = true;
    //                if(mcs.ExternalRecordType__c != null)
    //                {
    //                    logger.Trace('Checking external record type ' + mcs.ExternalRecordType__c + ' against account ' + trigger.new[0].recordtypeid);
    //                    if(mcs.ExternalRecordType__c.equalsIgnoreCase(string.valueof(trigger.new[0].recordtypeid)))
    //                    {
    //                        checkDuplicate = false;
    //                    }
    //                }                
                    
    //                if(mcs.no_allowed__c > -1 && checkDuplicate)
    //                {                
    //                    try
    //                    {                
    //                        logger.Trace('Checking for duplicate on insert');
    //                        Account a = trigger.new[0];
                        
    //                    //we need date of birth and first name.last name for the check
    //                    if( a.date_of_birth__c != null 
    //                            && a.lastname != null && a.firstname != null)
    //                    {
    //                        if(a.name != null)
    //                        {
    //                            system.debug('Name to check : ' + a.name);
    //                            if(a.firstname.EqualsIgnoreCase('New') && a.lastname.equalsIgnoreCase('Account'))
    //                            {
    //                                //Liabilities account insert
    //                                logger.Info('Checking for duplicate');
    //                                logger.Trace('Account Data:');
    //                                logger.Trace('Insert: FirstName: ' + a.firstName + ' LastName: ' + a.lastName + ' DOB: ' + a.date_of_birth__c );
    //                                AccountTriggerMethods.CheckDuplicate(a,mcs.no_allowed__c.intValue() );
    //                            }
    //                        }
    //                        else
    //                        {
    //                            //HPP CAA internal insert
    //                            AccountTriggerMethods.CheckDuplicate(a,mcs.no_allowed__c.intValue() );
    //                        }    
    //                    }
    //                  }
    //                  catch(Exception ex)
    //                  {
    //                      throw ex;
    //                  }
    //                }
    //            }
                
    //        }
    //        if (trigger.isUpdate)
    //        {
    //            logger.Trace('Before Update Trigger for account :' + trigger.new[0].id);
    //            logger.Trace('Calling Capitalize Account');
    //            AccountTriggerMethods.Capitalize(trigger.new);
            
    //            DuplicateAccount__c mcs = DuplicateAccount__c.getValues('Default'); 
    //            if(mcs != null  )
    //            {
    //                 Boolean checkDuplicate = true;
    //                if(mcs.ExternalRecordType__c != null)
    //                {
    //                    if(mcs.ExternalRecordType__c.equalsIgnoreCase(string.valueof(trigger.new[0].recordtypeid)))
    //                    {
    //                        checkDuplicate = false;
    //                        logger.Trace('Skipping duplicate check because config record type ' +mcs.ExternalRecordType__c + ' matches account record type ' + trigger.new[0].recordtypeid );
    //                    }
    //                }
                
    //                if(mcs.no_allowed__c > -1 && checkDuplicate)
    //                {
    //                    try
    //                    {
    //                    Account a = trigger.new[0];
    //                    Account b = trigger.old[0];
                        
    //                    logger.trace('Checking for a change of lastname, firstname or date of birth');
                        
    //                    if(a.firstname != null && b.firstname != null & a.lastname != null && b.lastname != null && a.date_of_birth__c != null && b.date_of_birth__c != null)
    //                    {                        
    //                        if(!a.firstname.equalsIgnoreCase(b.firstname) || !a.lastname.equalsIgnoreCase(b.lastname) || a.date_of_birth__c != b.date_of_birth__c)
    //                        {
    //                            //Name of date of birth has changed, check that it's not now a duplicate
    //                            if(b.firstname.EqualsIgnoreCase('New') && b.lastname.equalsIgnoreCase('Account'))
    //                            {                            
    //                                logger.Info('Checking for duplicate');
    //                                logger.Trace('Account Data:');
    //                                logger.Trace('Before: FirstName: ' + b.firstName + ' LastName: ' + b.lastName + ' DOB: ' + b.date_of_birth__c );
    //                                logger.Trace('After: FirstName: ' + a.firstName + ' LastName: ' + a.lastName + ' DOB: ' + a.date_of_birth__c );                                
    //                                AccountTriggerMethods.CheckDuplicate(a,mcs.no_allowed__c.intValue() );
    //                            }
    //                        }
    //                    }
    //                    else
    //                    {
    //                        logger.Trace('No change detected, skipping account duplicate check');
    //                    }
    //                    }
    //                    catch(Exception ex)
    //                    {
    //                        logger.Fatal('Unexpected error',ex);
    //                        throw ex;
    //                    }
    //                }
    //            }
            
    //            AccountTriggerMethods.populateDistrict(trigger.new);
                
    //          /* C0CPDR */
    //          //Account ac = trigger.new[0];
    //          //AccountTriggerMethods.DoTax (ac.id);

    //          /**/
    //            Trigger_Helper.Audit('Account',trigger.oldMap, trigger.newMap);            
    //        }
    //    }

    //  /* C0684 */
    //  if (trigger.isAfter)
    //    {
    //      if(trigger.IsUpdate)
    //      {
    //          CAA_Settings__c sett = [select id, value__c from CAA_Settings__c where name = 'SendMCDOnTaxChanges'];
    //          if (sett.value__c == 'YES')
    //          {
    //              List<Fields_for_Triggers__c> flds = [SELECT id, API_Field_Name__c FROM Fields_for_Triggers__c WHERE SObject_Name__c = 'Account' and Is_Active__c = true];
    //              if (flds.Size() > 0)
    //              {
    //                  Account a = trigger.new[0];
    //                  Account b = trigger.old[0];
    //                  if (!String.IsBlank(a.EBS_ID__c ) && !String.IsBlank(b.EBS_ID__c))
    //                  {
    //                      SObject aSObject = new Account();
    //                      SObject bSObject = new Account();
    //                      aSObject = a;
    //                      bSObject = b;
    //                      boolean fldChange = false;
    //                      for (Fields_for_Triggers__c fld : flds)
    //                      {
    //                          if (aSObject.get(fld.API_Field_Name__c) != bSObject.get(fld.API_Field_Name__c))
    //                          {
    //                              fldChange = true;
    //                              break;
    //                          }
                            
    //                      }
    //                      if (fldChange)
    //                      {
    //                          string weblogid = Teller_Core_Controller.CreateWebLog (a.id, true);
    //                      }
    //                  }
    //              }
    //          }
    //      }
    //  }
    //  /* C0684 */
    //}
    //catch(Exception ex)
    //{
    //    logger.Fatal('Unexpected Error',ex);
    //}    
        
    //aLog.TriggerSave();
}