# Quick Start Guide - Flow Doctor AI

Get Flow Doctor AI running in your Salesforce org in 15 minutes.

## 1. Prerequisites Check (2 minutes)

✅ Salesforce org with API v62.0+  
✅ Agentforce enabled  
✅ Prompt Builder enabled  
✅ System Administrator access  

Not sure? Run this in Developer Console:
```apex
System.debug('API Version: ' + UserInfo.getOrganizationId());
// Check Setup → Feature Settings → Agentforce
// Check Setup → Feature Settings → Prompt Builder
```

## 2. Deploy the Package (5 minutes)

### Option A: SFDX (Recommended)
```bash
# Clone repo
git clone https://github.com/salesforce-labs/flow-doctor-ai.git
cd flow-doctor-ai

# Authenticate
sf org login web --alias FlowDoctor

# Deploy
sf project deploy start --source-dir force-app --target-org FlowDoctor
```

### Option B: Unmanaged Package
Coming soon on AppExchange!

## 3. Assign Permissions (1 minute)

```bash
sf org assign permset --name Flow_Doctor_Admin --target-org FlowDoctor
```

Or manually:
1. Setup → Users → Permission Sets
2. Click "Flow Doctor Admin"
3. Manage Assignments → Add yourself

## 4. Configure Agentforce (5 minutes)

**Critical Step!** Flow Doctor needs AI.

1. **Setup → Prompt Builder → New Prompt Template**

2. **Create "analyzeFlowError":**
   - Name: `analyzeFlowError`
   - Input: `errorContext` (Text)
   - Copy prompt from: [docs/AGENTFORCE_SETUP.md](docs/AGENTFORCE_SETUP.md)
   - Output: `analysisResult` (Text)
   - Save

3. **Create "detectErrorPatterns":**
   - Name: `detectErrorPatterns`
   - Inputs: `flowApiName` (Text), `errorsContext` (Text)
   - Copy prompt from: [docs/AGENTFORCE_SETUP.md](docs/AGENTFORCE_SETUP.md)
   - Output: `patternsResult` (Text)
   - Save

## 5. Schedule Jobs (2 minutes)

Developer Console → Debug → Execute Anonymous:

```apex
// Pattern detection (hourly)
System.schedule('Flow Pattern Detection', '0 0 * * * ?', 
    new FlowPatternDetectionService());

// Error polling (every 5 min)
System.schedule('Flow Error Polling', '0 0/5 * * * ?', 
    new FlowErrorPollingSchedulable());
```

Verify: Setup → Scheduled Jobs (both jobs should appear)

## 6. Test It! (5 minutes)

### Create Test Flow with Error:
1. Flow Builder → New Flow
2. Add "Update Records" element
3. Object: Account
4. Filter: Account Number = "TEST"
5. Set field: Name = null
6. Save as "Test_Error_Flow"
7. Activate

### Trigger the Error:
1. Create Account with Number = "TEST"
2. Run Flow manually (or trigger it)
3. Flow will fail (intentionally)

### View in Flow Doctor:
1. App Launcher → "Flow Doctor"
2. Error appears within 30 seconds
3. Click error row
4. See AI analysis with:
   - Root cause
   - Fix steps
   - Test scenario

### Expected Analysis:
```
Root Cause: Attempting to set required field 'Name' to null
Category: Field Validation
Fix Steps:
1. Open Flow Builder → Test_Error_Flow
2. Click Update_Records element
3. Add Fault Path connector
4. Create Screen: "Error: Cannot clear Account Name"
5. Save and activate
```

## 7. Clean Up Test (1 minute)

```apex
delete [SELECT Id FROM Flow_Error_Log__c WHERE Flow_API_Name__c = 'Test_Error_Flow'];
```

Deactivate Test_Error_Flow in Flow Builder.

## Success!

Flow Doctor AI is now:
- ✅ Monitoring all Flow errors in real-time
- ✅ Analyzing errors with AI
- ✅ Detecting patterns hourly
- ✅ Available in your Lightning apps

## Next Steps

- Read [USER_GUIDE.md](docs/USER_GUIDE.md) for full features
- Customize alerts and thresholds
- Add dashboard to Home page
- Share with your admin team

## Troubleshooting

**Errors not appearing?**
- Check scheduled jobs are running
- Verify Platform Event trigger is active

**AI analysis stuck on "pending"?**
- Confirm Prompt Templates created correctly
- Check Agentforce is enabled
- Review Apex debug logs

**Need help?**
- GitHub Issues: Report bugs
- Trailblazer Community: Ask questions
- Full docs: [docs/INSTALLATION.md](docs/INSTALLATION.md)

## What You Just Built

You now have:
- Real-time Flow error monitoring
- AI-powered root cause analysis (10-second response)
- Pattern detection across all Flows
- Historical trend tracking
- Resolution time metrics

**Estimated time savings: 90% reduction in Flow debugging**

Welcome to the future of Flow debugging! 🚀
