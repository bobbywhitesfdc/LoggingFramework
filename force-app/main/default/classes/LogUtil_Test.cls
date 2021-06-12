@isTest
public class LogUtil_Test {
    private final static String APP = 'DEFAULT';
    private final static String MSG = 'Sample error';

    private testMethod static void testSimple() {
        Test.startTest();
        
        Lead myLead = new Lead(firstname='TestF',lastname='TestL',company='Acme');
        insert myLead;
        
        LogUtil.log(APP, MSG, myLead.id);
        
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
        System.AssertEquals(MSG,logs[0].ErrorMessage__c);
        System.AssertEquals(null,logs[0].Classname__c);
        System.AssertEquals(null,logs[0].Methodname__c);
        System.AssertEquals(null,logs[0].StackTrace__c);
        System.AssertEquals('Class',logs[0].Context__c);
        System.AssertEquals(''+myLead.Id,logs[0].RelatedRecordId__c);
    }
    
    private testMethod static void testFlowFault() {
        final string APP='MyFlow';
        final string FLOWNAME='MyTestFlow';
        final string FLOWELEMENT='Element1';
        final string MSG='Something went wrong in the flow';
        final Id RELATEDID= UserInfo.getProfileId();
        
        Test.startTest();
        LogUtil.logFlowFault(APP,FLOWNAME,FLOWELEMENT,MSG,RELATEDID);
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
        System.AssertEquals(MSG,logs[0].ErrorMessage__c);
        System.AssertEquals(FLOWNAME,logs[0].Classname__c);
        System.AssertEquals(FLOWELEMENT,logs[0].Methodname__c);
        System.AssertEquals(null,logs[0].StackTrace__c);
        System.AssertEquals('Flow',logs[0].Context__c);
        System.AssertEquals(RELATEDID,logs[0].RelatedRecordId__c);

    }
    private testMethod static void testLogExceptionInnerClass() {
        Exception exCaught=null;
        Test.startTest();
        
        try {
           new Helper().createExceptionMethod();
           System.assert(false,'Should never reach this line');
        } catch (Exception ex) {
          exCaught=ex;
          LogUtil.log(APP,ex,null);
        }
                
        Test.stopTest();
        Test.getEventBus().deliver();
        
        List<ApplicationErrorLog__c> logs = [Select Id, Name
                                             , Application__c
                                             , ErrorMessage__c
                                             , Classname__c
                                             , MethodName__c
                                             , Context__c
                                             , LineNumber__c
                                             , StackTrace__c
                                             , RelatedRecordId__c 
                                            FROM ApplicationErrorLog__c];
        
        System.Assert(!logs.isEmpty(),'Expected an error to be logged');
        System.AssertEquals(APP,logs[0].Application__c,'Application check');
        System.AssertEquals(exCaught.getMessage().left(40),logs[0].ErrorMessage__c.left(40),'Messages do not match');
        System.AssertEquals('Class',logs[0].Context__c);
        System.AssertEquals('LogUtil_Test.Helper',logs[0].Classname__c,'Inner class name check');
        System.AssertEquals('createExceptionMethod',logs[0].MethodName__c,'Method must be set');
        System.AssertNotEquals(null,logs[0].LineNumber__c,'Line Number must be initialized');
        System.AssertNotEquals(null,logs[0].StackTrace__c,'StackTrace must be initialized');
        System.AssertEquals(null,logs[0].RelatedRecordId__c);
    }
    
    private testMethod static void testLogExceptionOuterClass() {
        Exception exCaught=null;
        Test.startTest();
        
        try {
           insert new Lead(FirstName='Moose'); // Intentionally fail
           System.assert(false,'Should never reach this line');
        } catch (Exception ex) {
          exCaught=ex;
          LogUtil.log(APP,ex,null);
        }
                
        Test.stopTest();
        Test.getEventBus().deliver();
        
        List<ApplicationErrorLog__c> logs = [Select Id, Name
                                             , Application__c
                                             , ErrorMessage__c
                                             , Context__c
                                             , StackTrace__c
                                             , Classname__c
                                             , MethodName__c
                                             , LineNumber__c
                                             , RelatedRecordId__c 
                                            FROM ApplicationErrorLog__c];
        
        System.Assert(!logs.isEmpty(),'Expected an error to be logged');
        System.AssertEquals(APP,logs[0].Application__c,'Application check');
        System.AssertEquals(exCaught.getMessage().left(40),logs[0].ErrorMessage__c.left(40),'Messages do not match');
        System.AssertEquals('Class',logs[0].Context__c);
        System.AssertEquals('LogUtil_Test',logs[0].Classname__c,'Outer class name check');
        System.AssertEquals('testLogExceptionOuterClass',logs[0].MethodName__c,'Method must be set');
        System.AssertNotEquals(null,logs[0].LineNumber__c,'Line Number must be initialized');
        System.AssertNotEquals(null,logs[0].StackTrace__c,'StackTrace must be initialized');
        System.AssertEquals(null,logs[0].RelatedRecordId__c);
    }


    /**
     * Inner class to test classname parsing capability
     **/ 
    private class Helper {
        public void createExceptionMethod() {
           // This DML will intentionally fail and throw an exception
           final Lead myLead = new Lead(firstname='TestF');
           insert myLead;
        }
    }

}