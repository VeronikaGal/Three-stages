@RestResource(UrlMapping='/Payment/*')
global with sharing class MyRestResource {

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();
        Map<String, List<Wrapper>> paymentFromJSON = (Map<String, List<Wrapper>>) JSON.deserialize(requestBody, (Map<String, List<Wrapper>>.class));
        List<Payment__c> payments = new List<Payment__c>();
        for (Wrapper wrapper : paymentFromJSON.get('payments')) {
            payments.add(new Payment__c(
                    Opportunity__c = wrapper.Opportunity,
                    Amount__c = wrapper.Amount,
                    First_Name__c = wrapper.FirstName,
                    Last_Name__c = wrapper.LastName)
            );
        }
        insert payments;

        RestResponse response = RestContext.response;
        String jsonResponse = '{"isSuccess" : "True" }';
        response.statusCode = 200;
        response.responseBody = Blob.valueOf(jsonResponse);
    }

    public class Wrapper {
        public String Opportunity { get; set; }
        public Decimal Amount { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
    }
}
