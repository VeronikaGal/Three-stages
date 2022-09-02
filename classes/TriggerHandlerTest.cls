/**
 * Created by User on 6/21/2022.
 */
@IsTest
public with sharing class TriggerHandlerTest {

    @TestSetup
    public static void testSetup() {
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Test ', Phone = '6070123', Email = 'test@gmail.com', OwnerId = UserInfo.getUserId()));
        insert contacts;
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Test ', OwnerId = UserInfo.getUserId()));
        insert accounts;
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            opportunities.add(new Opportunity(Name = 'Test ' + i, Amount = 0, AccountId = accounts[0].Id,
                    StageName = 'Needs Analysis', CloseDate = Date.newInstance(2022, 08, 08)));
        }
        insert opportunities;
        OpportunityContactRole opportunityContactRole =
                new OpportunityContactRole(ContactId = contacts[0].Id, IsPrimary = true, OpportunityId = opportunities[0].Id);
        insert opportunityContactRole;
        List<Payment__c> payments = new List<Payment__c>();
        for (Integer i = 0; i < 3; i++) {
            payments.add(new Payment__c(Opportunity__c = opportunities[0].Id,
                    Amount__c = 1000,
                    First_Name__c = 'Petr' + i,
                    Last_Name__c = 'Petrov' + i));
        }
        insert payments;
    }

    @IsTest
    public static void afterInsertMethodTest() {
        List<Opportunity> opportunities = [
                SELECT Id, StageName, Amount, Total_Amount__c
                FROM Opportunity
        ];
        System.debug(opportunities);
        List<Payment__c> payments = new List<Payment__c>();
        for (Integer i = 0; i < 3; i++) {
            payments.add(new Payment__c(Opportunity__c = opportunities[0].Id,
                    Amount__c = 10,
                    First_Name__c = 'Petr' + i,
                    Last_Name__c = 'Petrov' + i));
        }
        Test.startTest();
        insert payments;
        Test.stopTest();
        System.assertEquals('Fully Paid', opportunities[0].StageName);
    }
}