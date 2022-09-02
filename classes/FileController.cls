public with sharing class FileController {

    public static void getFile() {
        Opportunity opportunity = [
                SELECT Id, Invoice__c
                FROM Opportunity
                WHERE Opportunity.Id = :ApexPages.currentPage().getParameters().get('id')
                LIMIT 1
        ];
        PageReference pageReference = Page.PdfByOpportunity;
        pageReference.getParameters().put('id', ApexPages.currentPage().getParameters().get('id'));
        Blob blobData;
        if (Test.isRunningTest()) {
            blobData = Blob.valueOf('Unit.Test');
        } else {
            blobData = pageReference.getContent();
        }
        ContentVersion contentVersion = new ContentVersion();
        List <ContentVersion> contentVersions = [
                SELECT Id, Title, ContentSize, PathOnClient, VersionData
                FROM ContentVersion
                WHERE Title = :opportunity.Invoice__c
                AND IsMajorVersion = FALSE
                LIMIT 1
        ];
        if (contentVersions.size() > 0) {
            contentVersion = contentVersions[0];
            contentVersion.VersionData = blobData;
            update contentVersion;
        } else {
            contentVersion.Title = opportunity.Invoice__c;
            contentVersion.PathOnClient = opportunity.Invoice__c + '.pdf';
            contentVersion.VersionData = blobData;
            contentVersion.ContentLocation = 'S';
            contentVersion.IsMajorVersion = false;
            insert contentVersion;
            Id contentDocumentId = [
                    SELECT ContentDocumentId, IsLatest
                    FROM ContentVersion
                    WHERE Id = :contentVersion.Id
            ].ContentDocumentId;
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                    LinkedEntityId = opportunity.Id,
                    ContentDocumentId = contentDocumentId);
            insert contentDocumentLink;
        }
    }
}




