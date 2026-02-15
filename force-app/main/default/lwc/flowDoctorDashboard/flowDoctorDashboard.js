import { LightningElement, wire, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecentErrors from '@salesforce/apex/FlowDoctorController.getRecentErrors';
import getErrorAnalysis from '@salesforce/apex/FlowDoctorController.getErrorAnalysis';

const COLUMNS = [
    {
        label: 'Severity',
        fieldName: 'Severity__c',
        type: 'text',
        sortable: true,
        initialWidth: 100,
        cellAttributes: {
            class: { fieldName: 'severityCssClass' }
        }
    },
    {
        label: 'Flow Name',
        fieldName: 'Flow_Label__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Element',
        fieldName: 'Element_API_Name__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Error Message',
        fieldName: 'Error_Message__c',
        type: 'text',
        wrapText: true
    },
    {
        label: 'Status',
        fieldName: 'Status__c',
        type: 'text',
        sortable: true,
        initialWidth: 110
    },
    {
        label: 'AI',
        fieldName: 'AI_Analysis_Complete__c',
        type: 'boolean',
        initialWidth: 60
    },
    {
        label: 'Timestamp',
        fieldName: 'Error_Timestamp__c',
        type: 'date',
        sortable: true,
        initialWidth: 170,
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'View AI Analysis', name: 'view_analysis' },
                { label: 'View Record', name: 'view_record' }
            ]
        }
    }
];

export default class FlowDoctorDashboard extends LightningElement {
    @track errors = [];
    @track analysis = null;
    @track showAnalysisModal = false;
    @track isLoadingAnalysis = false;
    @track selectedErrorName = '';
    @track sortedBy = 'Error_Timestamp__c';
    @track sortedDirection = 'desc';

    columns = COLUMNS;
    subscription = {};
    channelName = '/event/Flow_Error_Alert__e';
    wiredErrorsResult;

    @wire(getRecentErrors, { limitCount: 50 })
    wiredErrors(result) {
        this.wiredErrorsResult = result;
        if (result.data) {
            this.errors = result.data.map(error => ({
                ...error,
                severityCssClass: this.getSeverityClass(error.Severity__c)
            }));
        }
    }

    connectedCallback() {
        this.handleSubscribe();
        this.registerErrorListener();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleSubscribe() {
        const messageCallback = (response) => {
            this.handleNewError(response.data.payload);
        };
        subscribe(this.channelName, -1, messageCallback).then(response => {
            this.subscription = response;
        });
    }

    handleUnsubscribe() {
        unsubscribe(this.subscription, () => {});
    }

    registerErrorListener() {
        onError(error => {
            console.error('EMP API Error:', JSON.stringify(error));
        });
    }

    handleNewError(payload) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'New Flow Error Detected',
                message: `${payload.Flow_API_Name__c} failed at ${payload.Element_API_Name__c}`,
                variant: 'error',
                mode: 'sticky'
            })
        );
        refreshApex(this.wiredErrorsResult);
    }

    handleRefresh() {
        refreshApex(this.wiredErrorsResult);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Refreshed',
                message: 'Error list updated.',
                variant: 'success'
            })
        );
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;

        const data = [...this.errors];
        const reverse = this.sortedDirection === 'asc' ? 1 : -1;
        const fieldName = this.sortedBy;

        data.sort((a, b) => {
            const valA = a[fieldName] || '';
            const valB = b[fieldName] || '';
            if (valA < valB) return -1 * reverse;
            if (valA > valB) return 1 * reverse;
            return 0;
        });

        this.errors = data;
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        switch (action.name) {
            case 'view_analysis':
                this.viewAnalysis(row);
                break;
            case 'view_record':
                this.navigateToRecord(row.Id);
                break;
            default:
                break;
        }
    }

    viewAnalysis(row) {
        this.selectedErrorName = row.Flow_Label__c || row.Flow_API_Name__c;
        this.showAnalysisModal = true;
        this.isLoadingAnalysis = true;
        this.analysis = null;

        getErrorAnalysis({ errorLogId: row.Id })
            .then(result => {
                this.analysis = result;
                this.isLoadingAnalysis = false;
            })
            .catch(error => {
                this.isLoadingAnalysis = false;
                console.error('Error loading analysis:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Could not load AI analysis.',
                        variant: 'error'
                    })
                );
            });
    }

    navigateToRecord(recordId) {
        window.open('/' + recordId, '_blank');
    }

    closeAnalysisModal() {
        this.showAnalysisModal = false;
        this.analysis = null;
    }

    openDocumentation() {
        if (this.analysis && this.analysis.Documentation_URL__c) {
            window.open(this.analysis.Documentation_URL__c, '_blank');
        }
    }

    getSeverityClass(severity) {
        switch (severity) {
            case 'Critical': return 'slds-text-color_error';
            case 'High': return 'slds-text-color_error';
            case 'Medium': return '';
            case 'Low': return 'slds-text-color_weak';
            default: return '';
        }
    }

    get hasErrors() {
        return this.errors && this.errors.length > 0;
    }

    get totalErrorCount() {
        return this.errors ? this.errors.length : 0;
    }

    get criticalCount() {
        return this.errors
            ? this.errors.filter(e => e.Severity__c === 'Critical' || e.Severity__c === 'High').length
            : 0;
    }

    get analyzedCount() {
        return this.errors
            ? this.errors.filter(e => e.AI_Analysis_Complete__c === true).length
            : 0;
    }

    get resolvedCount() {
        return this.errors
            ? this.errors.filter(e => e.Status__c === 'Resolved').length
            : 0;
    }

    get confidenceBadgeClass() {
        if (!this.analysis) return 'slds-badge';
        const score = this.analysis.Confidence_Score__c;
        if (score >= 80) return 'slds-badge slds-theme_success';
        if (score >= 50) return 'slds-badge slds-theme_warning';
        return 'slds-badge slds-theme_error';
    }
}
