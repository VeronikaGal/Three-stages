 @IsTest
public with sharing class ScheduleBatchApexControllerTest {

    @IsTest
    public static void executeBatchJobTest() {
        String className = 'MailingBatch';
        Test.startTest();
        Id jobId = ScheduleBatchApexController.executeBatchJob(className);
        Test.stopTest();
        AsyncApexJob apexJob = [SELECT Id FROM AsyncApexJob WHERE Id = :jobId];
        System.assertEquals(apexJob.Id, jobId);
    }

    @IsTest
    public static void scheduleBatchTest() {
        String scheduler = 'MailingSchedule';
        String cronString = '0 0 0 * * ?';
        Test.startTest();
        Id jobId = ScheduleBatchApexController.scheduleBatch(scheduler, cronString);
        Test.stopTest();
        CronTrigger cronTrigger = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronTrigger.Id, jobId);
    }

    @IsTest
    public static void abortBatchTest() {
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1); String ss = String.valueOf(Datetime.now().second());
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        MailingSchedule mailingSchedule = new MailingSchedule();
        System.schedule('CronJobNameToDelete' + String.valueOf(Datetime.now()), nextFireTime, mailingSchedule);
        Id jobId = System.schedule('TestJob' + String.valueOf(Datetime.now()), nextFireTime, mailingSchedule);
        Test.startTest();
        ScheduleBatchApexController.abortBatch(jobId);
        Test.stopTest();
    }

    @IsTest
    public static void getJobIdTest() {
        String cronJobName1 = 'Metalytics Data Loader Job for Org : 00D5j00000BWoW1';
        Test.startTest();
        Id jobId1 = ScheduleBatchApexController.getJobId(cronJobName1);
        Test.stopTest();
        System.assertEquals(jobId1, '08e5j00000BWDZLAA5');
    }
}