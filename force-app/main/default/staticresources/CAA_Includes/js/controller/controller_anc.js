caaApp.controller('controllerANC', ['$scope','$window','$filter','serviceANC','serviceApplication',
        function ($scope,$window,$filter,serviceANC,serviceApplication) 
        {  
			

		$scope.Create = function()
		{
			serviceApplication.LoadShow('Processing...');
			serviceANC.Create ($scope.DEType, $scope.AccountId)
                	.then(
                    	function(result){
				if(result.URL){
					$window.location.href = result.URL.FormatURL();
				}
				//serviceApplication.LoadHide(false);  
                    	},
                    	function(error){
                    		serviceApplication.LoadHide(false);  
                    	}
                   	); 
		}	


		
        }
    ]);