# Agentforce Setup Guide - Flow Doctor AI

This guide explains how to configure the Agentforce Prompt Templates required for Flow Doctor AI.

## Overview

Flow Doctor uses **Prompt Templates as Infrastructure** - a pattern where AI becomes reliable, versioned API endpoints rather than freeform chat.

**Why This Matters:**
- Guaranteed JSON output (parseable, structured)
- Version controlled prompts (audit trail)
- Context-rich analysis (Flow metadata included)
- Scalable (processes thousands of errors)

## Required Prompt Templates

You need to create two Prompt Templates:

1. **analyzeFlowError** - Analyzes individual Flow errors
2. **detectErrorPatterns** - Identifies patterns across multiple errors

## Creating Prompt Templates

### Step 1: Access Prompt Builder

1. Navigate to Setup → Feature Settings → Prompt Builder
2. Click "New Prompt Template"

### Step 2: Create analyzeFlowError Prompt Template

**Template Name:** `analyzeFlowError`

**Description:** Analyzes Salesforce Flow errors and provides root cause with remediation steps

**Input Variables:**

Create one input variable:
- **Name:** `errorContext`
- **Type:** Text
- **Description:** JSON string containing error details, Flow metadata, and similar errors

**Prompt:**

```
You are an expert Salesforce Flow developer analyzing a Flow error. Your goal is to identify the root cause and provide actionable remediation steps.

CONTEXT:
{!$Input:errorContext}

ANALYSIS REQUIREMENTS:

1. ROOT CAUSE: Identify the specific reason this error occurred (not just symptoms)

2. CATEGORIZATION: Classify into one of these categories:
   - Missing Fault Path
   - Null Reference
   - DML Exception
   - Field Validation
   - Permission Error
   - Governor Limits
   - Configuration Error
   - Data Issue

3. USER IMPACT: Describe how this affects end users and which functionality is broken

4. IMMEDIATE ACTION: Provide a quick workaround or mitigation if available

5. LONG TERM FIX: Describe the proper solution to prevent recurrence

6. FIX STEPS: Provide 3-7 specific, numbered steps with exact element names and field API names

7. TEST SCENARIO: Provide exact steps to reproduce this error in a sandbox

8. DOCUMENTATION: Provide a Salesforce help article URL if relevant

9. PATTERN: Identify if this matches a common pattern (e.g., "MISSING_FAULT_PATH_ON_DML")

10. CONFIDENCE: Assign a confidence score (0.0 to 1.0)

RESPOND IN THIS EXACT JSON FORMAT (no markdown, no backticks):

{
  "rootCause": "Single sentence explaining WHY this occurred",
  "rootCauseCategory": "One of the 8 categories listed above",
  "affectedElementDetails": "Details about the element that failed",
  "userImpact": "How this affects end users",
  "immediateAction": "Quick workaround",
  "longTermFix": "Proper solution",
  "fixSteps": [
    "Step 1: Open Flow Builder and navigate to [FlowName]",
    "Step 2: Click on element [ElementName]",
    "Step 3: Add Fault Path connector",
    "Step 4: Save and activate the new version"
  ],
  "testScenario": "Exact reproduction steps",
  "documentationUrl": "https://help.salesforce.com/...",
  "patternDetected": "PATTERN_NAME or null",
  "confidenceScore": 0.95
}

IMPORTANT:
- Use exact element API names from the context
- Include specific field API names in fix steps
- If element lacks fault path (hasFaultPath: false), prioritize adding one
- Consider similar errors from the context
- Be specific and actionable
- If multiple root causes possible, choose most likely and note confidence
```

**Output Variables:**

Create one output variable:
- **Name:** `analysisResult`
- **Type:** Text
- **Description:** JSON string containing the analysis

**Model:** Use latest Claude Sonnet model

**Save** the prompt template and note its name.

### Step 3: Create detectErrorPatterns Prompt Template

**Template Name:** `detectErrorPatterns`

**Description:** Detects patterns across multiple Flow errors to identify systemic issues

**Input Variables:**

Create two input variables:
- **Name:** `flowApiName`
  - **Type:** Text
  - **Description:** API name of the Flow being analyzed

- **Name:** `errorsContext`
  - **Type:** Text
  - **Description:** JSON array of recent errors for this Flow

**Prompt:**

```
You are analyzing multiple Salesforce Flow errors to detect systemic patterns that suggest architectural issues.

FLOW: {!$Input:flowApiName}

ERRORS:
{!$Input:errorsContext}

PATTERN DETECTION REQUIREMENTS:

Analyze these errors and identify:

1. COMMON ELEMENT FAILURES: Same element failing repeatedly
2. TEMPORAL PATTERNS: Errors spiking at specific times
3. CATEGORICAL PATTERNS: Same error type recurring
4. ARCHITECTURAL ISSUES: Flow design flaws causing repeated failures
5. DATA PATTERNS: Errors with records matching certain criteria

For each pattern detected, provide:
- Pattern type
- Clear description
- Number of occurrences
- Estimated affected users
- High-level architectural recommendation

RESPOND IN THIS EXACT JSON FORMAT (no markdown, no backticks):

{
  "patterns": [
    {
      "name": "Descriptive pattern name",
      "type": "MISSING_FAULT_PATH|TEMPORAL_SPIKE|REPEATED_ELEMENT_FAILURE|DATA_QUALITY_ISSUE",
      "description": "Human-readable description of what's happening",
      "occurrences": 47,
      "affectedUsers": 23,
      "recommendedFix": "High-level architecture change needed",
      "confidence": 0.89
    }
  ],
  "recommendations": [
    "Add comprehensive fault handling to all DML operations",
    "Consider splitting this Flow into smaller, focused Flows"
  ]
}

IMPORTANT:
- Only report patterns with 3+ occurrences
- Prioritize patterns with high user impact
- Be specific about architectural recommendations
- If no clear patterns, return empty patterns array
```

**Output Variables:**

Create one output variable:
- **Name:** `patternsResult`
- **Type:** Text
- **Description:** JSON string containing detected patterns

**Model:** Use latest Claude Sonnet model

**Save** the prompt template.

## Testing Prompt Templates

### Test analyzeFlowError

1. Open Prompt Builder
2. Select "analyzeFlowError" template
3. Click "Test"
4. Provide sample errorContext:

```json
{
  "flowApiName": "Account_Update_Handler",
  "flowLabel": "Account Update Handler",
  "elementApiName": "Update_Account_Record",
  "elementType": "Update Records",
  "elementHasFaultPath": false,
  "errorMessage": "REQUIRED_FIELD_MISSING: Required fields are missing: [AccountNumber]",
  "severity": "High"
}
```

5. Run test
6. Verify output is valid JSON with all required fields

### Test detectErrorPatterns

1. Open Prompt Builder
2. Select "detectErrorPatterns" template
3. Click "Test"
4. Provide sample inputs:
   - flowApiName: "Account_Update_Handler"
   - errorsContext: `{"errorCount": 5, "errors": [{"elementName": "Update_Account_Record", "errorMessage": "REQUIRED_FIELD_MISSING"}]}`

5. Run test
6. Verify output is valid JSON

## Integration with Flow Doctor

Once Prompt Templates are created, Flow Doctor automatically invokes them:

**analyzeFlowError** is called by:
- `FlowErrorAnalysisService.analyzeErrorWithAI()`
- Triggered when new error arrives
- Passes complete error context including Flow metadata

**detectErrorPatterns** is called by:
- `FlowPatternDetectionService.analyzePatternForFlow()`
- Runs on scheduled job (hourly)
- Analyzes last 24 hours of errors

## Troubleshooting

### Prompt Template Not Found Error

**Error in Apex logs:** "Prompt template 'analyzeFlowError' not found"

**Solution:**
- Verify template name exactly matches (case-sensitive)
- Ensure template is Active
- Check Agentforce API access

### Invalid JSON Response

**Error:** "JSON parse exception"

**Solution:**
- Add instruction "no markdown, no backticks" to prompt
- Test prompt template independently
- Verify output format matches expected structure

### Low Confidence Scores

**Confidence consistently below 0.7**

**Solution:**
- Provide more context in errorContext
- Include more similar errors
- Refine prompt instructions
- Check if Flow metadata is being passed correctly

## Advanced Configuration

### Custom Prompt Variations

You can create variations for different scenarios:
- **analyzeFlowError_Detailed** - More verbose analysis
- **analyzeFlowError_Quick** - Faster, less detailed
- **detectErrorPatterns_Critical** - Only critical patterns

Update Apex class to use variations based on error severity.

### Monitoring Prompt Performance

Track these metrics:
- Average analysis duration (stored in Analysis_Duration_MS__c)
- Confidence score distribution
- User feedback on analysis quality

Query for performance metrics:

```sql
SELECT AVG(Analysis_Duration_MS__c), AVG(Confidence_Score__c)
FROM Flow_Error_Analysis__c
WHERE Analysis_Timestamp__c = LAST_N_DAYS:7
```

## Best Practices

1. **Version Control Prompts**
   - Export prompt templates regularly
   - Document changes in release notes
   - Test changes in sandbox first

2. **Monitor Token Usage**
   - Agentforce charges per token
   - Optimize errorContext size
   - Cache Flow metadata

3. **Iterate on Prompts**
   - Review low-confidence analyses
   - Update prompts based on feedback
   - A/B test prompt variations

4. **Secure Sensitive Data**
   - Sanitize error messages before AI analysis
   - Don't send PII to Agentforce
   - Use field masking for sensitive fields

## Next Steps

- [USER_GUIDE.md](USER_GUIDE.md) - Learn how to use Flow Doctor
- [ARCHITECTURE.md](ARCHITECTURE.md) - Understand technical design
- Test the complete flow with an intentional error
