public class LogUtilFlowWrapper {
    @InvocableMethod(label='Log Flow Error' category='Logging')
    public static void logFlowError(List<LogFaultDetail> faults) {
        for(LogFaultDetail current : faults) {
            LogUtil.logFlowFault(current.appName
                                 , current.flowName
                                 , current.flowElement
                                 , current.message
                                 , current.recordId);
        }
    }
    public class LogFaultDetail {
        @InvocableVariable(required=true)
        public String appName;
        @InvocableVariable(required=true)
        public String flowName;
        @InvocableVariable(required=true)
        public String flowElement;
        @InvocableVariable(required=true)
        public String message;
        @InvocableVariable
        public String recordId;
    }

}