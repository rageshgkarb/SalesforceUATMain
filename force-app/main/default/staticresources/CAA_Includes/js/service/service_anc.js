caaApp.service('serviceANC', ['$q', '$rootScope', function ($q, $rootScope) {
       this.Create = function(type,id)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CreateANC(type,id,function(result, event){
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