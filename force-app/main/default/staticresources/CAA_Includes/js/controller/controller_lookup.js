caaApp.controller('controllerFTD', ['$scope','serviceFTD','$window',
        function ($scope,serviceFTD,$window) 
        {
		$scope.Complete= function(){
                if(!$scope.EventLogId) return null;                
                
                serviceFTD.Complete($scope.EventLogId, $scope.Product)
                .then(
                    function(result){
                        if(result.Success)
                        {
				$scope.SuccessMessage = 'Completed';
                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }
                            else
                            {                                

                            } 
                        }
                        else
                        {
				$scope.ErrorMessage = result.Error;
                        }
                    },
                    function(error){
                    	$scope.ErrorMessage = error;
                    }
                   );
            }
	

	$scope.ShowCompleteButton = function(){
		
		if(!$scope.Product ||  (!$scope.Product.OptionsOnMaturity && !$scope.Product.WhatToDoWithProfit) || !$scope.Product.TransferToType)
			return false;

		if($scope.Product.TransferToType == 'external' && (!$scope.Product.TransferToExternalAccount || !$scope.Product.TransferToExternalSortCode ))
			return false;
		
		if($scope.Product.TransferToType == 'existing' && !$scope.Product.TransferToInternalAccount)
			return false;


		return true; 
	
	};	


	}
    ]);

