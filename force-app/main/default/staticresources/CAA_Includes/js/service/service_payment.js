caaApp.service('servicePayment', ['$q', '$rootScope', function ($q, $rootScope) {
       this.Is3dSecure= function(data,id)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.Is3dSecure(data,id,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

this.MakePayment= function(data,id,eventLogId, sessionId)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.MakePayment(data,id,eventLogId, sessionId,function(result, event){
                if(event.status){
                    deferred.resolve(result);					
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

//C0638
	/*this.CreateCase= function(CaseTypeData)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CreateCase(CaseTypeData,function(result, event)
			{
                if(event.status){
                    deferred.resolve(result);					
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }*/
//

/* C0610 Start -- NVM API CODE */
this.ResumeCallRecording = function(id, eventLogId, sessionId)
{
	var deferred = $q.defer();
	Visualforce.remoting.timeout = 120000;
	CAA_Core_Controller.ResumeCallRecording(id,eventLogId, sessionId, function(result, event){
		if(event.status) {
			deferred.resolve(result);
		}
		else {
			deferred.reject(event);
		}
	});
	return deferred.promise;
} 
/* C0610 End */

this.FTDSetup= function(id)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.FTDSetup(id,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

this.CallAJE= function(id,session)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CallAJE(id,session,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }


	this.updateACSResponse= function(md,pares,id)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.updateACSResponse(md,pares,id,function(result, event){
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