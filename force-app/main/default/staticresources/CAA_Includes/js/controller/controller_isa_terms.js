caaApp.controller('controllerISATerms', ['$scope','serviceISATerms','$window','serviceApplication',
        function ($scope,serviceISATerms,$window,serviceApplication) 
        {
		$scope.CompleteISATerms= function(){
                if(!$scope.EventLogId) return null;                
                
                serviceISATerms.Complete($scope.EventLogId, $scope.Product)
                .then(
                    function(result){
                        if(result.Success)
                        {
				$scope.SuccessMessage = 'Completed';
                            if(result.URL)
                            {
                                $window.location.href = result.URL;
				return;
                            }
                            else
                            {                                
			
                            } 
                        }
                        else
                        {
				$scope.ErrorMessage = result.Error;
                        }
			serviceApplication.LoadHide(false);
                    },
                    function(error){
			serviceApplication.LoadHide(false);
                    	$scope.ErrorMessage = error;
                    }
                   );
            }
	

	$scope.ShowCompleteButton = function(){
		if(!$scope.Product || !$scope.Product.ISA1 || !$scope.Product.ISA2 || !$scope.Product.ISA3 || !$scope.Product.ISA4 || !$scope.Product.ISA5 || !$scope.Product.ISA6 || !$scope.Product.ISA7 || !$scope.Product.ISA8 || !$scope.Product.ISAYear || !$scope.Product.NI || !$scope.Product.LinkedAccountNumber || !$scope.Product.LinkedSortCode)
		return false;

		if($scope.Product.LinkedAccountNumber.toString().length != 8 || $scope.Product.LinkedSortCode.toString().length != 6)
		return false;


		return true; 
	
	};	
	$scope.ShowNiError = function(){
		if(!$scope.Product.NI)
		return true;
	
		return false; 
	
	};	
	
	


	}
    ]);


caaApp.directive('validateNi', function() {
    return {
      require: 'ngModel',
      restrict: 'A',
      link: function(scope, elem, attr, ngModel) {

        var validator = function(value) {
          if (/^(?!BG|GB|NK|KN|TN|NT|ZZ)[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-D]{1}$/.test(value)) {
          ngModel.$setValidity('ni', true);
            return value;
          } else {
			
            ngModel.$setValidity('ni', false);
            return undefined;
          }
        };
        //For DOM -> model validation
        ngModel.$parsers.unshift(validator);
        //For model -> DOM validation
        ngModel.$formatters.unshift(validator);
      }
    };
  });
