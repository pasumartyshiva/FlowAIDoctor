public with sharing class FlowErrorCaptureService {
    
    private static final Integer DEDUP_WINDOW_MINUTES = 5;
    
    /**
     * Processes FlowExecutionErrorEvent from platform
     * Deduplicates and enriches before publishing to custom event
     */
    public static void handleFlowExecutionError(List<FlowExecutionErrorEvent> events) {
        List<Flow_Error_Alert__e> alertsToPublish = new List<Flow_Error_Alert__e>();
        
        for (FlowExecutionErrorEvent event : events) {
            // Check for duplicate in recent window
            if (!isDuplicate(event.FlowApiName, event.ElementApiName, event.ErrorMessage)) {
                Flow_Error_Alert__e alert = new Flow_Error_Alert__e(
                    Flow_API_Name__c = event.FlowApiName,
                    Element_API_Name__c = event.ElementApiName,
                    Error_Message__c = truncate(event.ErrorMessage, 255),
                    Error_Type__c = event.EventType,
                    Interview_GUID__c = event.InterviewGuid,
                    Related_Record_Id__c = event.RelatedRecordId,
                    User_Id__c = UserInfo.getUserId(),
                    Error_Timestamp__c = System.now()
                );
                
                alertsToPublish.add(alert);
            }
        }
        
        if (!alertsToPublish.isEmpty()) {
            EventBus.publish(alertsToPublish);
        }
    }
    
    /**
     * Polls for failed Flow interviews (non-screen flows)
     * Runs every 5 minutes via scheduled job
     */
    @future(callout=true)
    public static void pollFailedFlowInterviews() {
        try {
            String query = 'SELECT Id, FlowVersionViewId, CurrentElement, InterviewStatus, ' +
                          'InterviewLabel, CreatedDate, CreatedById ' +
                          'FROM FlowInterview ' +
                          'WHERE InterviewStatus = \'Failed\' ' +
                          'AND CreatedDate >= ' + System.now().addMinutes(-5).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + 
                '/services/data/v62.0/tooling/query?q=' + 
                EncodingUtil.urlEncode(query, 'UTF-8'));
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> records = (List<Object>) result.get('records');
                
                List<Flow_Error_Alert__e> alerts = new List<Flow_Error_Alert__e>();
                
                for (Object record : records) {
                    Map<String, Object> interviewData = (Map<String, Object>) record;
                    
                    // Get Flow details
                    String flowVersionId = (String) interviewData.get('FlowVersionViewId');
                    Map<String, Object> flowDetails = getFlowDetails(flowVersionId);
                    
                    Flow_Error_Alert__e alert = new Flow_Error_Alert__e(
                        Flow_API_Name__c = (String) flowDetails.get('ApiName'),
                        Flow_Label__c = (String) flowDetails.get('Label'),
                        Element_API_Name__c = (String) interviewData.get('CurrentElement'),
                        Error_Message__c = 'Flow interview failed',
                        Interview_GUID__c = (String) interviewData.get('Id'),
                        User_Id__c = (String) interviewData.get('CreatedById'),
                        Error_Timestamp__c = DateTime.valueOf(interviewData.get('CreatedDate'))
                    );
                    
                    alerts.add(alert);
                }
                
                if (!alerts.isEmpty()) {
                    EventBus.publish(alerts);
                }
            }
        } catch (Exception e) {
            System.debug('Error polling failed interviews: ' + e.getMessage());
        }
    }
    
    private static Boolean isDuplicate(String flowApiName, String elementName, String errorMsg) {
        List<Flow_Error_Log__c> recentLogs = [
            SELECT Id
            FROM Flow_Error_Log__c
            WHERE Flow_API_Name__c = :flowApiName
            AND Element_API_Name__c = :elementName
            AND Error_Timestamp__c >= :System.now().addMinutes(-DEDUP_WINDOW_MINUTES)
            LIMIT 1
        ];

        return !recentLogs.isEmpty();
    }
    
    private static Map<String, Object> getFlowDetails(String flowVersionId) {
        String query = 'SELECT ApiName, Label FROM FlowDefinitionView WHERE Id = \'' + flowVersionId + '\'';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + 
            '/services/data/v62.0/tooling/query?q=' + 
            EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> records = (List<Object>) result.get('records');
            if (!records.isEmpty()) {
                return (Map<String, Object>) records[0];
            }
        }
        
        return new Map<String, Object>();
    }
    
    private static String truncate(String text, Integer maxLength) {
        return text != null && text.length() > maxLength ? text.substring(0, maxLength) : text;
    }
}
