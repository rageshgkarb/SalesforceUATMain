caaApp.controller('controllerDocuments', ['$scope','serviceDocuments','$window',
        function ($scope,serviceDocuments,$window) 
        {
		$scope.GetDocumentData= function(){
                if(!$scope.EventLogId) return null;                
                
                serviceDocuments.GetDocumentData($scope.EventLogId, $scope.SessionId, $scope.Stage)
                .then(
                    function(result){
                        if(result.Success)
                        {
				$scope.Data = result.Data;
				
				for (i = 0; i < result.Data.Docs.length; i++) { 
    					if(result.Data.Docs[i].Complete != true)
						$scope.CreateDocument(result.Data.Docs[i]);

					if(result.Data.Docs[i].URL)
						result.Data.Docs[i].URL = result.Data.Docs[i].URL.FormatURL();
				}

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



		$scope.CreateDocument= function(docItem){
                if(!$scope.EventLogId || !docItem || !docItem.SettingId) return null;  


		docItem.Generating = true;
		//return null;              
                
                serviceDocuments.CreateDocument($scope.EventLogId, $scope.SessionId, docItem.SettingId)
                .then(
                    function(result){
			docItem.Generating = false;
                        if(result.Success)
                        {
				docItem.Complete = result.Data.Docs[0].Complete;
				docItem.AttachmentId = result.Data.Docs[0].AttachmentId;
				docItem.URL = result.Data.Docs[0].URL.FormatURL();
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

