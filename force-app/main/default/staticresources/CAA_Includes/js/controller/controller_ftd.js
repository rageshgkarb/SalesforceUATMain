caaApp.controller('controllerFTD', ['$scope','serviceFTD','$window','serviceApplication',
        function ($scope,serviceFTD,$window,serviceApplication) 
        {
		$scope.Complete= function(){
                if(!$scope.EventLogId) return null;                
                serviceApplication.LoadShow('Processing...');
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
	

	$scope.ShowCompleteButton = function(){
		
		if(!$scope.Product ||  (!$scope.Product.OptionsOnMaturity && !$scope.Product.WhatToDoWithProfit) )
			return false;

		
		if($scope.Product.WhatToDoWithProfit && $scope.Product.WhatToDoWithProfit=='invest')
		{
			//check maturity
			if(!$scope.Product.MaturityTransferToType) return false;

			if($scope.Product.MaturityTransferToType == 'existing')
			{
				return $scope.MaturityExistingAccountValid();
			}			

			if($scope.Product.MaturityTransferToType == 'external')
			{
				return $scope.MaturityExternalAccountValid() && $scope.MaturityExternalSortCodeValid();
			}			
		}

		if($scope.Product.WhatToDoWithProfit && $scope.Product.WhatToDoWithProfit=='quarterly')
		{
			//check maturity
			if(!$scope.Product.MaturityTransferToType) return false;

			if($scope.Product.MaturityTransferToType == 'existing')
			{
				return $scope.MaturityExistingAccountValid();
			}			

			if($scope.Product.MaturityTransferToType == 'external')
			{
				return $scope.MaturityExternalAccountValid() && $scope.MaturityExternalSortCodeValid();
			}

			//check profit
			if(!$scope.Product.ProfitTransferToType) return false;

			if($scope.Product.ProfitTransferToType == 'existing')
			{
				return $scope.ProfitExistingAccountValid();
			}			

			if($scope.Product.ProfitTransferToType == 'external')
			{
				return $scope.ProfitExternalAccountValid() && $scope.ProfitExternalSortCodeValid();
			}			
		}
		
	
		/*
		if($scope.Product.TransferToType == 'external' && (!$scope.Product.TransferToExternalAccount || !$scope.Product.TransferToExternalSortCode ))
			return false;
		
		if($scope.Product.TransferToType == 'existing' && !$scope.Product.TransferToInternalAccount)
			return false;		
		*/
		return true; 	
	};	


	$scope.ProfitExternalAccountValid = function(){
		return CheckLength($scope.Product.ProfitTransferToExternalAccount,8);
	}
	$scope.ProfitExistingAccountValid = function(){
		return  CheckLength($scope.Product.ProfitTransferToInternalAccount,8);
	}
	$scope.ProfitExternalSortCodeValid = function(){
		return CheckLength($scope.Product.ProfitTransferToExternalSortCode,6);
	}


	$scope.MaturityExternalAccountValid = function(){
		return CheckLength($scope.Product.MaturityTransferToExternalAccount,8);
	}
	$scope.MaturityExistingAccountValid = function(){
		return CheckLength($scope.Product.MaturityTransferToInternalAccount,8);
	}
	$scope.MaturityExternalSortCodeValid = function(){
		return CheckLength($scope.Product.MaturityTransferToExternalSortCode,6);
	}





	function CheckLength(value, length){
		return value && value.toString().length == length;
	}
	


	function MaturityComplete()
	{
		
	}

	function ValidateAccountData(transferTo, internalAccount, externalAccount, externalSortcode)
    	{
        if(transferTo == 'external')
        {
            if(externalAccount.toString().length != 8 || externalAccount.toString().length != 6 || !$.isNumeric(externalAccount))
                return false;
        }
        else if(transferTo == 'existing')
        {
            if(internalAccount.toString().length != 8)
                return false;
        }
        else
        {
            return false;
        }
	return true;
    	}


	}
    ]);

