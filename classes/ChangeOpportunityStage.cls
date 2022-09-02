global class ChangeOpportunityStage implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
            Messaging.InboundEnvelope env) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String subject = email.subject.replace('Re: ', '');
        System.debug(subject);
        String approvedSearch = 'Approved';
        String rejectedSearch = 'Reject';
        Opportunity currentOpportunity = [
                SELECT Id, StageName, Invoice__c
                FROM Opportunity
                WHERE Opportunity.Invoice__c = :subject
                LIMIT 1
        ];
        System.debug('subject ' + subject + ' opportunity ' + currentOpportunity.StageName);

        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        List<String> lStrings = new List<String>();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            lStrings.add(picklistEntry.getLabel());
        }
        Integer currentIndex = lStrings.indexOf(currentOpportunity.StageName);
        String newStageName = lStrings.get(currentIndex + 1);
        if (email.plainTextBody.contains(approvedSearch)) {
            currentOpportunity.StageName = newStageName;
            update currentOpportunity ;
            result.success = true;
        } else if (email.plainTextBody.contains(rejectedSearch)) {
            currentOpportunity.StageName = 'Closed Lost';
            update currentOpportunity;
            result.success = true;
        }
        return result;
    }
}
