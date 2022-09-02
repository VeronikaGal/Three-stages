global with sharing class SummaryCustomersDataController {

    @AuraEnabled
    public static List<OpportunityLineItem> getProducts(String opportunityId) {
        List<OpportunityLineItem> opportunityLineItems = [
                SELECT Id, Opportunity.IsClosed, OpportunityId, Product2.Name, Quantity, UnitPrice, TotalPrice
                FROM OpportunityLineItem
                WHERE Opportunity.IsClosed = TRUE AND OpportunityId = :opportunityId
        ];
        System.debug(opportunityLineItems);
        return opportunityLineItems;
    }

    @AuraEnabled
    public static List<Wrapper> getOpportunityWrappers(String recordId) {
        System.debug('record' + recordId);
        Map<Id, Wrapper> wrapperMap = new Map<Id, Wrapper>();
        String getOpportunities = 'SELECT Id, AccountId, Account.Name, Name, CreatedDate, CloseDate, Amount, Account.Total_Amount__c FROM Opportunity WHERE IsClosed = TRUE';
        List<Opportunity> opportunities = new List<Opportunity>();

        if (recordId == null) {
            opportunities = Database.query(getOpportunities);
        } else {
            opportunities = Database.query(getOpportunities + ' AND AccountId =: recordId');
        }
        for (Opportunity opportunity : opportunities) {
            Wrapper wrapper = new Wrapper();
            if (wrapperMap.containsKey(opportunity.AccountId)) {
                wrapperMap.get(opportunity.AccountId).listOpportunities.add(opportunity);
            } else {
                wrapper.account = opportunity.Account.Name + '----Total amount: ' + opportunity.Account.Total_Amount__c;
                wrapper.listOpportunities = new List<Opportunity>{
                        opportunity
                };
                wrapperMap.put(opportunity.AccountId, wrapper);
            }
        }
        System.debug('map' + wrapperMap.values());
        return wrapperMap.values();
    }

    global class Wrapper {

        @AuraEnabled
        public String account { get; set; }
        @AuraEnabled
        public List<Opportunity> listOpportunities { get; set; }

        public Wrapper() {
            this.account = account;
            this.listOpportunities = listOpportunities;
        }
    }
}