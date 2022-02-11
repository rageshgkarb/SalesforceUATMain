caaApp.controller('controllerISATransfer', ['$scope','serviceISATransfer','$window','serviceApplication','serviceDocuments',
        function ($scope,serviceISATransfer,$window,serviceApplication,serviceDocuments) 
        {



		$scope.SaveISATerms= function(complete){

				$scope.Submitted = true;
                if(!$scope.EventLogId) return null;     
		if(!$scope.myform.$valid) return;  
		
		if(!$scope.ISA.TransferAmount) 
		{
			$scope.ISA.TransferAmount = null;
		}        
                
		serviceApplication.LoadShow('Saving...');

                serviceISATransfer.Complete($scope.EventLogId,$scope.SessionId,$scope.ISA,complete)
                .then(
                    function(result){
                        if(result.Success)
                        {
				if(complete)
				{
					if(result.URL)
                           		{
                                		$window.location.href = result.URL.FormatURL();
						return;
                            		}
				}
				else
				{
					$scope.ShowDocScreen = true;
					$scope.CreateDocument();
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


	$scope.CreateDocument= function(){
                if(!$scope.EventLogId || !$scope.DocId) return null;  

		$scope.DocGenerating = true;             
                
                serviceDocuments.CreateDocument($scope.EventLogId, $scope.SessionId, $scope.DocId)
                .then(
                    function(result){
			$scope.DocGenerating = false;
                        if(result.Success)
                        {
				$scope.DocComplete = result.Data.Docs[0].Complete;
				$scope.DocAttachmentId = result.Data.Docs[0].AttachmentId;
				$scope.URL = result.Data.Docs[0].URL.FormatURL();
                        }
                        else
                        {
				$scope.ErrorMessage = result.Error;
                        }
                    },
                    function(error){
                    	$scope.ErrorMessage = error;
                    }
                   );
            }





	}
    ]);

