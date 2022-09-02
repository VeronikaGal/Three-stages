public with sharing class MyControllerExtension {

    public final OpportunityContactRole opportunityContactRole { get; set; }
    public final Opportunity opportunity { get; set; }
    public final List<OpportunityLineItem> opportunityLineItems { get; set; }
    public final Double total { get; set; }

    public MyControllerExtension(ApexPages.StandardController stdController) {
        this.opportunity = (Opportunity) stdController.getRecord();
        this.opportunityContactRole = getContact();
        this.opportunityLineItems = getProducts();
        this.total = getSum();
    }

    public static OpportunityContactRole getContact() {
        return [
                SELECT Id, Contact.Name, Contact.Account.Name, Contact.Phone, Contact.Email, OpportunityId, IsPrimary
                FROM OpportunityContactRole
                WHERE OpportunityId = :ApexPages.currentPage().getParameters().get('id') AND IsPrimary = TRUE
                LIMIT 1
        ];
    }

    public static List<OpportunityLineItem> getProducts() {

        return [
                SELECT Product2.Name, Quantity, UnitPrice, TotalPrice
                FROM OpportunityLineItem
                WHERE OpportunityId = :ApexPages.currentPage().getParameters().get('id')
        ];
    }

    public static Double getSum() {
        List<OpportunityLineItem> opportunityLineItems = getProducts();
        Double totalSum = 0;
        for (OpportunityLineItem opportunityLineItem : opportunityLineItems) {
            totalSum += opportunityLineItem.TotalPrice;
        }
        return totalSum;
    }
}




