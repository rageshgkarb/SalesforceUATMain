tellerApp.service('serviceAccounts', ['$q', '$rootScope', function ($q, $rootScope) {

	this.GetAccountDetailsWithReasonCheck = function(customerId, ebsId)
	{
		var deferred = $q.defer();
        Teller_Core_Controller.GetAccountDetailsWithReasonCheck(customerId, ebsId, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
	}

    this.GetMiniStatementPrintTemplate = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetMiniStatementPrintTemplate(function (result, event) {
            
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