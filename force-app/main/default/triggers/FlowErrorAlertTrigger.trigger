trigger FlowErrorAlertTrigger on Flow_Error_Alert__e (after insert) {
    FlowErrorAnalysisService.analyzeErrors(Trigger.new);
}
