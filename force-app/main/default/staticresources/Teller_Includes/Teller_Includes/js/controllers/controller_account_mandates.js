tellerApp.controller('controllerAccountMandates', ['$scope', 'serviceApplication', 'serviceMessageBroker', 'serviceMandates', 'serviceStateTransition',
    function ($scope, serviceApplication, serviceMessageBroker, serviceMandates, serviceStateTransition) {
        $scope.AccountId = null;       
        $scope.MandateSignatories = null;
        $scope.Loading = false;    
        $scope.ErrorMsg = null;
        $scope.ErrorFlag = false;  

        $scope.GetAccountMandates = function () {            
            if ($scope.SelectedAccount != null && $scope.SelectedAccount.Name != '') {
                $scope.Loading = true;
                serviceMandates.LoadMandatesAndSignatories($scope.SelectedAccount.Name)
                    .then(
                            function (result) {
                                if (result.Success) {
                                    $scope.MandateSignatories = result;
                                    $scope.ErrorFlag = false;
                                    $scope.ErrorMsg = null; 
                                }
                                else {  
                                    $scope.MandateSignatories = null;   
                                    $scope.ErrorFlag = true;
                                    $scope.ErrorMsg = result.ErrorMessage;                           
                                }
    
                                if (!$scope.$$phase) {
                                    $scope.$apply();
                                }
                                $scope.Loading = false;
                            },
                            function (error) {
                                $scope.Loading = false;
                                $scope.MandateSignatories = null; 
                                $scope.ErrorFlag = true;
                                alert(error.message);
                            }
                        );
            }
        }
        
        $scope.GotoCustomer = function(signatoryItem)
        {
            if(typeof signatoryItem.ProspectCustomerId != 'undefined')
            {
                var customer = {
                                Id: signatoryItem.ProspectCustomerId, 
                                EBSId: signatoryItem.CustomerEBSId,
                                DOB: '',
                                Address: '',
                                ImageURL: '/servlet/servlet.FileDownload?file=' + signatoryItem.ImageId,
                                Name: signatoryItem.CustomerName,
                                PostCode: ''
                            };
                console.log('customer='+JSON.stringify(customer));
                serviceStateTransition.GotoCustomerSummary(customer);
                $scope.$parent.$parent.$parent.account = null;
            }
        }       
        
        //-- Listeners -----------------------------------------------------------

        $scope.$on('RefreshAccountMandates', function()
        {
            $scope.GetAccountMandates();
        });
    }
]);