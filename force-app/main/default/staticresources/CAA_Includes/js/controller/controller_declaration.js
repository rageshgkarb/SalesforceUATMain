caaApp.controller('controllerDeclaration', ['$scope','$window','serviceDeclaration','serviceEBS', 'serviceApplication',
        function ($scope,$window,serviceDeclaration,serviceEBS,serviceApplication) 
        {

        
            $scope.CallDe= function(){
				var num = parseInt($scope.applicantNames);
				var declarations = [];
				for(var i =0; i < num; i++){
					var declaration = {};

					if(i==0){declaration.capacity = $scope.capacity0;}
					if(i==1){declaration.capacity = $scope.capacity1;}
					if(i==2){declaration.capacity = $scope.capacity2;}
					if(i==3){declaration.capacity = $scope.capacity3;}
					declarations.push(declaration);
				}



			$scope.Data = null;
                if(!$scope.EventLogId) return null;
                
                serviceApplication.LoadShow('Processing...');
                serviceDeclaration.CallDe($scope.EventLogId,$scope.SessionId, declarations)
                .then(
                    function(result){
					console.log(JSON.stringify(result));
                        if(result.Success)
                        {
							if(result.URL && !result.CallEBS)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }
                            else
                            {                                
								if(result.CallEBS)
								{
									// C0592 No longer make call to CallEbs
									$scope.CompleteSummaryExternal();
								}
								else
								{
									serviceApplication.LoadHide(false);
								}
							}
                        }
                        else
                        {
							$scope.Error = result.Error;
							$scope.Data = result;
							$scope.Decision = result.Decision;
							serviceApplication.LoadHide(false);
                        }
                    },
                    function(error){
                    	serviceApplication.LoadHide(false);
                    }
                   );
            }


			$scope.CallEBS= function(){
                if(!$scope.EventLogId) return null;
                
                
                serviceEBS.CallEBSDE($scope.EventLogId,$scope.SessionId)
                .then(
                    function(result){
                        if(result.Success)
                        {
							if(result.Data)
							{
								if(result.Data.Complete)
								{
									$scope.CompleteExternal();
									return;
								}
								else
								{
									$scope.Error = ' ';						
								}

								if(result.Data.NextEventUrl)
								{
									$window.location.href = result.Data.NextEventUrl.FormatURL();
								}
							}

                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }                             
                        }
						else
						{
							$scope.Error = ' ';
						}
                        
						serviceApplication.LoadHide(false);
                    },
                    function(error){
                    	serviceApplication.LoadHide(false);
                    }
                   );
            }

            $scope.ShowContinue= function () {
				var num = parseInt($scope.applicantNames);

				var allClicked = true;
				var showApplicant1 = $scope.isISA != true && $scope.isYPSA != true;

				for(var i =0; i < num; i++){
					if(i==0) {
						if(showApplicant1){
							if($scope.i_agree0_clicked0 != true){return false;}
							//if(!$scope.capacity0){return false;}
						}

						if($scope.isYPSA != true) {
							if ($scope.i_agree1_clicked0 != true) {
								return false;
							}
							if ($scope.i_agree2_clicked0 != true) {
								return false;
							}
							if ($scope.i_agree3_clicked0 != true) {
								return false;
							}
						}
					}
					if(i==1) {
						if(showApplicant1){
							if ($scope.i_agree0_clicked1 != true) {return false;}
							//if(!$scope.capacity1){return false;}
						}
						if($scope.i_agree1_clicked1 != true){return false;}
						if($scope.i_agree2_clicked1 != true){return false;}
						if($scope.i_agree3_clicked1 != true){return false;}

					}
					if(i==2) {
						if(showApplicant1){
							if ($scope.i_agree0_clicked2 != true) {
								return false;
							}
							//if(!$scope.capacity2){return false;}
						}
						if($scope.i_agree1_clicked2 != true){return false;}
						if($scope.i_agree2_clicked2 != true){return false;}
						if($scope.i_agree3_clicked2 != true){return false;}

					}
					if(i==3) {
						if(showApplicant1){
							if ($scope.i_agree0_clicked3 != true) {
								return false;
							}
							//if(!$scope.capacity3){return false;}
						}
						if($scope.i_agree1_clicked3 != true){return false;}
						if($scope.i_agree2_clicked3 != true){return false;}
						if($scope.i_agree3_clicked3 != true){return false;}
					}

				}
			return allClicked;

			}



		$scope.CompleteExternal= function(){
			if(!$scope.EventLogId) return null;
                
                
			serviceEBS.CompleteExternal($scope.EventLogId,$scope.SessionId)
			.then(
				function(result){
					if(result.Success  && result.Data && result.Data.NextEventUrl)
					{
				
					$window.location.href = result.Data.NextEventUrl.FormatURL();
						return;
					}
					else
					{
						$scope.Error = ' ';
					}
                        
					serviceApplication.LoadHide(false);
                },
                function(error){
				 	serviceApplication.LoadHide(false);
                }
		       );
         }

		$scope.CompleteSummaryExternal= function(){
			if(!$scope.EventLogId) return null;
                
			serviceEBS.CompleteSummaryExternal($scope.EventLogId,$scope.SessionId)
			.then(
				function(result){
					if(result.Success  && result.Data && result.Data.NextEventUrl)
					{
						$window.location.href = result.Data.NextEventUrl.FormatURL();
						return;
					}
					else
					{
						$scope.Error = ' ';
					}
                        
					serviceApplication.LoadHide(false);
                },
                function(error){
				 	serviceApplication.LoadHide(false);
                }
		       );
         }













            
            
        }
    ]);