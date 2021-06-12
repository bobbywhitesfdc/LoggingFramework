@isTest
public class LogUtilFlowWrapper_Test {
    private testmethod static void testWrapper() {
        // Assumptions that are constants in the Flow itself
        final String APP='MyTestApplication';
        final String FLOWNAME='TestFlowFault';
        final String MSG='This error occurred when the flow tried to create records: REQUIRED_FIELD_MISSING:';
        final String FLOWELEMENT='CreateBadLeadRecord';
        
        Test.startTest();
        
        Flow.Interview.TestFlowFault testFlow = new Flow.Interview.TestFlowFault(new map<String,Object>());
        testFlow.start();
        
        Test.stopTest();
        
        List<ApplicationErrorLog__c> logs = [Select Id, Name
                                             , Application__c
                                             , ErrorMessage__c
                                             , Classname__c
                                             , Context__c
                                             , StackTrace__c
                                             , Methodname__c
                                             , LineNumber__c
                                             , RelatedRecordId__c 
                                            FROM ApplicationErrorLog__c];
        
        System.Assert(!logs.isEmpty(),'Expected an error to be logged');
        System.AssertEquals(APP,logs[0].Application__c);
        System.AssertEquals(FLOWNAME,logs[0].Classname__c);
        System.AssertEquals(FLOWELEMENT,logs[0].Methodname__c);
        System.AssertEquals(null,logs[0].StackTrace__c);
        System.AssertEquals('Flow',logs[0].Context__c);
        System.AssertEquals(null,logs[0].RelatedRecordId__c);
        System.Assert((''+logs[0].ErrorMessage__c).startsWith(MSG));
    }
}