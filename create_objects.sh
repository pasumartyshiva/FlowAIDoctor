#!/bin/bash

BASE_DIR="/home/claude/flow-doctor-ai/force-app/main/default/objects"

# Create Flow_Error_Log__c object
mkdir -p "$BASE_DIR/Flow_Error_Log__c/fields"

cat > "$BASE_DIR/Flow_Error_Log__c/Flow_Error_Log__c.object-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <deploymentStatus>Deployed</deploymentStatus>
    <label>Flow Error Log</label>
    <pluralLabel>Flow Error Logs</pluralLabel>
    <nameField>
        <displayFormat>FE-{0000}</displayFormat>
        <label>Error Number</label>
        <type>AutoNumber</type>
    </nameField>
    <sharingModel>ReadWrite</sharingModel>
</CustomObject>
EOF

# Create key fields for Flow_Error_Log__c
cat > "$BASE_DIR/Flow_Error_Log__c/fields/Flow_API_Name__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Flow_API_Name__c</fullName>
    <label>Flow API Name</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Flow_Label__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Flow_Label__c</fullName>
    <label>Flow Label</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Element_API_Name__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Element_API_Name__c</fullName>
    <label>Element API Name</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Error_Message__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Error_Message__c</fullName>
    <label>Error Message</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>5</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Interview_GUID__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Interview_GUID__c</fullName>
    <externalId>true</externalId>
    <label>Interview GUID</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
    <unique>true</unique>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Severity__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Severity__c</fullName>
    <label>Severity</label>
    <required>false</required>
    <type>Picklist</type>
    <valueSet>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <fullName>Critical</fullName>
                <default>false</default>
                <label>Critical</label>
            </value>
            <value>
                <fullName>High</fullName>
                <default>false</default>
                <label>High</label>
            </value>
            <value>
                <fullName>Medium</fullName>
                <default>false</default>
                <label>Medium</label>
            </value>
            <value>
                <fullName>Low</fullName>
                <default>false</default>
                <label>Low</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Status__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Status__c</fullName>
    <label>Status</label>
    <required>false</required>
    <type>Picklist</type>
    <valueSet>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <fullName>New</fullName>
                <default>true</default>
                <label>New</label>
            </value>
            <value>
                <fullName>Analyzed</fullName>
                <default>false</default>
                <label>Analyzed</label>
            </value>
            <value>
                <fullName>In Progress</fullName>
                <default>false</default>
                <label>In Progress</label>
            </value>
            <value>
                <fullName>Resolved</fullName>
                <default>false</default>
                <label>Resolved</label>
            </value>
            <value>
                <fullName>Ignored</fullName>
                <default>false</default>
                <label>Ignored</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/AI_Analysis_Complete__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>AI_Analysis_Complete__c</fullName>
    <defaultValue>false</defaultValue>
    <label>AI Analysis Complete</label>
    <type>Checkbox</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Error_Timestamp__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Error_Timestamp__c</fullName>
    <label>Error Timestamp</label>
    <required>false</required>
    <type>DateTime</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Element_Type__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Element_Type__c</fullName>
    <label>Element Type</label>
    <length>100</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Error_Type__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Error_Type__c</fullName>
    <label>Error Type</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Related_Record_Id__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Related_Record_Id__c</fullName>
    <label>Related Record ID</label>
    <length>18</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/User__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>User__c</fullName>
    <deleteConstraint>SetNull</deleteConstraint>
    <label>User</label>
    <referenceTo>User</referenceTo>
    <relationshipName>Flow_Error_Logs</relationshipName>
    <required>false</required>
    <type>Lookup</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Flow_Version__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Flow_Version__c</fullName>
    <label>Flow Version</label>
    <precision>3</precision>
    <required>false</required>
    <scale>0</scale>
    <type>Number</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Resolution_Notes__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Resolution_Notes__c</fullName>
    <label>Resolution Notes</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>5</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Log__c/fields/Resolution_Time_Minutes__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Resolution_Time_Minutes__c</fullName>
    <label>Resolution Time (Minutes)</label>
    <precision>10</precision>
    <required>false</required>
    <scale>0</scale>
    <type>Number</type>
</CustomField>
EOF

# Create Flow_Error_Analysis__c object
mkdir -p "$BASE_DIR/Flow_Error_Analysis__c/fields"

cat > "$BASE_DIR/Flow_Error_Analysis__c/Flow_Error_Analysis__c.object-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <deploymentStatus>Deployed</deploymentStatus>
    <label>Flow Error Analysis</label>
    <pluralLabel>Flow Error Analyses</pluralLabel>
    <nameField>
        <displayFormat>FEA-{0000}</displayFormat>
        <label>Analysis Number</label>
        <type>AutoNumber</type>
    </nameField>
    <sharingModel>ControlledByParent</sharingModel>
</CustomObject>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Flow_Error_Log__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Flow_Error_Log__c</fullName>
    <label>Flow Error Log</label>
    <referenceTo>Flow_Error_Log__c</referenceTo>
    <relationshipLabel>Flow Error Analyses</relationshipLabel>
    <relationshipName>Flow_Error_Analyses</relationshipName>
    <relationshipOrder>0</relationshipOrder>
    <reparentableMasterDetail>false</reparentableMasterDetail>
    <required>true</required>
    <type>MasterDetail</type>
    <writeRequiresMasterRead>false</writeRequiresMasterRead>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Root_Cause__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Root_Cause__c</fullName>
    <label>Root Cause</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>5</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Root_Cause_Category__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Root_Cause_Category__c</fullName>
    <label>Root Cause Category</label>
    <required>false</required>
    <type>Picklist</type>
    <valueSet>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <fullName>Missing Fault Path</fullName>
                <default>false</default>
                <label>Missing Fault Path</label>
            </value>
            <value>
                <fullName>Null Reference</fullName>
                <default>false</default>
                <label>Null Reference</label>
            </value>
            <value>
                <fullName>DML Exception</fullName>
                <default>false</default>
                <label>DML Exception</label>
            </value>
            <value>
                <fullName>Field Validation</fullName>
                <default>false</default>
                <label>Field Validation</label>
            </value>
            <value>
                <fullName>Permission Error</fullName>
                <default>false</default>
                <label>Permission Error</label>
            </value>
            <value>
                <fullName>Governor Limits</fullName>
                <default>false</default>
                <label>Governor Limits</label>
            </value>
            <value>
                <fullName>Configuration Error</fullName>
                <default>false</default>
                <label>Configuration Error</label>
            </value>
            <value>
                <fullName>Data Issue</fullName>
                <default>false</default>
                <label>Data Issue</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/User_Impact_Description__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>User_Impact_Description__c</fullName>
    <label>User Impact Description</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Immediate_Action__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Immediate_Action__c</fullName>
    <label>Immediate Action</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Long_Term_Fix__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Long_Term_Fix__c</fullName>
    <label>Long Term Fix</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Fix_Steps__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Fix_Steps__c</fullName>
    <label>Fix Steps</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>5</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Test_Scenario__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Test_Scenario__c</fullName>
    <label>Test Scenario</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Documentation_URL__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Documentation_URL__c</fullName>
    <label>Documentation URL</label>
    <required>false</required>
    <type>Url</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Confidence_Score__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Confidence_Score__c</fullName>
    <label>Confidence Score</label>
    <precision>3</precision>
    <required>false</required>
    <scale>0</scale>
    <type>Percent</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Pattern_Detected__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Pattern_Detected__c</fullName>
    <label>Pattern Detected</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Analysis_Timestamp__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Analysis_Timestamp__c</fullName>
    <label>Analysis Timestamp</label>
    <required>false</required>
    <type>DateTime</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Analysis_Duration_MS__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Analysis_Duration_MS__c</fullName>
    <label>Analysis Duration (MS)</label>
    <precision>10</precision>
    <required>false</required>
    <scale>0</scale>
    <type>Number</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Analysis__c/fields/Affected_Element_Details__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Affected_Element_Details__c</fullName>
    <label>Affected Element Details</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>
EOF

# Create Flow_Error_Pattern__c object
mkdir -p "$BASE_DIR/Flow_Error_Pattern__c/fields"

cat > "$BASE_DIR/Flow_Error_Pattern__c/Flow_Error_Pattern__c.object-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <deploymentStatus>Deployed</deploymentStatus>
    <label>Flow Error Pattern</label>
    <pluralLabel>Flow Error Patterns</pluralLabel>
    <nameField>
        <label>Pattern Name</label>
        <type>Text</type>
    </nameField>
    <sharingModel>ReadWrite</sharingModel>
</CustomObject>
EOF

cat > "$BASE_DIR/Flow_Error_Pattern__c/fields/Error_Signature__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Error_Signature__c</fullName>
    <caseSensitive>false</caseSensitive>
    <externalId>true</externalId>
    <label>Error Signature</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
    <unique>true</unique>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Pattern__c/fields/Pattern_Type__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Pattern_Type__c</fullName>
    <label>Pattern Type</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Pattern__c/fields/Flow_API_Names__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Flow_API_Names__c</fullName>
    <label>Flow API Names</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Pattern__c/fields/Pattern_Description__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Pattern_Description__c</fullName>
    <label>Pattern Description</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Pattern__c/fields/Recommended_Fix__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Recommended_Fix__c</fullName>
    <label>Recommended Fix</label>
    <length>32768</length>
    <type>LongTextArea</type>
    <visibleLines>3</visibleLines>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Pattern__c/fields/Occurrence_Count__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Occurrence_Count__c</fullName>
    <label>Occurrence Count</label>
    <precision>10</precision>
    <required>false</required>
    <scale>0</scale>
    <type>Number</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Pattern__c/fields/Status__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Status__c</fullName>
    <label>Status</label>
    <required>false</required>
    <type>Picklist</type>
    <valueSet>
        <valueSetDefinition>
            <sorted>false</sorted>
            <value>
                <fullName>Active</fullName>
                <default>true</default>
                <label>Active</label>
            </value>
            <value>
                <fullName>Resolved</fullName>
                <default>false</default>
                <label>Resolved</label>
            </value>
            <value>
                <fullName>Monitoring</fullName>
                <default>false</default>
                <label>Monitoring</label>
            </value>
            <value>
                <fullName>Ignored</fullName>
                <default>false</default>
                <label>Ignored</label>
            </value>
        </valueSetDefinition>
    </valueSet>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Pattern__c/fields/Last_Occurrence__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Last_Occurrence__c</fullName>
    <label>Last Occurrence</label>
    <required>false</required>
    <type>DateTime</type>
</CustomField>
EOF

echo "All custom objects created successfully"
