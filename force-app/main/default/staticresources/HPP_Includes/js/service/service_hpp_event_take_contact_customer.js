hppApp.service('serviceHPPEventContactCustomerController', ['$q', '$rootScope', function ($q, $rootScope) {
       this.SaveCard= function(data)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            HPPEventContactCustomerController.SaveCard(data,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

	this.TakePayment= function(data)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            HPPEventContactCustomerController.TakePayment(data,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

	this.TakeOtherPayment= function(id,data)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            HPPEventContactCustomerController.TakeOtherPayment(id,data,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

	this.Complete= function(id,logId)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            HPPEventContactCustomerController.CompleteTheEvent(id,logId,function(result, event){
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