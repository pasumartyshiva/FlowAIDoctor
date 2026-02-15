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
