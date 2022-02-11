caaApp.controller('controllerSendToHost', ['$scope','$window','serviceSendToHost','serviceApplication',
        function ($scope,$window,serviceSendToHost,serviceApplication) 
        {
		$scope.$watch('EventLogId', function () {
              		$scope.GetHostData();
			$scope.Checklist = {};
            });  


		$scope.CallEBS= function(){
                if(!$scope.EventLogId) return null;
                
		serviceApplication.LoadShow('Sending to host..');
                
                serviceSendToHost.CallEBS($scope.EventLogId,$scope.SessionId, $scope.Checklist)
                .then(
                    function(result){
                        if(result.Success)
                        {
				$scope.Data = result.Data;
                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
				return;
                            }  
				
 			if($scope.IsANC && result.Items && result.Items[0].EBSId)
			{
				$scope.HideButton = true;
			}
                        
                        }
			serviceApplication.LoadHide(false);
                    },
                    function(error){
                    	serviceApplication.LoadHide(false);
                    }
                   );
            }



        
            $scope.GetHostData= function(){
                if(!$scope.EventLogId) return null;
                
		serviceApplication.LoadShow('Getting application data...');
                
                serviceSendToHost.GetHostData($scope.EventLogId)
                .then(
                    function(result){
                        if(result.Success)
                        {
				$scope.Data = result.Data;
                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
				return;
                            } 

			if($scope.Data && $scope.Data.ProductName)
			{
				$scope.Data.ProductName	= $scope.Data.ProductName.replace("&#39;","'");
				$scope.Data.ProductName	= $scope.Data.ProductName.replace("&amp;","&");
			}

                        }
			serviceApplication.LoadHide(false); 
                    },
                    function(error){
                    
                    }
                   );
            }


		

            
            
        }
    ]);