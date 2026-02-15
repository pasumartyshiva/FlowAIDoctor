# Installation Guide - Flow Doctor AI

## Prerequisites

Before installing Flow Doctor AI, ensure your Salesforce org meets these requirements:

- Salesforce API version 62.0 or higher
- **Agentforce enabled** (contact Salesforce to enable if not available)
- **Prompt Builder enabled** (available in Setup → Feature Settings)
- System Administrator access
- Platform Events enabled (enabled by default in most orgs)

## Installation Methods

### Method 1: SFDX Deployment (Recommended)

1. **Clone or download the repository**
```bash
git clone https://github.com/salesforce-labs/flow-doctor-ai.git
cd flow-doctor-ai
```

2. **Authenticate to your Salesforce org**
```bash
sf org login web --set-default-dev-hub --alias FlowDoctorOrg
```

3. **Deploy the package**
```bash
sf project deploy start --source-dir force-app --target-org FlowDoctorOrg
```

4. **Wait for deployment to complete**
The deployment includes:
- 5 Apex classes
- 1 Apex trigger
- 4 custom objects with fields
- 1 platform event
- 1 LWC component
- Permission sets

5. **Verify deployment**
```bash
sf project deploy report --target-org FlowDoctorOrg
```

### Method 2: Change Sets

1. **In Source Org (where you downloaded the package):**
   - Navigate to Setup → Outbound Change Sets
   - Create new change set: "Flow Doctor AI v1.0"
   - Add all components from the package
   - Upload to target org

2. **In Target Org:**
   - Navigate to Setup → Inbound Change Sets
   - Find "Flow Doctor AI v1.0"
   - Validate
   - Deploy

### Method 3: Unmanaged Package (Coming Soon)

Will be available on AppExchange as Salesforce Labs app.

## Post-Installation Setup

### Step 1: Assign Permission Sets

Assign the appropriate permission set to users:

```bash
# For administrators
sf org assign permset --name Flow_Doctor_Admin --target-org FlowDoctorOrg

# For end users (view only)
sf org assign permset --name Flow_Doctor_User --target-org FlowDoctorOrg
```

Or manually via Setup:
1. Setup → Users → Permission Sets
2. Select "Flow Doctor Admin"
3. Click "Manage Assignments"
4. Add your admin users

### Step 2: Configure Agentforce Prompt Templates

This is the most critical step! Flow Doctor requires two Prompt Templates.

1. **Navigate to Prompt Builder**
   - Setup → Feature Settings → Prompt Builder
   - Click "New Prompt Template"

2. **Create "analyzeFlowError" Prompt Template**

   See [AGENTFORCE_SETUP.md](AGENTFORCE_SETUP.md) for the complete prompt template configuration.

3. **Create "detectErrorPatterns" Prompt Template**

   See [AGENTFORCE_SETUP.md](AGENTFORCE_SETUP.md) for the complete prompt template configuration.

### Step 3: Schedule Automated Jobs

Run this code in Developer Console (Debug → Open Execute Anonymous Window):

```apex
// Delete existing schedules if reinstalling
List<CronTrigger> existingJobs = [
    SELECT Id FROM CronTrigger 
    WHERE CronJobDetail.Name LIKE 'Flow%'
];
for (CronTrigger job : existingJobs) {
    System.abortJob(job.Id);
}

// Schedule pattern detection (runs hourly at :00)
System.schedule(
    'Flow Pattern Detection', 
    '0 0 * * * ?', 
    new FlowPatternDetectionService()
);

// Schedule error polling (runs every 5 minutes)
System.schedule(
    'Flow Error Polling', 
    '0 0/5 * * * ?', 
    new FlowErrorPollingSchedulable()
);

System.debug('Jobs scheduled successfully');
```

Verify jobs are running:
1. Setup → Scheduled Jobs
2. Confirm both jobs appear in the list

### Step 4: Add Flow Doctor to Lightning App

**Option A: Access via App Launcher**
1. Setup → App Manager
2. Find "Flow Doctor" app
3. Click "Edit"
4. Add user profiles that should see the app
5. Save

**Option B: Add Component to Existing Page**
1. Navigate to any Lightning page in App Builder
2. Edit page
3. Drag "flowDoctorDashboard" component onto page
4. Save and activate

### Step 5: Test the Installation

1. **Create a test Flow with an intentional error:**
   - Flow Builder → New Flow
   - Add "Update Records" element
   - Configure to update a required field to null
   - Save as "Test_Error_Flow"
   - Activate

2. **Trigger the error:**
   - Run the Flow manually
   - Let it fail

3. **Verify error capture:**
   - Open Flow Doctor dashboard
   - Error should appear within 30 seconds
   - Click error to view AI analysis

4. **Check AI analysis:**
   - Analysis should show root cause
   - Fix steps should be present
   - If analysis shows "pending", check Agentforce setup

## Troubleshooting Installation

### Deployment Fails

**Error: "Custom object 'Flow_Error_Log__c' already exists"**
- Solution: Delete existing objects first, then redeploy

**Error: "Package version conflict"**
- Solution: Ensure API version 62.0+ in sfdx-project.json

### Permission Issues

**Error: Users can't see Flow Doctor app**
- Verify permission set assignments
- Check user profile has access to custom objects
- Confirm Lightning App permissions

### Agentforce Not Working

**Analysis shows "AI analysis pending"**
- Verify Agentforce is enabled in your org
- Confirm Prompt Templates are created correctly
- Check Apex class can call Agentforce API
- Review debug logs for errors

### Scheduled Jobs Not Running

**Jobs don't appear in Scheduled Jobs**
- Re-run the scheduling code
- Check for Apex errors in debug logs
- Verify user has "Schedule Jobs" permission

### Platform Events Not Firing

**Errors not appearing in dashboard**
- Verify FlowExecutionErrorEvent is enabled
- Check Platform Event trigger is active
- Confirm LWC subscription is working
- Check browser console for errors

## Uninstallation

To completely remove Flow Doctor AI:

1. **Delete scheduled jobs**
```apex
List<CronTrigger> jobs = [
    SELECT Id FROM CronTrigger 
    WHERE CronJobDetail.Name LIKE 'Flow%'
];
for (CronTrigger job : jobs) {
    System.abortJob(job.Id);
}
```

2. **Delete custom data**
```apex
delete [SELECT Id FROM Flow_Error_Pattern__c];
delete [SELECT Id FROM Flow_Error_Analysis__c];
delete [SELECT Id FROM Flow_Error_Log__c];
```

3. **Remove via Change Set or SFDX**
```bash
sf project delete source --source-dir force-app --target-org FlowDoctorOrg
```

## Support

- GitHub Issues: Report bugs or request features
- Trailblazer Community: Ask questions
- Documentation: Check /docs folder for detailed guides

## Next Steps

- [AGENTFORCE_SETUP.md](AGENTFORCE_SETUP.md) - Configure Prompt Templates
- [USER_GUIDE.md](USER_GUIDE.md) - Learn how to use Flow Doctor
- [ARCHITECTURE.md](ARCHITECTURE.md) - Understand the technical design
