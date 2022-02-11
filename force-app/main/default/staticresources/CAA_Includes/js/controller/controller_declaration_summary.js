caaApp.controller('controllerDeclarationSummary', ['$scope','$window','serviceDeclarationSummary','serviceApplication',
        function ($scope,$window,serviceDeclarationSummary,serviceApplication) 
        {
        
            $scope.CompleteSummary= function(){
                if(!$scope.EventLogId) return null;
                serviceApplication.LoadShow('Processing...');
                
                serviceDeclarationSummary.CompleteSummary($scope.EventLogId)
                .then(
                    function(result){
                        console.log(JSON.stringify(result));
						if(result.Success)
                        {
                            if(result.URL)
                            {
                                $window.location.href = result.URL;
                            }
                            else
                            {                                
				serviceApplication.LoadHide(false);  
                            } 
                        }
                        else
                        {
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