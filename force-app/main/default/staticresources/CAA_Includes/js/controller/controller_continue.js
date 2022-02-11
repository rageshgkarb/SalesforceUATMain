caaApp.controller('controllerContinue', ['$scope','$window','serviceContinue','serviceApplication',
        function ($scope,$window,serviceContinue,serviceApplication) 
        {
		


		$scope.CheckQuestions= function(){
                if(!$scope.Data || !$scope.Data.SessionId) return null;
				
				if(!$scope.myform.$valid) return ;
                
		serviceApplication.LoadShow('Sending to host..');
                
                serviceContinue.CheckQuestions($scope.Data)
                .then(
                    function(result){
                 						
						if(result.Success && result.URL)
						{
							$window.location.href = result.URL.FormatURL();							
						}
						else
						{
							$scope.ErrorMessage = result.Error;
							serviceApplication.LoadHide(false);
						}  
                    },
                    function(error){
                    	serviceApplication.LoadHide(false);
                    }
                   );
            }



       


		

            
            
        }
    ]);