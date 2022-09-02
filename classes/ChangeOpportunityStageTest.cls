@IsTest(SeeAllData=true)
public with sharing class ChangeOpportunityStageTest {

    @IsTest
    public static void handleInboundEmailTest1() {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'INV-000005';
        email.fromName = 'FirstName LastName';
        email.plainTextBody = 'Approved';
        env.fromAddress = 'someaddress@email.com';
        ChangeOpportunityStage changeOpportunityStage = new ChangeOpportunityStage();
        Test.startTest();
        changeOpportunityStage.handleInboundEmail(email, env);
        Test.stopTest();
        Opportunity opp = [
                SELECT Id, Name, Invoice__c, StageName
                FROM Opportunity
                WHERE Invoice__c = 'INV-000005'
        ];
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        List<String> lStrings = new List<String>();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            lStrings.add(picklistEntry.getLabel());
        }
        Integer currentIndex = lStrings.indexOf(opp.StageName);
        String newStageName = lStrings.get(currentIndex + 1);

        System.assertEquals(newStageName, lStrings.get(currentIndex + 1));
    }

    @IsTest
    public static void handleInboundEmailTest2() {
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'INV-000005';
        email.fromName = 'FirstName LastName';
        email.plainTextBody = 'Rejected';
        env.fromAddress = 'someaddress@email.com';
        ChangeOpportunityStage changeOpportunityStage = new ChangeOpportunityStage();
        Test.startTest();
        changeOpportunityStage.handleInboundEmail(email, env);
        Test.stopTest();
        Opportunity opportunity = [
                SELECT Id, Name, Invoice__c, StageName
                FROM Opportunity
                WHERE Invoice__c = 'INV-000005'
        ];
        System.assertEquals(opportunity.StageName, 'Closed Lost');
    }
}