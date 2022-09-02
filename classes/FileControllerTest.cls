@IsTest
public with sharing class FileControllerTest {

    @TestSetup
    public static void testSetup() {
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            opportunities.add(new Opportunity(Name = 'Test ' + i, StageName = 'Proposal/Price Quote', CloseDate = Date.newInstance(2022, 06, 08)));
        }
        insert opportunities;
    }

    @IsTest
    public static void getFileTest1() {
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, CloseDate, Invoice__c
                FROM Opportunity
        ];
        PageReference pageRef = Page.PdfByOpportunity;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(opportunities[0].Id));
        Test.startTest();
        FileController.getFile();
        Test.stopTest();
    }

    @IsTest
    public static void getFileTest2() {
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, CloseDate, Invoice__c
                FROM Opportunity
        ];
        Blob blobData = Blob.valueOf('Test Content');
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = opportunities[0].Invoice__c;
        contentVersion.PathOnClient = opportunities[0].Invoice__c + '.pdf';
        contentVersion.VersionData = blobData;
        contentVersion.ContentLocation = 'S';
        contentVersion.IsMajorVersion = false;
        insert contentVersion;
        PageReference pageRef = Page.PdfByOpportunity;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(opportunities[0].Id));
        Test.startTest();
        FileController.getFile();
        Test.stopTest();
    }
}