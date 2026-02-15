#!/bin/bash

BASE_DIR="/home/claude/flow-doctor-ai"
cd $BASE_DIR

# Create FlowErrorAnalysisService
cat > force-app/main/default/classes/FlowErrorAnalysisService.cls << 'EOF'
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
EOF

cat > force-app/main/default/classes/FlowErrorAnalysisService.cls-meta.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <status>Active</status>
</ApexClass>
EOF

# Create FlowDoctorController
cat > force-app/main/default/classes/FlowDoctorController.cls << 'EOF'
public with sharing class FlowDoctorController {
    
    @AuraEnabled(cacheable=true)
    public static List<Flow_Error_Log__c> getRecentErrors(Integer limitCount) {
        return [
            SELECT Id, Name, Flow_API_Name__c, Flow_Label__c, Element_API_Name__c,
                   Element_Type__c, Error_Message__c, Error_Timestamp__c, 
                   Severity__c, Status__c, AI_Analysis_Complete__c,
                   User__r.Name
            FROM Flow_Error_Log__c
            ORDER BY Error_Timestamp__c DESC
            LIMIT :limitCount
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static Flow_Error_Analysis__c getErrorAnalysis(Id errorLogId) {
        List<Flow_Error_Analysis__c> results = [
            SELECT Root_Cause__c, Root_Cause_Category__c, Affected_Element_Details__c,
                   User_Impact_Description__c, Immediate_Action__c, Long_Term_Fix__c,
                   Fix_Steps__c, Test_Scenario__c, Documentation_URL__c,
                   Pattern_Detected__c, Confidence_Score__c
            FROM Flow_Error_Analysis__c
            WHERE Flow_Error_Log__c = :errorLogId
            LIMIT 1
        ];
        
        return results.isEmpty() ? null : results[0];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getTopErrors(Integer limitCount, Integer hours) {
        DateTime since = System.now().addHours(-hours);
        
        return [
            SELECT Flow_API_Name__c flowApiName, Flow_Label__c flowLabel,
                   COUNT(Id) errorCount, MAX(Id) lastErrorId,
                   MAX(Severity__c) maxSeverity
            FROM Flow_Error_Log__c
            WHERE Error_Timestamp__c >= :since
            GROUP BY Flow_API_Name__c, Flow_Label__c
            ORDER BY COUNT(Id) DESC
            LIMIT :limitCount
        ];
    }
    
    @AuraEnabled
    public static void markErrorResolved(Id errorLogId, String resolutionNotes) {
        Flow_Error_Log__c errorLog = [
            SELECT Id, Error_Timestamp__c
            FROM Flow_Error_Log__c
            WHERE Id = :errorLogId
            LIMIT 1
        ];
        
        Long resolutionMinutes = (System.now().getTime() - errorLog.Error_Timestamp__c.getTime()) / 60000;
        
        errorLog.Status__c = 'Resolved';
        errorLog.Resolution_Notes__c = resolutionNotes;
        errorLog.Resolution_Time_Minutes__c = resolutionMinutes;
        
        update errorLog;
    }
}
EOF

cat > force-app/main/default/classes/FlowDoctorController.cls-meta.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <status>Active</status>
</ApexClass>
EOF

# Create FlowPatternDetectionService
cat > force-app/main/default/classes/FlowPatternDetectionService.cls << 'EOF'
public with sharing class FlowPatternDetectionService implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        detectPatterns();
    }
    
    public static void detectPatterns() {
        List<Flow_Error_Log__c> recentErrors = [
            SELECT Flow_API_Name__c, Element_API_Name__c, Element_Type__c,
                   Error_Message__c, Error_Type__c
            FROM Flow_Error_Log__c
            WHERE Error_Timestamp__c >= :System.now().addHours(-24)
            AND AI_Analysis_Complete__c = true
            ORDER BY Error_Timestamp__c DESC
            LIMIT 1000
        ];
        
        Map<String, List<Flow_Error_Log__c>> errorsByFlow = new Map<String, List<Flow_Error_Log__c>>();
        
        for (Flow_Error_Log__c error : recentErrors) {
            if (!errorsByFlow.containsKey(error.Flow_API_Name__c)) {
                errorsByFlow.put(error.Flow_API_Name__c, new List<Flow_Error_Log__c>());
            }
            errorsByFlow.get(error.Flow_API_Name__c).add(error);
        }
        
        for (String flowApiName : errorsByFlow.keySet()) {
            List<Flow_Error_Log__c> flowErrors = errorsByFlow.get(flowApiName);
            
            if (flowErrors.size() >= 3) {
                analyzePatternForFlow(flowApiName, flowErrors);
            }
        }
    }
    
    private static void analyzePatternForFlow(String flowApiName, List<Flow_Error_Log__c> errors) {
        String signature = generatePatternSignature(flowApiName, 'REPEATED_FAILURES');
        
        Flow_Error_Pattern__c pattern = new Flow_Error_Pattern__c(
            Error_Signature__c = signature,
            Pattern_Name__c = 'Repeated Failures in ' + flowApiName,
            Pattern_Type__c = 'Repeated Element Failure',
            Flow_API_Names__c = flowApiName,
            Pattern_Description__c = errors.size() + ' errors detected in last 24 hours',
            Recommended_Fix__c = 'Review Flow logic and add fault paths',
            Occurrence_Count__c = errors.size(),
            Status__c = 'Active',
            Last_Occurrence__c = System.now()
        );
        
        Database.upsert(new List<Flow_Error_Pattern__c>{pattern}, Flow_Error_Pattern__c.Error_Signature__c, false);
    }
    
    private static String generatePatternSignature(String flowApiName, String patternType) {
        String combined = flowApiName + ':' + patternType;
        Blob hash = Crypto.generateDigest('SHA-256', Blob.valueOf(combined));
        return EncodingUtil.base64Encode(hash).substring(0, 40);
    }
}
EOF

cat > force-app/main/default/classes/FlowPatternDetectionService.cls-meta.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <status>Active</status>
</ApexClass>
EOF

# Create FlowErrorPollingSchedulable
cat > force-app/main/default/classes/FlowErrorPollingSchedulable.cls << 'EOF'
public class FlowErrorPollingSchedulable implements Schedulable {
    public void execute(SchedulableContext ctx) {
        FlowErrorCaptureService.pollFailedFlowInterviews();
    }
}
EOF

cat > force-app/main/default/classes/FlowErrorPollingSchedulable.cls-meta.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <status>Active</status>
</ApexClass>
EOF

echo "All Apex classes created successfully"
