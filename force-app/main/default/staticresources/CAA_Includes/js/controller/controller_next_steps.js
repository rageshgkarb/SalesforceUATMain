caaApp.controller('controllerNextSteps', ['$scope','serviceNextSteps','$window','serviceApplication','servicePayment',
        function ($scope,serviceNextSteps,$window,serviceApplication,servicePayment) 
        {
		$scope.Complete= function(){
                if(!$scope.EventLogId) return null;                
                serviceApplication.LoadShow('Processing...');
                serviceNextSteps.Complete($scope.EventLogId, $scope.Product)
                .then(
                    function(result){
                        if(result.Success)
                        {				
                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }
                            else
                            {                                
				serviceApplication.LoadHide(false); 
                            } 
                        }
                        else
                        {
				serviceApplication.LoadHide(false); 
				$scope.ErrorMessage = result.Error;
                        }
                    },
                    function(error){
			serviceApplication.LoadHide(false); 
                    	$scope.ErrorMessage = error;
                    }
                   );
            }
	

	$scope.CallAJE= function(){
		$scope.AJEError = '';
                if(!$scope.EventLogId) return null;                
                serviceApplication.LoadShow('Processing...');
                serviceNextSteps.CallAJE($scope.EventLogId)
                .then(
                    function(result){
                        if(result.Success)
                        {
			    
			    $scope.AJECompleted = true;
                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }
                            else
                            {     
				                           
				serviceApplication.LoadHide(false);
                            } 
                        }
                        else
                        {
				$scope.AJECompleted = false;
				$scope.AJEError = result.Error;
				serviceApplication.LoadHide(false);
				$scope.ErrorMessage = 'Account not setup';
                        }
                    },
                    function(error){
                    	$scope.ErrorMessage = error;
			$scope.AJEError = error;
			serviceApplication.LoadHide(false);
                    }
                   );
            }

	
	$scope.UpdatePaymentMethod= function(paymentType){
                if(!$scope.EventLogId) return null;                
		$scope.Updating = true;
		$scope.PaymentMethod = paymentType;
                serviceNextSteps.UpdatePaymentMethod($scope.EventLogId,$scope.SessionId, paymentType)
                .then(
                    function(result){
			$scope.Updating = false;
                        if(result.Success)
                        {				
                           
                        }
   
                    },
                    function(error){
			$scope.Updating = false;
                    }
                   );
            }







	}
    ]);




