caaApp.service('serviceRMDetails', ['$q', '$rootScope', function ($q, $rootScope) {
        this.GetApplicantData = function(id,sessionId)
        {
            var deferred = $q.defer();
            CAA_Core_Controller.GetRMApplicantData(id,sessionId,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            },{ buffer: false, escape: false, timeout: 90000});
            return deferred.promise;
        }
        
        
        this.CompleteEvent= function(data,sessionId)
        {
             var deferred = $q.defer();
             CAA_Core_Controller.CompleteRM(data,sessionId,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

    this.SaveData= function(data,sessionId)
	{
			var deferred = $q.defer();
		    CAA_Core_Controller.SavePersonalDetails(data,sessionId,function(result, event){
			if(event.status){
				deferred.resolve(result);
			}
			else {
				deferred.reject(event);
			}     
		});
		return deferred.promise;
	}

	this.CallRM= function(id, session, isHigh,isABranch)
        {
            var deferred = $q.defer();
		    Visualforce.remoting.timeout = 90000;
			console.log('id='+id+',session='+session+',isHighide='+isHigh+'isABranch='+isABranch);
            CAA_Core_Controller.CallRM(id,session,isHigh,isABranch,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

        this.CheckIsExistingAccount= function(data, logid, override)
        {
            var deferred = $q.defer();
            CAA_Core_Controller.IsExistingAccount(data,logid,override,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

		this.PasswordVerification = function(userName, password)
		{
			var deferred = $q.defer();
			CAA_RM_Controller.PasswordVerification(userName, password, function (result, event) {
            
				if (event.status) {
					deferred.resolve(result);
				}
				else {
					deferred.reject(event);
				}   
			});

			return deferred.promise;
		}

		this.CallEBS= function(id,session)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CallEBS(id,session,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

		this.CallEBSDE= function(id,session)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CallEBSDE(id,session,function(result, event){
                if(event.status){
                    deferred.resolve(result);
                }
                else {
                    deferred.reject(event);
                }     
            });
            return deferred.promise;
        }

		this.CompleteExternal= function(id,session)
        {
            var deferred = $q.defer();
		Visualforce.remoting.timeout = 120000;
            CAA_Core_Controller.CompleteExternal(id,session,function(result, event){
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