tellerApp.controller('controllerPreApprovedCase', ['$rootScope', '$scope', '$location', '$stateParams', '$state', '$filter', 'serviceParameters', 'serviceTransactions', 'serviceApplication', 'serviceMessageBroker',
	function($rootScope, $scope, $location, $stateParams, $state, $filter, serviceParameters, serviceTransactions, serviceApplication, serviceMessageBroker)
{

    $scope.Initiate = function() {
    	console.log('controller_preapprovedcase.Initiate Entry')

    	serviceParameters.PreCaseSelection.CaseId=null;
    	serviceParameters.PreCaseSelection.CaseNo=null;

        serviceApplication.LoadShow('Getting Pre-Approved Cases');
        serviceTransactions.GetPreApprovedCases(serviceParameters.PreCaseSelection.pageData, serviceParameters.PreCaseSelection.AuthorisorNo, serviceParameters.PreCaseSelection.AuthorisorId)
            .then(
                function(result) {
                    serviceApplication.LoadHide();
                    $scope.PreApprovedCases = result;
                },
                function(error) {
                    alert(error.message);
                    serviceApplication.LoadHide();
                }
        );
    }

    $scope.updateSelection = function(caseId, caseNo)
    {
    	serviceParameters.PreCaseSelection.CaseId=caseId;
    	serviceParameters.PreCaseSelection.CaseNo=caseNo;
    }

    $scope.SelectCase = function()
    {
    	if (serviceParameters.PreCaseSelection.CaseId==null)
    	{
    		alert('Case has not been selected');
    	}
    	else
    	{
    		serviceApplication.ModalHide();
    	}
    }

    $scope.Close = function()
    {
    	serviceApplication.ModalHide();
    }

}]);

