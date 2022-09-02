public without sharing class TriggerHandler {

    public static void afterInsertMethod(Map<Id, Payment__c> paymentMap) {
        List <Id> ids = new List<Id>();
        for (Payment__c payment : paymentMap.values()) {
            ids.add(payment.Opportunity__c);
            System.debug(payment.Amount__c);
        }
        System.debug('idsPayment' + ids);
        Map<Id, Id> idsByIds = new Map<Id, Id>();
        for (OpportunityContactRole opportunityContactRole : [
                SELECT Id, Contact.OwnerId, ContactId, OpportunityId
                FROM OpportunityContactRole
                WHERE OpportunityId IN :ids
        ]) {
            idsByIds.put(opportunityContactRole.OpportunityId, opportunityContactRole.Contact.OwnerId);
        }
        List <Opportunity> opportunities = [
                SELECT Id, StageName, OwnerId, Amount, Total_Amount__c
                FROM Opportunity
                WHERE Id IN :ids
        ];
        System.debug(opportunities);
        for (Opportunity opportunity : opportunities) {
            System.debug('tot' + opportunity.Total_Amount__c);
            System.debug('amount' + opportunity.Amount);
            System.debug('stageOpp' + opportunity.StageName);
            if (opportunity.Total_Amount__c < opportunity.Amount) {
                opportunity.StageName = 'Partially Paid';
                System.debug(opportunity.StageName);
            } else if (opportunity.Amount == opportunity.Total_Amount__c || opportunity.Amount < opportunity.Total_Amount__c) {
                opportunity.StageName = 'Fully Paid';
                Id ownerId = idsByIds.get(opportunity.Id);
                System.debug('owner' + ownerId);
                Datetime tomorrow = System.today().addDays(1);
                Datetime reminder = tomorrow.addHours(10);
                Task task = new Task(OwnerId = ownerId,
                        Priority = 'High',
                        Status = 'Not Started',
                        Subject = 'Delivery of goods',
                        ReminderDateTime = reminder,
                        WhatId = opportunity.Id);
                insert task;
            }
            update opportunity;
        }
    }
}