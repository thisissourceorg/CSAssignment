import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPublicHolidays from '@salesforce/apex/PublicHolidaysController.getPublicHolidays';
import upsertIdInformation from '@salesforce/apex/PublicHolidaysController.upsertIdInformation';


export default class PublicHolidays extends LightningElement {
    pHolidays;
    searchedId;
    isValid = false;
    isDisabled = true;
    @api targetYear;

    handleKeyUp(event) {
        this.isValid = false;
        this.searchedId = event.target.value;
        console.log(this.searchedId);
        if (this.validateSearchedId()) {
            this.isDisabled = false;
        } else if (this.searchedId.length == 13) {

            this.dispatchEvent(new ShowToastEvent({
                title: 'Invalid Id',
                variant: 'error',
                message:
                    'The ID eneterd is invalid.',
            }));
        }else{
            this.isDisabled = true;
        }
    }

    validateSearchedId() {
        return this.searchedId.length == 13 && this.calculateSumOfNumbers() && isNaN(this.searchedId) == false;
    }

    handleClick(evt) {
        this.targetYear = '19' + this.searchedId.substring(0, 2);
        this.isValid = true;
        this.isDisabled = true;
        this.updateCountInDB();
        getPublicHolidays({targetYear : this.targetYear})
            .then(result => {
                console.log('Result' + result);
                this.pHolidays = result;
            })
            .catch(error => {
                console.log('CallBack Error: ' + error);
            });

    }

    updateCountInDB(){
        console.log('In updateCountInDB: ');
        upsertIdInformation({ saId : this.searchedId })
            .then(result => {
                console.log('Update result: '+ result);
            })
            .catch(error => {
                console.log('update error: ' + error);
            });
    }

    calculateSumOfNumbers() {
        var arr = this.searchedId.split('');
        var sum = 0;
        var n = arr.length;
        for (var i = 0; i < n; i++) {
            arr[i] = parseInt(arr[i]);
        }
        for (var i = 1; i < n; i = i + 2) {
            var v = arr[n - 1 - i] * 2;
            if (v > 9) { arr[n - 1 - i] = v - 9; }
            else { arr[n - 1 - i] = v; }
        }
        for (var i = 0; i < n; i++) {
            sum = sum + arr[i];
        }
        console.log('Sum: ' + sum);
        return sum % 10 === 0;
    }
}