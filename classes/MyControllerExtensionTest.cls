@IsTest
public with sharing class MyControllerExtensionTest {

    @TestSetup
    public static void testSetup() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(LastName = 'Test ' + i, Phone = '6070123', Email = 'test@gmail.com'));
        }
        insert contacts;
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Test ' + i));
        }
        insert accounts;
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            opportunities.add(new Opportunity(Name = 'Test ' + i, StageName = 'Proposal/Price Quote', CloseDate = Date.newInstance(2022, 06, 08)));
        }
        insert opportunities;
        List<Product2> product2s = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            product2s.add(new Product2(Name = 'Test' + i));
        }
        insert product2s;
    }

    @IsTest
    public static void testMyControllerExtension() {
        List<Contact> contacts = [
                SELECT Id, Name, Phone, Email
                FROM Contact
        ];
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, CloseDate
                FROM Opportunity
        ];
        System.debug(opportunities);
        OpportunityContactRole opportunityContactRole =
                new OpportunityContactRole(ContactId = contacts[0].Id, IsPrimary = true, OpportunityId = opportunities[0].Id);
        insert opportunityContactRole;
        Test.startTest();
        PageReference testPage = Page.PdfByOpportunity;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(opportunities[0].Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(opportunities[0]);
        MyControllerExtension myControllerExtension = new MyControllerExtension(standardController);
        Test.stopTest();
    }

    @IsTest
    public static void getContactTest() {
        List<Contact> contacts = [
                SELECT Id, Name, Phone, Email
                FROM Contact
        ];
        List<Opportunity> opportunities = [
                SELECT Id, Name
                FROM Opportunity
        ];
        List<OpportunityContactRole> opportunityContactRoles = new List<OpportunityContactRole>();
        opportunityContactRoles.add(new OpportunityContactRole(ContactId = contacts[0].Id, OpportunityId = opportunities[0].Id, IsPrimary = true));
        insert opportunityContactRoles;
        PageReference pageRef = Page.PdfByOpportunity;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(opportunities[0].Id));
        Test.startTest();
        OpportunityContactRole opportunityContactRole = MyControllerExtension.getContact();
        Test.stopTest();
        System.assertEquals(opportunityContactRole.Id, opportunityContactRoles[0].Id);
    }

    @IsTest
    public static void getSumTest() {
        List<Product2> product2s = [
                SELECT Id, Name
                FROM Product2
        ];
        List<Opportunity> opportunities = [
                SELECT Id, Name
                FROM Opportunity
        ];
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product2s[0].Id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        opportunityLineItems.add(new OpportunityLineItem(Product2Id = product2s[0].Id, Quantity = 2, UnitPrice = standardPrice.UnitPrice, PricebookEntryId = standardPrice.Id, OpportunityId = opportunities[0].Id));
        insert opportunityLineItems;
        PageReference pageRef = Page.PdfByOpportunity;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(opportunities[0].Id));
        Test.startTest();
        List<OpportunityLineItem> opportunityLineItem = MyControllerExtension.getProducts();
        MyControllerExtension.getSum();
        Test.stopTest();
        System.assertEquals(opportunityLineItem[0].Id, opportunityLineItems[0].Id);
    }
}