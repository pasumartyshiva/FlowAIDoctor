public with sharing class FlowMetadataService {
    
    private static Map<String, FlowMetadata> metadataCache = new Map<String, FlowMetadata>();
    private static final Integer CACHE_DURATION_HOURS = 1;
    
    public class FlowMetadata {
        public String apiName;
        public String label;
        public Integer version;
        public String processType;
        public String triggerType;
        public List<FlowElement> elements;
        public DateTime cachedAt;
        
        public FlowMetadata() {
            this.elements = new List<FlowElement>();
            this.cachedAt = System.now();
        }
        
        public Boolean isCacheValid() {
            return System.now() < this.cachedAt.addHours(CACHE_DURATION_HOURS);
        }
    }
    
    public class FlowElement {
        public String apiName;
        public String elementType;
        public String label;
        public Map<String, Object> properties;
        public List<String> connectedTo;
        public Boolean hasFaultPath;
        
        public FlowElement() {
            this.properties = new Map<String, Object>();
            this.connectedTo = new List<String>();
            this.hasFaultPath = false;
        }
    }
    
    public static FlowMetadata getFlowMetadata(String flowApiName) {
        if (metadataCache.containsKey(flowApiName)) {
            FlowMetadata cached = metadataCache.get(flowApiName);
            if (cached.isCacheValid()) {
                return cached;
            }
        }
        
        FlowMetadata metadata = fetchFlowMetadata(flowApiName);
        
        if (metadata != null) {
            metadataCache.put(flowApiName, metadata);
        }
        
        return metadata;
    }
    
    private static FlowMetadata fetchFlowMetadata(String flowApiName) {
        try {
            String query = 'SELECT Metadata, VersionNumber, ProcessType, TriggerType ' +
                          'FROM Flow ' +
                          'WHERE ApiName = \'' + String.escapeSingleQuotes(flowApiName) + '\' ' +
                          'AND Status = \'Active\' ' +
                          'LIMIT 1';
            
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
                    Map<String, Object> flowRecord = (Map<String, Object>) records[0];
                    return parseFlowMetadata(flowRecord);
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching Flow metadata: ' + e.getMessage());
        }
        
        return null;
    }
    
    private static FlowMetadata parseFlowMetadata(Map<String, Object> flowRecord) {
        FlowMetadata metadata = new FlowMetadata();
        
        Map<String, Object> flowData = (Map<String, Object>) flowRecord.get('Metadata');
        
        metadata.version = Integer.valueOf(flowRecord.get('VersionNumber'));
        metadata.processType = (String) flowRecord.get('ProcessType');
        metadata.triggerType = (String) flowRecord.get('TriggerType');
        
        if (flowData.containsKey('actionCalls')) {
            parseElements((List<Object>) flowData.get('actionCalls'), 'Action', metadata);
        }
        if (flowData.containsKey('recordLookups')) {
            parseElements((List<Object>) flowData.get('recordLookups'), 'Get Records', metadata);
        }
        if (flowData.containsKey('recordUpdates')) {
            parseElements((List<Object>) flowData.get('recordUpdates'), 'Update Records', metadata);
        }
        if (flowData.containsKey('recordCreates')) {
            parseElements((List<Object>) flowData.get('recordCreates'), 'Create Records', metadata);
        }
        if (flowData.containsKey('recordDeletes')) {
            parseElements((List<Object>) flowData.get('recordDeletes'), 'Delete Records', metadata);
        }
        if (flowData.containsKey('decisions')) {
            parseElements((List<Object>) flowData.get('decisions'), 'Decision', metadata);
        }
        if (flowData.containsKey('assignments')) {
            parseElements((List<Object>) flowData.get('assignments'), 'Assignment', metadata);
        }
        
        return metadata;
    }
    
    private static void parseElements(List<Object> elements, String elementType, FlowMetadata metadata) {
        for (Object elem : elements) {
            Map<String, Object> elemData = (Map<String, Object>) elem;
            
            FlowElement flowElement = new FlowElement();
            flowElement.apiName = (String) elemData.get('name');
            flowElement.elementType = elementType;
            flowElement.label = (String) elemData.get('label');
            
            if (elemData.containsKey('faultConnector')) {
                flowElement.hasFaultPath = elemData.get('faultConnector') != null;
            }
            
            if (elemData.containsKey('connector')) {
                Map<String, Object> connector = (Map<String, Object>) elemData.get('connector');
                if (connector != null && connector.containsKey('targetReference')) {
                    flowElement.connectedTo.add((String) connector.get('targetReference'));
                }
            }
            
            flowElement.properties = elemData;
            metadata.elements.add(flowElement);
        }
    }
    
    public static FlowElement getElementDetails(String flowApiName, String elementApiName) {
        FlowMetadata metadata = getFlowMetadata(flowApiName);
        
        if (metadata != null) {
            for (FlowElement element : metadata.elements) {
                if (element.apiName == elementApiName) {
                    return element;
                }
            }
        }
        
        return null;
    }
}
