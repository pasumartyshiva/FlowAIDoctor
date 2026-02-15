#!/bin/bash

BASE_DIR="/home/claude/flow-doctor-ai/force-app/main/default/lwc"

# Create flowDoctorDashboard LWC
mkdir -p "$BASE_DIR/flowDoctorDashboard"

cat > "$BASE_DIR/flowDoctorDashboard/flowDoctorDashboard.js" << 'EOF'
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
EOF

cat > "$BASE_DIR/flowDoctorDashboard/flowDoctorDashboard.html" << 'EOF'
<template>
    <lightning-card title="Flow Doctor AI" icon-name="custom:custom91">
        <div slot="actions">
            <lightning-button 
                label="Refresh" 
                onclick={handleRefresh}
                icon-name="utility:refresh">
            </lightning-button>
        </div>
        
        <div class="slds-p-around_medium">
            <template if:true={hasErrors}>
                <lightning-datatable
                    key-field="Id"
                    data={errors}
                    columns={columns}
                    hide-checkbox-column>
                </lightning-datatable>
            </template>
            
            <template if:false={hasErrors}>
                <div class="slds-align_absolute-center slds-p-around_large">
                    <p class="slds-text-color_weak">No errors found. Your Flows are running smoothly!</p>
                </div>
            </template>
        </div>
    </lightning-card>
</template>
EOF

cat > "$BASE_DIR/flowDoctorDashboard/flowDoctorDashboard.js-meta.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>62.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__AppPage</target>
        <target>lightning__HomePage</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__AppPage, lightning__HomePage">
            <property name="height" type="Integer" default="600" label="Component Height (px)"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
EOF

echo "LWC components created successfully"
