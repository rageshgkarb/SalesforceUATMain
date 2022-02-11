caaApp.service('serviceEligibility', ['$q', '$rootScope', function ($q, $rootScope) {
       this.CreateEligibility = function(id)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.Eligibility(id,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

	this.GetCampaigns = function(search)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.GetCampaigns(search,function(result, event){
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