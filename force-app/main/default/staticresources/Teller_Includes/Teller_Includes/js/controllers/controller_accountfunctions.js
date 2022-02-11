tellerApp.controller('controllerAccountFunctions', ['$scope', '$state', '$stateParams', 'serviceParameters', function($scope, $state, $stateParams, serviceParameters)
{
	$scope.Account = null;
	$scope.SelectedRoot = null;

	$scope.Initialise = function()
	{
		serviceParameters.TransactionParams.AccountNum = null;
		serviceParameters.TransactionParams.FunctionId = null;
	}

	$scope.onClickFunctionRoot = function(root)
	{
		$scope.SelectedRoot = root;
	}

	$scope.onClickCloseFunctions = function(root)
	{
		$scope.SelectedRoot = null;
	}

	$scope.onClickFunction = function(selectedFunction)
	{
		serviceParameters.TransactionParams.FunctionId = selectedFunction.FunctionId;
		serviceParameters.TransactionParams.Account = $scope.Account;
		$state.transitionTo('customercore.customertransaction');
	}

	$scope.GetAccountFunctionRootTileClass = function(rootTitle)
	{
		if($scope.SelectedRoot == null)
			return "accountFunctionRootNormal";
		// if(rootTitle == $scope.SelectedRoot.Title)		
		// 	return "accountFunctionRootHidden";		
		else		
			return "accountFunctionRootMinimised";		
	}

}]);