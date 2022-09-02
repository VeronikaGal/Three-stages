public with sharing class SendInvoiceController {

    @AuraEnabled(Cacheable=true)
    public static String getInvoiceNumber(String opportunityId) {
        Opportunity opportunity = [
                SELECT Id, Invoice__c
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
        ];
        return opportunity.Invoice__c;
    }

    @AuraEnabled(Cacheable=true)
    public static String getEmailBody(String recordId) {
        EmailTemplate emailTemplate = [
                SELECT Id, Body
                FROM EmailTemplate
                WHERE Name = 'Sales: Email Template For Opportunity'
                LIMIT 1
        ];
        String contactName = getContactName(recordId);
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!Contact.FirstName}', contactName);
        return plainBody;
    }

    @AuraEnabled(Cacheable=true)
    public static String getContactName(String recordId) {
        OpportunityContactRole opportunityContactRole = [
                SELECT Id, Contact.Name
                FROM OpportunityContactRole
                WHERE IsPrimary = TRUE AND OpportunityId = :recordId
        ];
        return opportunityContactRole.Contact.Name;
    }

    @AuraEnabled(Cacheable=true)
    public static String getContactEmail(String recordId) {
        OpportunityContactRole opportunityContactRole = [
                SELECT Id,Contact.Email
                FROM OpportunityContactRole
                WHERE OpportunityId = :recordId AND IsPrimary = TRUE
        ];
        return opportunityContactRole.Contact.Email;
    }

    @AuraEnabled(Cacheable=true)
    public static Id getFileByRecordId(String recordId) {
        ContentDocumentLink file = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
                LIMIT 1
        ];
        Id fileId = file.ContentDocumentId;
        return fileId;
    }

    @AuraEnabled(Cacheable=true)
    public static void sendSingleEmailMessage(String subject, String contactEmail, String emailBodyText) {
        System.debug('number ' + subject + ' email ' + contactEmail + ' body ' + emailBodyText);
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[]{
                contactEmail
        };
        String[] ccAddress = new String[]{
                contactEmail
        };
        message.setToAddresses(toAddress);
        message.setCcAddresses(ccAddress);
        message.setSenderDisplayName('salesforce');
        message.setSubject(subject);
        message.setPlainTextBody(emailBodyText);
        message.setHtmlBody(emailBodyText);
        message.setReplyTo('changeopportunity@2xqvj7xzo86zyb9kemajvtt9kjzrcz79919gs5vhvuhdt6yaxz.5j-bwow1eal.ap27.apex.salesforce.com');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                message
        });
    }
}