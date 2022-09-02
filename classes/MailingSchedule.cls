global class MailingSchedule implements Schedulable{

    global void execute(SchedulableContext sc) {
        MailingBatch mailingBatch = new MailingBatch();
        Database.executeBatch(mailingBatch);
    }
}
