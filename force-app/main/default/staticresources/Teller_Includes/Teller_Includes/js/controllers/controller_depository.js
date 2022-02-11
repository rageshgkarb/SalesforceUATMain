tellerApp.controller('depositoryController', ['$scope', 'serviceApplication', 'serviceTeller',
    function($scope, serviceApplication, serviceTeller, $stateParams)
{
	$scope.Till = null;

	$scope.GetTellerTillDetails = function()
	{
		serviceApplication.LoadShow('Loading till information');
		serviceTeller.GetTellerTillDetails()
        .then(
                function(result) 
                {
					$scope.Till = result;
                    serviceApplication.LoadHide();
                },
                function(error) 
                {
                    alert(error.message);
                    serviceApplication.LoadHide();
                }
        );
	}

    //Message Listeners---------------------------
    $scope.$on('TellerTillRefresh', function(event, args)
    {
        $scope.GetTellerTillDetails();
    });

}]);