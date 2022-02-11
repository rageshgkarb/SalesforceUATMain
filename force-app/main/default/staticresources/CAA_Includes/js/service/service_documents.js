caaApp.service('serviceDocuments', ['$q', '$rootScope', function ($q, $rootScope) {
       this.GetDocumentData= function(id,session,stage)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.GetDocumentData(id,session,stage,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            },{ buffer: false, escape: false, timeout: 120000});
            return deferred.promise;
        }

	this.CreateDocument= function(id,session,settingId)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CreateDocument(id,session,settingId,function(result, event){
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