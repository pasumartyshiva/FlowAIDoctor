public with sharing class FlowErrorAnalysisService {
    
    public static void analyzeErrors(List<Flow_Error_Alert__e> alerts) {
        List<Flow_Error_Log__c> errorLogs = new List<Flow_Error_Log__c>();
        
        for (Flow_Error_Alert__e alert : alerts) {
            Flow_Error_Log__c errorLog = createErrorLog(alert);
            errorLogs.add(errorLog);
        }
        
        if (!errorLogs.isEmpty()) {
            insert errorLogs;
            
            Set<Id> errorLogIds = new Set<Id>();
            for (Flow_Error_Log__c log : errorLogs) {
                errorLogIds.add(log.Id);
            }
            
            performAIAnalysisAsync(errorLogIds);
        }
    }
    
    private static Flow_Error_Log__c createErrorLog(Flow_Error_Alert__e alert) {
        FlowMetadataService.FlowMetadata metadata = 
            FlowMetadataService.getFlowMetadata(alert.Flow_API_Name__c);
        
        Flow_Error_Log__c errorLog = new Flow_Error_Log__c(
            Flow_API_Name__c = alert.Flow_API_Name__c,
            Flow_Label__c = alert.Flow_Label__c != null ? alert.Flow_Label__c : 
                           (metadata != null ? metadata.label : alert.Flow_API_Name__c),
            Flow_Version__c = metadata != null ? metadata.version : null,
            Element_API_Name__c = alert.Element_API_Name__c,
            Element_Type__c = alert.Element_Type__c,
            Error_Message__c = alert.Error_Message__c,
            Error_Type__c = alert.Error_Type__c,
            Interview_GUID__c = alert.Interview_GUID__c,
            Related_Record_Id__c = alert.Related_Record_Id__c,
            User__c = alert.User_Id__c,
            Error_Timestamp__c = alert.Error_Timestamp__c,
            Severity__c = calculateSeverity(alert),
            Status__c = 'New',
            AI_Analysis_Complete__c = false
        );
        
        return errorLog;
    }
    
    private static String calculateSeverity(Flow_Error_Alert__e alert) {
        Integer recentErrorCount = [
            SELECT COUNT()
            FROM Flow_Error_Log__c
            WHERE Flow_API_Name__c = :alert.Flow_API_Name__c
            AND Error_Timestamp__c >= :System.now().addMinutes(-10)
        ];
        
        if (recentErrorCount >= 10) {
            return 'Critical';
        } else if (recentErrorCount >= 5) {
            return 'High';
        } else if (recentErrorCount >= 2) {
            return 'Medium';
        } else {
            return 'Low';
        }
    }
    
    @future(callout=true)
    private static void performAIAnalysisAsync(Set<Id> errorLogIds) {
        List<Flow_Error_Log__c> errorLogs = [
            SELECT Id, Flow_API_Name__c, Element_API_Name__c, Element_Type__c,
                   Error_Message__c, Error_Type__c, Interview_GUID__c,
                   Related_Record_Id__c, User__c, Severity__c
            FROM Flow_Error_Log__c
            WHERE Id IN :errorLogIds
        ];
        
        for (Flow_Error_Log__c errorLog : errorLogs) {
            analyzeErrorWithAI(errorLog);
        }
    }
    
    private static void analyzeErrorWithAI(Flow_Error_Log__c errorLog) {
        Long startTime = System.currentTimeMillis();
        
        try {
            String context = buildAnalysisContext(errorLog);
            
            // Call Agentforce Prompt Template
            // NOTE: Replace with actual Agentforce API call
            // For now, create fallback analysis
            createFallbackAnalysis(errorLog.Id, startTime);
            
        } catch (Exception e) {
            System.debug('Error in AI analysis: ' + e.getMessage());
            createFallbackAnalysis(errorLog.Id, startTime);
        }
    }
    
    private static String buildAnalysisContext(Flow_Error_Log__c errorLog) {
        FlowMetadataService.FlowMetadata metadata = 
            FlowMetadataService.getFlowMetadata(errorLog.Flow_API_Name__c);
        
        FlowMetadataService.FlowElement element = 
            FlowMetadataService.getElementDetails(
                errorLog.Flow_API_Name__c, 
                errorLog.Element_API_Name__c
            );
        
        List<Flow_Error_Log__c> similarErrors = [
            SELECT Element_API_Name__c, Error_Message__c
            FROM Flow_Error_Log__c
            WHERE Flow_API_Name__c = :errorLog.Flow_API_Name__c
            AND Error_Timestamp__c >= :System.now().addHours(-24)
            AND AI_Analysis_Complete__c = true
            AND Id != :errorLog.Id
            ORDER BY Error_Timestamp__c DESC
            LIMIT 10
        ];
        
        Map<String, Object> context = new Map<String, Object>{
            'flowApiName' => errorLog.Flow_API_Name__c,
            'flowLabel' => metadata != null ? metadata.label : errorLog.Flow_API_Name__c,
            'elementApiName' => errorLog.Element_API_Name__c,
            'elementType' => errorLog.Element_Type__c,
            'elementHasFaultPath' => element != null ? element.hasFaultPath : false,
            'errorMessage' => errorLog.Error_Message__c,
            'severity' => errorLog.Severity__c
        };
        
        return JSON.serialize(context);
    }
    
    private static void createFallbackAnalysis(Id errorLogId, Long startTime) {
        Flow_Error_Analysis__c fallback = new Flow_Error_Analysis__c(
            Flow_Error_Log__c = errorLogId,
            Root_Cause__c = 'AI analysis pending. Configure Agentforce Prompt Templates.',
            Root_Cause_Category__c = 'Configuration Error',
            User_Impact_Description__c = 'Review error manually in Flow Builder.',
            Immediate_Action__c = 'Check the failed element for issues.',
            Long_Term_Fix__c = 'Add comprehensive error handling with fault paths.',
            Confidence_Score__c = 0,
            Analysis_Duration_MS__c = System.currentTimeMillis() - startTime,
            Analysis_Timestamp__c = System.now()
        );
        
        insert fallback;
        
        update new Flow_Error_Log__c(
            Id = errorLogId,
            AI_Analysis_Complete__c = true,
            Status__c = 'Analyzed'
        );
    }
}
