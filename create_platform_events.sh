#!/bin/bash

BASE_DIR="/home/claude/flow-doctor-ai/force-app/main/default/platformEvents"
mkdir -p "$BASE_DIR/Flow_Error_Alert__e/fields"

cat > "$BASE_DIR/Flow_Error_Alert__e/Flow_Error_Alert__e.object-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">
    <deploymentStatus>Deployed</deploymentStatus>
    <eventType>HighVolume</eventType>
    <label>Flow Error Alert</label>
    <pluralLabel>Flow Error Alerts</pluralLabel>
    <publishBehavior>PublishAfterCommit</publishBehavior>
</CustomObject>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/Flow_API_Name__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Flow_API_Name__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>Flow API Name</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/Flow_Label__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Flow_Label__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>Flow Label</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/Element_API_Name__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Element_API_Name__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>Element API Name</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/Error_Message__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Error_Message__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>Error Message</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/Interview_GUID__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Interview_GUID__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>Interview GUID</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/User_Id__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>User_Id__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>User ID</label>
    <length>18</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/Error_Timestamp__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Error_Timestamp__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>Error Timestamp</label>
    <required>false</required>
    <type>DateTime</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/Element_Type__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Element_Type__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>Element Type</label>
    <length>50</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/Error_Type__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Error_Type__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>Error Type</label>
    <length>255</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

cat > "$BASE_DIR/Flow_Error_Alert__e/fields/Related_Record_Id__c.field-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Related_Record_Id__c</fullName>
    <isFilteringDisabled>false</isFilteringDisabled>
    <isNameField>false</isNameField>
    <isSortingDisabled>false</isSortingDisabled>
    <label>Related Record ID</label>
    <length>18</length>
    <required>false</required>
    <type>Text</type>
</CustomField>
EOF

echo "Platform Event created successfully"
