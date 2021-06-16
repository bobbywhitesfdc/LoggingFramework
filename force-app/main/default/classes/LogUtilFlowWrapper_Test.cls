@isTest
public class LogUtilFlowWrapper_Test {
  public static final string VAR_NOFAULT = 'NoFaultMessage';
  private testMethod static void testWrapper() {
    // Assumptions that are constants in the Flow itself
    final String APP = 'MyTestApplication';
    final String FLOWNAME = 'TestFlowFault';
    final String MSG = 'This error occurred when the flow tried to create records: REQUIRED_FIELD_MISSING:';
    final String FLOWELEMENT = 'CreateBadLeadRecord';

    Test.startTest();

    Flow.Interview.TestFlowFault testFlow = new Flow.Interview.TestFlowFault(
      new Map<String, Object>()
    );
    testFlow.start();

    Test.stopTest();

    List<ApplicationErrorLog__c> logs = [
      SELECT
        Id,
        Name,
        Application__c,
        ErrorMessage__c,
        Classname__c,
        Context__c,
        StackTrace__c,
        Methodname__c,
        LineNumber__c,
        RelatedRecordId__c
      FROM ApplicationErrorLog__c
    ];

    System.Assert(!logs.isEmpty(), 'Expected an error to be logged');
    System.AssertEquals(APP, logs[0].Application__c);
    System.AssertEquals(FLOWNAME, logs[0].Classname__c);
    System.AssertEquals(FLOWELEMENT, logs[0].Methodname__c);
    System.AssertEquals(null, logs[0].StackTrace__c);
    System.AssertEquals('Flow', logs[0].Context__c);
    System.AssertEquals(null, logs[0].RelatedRecordId__c);
    System.Assert(('' + logs[0].ErrorMessage__c).startsWith(MSG));
  }
  private testMethod static void testWrapperNoFaultValue() {
    // Assumptions that are constants in the Flow itself
    final String APP = 'MyTestApplication';
    final String FLOWNAME = 'TestFlowFault';

    // For this scenario, the flow doesn't pass values for these
    final String MSG = LogUtilFlowWrapper.DEFAULT_FAULTMSG;
    final String FLOWELEMENT = LogUtilFlowWrapper.DEFAULT_ELEMENTNAME;

    Test.startTest();

    final Map<String, Object> inputVariables = new Map<String, Object>();
    inputVariables.put(VAR_NOFAULT, 'true');
    Flow.Interview.TestFlowFault testFlow = new Flow.Interview.TestFlowFault(
      inputVariables
    );
    testFlow.start();

    Test.stopTest();

    List<ApplicationErrorLog__c> logs = [
      SELECT
        Id,
        Name,
        Application__c,
        ErrorMessage__c,
        Classname__c,
        Context__c,
        StackTrace__c,
        Methodname__c,
        LineNumber__c,
        RelatedRecordId__c
      FROM ApplicationErrorLog__c
    ];

    System.Assert(!logs.isEmpty(), 'Expected an error to be logged');
    System.AssertEquals(APP, logs[0].Application__c);
    System.AssertEquals(FLOWNAME, logs[0].Classname__c);
    System.AssertEquals(FLOWELEMENT, logs[0].Methodname__c);
    System.AssertEquals(null, logs[0].StackTrace__c);
    System.AssertEquals('Flow', logs[0].Context__c);
    System.AssertEquals(null, logs[0].RelatedRecordId__c);
    System.Assert(('' + logs[0].ErrorMessage__c).startsWith(MSG));
  }
}
