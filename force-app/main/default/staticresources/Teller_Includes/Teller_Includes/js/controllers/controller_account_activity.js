tellerApp.controller('controllerAccountActivity', ['$scope', 'serviceApplication', 'serviceReporting', 'serviceParameters',
    function ($scope, serviceApplication, serviceReporting, serviceParameters) {
       $scope.Activity = null;
       $scope.Loading = false; 
       $scope.SearchCriteria = null;
       $scope.debitAccount = null;

       $scope.dealInfo = null;
       $scope.isDepositeAccount = null;
       $scope.DealAcountNo = null;

       $scope.InitialiseSearchCriteria = function(debitAccount)
       {
           $scope.debitAccount = debitAccount;
       }
       $scope.InitialiseDealInfo = function(AccountNo, isDeposite)
       {
           $scope.isDepositeAccount = isDeposite;
           $scope.DealAcountNo = AccountNo;
       }
       $scope.GetAwaitingApprovals = function()
       {
           $scope.Loading = true;
           
           serviceReporting.GetSubmittedForAuthorisationForAccount($scope.debitAccount)
            .then(
                    function(result) 
                    {                        
                         $scope.Activity = result;
                         $scope.Loading = false; 
                    },
                    function(error) {
                        alert(error.message);
                        $scope.Loading = false;                        
                    }
            );
       }
       $scope.GetDealInfo = function()
       {
            $scope.Loading = true;
            if ($scope.isDepositeAccount)
            {
              serviceReporting.GetDealDepositInfo($scope.DealAcountNo)
              .then(
                      function(result) 
                      {                        
                           $scope.dealInfo = result;
                           $scope.Loading = false; 
                      },
                      function(error) {
                          alert(error.message);
                          $scope.Loading = false;                        
                      }
              );
            }
            else if ($scope.isDepositeAccount==false)
            {
              //alert('1');
              serviceReporting.GetDealFinanceInfo($scope.DealAcountNo)
              .then(
                      function(result) 
                      {                        
                           $scope.dealInfo = result;
                           $scope.Loading = false; 
                      },
                      function(error) {
                          alert(error.message);
                          $scope.Loading = false;                        
                      }
              );
            }
       }
        $scope.OpenActivity = function(object)
        {
            serviceParameters.ActivityParams.SelectedActivityReferenceId = object.Object_Id__c;
            serviceParameters.ActivityParams.SelectedActvityType = object.Activity_Type__c;
            serviceApplication.ModalShow('Activity Details', 'Activity');
        }
       
       //-- Listeners -----------------------------------------------------------

        $scope.$on('RefreshAwaitingAuthorisation', function()
        {
            $scope.GetAwaitingApprovals();
        }); 
        $scope.$on('RefreshDealInfo', function()
        {
            $scope.GetDealInfo();
        }); 
    }
]);