/**
 * Created by User on 7/14/2022.
 */
global with sharing class ExchangeRatesController{

    //String baseCurrency, Date startDate, Date endDate
    global static void doGet() {

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.exchangerate.host/latest/?base=GBP&symbols=USD,CAD,EUR&start_date=2022-01-01&end_date=2022-01-04');
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        System.debug(responseBody);


        System.debug(responseBody);
//        if (response.getStatusCode() == 200) {
//            Map<String, Wrapper> exchangeRates = (Map<String, Wrapper>) JSON.deserialize(responseBody, (Map<String, Wrapper>.class));
//
//            Date dateToday = Date.today();
//
//            List<Exchange_Rate__c> rates = new List<Exchange_Rate__c>();
//            for (Wrapper wrapper : exchangeRates.get('rates')) {
//                rates.add(new Exchange_Rate__c(
//                        GBP__c = wrapper.GBP,
//                        EUR__c = wrapper.EUR,
//                        CAD__c = wrapper.CAD,
//                        USD__c = wrapper.USD,
//                        Date__c = wrapper.date,
//                        BaseCurrency__c = wrapper.baseCurrency)
//                );
//            }
//            insert rates;
//        }
    }

//    public class Wrapper {
//        public Decimal GBP { get; set; }
//        public Decimal EUR { get; set; }
//        public Decimal CAD { get; set; }
//        public Decimal USD { get; set; }
//        public Date date { get; set; }
//        public String baseCurrency { get; set; }
//    }
}
