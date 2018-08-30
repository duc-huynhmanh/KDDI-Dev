global class auCxKnowledgeEmailBatchSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
       
        // We now call the batch class to be scheduled
        auCxKnowledgeEmailBatch b = new auCxKnowledgeEmailBatch();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b, 200);
    }
   
}