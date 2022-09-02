global class MailingBatch implements Database.Batchable<SObject> {

    global String contactQuery;

    global MailingBatch() {
        contactQuery = 'SELECT FirstName, LastName, Birthdate FROM Contact WHERE Birthdate = TODAY';
    }

    global Database.QueryLocator start(Database.BatchableContext bContext) {
        return Database.getQueryLocator(contactQuery);
    }

    global void execute(Database.BatchableContext bContext, List<Contact> contacts) {
        List<Id> ids = new List<Id>();
        for (Contact contact : contacts) {
            ids.add(contact.Id);
        }
        EmailTemplate emailTemplate = [
                SELECT Id
                FROM EmailTemplate
                WHERE Name = 'Sales: Email Template For Congratulation'
                LIMIT 1
        ];
        Messaging.MassEmailMessage email = new Messaging.MassEmailMessage();
        email.setTargetObjectIds(ids);
        email.setSenderDisplayName('System admin');
        email.setTemplateId(emailTemplate.Id);
        Messaging.sendEmail(new Messaging.MassEmailMessage[]{
                email
        });
    }

    global void finish(Database.BatchableContext bContext) {
    }
}

