/**
 * Created by User on 6/17/2022.
 */
public with sharing class ScheduleBatchApexController {

    @AuraEnabled(Cacheable= true)
    public static Id executeBatchJob(String batch) {
        Type newBatchType = Type.forName(batch);
        Id batchJobId = Database.executeBatch((Database.Batchable<SObject>) newBatchType.newInstance());
        return batchJobId;
    }

    @AuraEnabled (Cacheable = true)
    public static Id scheduleBatch(String scheduler, String cronString) {
        Type newSchedulerType = Type.forName(scheduler);
        Id scheduleJobId = System.schedule(scheduler, cronString, (Schedulable) newSchedulerType.newInstance());
        return scheduleJobId;
    }

    @AuraEnabled (Cacheable = false)
    public static void abortBatch(Id scheduleJobId) {
        System.abortJob(scheduleJobId);
    }

    @AuraEnabled (Cacheable = false)
    public static Id getJobId(String scheduler) {
        CronTrigger cronTrigger = [
                SELECT Id, CronJobDetail.Name
                FROM CronTrigger
                WHERE CronJobDetail.Name = :scheduler
                LIMIT 1
        ];
        if (cronTrigger != null) {
            return cronTrigger.Id;
        } else {
            return null;
        }
    }
}