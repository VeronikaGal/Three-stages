/**
 * Created by User on 4/28/2022.
 */
import {LightningElement, api, wire, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord, getFieldValue} from "lightning/uiRecordApi";
import INVOICE_NUMBER from '@salesforce/schema/Opportunity.Invoice__c';
import getEmailBody from '@salesforce/apex/SendInvoiceController.getEmailBody';
import getContactName from '@salesforce/apex/SendInvoiceController.getContactName';
import getContactEmail from '@salesforce/apex/SendInvoiceController.getContactEmail';
import getFileByRecordId from '@salesforce/apex/SendInvoiceController.getFileByRecordId';
import sendSingleEmailMessage from '@salesforce/apex/SendInvoiceController.sendSingleEmailMessage';

const fields = [INVOICE_NUMBER];
export default class SendInvoice2 extends NavigationMixin(LightningElement) {

    @api recordId;
    emailBodyText;
    contactName;
    contactEmail;
    Navigate;
    fileId;
    @wire(getRecord, {recordId: "$recordId", fields})
    opportunity;

    get invoiceNumber() {
        return getFieldValue(this.opportunity.data, INVOICE_NUMBER);
    }

    @wire(getEmailBody, {recordId: '$recordId'})
    emailBody() {
        getEmailBody({recordId: this.recordId})
            .then(result => {
                this.emailBodyText = result
            }).catch(error => {
            console.log(error)
        })
    }

    handleChange(event) {
        this.emailBodyText = event.target.value;
    }

    @wire(getContactName, {recordId: '$recordId'})
    name() {
        getContactName({recordId: this.recordId})
            .then((result) => {
                this.contactName = result;
            }).catch((error) => {
            console.log(error)
        })
    }

    @wire(getContactEmail, {recordId: '$recordId'})
    email() {
        getContactEmail({recordId: this.recordId})
            .then((result) => {
                this.contactEmail = result;
            }).catch((error) => {
            console.log(error)
        })
    }

    @wire(getFileByRecordId, {recordId: '$recordId'})
    file() {
        getFileByRecordId({recordId: this.recordId})
            .then((result) => {
                this.fileId = result;
            }).catch((error) => {
            console.log(error)
        })
    }

    navigateToFiles() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: this.fileId
            }
        })
    }

    @wire(sendSingleEmailMessage)
    sendEmail() {
        sendSingleEmailMessage({
            subject: this.invoiceNumber,
            contactEmail: this.contactEmail,
            emailBodyText: this.emailBodyText,
        });
    }
}