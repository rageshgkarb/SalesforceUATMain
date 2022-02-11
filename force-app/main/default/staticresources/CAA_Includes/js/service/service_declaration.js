caaApp.service('serviceDeclaration', ['$q', '$rootScope', function ($q, $rootScope) {
       this.CallDe= function(id, session,declarations)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CallDe(id,session,declarations,function(result, event){
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