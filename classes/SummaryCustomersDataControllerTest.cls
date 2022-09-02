@IsTest
public with sharing class SummaryCustomersDataControllerTest {

    @TestSetup
    public static void testSetup() {
        List<Product2> product2s = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            product2s.add(new Product2(Name = 'Test' + i));
        }
        insert product2s;
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Test ' + i));
        }
        insert accounts;
        Id pricebookId = Test.getStandardPricebookId();
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            opportunities.add(new Opportunity(Name = 'Test ' + i, Amount = 10000, AccountId = accounts[0].Id,
                    StageName = 'Closed Won', Pricebook2Id = pricebookId, CloseDate = Date.newInstance(2022, 04, 08)));
        }
        insert opportunities;
    }

    @IsTest
    public static void getProductsTest() {
        List<Product2> product2s = [
                SELECT Id, Name
                FROM Product2
        ];
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, CloseDate
                FROM Opportunity
        ];
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product2s[0].Id, UnitPrice = 100, IsActive = true);
        insert standardPrice;
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(OpportunityId = opportunities[0].Id, Product2Id = product2s[0].Id, Quantity = 3,
                UnitPrice = standardPrice.UnitPrice);
        insert opportunityLineItem;
        Test.startTest();
        List<OpportunityLineItem> opportunityLineItems = SummaryCustomersDataController.getProducts(opportunities[0].Id);
        Test.stopTest();
    }

    @IsTest
    public static void getOpportunityWrappersTest1() {
        List<Account> accounts = [
                SELECT Id, Name, Total_Amount__c
                FROM Account
        ];
        Test.startTest();
        SummaryCustomersDataController.getOpportunityWrappers(accounts[0].Id);
        Test.stopTest();
    }

    @IsTest
    public static void getOpportunityWrappersTest2() {
        Test.startTest();
        SummaryCustomersDataController.getOpportunityWrappers(null);
        Test.stopTest();
    }
}