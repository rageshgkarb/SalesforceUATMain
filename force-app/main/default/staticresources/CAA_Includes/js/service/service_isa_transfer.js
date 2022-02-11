caaApp.service('serviceISATransfer', ['$q', '$rootScope', function ($q, $rootScope) {
       this.Complete = function(id,session,data,complete)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.SaveISATransfer(id,session,data,complete,function(result, event){
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