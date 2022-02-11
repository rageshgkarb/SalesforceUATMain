caaApp.service('serviceFTDISA', ['$q', '$rootScope', function ($q, $rootScope) {
       this.Complete = function(id,data)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Product_Detail_Controller.FTDISA(id,data,function(result, event){
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