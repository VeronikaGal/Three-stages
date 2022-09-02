@IsTest
public with sharing class MyRestResourceTest {

    @TestSetup
    public static void testSetup() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            accounts.add(new Account(Name = 'Test ' + i, OwnerId = UserInfo.getUserId()));
        }
        insert accounts;
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            contacts.add(new Contact(FirstName = 'Test ' + i, LastName = 'Test ' + i, Phone = '6070123', Email = 'test@gmail.com', OwnerId = UserInfo.getUserId()));
        }
        insert contacts;
        Id pricebookId = Test.getStandardPricebookId();
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            opportunities.add(new Opportunity(Name = 'Test ' + i, Amount = 1500, ContactId = contacts[0].Id,
                    StageName = 'Needs Analysis', Pricebook2Id = pricebookId, CloseDate = Date.newInstance(2022, 08, 08)));
        }
        insert opportunities;
        OpportunityContactRole opportunityContactRole =
                new OpportunityContactRole(ContactId = contacts[0].Id, OpportunityId = opportunities[0].Id, IsPrimary = true);
        insert opportunityContactRole;
        List<Payment__c> payments = new List<Payment__c>();
        for (Integer i = 0; i < 3; i++) {
            payments.add(new Payment__c(Opportunity__c = opportunities[0].Id,
                    Amount__c = 500,
                    First_Name__c = 'Petr' + i,
                    Last_Name__c = 'Petrov' + i));
        }
        insert payments;
    }

    @IsTest
    private static void doPostTest() {
        List<Opportunity> opportunities = [
                SELECT Id, StageName, ContactId, AccountId, OwnerId, Amount, Total_Amount__c
                FROM Opportunity
        ];
        System.debug('opp ' + opportunities[0].StageName);
        String requestJson = String.valueOf('{\"payments\":[{\"Opportunity\":\"' + opportunities[0].Id +
                '\",\"Amount\":500,\"FirstName\":\"Test\",\"LastName\":\"Test\"},' +
                '{\"Opportunity\":\"' + opportunities[0].Id + '\",' +
                '\"Amount\":600,' +
                '\"FirstName\":\"TestName\",' +
                '\"lastName\":\"TestLastName\"}]}');
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/services/apexrest/Payment';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestJson);

        Test.startTest();
        MyRestResource.doPost();
        Test.stopTest();
        System.debug('stage' + opportunities[0].StageName);

        List <Payment__c> listPayments = [
                SELECT Id
                FROM Payment__c
        ];
        System.assertEquals(5, listPayments.size());
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(opportunities[0].StageName, 'Partially Paid');
    }
}
