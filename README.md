# Flow Doctor AI

Open-source Salesforce application that revolutionizes Flow debugging with AI-powered root cause analysis using Agentforce.

## What It Does

Flow Doctor AI captures Flow errors in real-time and uses Agentforce Prompt Templates to provide:
- **Root cause analysis** in seconds instead of hours
- **Step-by-step remediation instructions** with exact element names
- **Pattern detection** across multiple errors to identify systemic issues
- **Real-time alerts** for critical Flow failures
- **Historical trend analysis** to prevent future errors

## Why This Matters

**The Traditional Flow Debugging Process:**
1. Receive cryptic error email with GUID
2. Navigate to Setup → Paused Flow Interviews
3. Spend 30-60 minutes digging through debug logs
4. Trial-and-error fixes
5. Users blocked the entire time

**With Flow Doctor AI:**
1. Error captured instantly
2. AI analyzes in 10 seconds
3. View root cause with fix steps
4. Apply fix in Flow Builder
5. Mark as resolved
**Total time: 5 minutes** ✨

## Key Features

### 1. Real-Time Error Capture
- Monitors Screen Flows via FlowExecutionErrorEvent
- Polls Record-Triggered/Scheduled Flows via Tooling API
- Automatic deduplication to prevent noise
- Zero configuration required

### 2. AI-Powered Analysis (Agentforce)
- Uses Prompt Templates for consistent, structured analysis
- Provides root cause categorization
- Assesses user impact
- Generates actionable fix steps
- Includes test scenarios for validation

### 3. Pattern Detection
- Identifies recurring issues across Flows
- Detects systemic architectural problems
- Suggests long-term improvements
- Runs automatically every hour

### 4. Native Lightning UI
- Real-time dashboard updates via Platform Events
- No page refresh needed
- Click any error to see full AI analysis
- Track resolution time metrics

## Installation

### Prerequisites
- Salesforce org with API v62.0+
- **Agentforce enabled** (required for AI analysis)
- **Prompt Builder enabled** (required for prompt templates)
- System Administrator access

### Quick Install

1. **Deploy the package**
```bash
sf project deploy start --source-dir force-app --target-org yourorg
```

2. **Assign permission set**
```bash
sf org assign permset --name Flow_Doctor_Admin --target-org yourorg
```

3. **Schedule automated jobs** (run in Developer Console)
```apex
// Pattern detection (runs hourly)
System.schedule('Flow Pattern Detection', '0 0 * * * ?', new FlowPatternDetectionService());

// Error polling for non-screen flows (runs every 5 minutes)
System.schedule('Flow Error Polling', '0 0/5 * * * ?', new FlowErrorPollingSchedulable());
```

4. **Configure Agentforce Prompt Templates**
   - Navigate to Setup → Prompt Builder
   - Create two prompt templates (see docs/AGENTFORCE_SETUP.md)
   - Template 1: "analyzeFlowError"
   - Template 2: "detectErrorPatterns"

5. **Access Flow Doctor**
   - Open App Launcher
   - Search for "Flow Doctor"
   - Or add the LWC component to any Lightning page

### Manual Setup (if using Change Sets)
See [docs/INSTALLATION.md](docs/INSTALLATION.md) for detailed instructions

## How It Works

```
┌─────────────────────────────────────────────────────┐
│  Flow Fails                                         │
│  ↓                                                  │
│  FlowExecutionErrorEvent fires                      │
│  ↓                                                  │
│  FlowErrorCaptureService captures error             │
│  ↓                                                  │
│  Publishes to Flow_Error_Alert__e                   │
│  ↓                                                  │
│  Trigger creates Flow_Error_Log__c record           │
│  ↓                                                  │
│  Queries Tooling API for Flow metadata              │
│  ↓                                                  │
│  Calls Agentforce Prompt Template                   │
│  ↓                                                  │
│  AI analyzes: root cause + fix steps                │
│  ↓                                                  │
│  Stores in Flow_Error_Analysis__c                   │
│  ↓                                                  │
│  Real-time update to Lightning dashboard            │
└─────────────────────────────────────────────────────┘
```

## Architecture

### Components

**Apex Classes:**
- `FlowErrorCaptureService` - Captures errors from platform events and polling
- `FlowMetadataService` - Queries Flow definitions via Tooling API
- `FlowErrorAnalysisService` - Orchestrates AI analysis
- `FlowPatternDetectionService` - Detects patterns across errors
- `FlowDoctorController` - Aura-enabled controller for LWC

**Custom Objects:**
- `Flow_Error_Log__c` - Stores error details
- `Flow_Error_Analysis__c` - Stores AI analysis results
- `Flow_Error_Pattern__c` - Stores detected patterns

**Platform Events:**
- `Flow_Error_Alert__e` - Real-time error notifications

**LWC Components:**
- `flowDoctorDashboard` - Main dashboard UI

**Agentforce Prompt Templates:**
- `analyzeFlowError` - Individual error analysis
- `detectErrorPatterns` - Pattern detection across errors

## Agentforce Integration

This application showcases **Prompt Templates as Infrastructure** - a new pattern for enterprise AI:

### Why Prompt Templates?
Instead of freeform AI chat, we use structured Prompt Templates as reliable APIs:
- **Guaranteed JSON output** - Parseable, structured responses
- **Version controlled** - Audit trail for all AI logic
- **Context-rich** - Flow metadata from Tooling API provides full context
- **Scalable** - Processes thousands of errors without human intervention

### Example Prompt Template: analyzeFlowError

**Input Variables:**
- `errorContext` - JSON with error details, Flow metadata, similar errors

**Prompt:**
```
You are analyzing a Salesforce Flow error...

CONTEXT:
{!$Input:errorContext}

Provide analysis in JSON format:
{
  "rootCause": "...",
  "rootCauseCategory": "Missing Fault Path|Null Reference|...",
  "immediateAction": "...",
  "fixSteps": ["Step 1...", "Step 2..."],
  "confidenceScore": 0.95
}
```

**Output:**
- Structured JSON stored in Flow_Error_Analysis__c
- Available immediately in dashboard

See [docs/AGENTFORCE_SETUP.md](docs/AGENTFORCE_SETUP.md) for complete setup instructions.

## Usage

### View Recent Errors
1. Open Flow Doctor dashboard
2. Errors appear in real-time as they occur
3. Click any error to view AI analysis

### Analyze an Error
1. Click error row
2. Review root cause and user impact
3. Follow step-by-step fix instructions
4. Add resolution notes
5. Mark as resolved

### Detect Patterns
Runs automatically every hour. View detected patterns in the "Patterns" section.

### Mark Errors Resolved
1. Apply the suggested fix in Flow Builder
2. Return to Flow Doctor
3. Click error → "Mark as Resolved"
4. Add resolution notes
5. System tracks resolution time

## Troubleshooting

### Errors not appearing?
- Verify scheduled jobs are running: Setup → Scheduled Jobs
- Check Platform Event subscription in LWC
- Confirm Agentforce is enabled

### AI analysis shows "pending"?
- Verify Prompt Templates are created in Prompt Builder
- Check that Agentforce API is accessible
- Review Apex debug logs for errors

### Pattern detection not working?
- Ensure scheduled job is running hourly
- Verify at least 3 errors exist for a Flow in last 24 hours

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more help.

## Contributing

This is an open-source Salesforce Labs project. Contributions welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests (80%+ coverage required)
5. Submit a pull request

## Roadmap

**v1.1 (Current)**
- Basic error capture and AI analysis
- Pattern detection
- Lightning dashboard

**v1.2 (Planned)**
- Auto-generate fault path Flows
- Slack/Teams integration for alerts
- Custom alerting thresholds

**v2.0 (Future)**
- Apex error monitoring
- Multi-org dashboard
- Predictive error prevention
- Mobile app

## License

BSD 3-Clause License (Salesforce Labs standard)

See [LICENSE](LICENSE) for details.

## Support

- **GitHub Issues**: Bug reports and feature requests
- **Trailblazer Community**: Questions and discussions
- **Documentation**: See /docs folder

## Credits

Built with ❤️ by the Salesforce community

Powered by Agentforce and Prompt Builder
