trigger GrossLeadCount on Lead(after delete, after insert, after undelete,after update) {

      if (Trigger.isDelete) {
     GrossLeadCount.customPageCount(Trigger.old);
     }
     if ( trigger.isInsert || trigger.isUpdate) {
     GrossLeadCount.customPageCount(Trigger.new);
     }
     
}