trigger PaymentTrigger on Payment__c (after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        TriggerHandler.afterInsertMethod(Trigger.newMap);
    }
}


