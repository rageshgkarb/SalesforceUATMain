caaApp.controller('controllerFTDSetup', ['$scope','$window','serviceFTDSetup','serviceApplication',
        function ($scope,$window,serviceFTDSetup,serviceApplication) 
        {        
            $scope.FTDSetup= function(){
                if(!$scope.EventLogId) return null;                
                serviceApplication.LoadShow('Processing...');
                serviceFTDSetup.FTDSetup($scope.EventLogId)
                .then(
                    function(result){
                        if(result.Success && result.Data && result.Data[0].FTDCompleted)
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
				$scope.ErrorMessage = 'Account not setup';
                        }
                    },
                    function(error){
                    	$scope.ErrorMessage = error;
			serviceApplication.LoadHide(false);
                    }
                   );
            }


	$scope.CallAJE= function(){

		

                if(!$scope.EventLogId) return null;                
                serviceApplication.LoadShow('Processing...');
                serviceFTDSetup.CallAJE($scope.EventLogId)
                .then(
                    function(result){
                        if(result.Success)
                        {
			    $scope.SuccessMessage = 'Completed';
			    $scope.Data.AJECompleted = true;
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
				$scope.ErrorMessage = 'Account not setup';
                        }
                    },
                    function(error){
                    	$scope.ErrorMessage = error;
			serviceApplication.LoadHide(false);
                    }
                   );
            }


	$scope.FTDSetupInit= function(){
                if(!$scope.EventLogId) return null;  

		if($scope.IsFTDSetup) return;
              
                serviceApplication.LoadShow('Processing...');
                serviceFTDSetup.FTDSetupInit($scope.EventLogId)
                .then(
                    function(result){
                        if(result.Success)
                        {
			    $scope.State = '1';    
			    $scope.Data = result.Data;                        
                        }                        
			serviceApplication.LoadHide(false);		
                    },
                    function(error){
                    	$scope.ErrorMessage = error;
			serviceApplication.LoadHide(false);
                    }
                   );
            }

	$scope.FTDSetupSave= function(d){
		if(!$scope.myform.$valid) return;


                if(!$scope.EventLogId) return null;                
                serviceApplication.LoadShow('Processing...');
                serviceFTDSetup.FTDSetupSave($scope.EventLogId, angular.copy(d))
                .then(
                    function(result){
                        if(result.Success)
                        {
			    $scope.State = '2';                            
                        }                        
			serviceApplication.LoadHide(false);		
                    },
                    function(error){
                    	$scope.ErrorMessage = error;
			serviceApplication.LoadHide(false);
                    }
                   );
            }




        }
    ]);