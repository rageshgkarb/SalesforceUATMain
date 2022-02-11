tellerApp.service('serviceCustomer', ['$q', '$rootScope', function ($q, $rootScope) {

    this.FindCustomer = function (criteria) {
        var deferred = $q.defer();
        Teller_Core_Controller.FindCustomer(criteria, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    };
	
	this.GetCustomerUserInfo = function(accountId) {
        var deferred = $q.defer();
        Teller_Core_Controller.GetUserInfo(accountId, function (result, event) {
        if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    };  
	
	this.OnlineBankingFunction = function(accountId,functionType) {
        var deferred = $q.defer();
        Teller_Core_Controller.OnlineBankingFunction(accountId,functionType, function (result, event) {
        if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    };

    this.GetCustomerDetails = function(accountId) {
        var deferred = $q.defer();
        Teller_Core_Controller.GetCustomerDetails(accountId, function (result, event) {
        if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    };  

    this.GetCustomerAlerts = function(accountId) {
        var deferred = $q.defer();
        Teller_Core_Controller.GetCustomerAlerts(accountId, function (result, event) {
        if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    };


    // this.GetCustomerTransactions = function(kendoGridOptions, accountId) {
    //     var deferred = $q.defer();
    //     Teller_Core_Controller.GetCustomerTransactions(kendoGridOptions, accountId, function (result, event) {
    //     if (event.status) {
    //             deferred.resolve(result);
    //         }
    //         else {
    //             deferred.reject(event);
    //         }   
    //     });

    //     return deferred.promise;
    // }; 
	
	

	this.GetIFMTransactions = function(accountId, fromDate, toDate) {
        var deferred = $q.defer();
        Teller_Core_Controller.GetIFMTransactions(accountId, fromDate, toDate, function (result, event) {
        if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }
	
    this.GetTransactionHistory = function(accountId, fromDate, toDate) {
        var deferred = $q.defer();
        Teller_Core_Controller.GetTransactionHistory(accountId, fromDate, toDate, function (result, event) {
        if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }


    this.LoadSignatories = function(externalAccountNum)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.LoadSignatories(externalAccountNum, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.SubmitViewingReason = function(accountId, previousReason, newReason)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.SubmitViewingReason(accountId, previousReason, newReason, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.SaveCustomerImages = function(ebsId, imgType, imgBase64Binary)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.SaveCustomerImages(ebsId, imgType, imgBase64Binary, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.UpdateCustomerDetails = function(customerDetails)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.UpdateCustomerDetails(customerDetails, function (result, event) {            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.UpdateCustomerDetailsInEBS = function(customerDetails, weblogId)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.UpdateCustomerDetailsInEBS(customerDetails, weblogId, function (result, event) {            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    // C0697 - Extended method signatures
	this.UpdateMarketingPreferences = function(accountId, hasEmail, hasMail, hasPhone, hasSMS, hasNewsletter, hasNone, noProfiling) {
        var deferred = $q.defer();
        Teller_Core_Controller.UpdateMarketingPreferences(accountId, hasEmail, hasMail, hasPhone, hasSMS, hasNewsletter, hasNone, !noProfiling, function (result, event) {            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;   
    }

}]);