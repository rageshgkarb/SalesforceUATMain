caaApp.controller('controllerDeclarationSummary', ['$scope','$window','serviceDeclarationSummary',
        function ($scope,$window,serviceDeclarationSummary) 
        {
        
            $scope.CompleteSummary= function(){
                if(!$scope.EventLogId) return null;
                
                
                serviceDeclarationSummary.CompleteSummary($scope.EventLogId)
                .then(
                    function(result){
                        if(result.Success)
                        {
                            if(result.URL)
                            {
                                $window.location.href = result.URL;
                            }
                            else
                            {                                
				
                            } 
                        }
                        else
                        {

                        }
                    },
                    function(error){
                    
                    }
                   );
            }


		
            
        }
    ]);