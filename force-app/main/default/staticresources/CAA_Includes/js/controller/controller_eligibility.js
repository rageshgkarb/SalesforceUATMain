caaApp.controller('controllerEligibility', ['$scope','$window','$filter','serviceEligibility','serviceApplication',
        function ($scope,$window,$filter,serviceEligibility,serviceApplication) 
        {  
		$scope.Data = {DOB:{}};

	

		$scope.Save = function()
		{
			serviceApplication.LoadShow('Processing...');
			serviceEligibility.CreateEligibility ($scope.Data)
                	.then(
                    	function(result){
				
                        	$scope.result= result;
				$scope.oppId = result.OpportunityId;
				serviceApplication.LoadHide(false);  
                    	},
                    	function(error){
                    		serviceApplication.LoadHide(false);  
                    	}
                   	); 
		}

		$scope.CampaignSelected = function(value)
		{
			$scope.Data.Campaign = value;
			$('#campaignLookup').modal('hide');
		}

		$scope.GetCampaigns = function()
		{
			if(!$scope.Search) return;

			serviceEligibility.GetCampaigns ($scope.Search)
                	.then(
                    	function(result){

				var objectString = JSON.stringify(result.Items);
				objectString = objectString.replace('&amp;','&');
				$scope.Campaigns = JSON.parse(objectString);				

                        	//$scope.Campaigns= result.Items;
                    	},
                    	function(error){
                    
                    	}
                   	); 
		}


		
        }
    ]);