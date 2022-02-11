caaApp.service('serviceContinue', ['$q', '$rootScope', function ($q, $rootScope) {
       this.CheckQuestions= function(data)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_ExternalContinue_Controller.CheckQuestions(data,function(result, event){
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