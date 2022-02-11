tellerApp.controller('controllerAccount', ['$scope', 'serviceApplication', 'serviceMessageBroker',
    function ($scope, serviceApplication, serviceMessageBroker) {
        $scope.SelectedAccount = null;

        $scope.AccountPanelBarOptions = { expandMode: "single" };        
        $scope.ExpandedTab = 'FunctionGroups';

        // $scope.FunctionGroupsExpanded = true;
        // $scope.OnExpandTransactionHistory = function () {
        //     if ($scope.FunctionGroupsExpanded == true) {
        //         $scope.FunctionGroupsExpanded = false;
        //         serviceMessageBroker.TransactionHistoryRefresh($scope);
        //     }
        // }   
       
       $scope.ActivateOption = function(functionName)
       {
           $scope.mbAccMenu = false;
           $scope.ExpandedTab = functionName;
       } 
       
       $scope.GetAccountFunctionClass = function(functionName)
       {
           if( $scope.ExpandedTab == functionName)
           {
               return 'accountExpanderHeaderSelected';
           }
           else if($scope.mobileMode)
           {
               return 'hidden-xs';
           }
       }      
       
        //Watchers --------------------------------------------------------
        
        $scope.$watch('ExpandedTab', function(){
            switch($scope.ExpandedTab)
            {
                case 'TransactionHistory':
                {
                    serviceMessageBroker.TransactionHistoryRefresh($scope);
                    break;
                }

                case 'AccountMandates':
                {
                    serviceMessageBroker.AccountMandatesRefresh($scope);
                    break;
                }
                
                case 'AwaitingApproval':
                {
                    serviceMessageBroker.AccountActivityRefresh($scope);
                    break;
                }
                case 'DealInformation':
                {
                    serviceMessageBroker.DealInfoRefresh($scope);
                    break;
                }
				case 'OnlineBankingPayments':
                {
                    serviceMessageBroker.OnlineBankingPaymentsRefresh($scope);
                    break;
                }
            }
        }, true);
 
    }
]);