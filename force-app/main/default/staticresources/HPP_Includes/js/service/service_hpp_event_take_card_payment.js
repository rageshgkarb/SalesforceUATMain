hppApp.service('serviceHPPEventTakeCardPayment', ['$q', '$rootScope', function ($q, $rootScope) {
       this.SaveCard= function(data)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            HPPEventTakeCardPaymentController.SaveCard(data,function(result, event){
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
            HPPEventTakeCardPaymentController.TakePayment(data,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

	this.TakeOtherPayment= function(id,isRemainder,data,value)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            HPPEventTakeCardPaymentController.TakeOtherPayment(id,isRemainder,data,value,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

	this.Complete= function(id,isRemainder,logId)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            HPPEventTakeCardPaymentController.completeTheEvent(id,isRemainder,logId,function(result, event){
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