caaApp.service('serviceProductSelect', ['$q', '$rootScope', function ($q, $rootScope) {
        this.GetProductSuitability = function()
        {
            var deferred = $q.defer();
            CAA_Core_Controller.GetProductSuitability(function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }
        
        this.SendProductSelected= function(data,sessionId, hasEmail, hasMail, hasPhone, hasSMS, hasNewsletter, hasNone)
        {
            var deferred = $q.defer();
			// C0697
		    CAA_Core_Controller.ProductSelected(data, sessionId, hasEmail, hasMail, hasPhone, hasSMS, hasNewsletter, hasNone, function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }
		
		this.getLoadSourceofFundPickLists = function()
        {
            var deferred = $q.defer();
            CAA_Core_Controller.getLoadSourceofFundPickLists(function(result, event){
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