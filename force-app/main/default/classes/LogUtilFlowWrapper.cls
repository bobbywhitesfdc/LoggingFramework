public class LogUtilFlowWrapper {
  public static final string DEFAULT_ELEMENTNAME = 'Unknown';
  public static final string DEFAULT_FAULTMSG = 'No message available';

  @InvocableMethod(label='Log Flow Error' category='Logging')
  public static void logFlowError(List<LogFaultDetail> faults) {
    for (LogFaultDetail current : faults) {
      LogUtil.logFlowFault(
        current.appName,
        current.flowName,
        current.flowElement == null ? DEFAULT_ELEMENTNAME : current.flowElement,
        current.message == null ? DEFAULT_FAULTMSG : current.message,
        current.recordId
      );
    }
  }
  public class LogFaultDetail {
    @InvocableVariable(required=true)
    public String appName;
    @InvocableVariable(required=true)
    public String flowName;
    @InvocableVariable
    public String flowElement;
    @InvocableVariable
    public String message;
    @InvocableVariable
    public String recordId;
  }
}
