/**
 * Created by User on 6/21/2022.
 */
@IsTest
public with sharing class MailingBatchSchedulerTest {

    @TestSetup
    public static void testSetup() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            contacts.add(new Contact(FirstName = 'test' + i, LastName = 'test' + i,
                    Birthdate = Date.today(), Email = 'galeeva.ver@gmail.com'));
        }
        insert contacts;
    }

    @IsTest
    public static void sendEmailTest() {
        Test.startTest();
        MailingBatch obj = new MailingBatch();
        Id batchId = Database.executeBatch(obj);

        MailingSchedule mailingSchedule = new MailingSchedule();
        mailingSchedule.execute(null);
        Test.stopTest();

        AsyncApexJob apexJob = [
                SELECT Id
                FROM AsyncApexJob
                WHERE Id = :batchId
        ];
        System.assertEquals(batchId, apexJob.Id);
    }
}
