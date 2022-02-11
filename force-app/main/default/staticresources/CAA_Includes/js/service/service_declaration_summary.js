caaApp.service('serviceDeclarationSummary', ['$q', '$rootScope', function ($q, $rootScope) {
       this.CompleteSummary= function(id)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CompleteSummary(id,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }
   }]);