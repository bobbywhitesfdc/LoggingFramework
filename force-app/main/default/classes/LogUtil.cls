/*
* Log Application Errors asynchronously using platform events
*/
public class LogUtil {
    public static final string UNKNOWN='Unknown';
    
    // Simple way to log an error directly
    public static void log(final string appName,final String msg,final Id recordId) {
        ApplicationError__e err = new ApplicationError__e();
        err.Application__c= safecopy(appName,40);
        err.ErrorMessage__c=safecopy(msg,128);
        err.RelatedRecordId__c=safecopy(recordId,18);
        err.Context__c='Class';
        EventBus.publish(err);
    }
    
    /**
     * Helper method for Flows
     **/ 
    public static void logFlowFault(final String appName
                               , final String flowName
                               , final String flowElement
                               , final String msg
                               , final Id recordId) {
        ApplicationError__e err = new ApplicationError__e();
        err.Application__c= safecopy(appName,40);
        err.ErrorMessage__c=safecopy(msg,128);
        err.RelatedRecordId__c=safecopy(recordId,18);
        err.Context__c='Flow';
        err.Classname__c= safecopy(flowName,60);
        err.MethodName__c= safecopy(flowElement,60);
                                  
        EventBus.publish(err);                                  
    }

    // Simple way to log an error from an Exception
    public static void log(final string appName,final Exception ex,final Id recordId) {
        ApplicationError__e err = new ApplicationError__e();
        err.Application__c=safecopy(appName,40);
        err.ErrorMessage__c=safecopy(ex.getMessage(),128);
        
        final StackTraceParser parser = new StackTraceParser(ex);
        err.Context__c = safecopy(parser.context,60);
        err.Classname__c=safecopy(parser.className,60);
        err.MethodName__c=safecopy(parser.methodName,60);
        err.StackTrace__c=safecopy(parser.stackTrace,131000);

        
        err.LineNumber__c=ex.getLineNumber();
        err.RelatedRecordId__c=safecopy(recordId,18);
        EventBus.publish(err);    
    }
    
    private static String safecopy(String val, Integer maxLen) {
        return (val == null) ? null : val.left(maxLen);
    }
    
    private class StackTraceParser {
        public final string context;
        public final string className;
        public final string methodName;
        public final string stackTrace;
        /**
		* Parse the stacktrace and initialize the results
		**/ 
        public StackTraceParser(final Exception ex) {
            stackTrace=ex.getStackTraceString();
            List<String> parts = stackTrace.split(':');
            final String classPart = parts[0];
            System.Debug('Class part: ' + classPart);
            List<String> tokens = classPart.split('\\.');
            System.Debug('Tokens: ' + tokens.size());
            /**
			* Scenarios
			* 
			* Anonymous Apex --> AnonymousBlock
			* Outer Class --> Class.Classname.Methodname
			* Inner Class --> Class.OuterClassName.InnerClassName.MethodName
			**/ 
            // First token is always the context
            context=tokens[0];
            // Last token can always be interpretted as methodname
            methodName=tokens[tokens.size()-1];
            
            if (tokens.size() > 2) {
               tokens.remove(0); // Remove Context
               tokens.remove(tokens.size()-1); // Remove Method
            }
            // Whatever is left we treat as the className
            className=String.join(tokens,'.'); 
        }
    }
}