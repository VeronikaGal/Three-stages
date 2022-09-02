@IsTest
public with sharing class SendInvoiceControllerTest {

    @TestSetup
    public static void testSetup() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(LastName = 'Test ' + i, Phone = '6070123', Email = 'test@gmail.com'));
        }
        insert contacts;
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            opportunities.add(new Opportunity(Name = 'Test ' + i, StageName = 'Proposal/Price Quote', CloseDate = Date.newInstance(2022, 06, 08)));
        }
        insert opportunities;
    }

    @IsTest
    public static void getInvoiceNumberTest() {
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, Invoice__c, CloseDate
                FROM Opportunity
        ];
        Test.startTest();
        String invoice = SendInvoiceController.getInvoiceNumber(opportunities[0].Id);
        Test.stopTest();
        System.assertEquals(opportunities[0].Invoice__c, invoice);
    }

    @IsTest
    public static void getEmailBodyTest() {
        String emailTemplateBody = 'Sales: Email Template For Opportunity';
        EmailTemplate emailTemplate = [
                SELECT Id, Body, Name
                FROM EmailTemplate
                WHERE Name = :emailTemplateBody
        ];
        List<Contact> contacts = [
                SELECT Id, Name, Phone, Email
                FROM Contact
        ];
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, Invoice__c, CloseDate
                FROM Opportunity
        ];
        OpportunityContactRole opportunityContactRole =
                new OpportunityContactRole(ContactId = contacts[0].Id, IsPrimary = true, OpportunityId = opportunities[0].Id);
        insert opportunityContactRole;
        Test.startTest();
        String emailBody = SendInvoiceController.getEmailBody(opportunities[0].Id);
        Test.stopTest();
        System.assertEquals(emailTemplate.Body, emailBody.replace(contacts[0].Name, '{!Contact.FirstName}'));
    }

    @IsTest
    public static void getContactNameTest() {
        List<Contact> contacts = [
                SELECT Id, Name, Phone, Email
                FROM Contact
        ];
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, Invoice__c, CloseDate
                FROM Opportunity
        ];
        OpportunityContactRole opportunityContactRole =
                new OpportunityContactRole(ContactId = contacts[0].Id, IsPrimary = true, OpportunityId = opportunities[0].Id);
        insert opportunityContactRole;
        Test.startTest();
        String contactName = SendInvoiceController.getContactName(opportunities[0].Id);
        Test.stopTest();
        System.assertEquals(contacts[0].Name, contactName);
    }

    @IsTest
    public static void getContactEmailTest() {
        List<Contact> contacts = [
                SELECT Id, Name, Phone, Email
                FROM Contact
        ];
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, Invoice__c, CloseDate
                FROM Opportunity
        ];
        OpportunityContactRole opportunityContactRole =
                new OpportunityContactRole(ContactId = contacts[0].Id, IsPrimary = true, OpportunityId = opportunities[0].Id);
        insert opportunityContactRole;
        Test.startTest();
        String contactEmail = SendInvoiceController.getContactEmail(opportunities[0].Id);
        Test.stopTest();
        System.assertEquals(contacts[0].Email, contactEmail);
    }

    @IsTest
    public static void getFileByRecordIdTest() {
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, Invoice__c, CloseDate
                FROM Opportunity
        ];
        ContentVersion contentVersion = new ContentVersion(Title = 'Test', PathOnClient = 'TestDocument.pdf',
                VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert contentVersion;
        List<ContentVersion> contentVersions = [
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :contentVersion.Id
        ];
        System.assertEquals(contentVersions.size(), 1);
        System.debug('ContentVersionID : ' + contentVersions[0].Id);
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(LinkedEntityId = opportunities[0].Id, ContentDocumentId = contentVersions[0].ContentDocumentId);
        insert contentDocumentLink;
        Test.startTest();
        Id file = SendInvoiceController.getFileByRecordId(opportunities[0].Id);
        Test.stopTest();
        System.assertEquals(contentDocumentLink.ContentDocumentId, file);
    }

    @IsTest
    public static void sendSingleEmailMessageTest() {
        String subject = 'INV-000004';
        String contactEmail = 'test@gmail.com';
        String emailBodyText = 'Test text for email';
        Test.startTest();
        SendInvoiceController.sendSingleEmailMessage(subject, contactEmail, emailBodyText);
        Test.stopTest();
    }
}


