trigger PropertyTrigger on Property__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    // ***** Add your Audicity instrumentation code on the line immediately following this comment *****

    // ***** Add your Audicity instrumentation code on the line immediately before this comment *****

    PropertyTriggerHandler.handleTrigger(
        Trigger.new,
        Trigger.newMap,
        Trigger.oldMap,
        Trigger.operationType
    );

    // ***** Add your Audicity instrumentation code on the line immediately following this comment *****

    // ***** Add your Audicity instrumentation code on the line immediately before this comment *****

}
