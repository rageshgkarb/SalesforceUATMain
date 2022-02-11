tellerApp.service('serviceReporting', ['$q', '$rootScope', function ($q, $rootScope) {

	this.InitialiseSearchCriteria = function(pageSize, pageOffset)
	{
		var deferred = $q.defer();
        Teller_Core_Controller.InitialiseSearchCriteria(pageSize, pageOffset, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
	}

    this.InitialiseFilterLists = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.InitialiseFilterLists(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.GetTellerActivityAudit = function(searchCriteria)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetTellerActivityAudit(searchCriteria, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.GetActivityAuditPrintTemplate = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetActivityAuditPrintTemplate(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.GetCurrentTellerActivityForToday = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetCurrentTellerActivityForToday(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }    

    this.GetActivityItem = function(activityType, referenceId)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetActivityItem(activityType, referenceId, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.ApproveTransaction = function(TransactionId, Password, Notes)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.ApproveTransaction(TransactionId, Password, Notes, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.DeclineTransaction = function(TransactionId, Password, Notes)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.DeclineTransaction(TransactionId, Password, Notes, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.SendTransactionToHost = function(TransactionId)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.SendTransactionToHost(TransactionId, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }
    
    this.GetSubmittedForAuthorisationForAccount = function(accountNo)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetSubmittedForAuthorisationForAccount(accountNo, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }
    this.GetDealDepositInfo = function(accountNo)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetDealDepositInfo(accountNo, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }
    this.GetDealFinanceInfo = function(accountNo)
    {
        var deferred = $q.defer();        
        Teller_Core_Controller.GetDealFinanceInfo(accountNo, function (result, event) {
            
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