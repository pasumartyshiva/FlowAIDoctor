public class FlowErrorPollingSchedulable implements Schedulable {
    public void execute(SchedulableContext ctx) {
        FlowErrorCaptureService.pollFailedFlowInterviews();
    }
}
