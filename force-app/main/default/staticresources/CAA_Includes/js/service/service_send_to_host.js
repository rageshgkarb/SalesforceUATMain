caaApp.service('serviceSendToHost', ['$q', '$rootScope', function ($q, $rootScope) {
       this.GetHostData= function(id)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.GetHostData(id,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            },{ buffer: false, escape: false, timeout: 120000});
            return deferred.promise;
        }

	this.CallEBS= function(id,session,data)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CallEBS(id,session,data,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            },{ buffer: false, escape: false, timeout: 120000});
            return deferred.promise;
        }
   }]);