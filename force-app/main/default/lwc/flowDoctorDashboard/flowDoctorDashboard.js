import { LightningElement, wire, track } from 'lwc';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecentErrors from '@salesforce/apex/FlowDoctorController.getRecentErrors';

export default class FlowDoctorDashboard extends LightningElement {
    @track errors = [];
    subscription = {};
    channelName = '/event/Flow_Error_Alert__e';
    
    @wire(getRecentErrors, { limitCount: 50 })
    wiredErrors(result) {
        this.wiredErrorsResult = result;
        if (result.data) {
            this.errors = result.data;
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
        unsubscribe(this.subscription, response => {
            console.log('Unsubscribed');
        });
    }
    
    registerErrorListener() {
        onError(error => {
            console.log('Error: ', JSON.stringify(error));
        });
    }
    
    handleNewError(payload) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'New Flow Error',
                message: `${payload.Flow_API_Name__c} failed`,
                variant: 'error'
            })
        );
        
        refreshApex(this.wiredErrorsResult);
    }
    
    handleRefresh() {
        refreshApex(this.wiredErrorsResult);
    }
    
    get hasErrors() {
        return this.errors && this.errors.length > 0;
    }
}
