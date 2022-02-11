tellerApp.service('serviceTeller', ['$q', '$rootScope', function ($q, $rootScope) {

	this.GetPermittedMenuItems = function(functionId, accountNo)
	{
		var deferred = $q.defer();
        Teller_Core_Controller.GetPermittedMenuItems(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
	}

    this.GetTellerInfo = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetTellerInfo(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.GetTellerTillDetails = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetTellerTillDetails(function (result, event) {
            
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