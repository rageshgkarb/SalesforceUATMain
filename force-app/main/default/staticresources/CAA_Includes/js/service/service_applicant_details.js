caaApp.service('serviceApplicantDetails', ['$q', '$rootScope', function ($q, $rootScope) {
    this.GetApplicantData = function (id, sessionId) {
        var deferred = $q.defer();
        CAA_Core_Controller.GetApplicantData(id, sessionId, function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        }, {
            buffer: false,
            escape: false,
            timeout: 30000
        });
        return deferred.promise;
    }


    this.FindExistingAccounts = function (search, eventLogId) {
        var deferred = $q.defer();
        CAA_Core_Controller.FindExistingAccounts(search, eventLogId, function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        }, {
            buffer: false,
            escape: false,
            timeout: 30000
        });
        return deferred.promise;
    }

    this.CompleteEvent = function (data, sessionId) {
        var deferred = $q.defer();
        CAA_Core_Controller.CompletePersonalDetails(data, sessionId, function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        });
        return deferred.promise;
    }

    this.CompleteEventOverride = function (data, sessionId) {
        var deferred = $q.defer();
        CAA_Core_Controller.CompletePersonalDetailsOverride(data, sessionId, function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        });
        return deferred.promise;
    }

    this.GetCampaigns = function (search) {
        var deferred = $q.defer();
        Visualforce.remoting.timeout = 120000;
        CAA_Core_Controller.GetCampaigns(search, function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        });
        return deferred.promise;
    }

    this.SaveData = function (data, sessionId) {
        var deferred = $q.defer();
        CAA_Core_Controller.SavePersonalDetails(data, sessionId, function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        });
        return deferred.promise;
    }

    this.FindCustomer = function (criteria) {
        var deferred = $q.defer();
        CAA_Core_Controller.FindCustomer(criteria, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        }, {
            buffer: false,
            escape: false,
            timeout: 30000
        });

        return deferred.promise;
    };

    this.AddApplicant = function (accountId, eventLogId) {
        var deferred = $q.defer();
        CAA_Core_Controller.AddApplicant(accountId, eventLogId, function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        });
        return deferred.promise;
    }


    this.RemoveApplicant = function (accountId, eventlogId) {
        var deferred = $q.defer();
        CAA_Core_Controller.RemoveApplicant(accountId, eventlogId, function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        });
        return deferred.promise;
    }

    this.CheckIsExistingAccount = function (data, logid, override) {
        var deferred = $q.defer();
        CAA_Core_Controller.IsExistingAccount(data, logid, override, function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event);
            }
        });
        return deferred.promise;
    }

}]);