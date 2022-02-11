caaApp.controller('controllerFTDISA', ['$scope','serviceFTDISA','$window','serviceApplication',
    function ($scope,serviceFTDISA,$window,serviceApplication) 
    {
      $scope.Complete= function(){
        if(!$scope.EventLogId) return null;                
        serviceApplication.LoadShow('Processing...');
        serviceFTDISA.Complete($scope.EventLogId, $scope.Product)
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
               $scope.ErrorMessage = error;
               serviceApplication.LoadHide(false);
           }
           );
    }


    $scope.ShowCompleteButton = function(){

        if(!$scope.Product || !$scope.Product.WhatToDoWithProfit) return false;


        var transferTo = $scope.Product.ProfitMaturityTransferToType;
        var extAccount = $scope.Product.ProfitMaturityTransferToExternalAccount;
        var extSortCode = $scope.Product.ProfitMaturityTransferToExternalSortCode;
        var internal = $scope.Product.ProfitMaturityTransferToInternalAccount;

	if($scope.Product.WhatToDoWithProfit == 'invest') return $scope.MaturityValid();

	if($scope.Product.WhatToDoWithProfit == 'quarterly') return $scope.MaturityValid() && $scope.ProfitValid();
     
  	return true; 
    };

    $scope.MaturityValid = function(){	
	if(!$scope.Product.MaturityTransferToType) return false;
	
	if($scope.Product.MaturityTransferToType =='existingIsa') return true;
	
	if($scope.Product.MaturityTransferToType == 'existing'){
	    if(!$scope.Product.MaturityTransferToInternalAccount || $scope.Product.MaturityTransferToInternalAccount.toString().length != 8) return false;
	}

	if($scope.Product.MaturityTransferToType == 'external'){
	    if(!$scope.Product.MaturityTransferToExternalAccount || !$scope.Product.MaturityTransferToExternalSortCode) return false;
	    if($scope.Product.MaturityTransferToExternalAccount.toString().length != 8 || $scope.Product.MaturityTransferToExternalSortCode.toString().length != 6) return false;
	}
	return true;
	
    }

    $scope.ProfitValid = function(){
	if(!$scope.Product.ProfitTransferToType) return false;

	if($scope.Product.ProfitTransferToType =='existingISA') return true;
	
	if($scope.Product.ProfitTransferToType == 'existing'){
	    if(!$scope.Product.ProfitTransferToInternalAccount || $scope.Product.ProfitTransferToInternalAccount.toString().length != 8) return false;
	}

	if($scope.Product.ProfitTransferToType == 'external'){
	    if(!$scope.Product.ProfitTransferToExternalAccount || !$scope.Product.ProfitTransferToExternalSortCode) return false;
	    if($scope.Product.ProfitTransferToExternalAccount.toString().length != 8 || $scope.Product.ProfitTransferToExternalSortCode.toString().length != 6) return false;
	}
	return true;
    }


      



   	


}
]);

