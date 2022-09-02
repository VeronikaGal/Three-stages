import {LightningElement, api, wire, track} from 'lwc';
import executeBatchJob from '@salesforce/apex/ScheduleBatchApexController.executeBatchJob';
import abortBatch from '@salesforce/apex/ScheduleBatchApexController.abortBatch';
import scheduleBatch from '@salesforce/apex/ScheduleBatchApexController.scheduleBatch';
import getJobId from '@salesforce/apex/ScheduleBatchApexController.getJobId';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class ScheduleBatch extends LightningElement {

    @api batch;
    @api scheduler;
    cronString;
    scheduleJobId;
    id;

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Some unexpected error',
            variant: 'error',
            mode: 'dismissible'
        });
        this.dispatchEvent(event);
    }

    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Toast Success',
            message: 'Operation successful',
            variant: 'success',
            mode: 'dismissible'
        });
        this.dispatchEvent(event);
    }

    handleInputChange(event) {
        this.cronString = event.detail.value;
        console.log(this.cronString)
    }

    connectedCallback() {
        console.log(this.scheduler)
        console.log(this.batch)
        console.log('cron')
        console.log(this.cronString)
        getJobId({scheduler: this.scheduler})
            .then(result => {
                this.scheduleJobId = result
            }).catch(error => {
            console.log(error)
        })
    }

    executeBatch() {
        executeBatchJob({batch: this.batch})
            .then(result => {
                this.id = result
                console.log(this.id)
                this.showSuccessToast()
            }).catch(error => {
            this.showErrorToast()
            console.log(error)
        })
    }

    scheduleBatch() {
        scheduleBatch({scheduler: this.scheduler, cronString: this.cronString})
            .then(result => {
                this.scheduleJobId = result
                this.showSuccessToast()
                console.log(this.scheduleJobId)
            }).catch(error => {
            this.showErrorToast()
            console.log(error)
        })
    }

    abortBatch() {
        console.log(this.scheduleJobId)
        abortBatch({scheduleJobId: this.scheduleJobId})
            .then(this.showSuccessToast(),
                this.scheduleJobId = false
            )
            .catch(error => {
                this.showErrorToast()
                console.log(error)
            })
    }
}