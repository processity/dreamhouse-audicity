trigger PropertyTrigger on Property__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {

    if (Trigger.isBefore){
        mantra.AudicityApex.track();
    }
    
    PropertyTriggerHandler.handleTrigger(
        Trigger.new,
        Trigger.newMap,
        Trigger.oldMap,
        Trigger.operationType
        );
        
    if (Trigger.isAfter){
        mantra.AudicityApex.track();
    }
}