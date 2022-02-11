tellerApp.service('serviceMandates', ['$q', '$rootScope', function ($q, $rootScope) {

    this.LoadMandatesAndSignatories = function(accountNo){
        var deferred = $q.defer();
        Teller_Core_Controller.LoadMandatesAndSignatories(accountNo, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    this.DeleteMandate = function (mandateId) {
        var deferred = $q.defer();
        Teller_Core_Controller.DeleteMandate(mandateId, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    //AccountHolder-----------------------------------
    this.LoadSignatoriesAndGroups = function(request) {
        var deferred = $q.defer();
        Teller_Core_Controller.LoadSignatoriesAndGroups(request, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    this.SaveSignatories = function(request) {
        var deferred = $q.defer();
        Teller_Core_Controller.SaveSignatories(request, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    //Mandate-----------------------------------------

    this.LoadMandateItems = function(request) {
        var deferred = $q.defer();
        Teller_Core_Controller.LoadMandateItems(request, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    this.SaveMandateItems = function(request) {
        var deferred = $q.defer();
        Teller_Core_Controller.SaveMandateItems(request, function (result, event) {

            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }
        });

        return deferred.promise;
    }

    this.CheckMandates = function(request)
    {
         var deferred = $q.defer();
        Teller_Core_Controller.CheckMandates(request, function (result, event) {

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