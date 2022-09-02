import {LightningElement, api, wire, track} from 'lwc';
import getOpportunityWrappers from '@salesforce/apex/SummaryCustomersDataController.getOpportunityWrappers';
import getProducts from '@salesforce/apex/SummaryCustomersDataController.getProducts';

const DELAY = 100;
export default class SummaryCustomersData extends LightningElement {

    @api recordId;
    @track accounts = [];
    newAccounts;
    @track error;
    @track page = 1;
    @track items = [];
    @track data = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 10;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    searchString;
    opportunityId;
    @track openModal = false;
    products;

    @wire(getOpportunityWrappers, {recordId: '$recordId'})
    getAccount() {
        getOpportunityWrappers({recordId: this.recordId}).then(result => {
            this.accounts = result
            this.newAccounts = result
            this.items = result
            this.totalRecountCount = result.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.accounts = this.items.slice(0, this.pageSize);
            this.endingRecord = this.pageSize;
            this.error = undefined;
        }).catch(error => {
            console.log(error)
        })
    }

    handleAccountAction(event) {
        this.searchString = event.target.value;
        let findAccounts = [];
        let searchString = this.searchString;
        window.clearTimeout(this.delayTimeout);
        this.newAccounts.find(function (keyword) {
            if (keyword['account'].toUpperCase().includes(searchString.toUpperCase())) {
                findAccounts.push(keyword)
            }
            console.log(keyword['account']);
        })
        this.delayTimeout = setTimeout(() => {
            this.accounts = findAccounts;
        }, DELAY);
    }

    showModal(event) {
        this.opportunityId = event.target.value;
        this.openModal = true;
        console.log(this.opportunityId)
    }

    closeModal() {
        this.openModal = false;
    }

    @wire(getProducts, {opportunityId: '$opportunityId'})
    getProduct() {
        getProducts({opportunityId: this.opportunityId}).then(result => {
            this.products = result
            console.log(this.products)
        }).catch(error => {
            console.log(error)
        })
    }

    show(event) {
        this.showModal(event);
        this.getProduct({opportunityId: this.opportunityId});
        return true;
    }

    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }

    displayRecordPerPage(page) {
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;
        this.accounts = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }
}