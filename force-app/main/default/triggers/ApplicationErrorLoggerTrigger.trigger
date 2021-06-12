/**
 * Subscribe to the ApplicationError platform event and log these errors
 * in a custom object
 **/ 
trigger ApplicationErrorLoggerTrigger on ApplicationError__e (AFTER INSERT) {
    System.debug('ApplicationErrorLoggerTrigger-begin');
    // For each event create an ApplicationError Record.
    final static integer MAXLOGS = 200;
    integer logsCreated = 0;
    final List<ApplicationErrorLog__c> logs = new List<ApplicationErrorLog__c>();
    for (ApplicationError__e current : Trigger.New)  {
        // Recovery control
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(current.ReplayId);

        final ApplicationErrorLog__c log = new ApplicationErrorLog__c();
        log.Application__c = current.Application__c;
        log.ErrorMessage__c = current.ErrorMessage__c;
        log.StackTrace__c=current.StackTrace__c;
        log.Context__c=current.Context__c;
        log.Classname__c = current.Classname__c;
        log.MethodName__c = current.MethodName__c;
        log.LineNumber__c = current.LineNumber__c;
        log.Severity__c = current.Severity__c;
        log.RelatedRecordId__c = current.RelatedRecordId__c;
        logs.add(log);
        logsCreated++;
        
        // Limit max events processed in one trigger execution
        if (logsCreated >= MAXLOGS) { break; }
    }
    insert logs;
}