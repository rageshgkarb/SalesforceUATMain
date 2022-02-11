caaApp.service('serviceNextSteps', ['$q', '$rootScope', function ($q, $rootScope) {
       this.Complete = function(id)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_NextSteps_Controller.CompleteNextSteps(id,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

	this.UpdatePaymentMethod = function(id,session,paymentMethod)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_NextSteps_Controller.UpdatePaymentMethod(id,session,paymentMethod,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

	this.CallAJE= function(id)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_NextSteps_Controller.CallAJEns(id,'',function(result, event){
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