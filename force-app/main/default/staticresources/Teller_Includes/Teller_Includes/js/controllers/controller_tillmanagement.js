tellerApp.controller('controllerTillManagement', ['$scope', '$state', 'serviceParameters', 'serviceApplication', 'serviceTillManagement', 'serviceMessageBroker',
    function($scope, $state, serviceParameters, serviceApplication, serviceTillManagement, serviceMessageBroker)
{

    $scope.TillManagement_LoadDenominations = function(){
        console.log('controllerTillManagement.TillManagement_LoadDenominations Entry');

        serviceApplication.LoadShow('Loading denominations');

        if (serviceParameters.BalanceTillParams.TillId == '')
        {
            serviceTillManagement.TillManagement_LoadDenominations()
            .then(
                    function (result) {    
                            $scope.Denominations=result;
                            $scope.Response_Success = true;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                            serviceApplication.LoadHide(false);
                        },
                    function (error) {
                            $scope.Response_Success = false;
                            $scope.Response_StatusDescription = error.message;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                            serviceApplication.LoadHide(false);
                            alert(error.message);
                        }
                );   
        }
        else
        {
            serviceTillManagement.TillManagement_LoadDenominationsForTill(serviceParameters.BalanceTillParams.TillId)
                .then(
                        function (result) {    
                                $scope.Denominations=result;
                                $scope.Response_Success = true;

                                if(!$scope.$$phase) {
                                    $scope.$apply();
                                }
                                serviceApplication.LoadHide(false);
                            },
                        function (error) {
                                $scope.Response_Success = false;
                                $scope.Response_StatusDescription = error.message;

                                if(!$scope.$$phase) {
                                    $scope.$apply();
                                }
                                serviceApplication.LoadHide(false);
                                alert(error.message);
                            }
                    );   
        }
    }

    $scope.BalanceTill_Execute = function(){
        console.log('controllerTillManagement.BalanceTill Entry');

        serviceApplication.LoadShow('Balancing Till');
        serviceTillManagement.BalanceTill($scope.Denominations)
        .then(
                function (result) {    
                        $scope.Response_Success = result.Success;
                        $scope.Response_StatusDescription = result.ErrorMessage;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }

                        if ($scope.Response_Success)
                        {
                            serviceParameters.BalanceTillParams.SuccessFlag=true;

                            if (serviceParameters.BalanceTillParams.SuccessState == '')
                            {
                                serviceParameters.BalanceTillParams.SuccessState = 'depository';
                            }
                            else if(serviceParameters.BalanceTillParams.SuccessState == 'depository.telleropentill')
                            {
                                serviceParameters.OpenTillParams.PreviousState = 'depository.tellerbalancetill';
                            }
                            else if(serviceParameters.BalanceTillParams.SuccessState == 'depository.tellerclosetill')
                            {
                                serviceParameters.CloseTillParams.PreviousState = 'depository.tellerbalancetill';
                            }
                            
                            $state.transitionTo(serviceParameters.BalanceTillParams.SuccessState);

                            //Reset state to default action
                            serviceParameters.BalanceTillParams.SuccessState = 'depository';
                            alert('Balance Till: Successfully balanced till');
                        }
                        serviceApplication.LoadHide(false);
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );   
    }

    $scope.DenominationsChange_Init = function(){
        console.log('controllerTillManagement.DenominationsChange_Init Entry');
        
        serviceApplication.LoadShow('Loading denominations');
        serviceTillManagement.TillManagement_LoadDenominationsForCurrency('DEFAULT')
        .then(
                function (result) {    
                        $scope.DenominationsReceived=result;
                        $scope.Response_Success = true;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );

        serviceTillManagement.TillManagement_LoadDenominationsForCurrency('DEFAULT')
        .then(
                function (result) {    
                        $scope.DenominationsGiven=result;
                        $scope.Response_Success = true;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );
    }

    $scope.DenominationsChange_Execute = function(){
        console.log('controllerTillManagement.DenominationsChange_Execute Entry');
        
        serviceApplication.LoadShow('Updating Denominations');
        serviceTillManagement.DenominationsChange($scope.DenominationsReceived, $scope.DenominationsGiven)
        .then(
                function (result) {    
                        $scope.Response_Success = result.Success;
                        $scope.Response_StatusDescription = result.ErrorMessage;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }

                        if ($scope.Response_Success)
                        {
                            $state.transitionTo('depository');
                        }
                        serviceApplication.LoadHide(false);
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );
    }

    $scope.OpenTill_Init = function(){
        console.log('controllerTillManagement.OpenTill_Init Entry');

        if (serviceParameters.OpenTillParams.PreviousState == '')
        {
            $scope.Stage='Initial';

            serviceApplication.LoadShow('Loading Tills');
            serviceTillManagement.GetClosedBranchTills()
            .then(
                    function (result) {    
                            $scope.Tills = result;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }                            
                            serviceApplication.LoadHide(false);                            
                        },
                    function (error) {
                            $scope.Response_Success = false;
                            $scope.Response_StatusDescription = error.message;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                            serviceApplication.LoadHide(false);
                            alert(error.message);
                        }
                );
        }
        else
        {
            $scope.Stage='Final';
        }
    }

    $scope.OpenTIll_Select = function(){
        console.log('controllerTillManagement.OpenTill_Select Entry');
        
        //serviceParameters.OpenTillParams.PreviousState = 'depository.tellerbalancetill';
        serviceParameters.OpenTillParams.TillId = $scope.tillIdToOpen;

        serviceParameters.BalanceTillParams.PreviousState = 'depository.telleropentill';
        serviceParameters.BalanceTillParams.SuccessState = 'depository.telleropentill';
        serviceParameters.BalanceTillParams.TillId = $scope.tillIdToOpen;

        $state.transitionTo('depository.tellerbalancetill');

        if(!$scope.$$phase) {
            $scope.$apply();
        }
        serviceApplication.LoadHide(false);
    }

    $scope.OpenTill_Execute = function(){
        console.log('controllerTillManagement.OpenTill_Execute Entry');

        serviceApplication.LoadShow('Opening Till');
        serviceTillManagement.OpenTill(serviceParameters.OpenTillParams.TillId)
        .then(
                function (result) {    
                        $scope.Response_Success = result.Success;
                        $scope.Response_StatusDescription = result.ErrorMessage;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }

                        if ($scope.Response_Success)
                        {
                            // CLear down Balance TIll parameters
                            serviceParameters.BalanceTillParams.TillId='';
                            serviceParameters.BalanceTillParams.SuccessFlag=false;
                            serviceParameters.BalanceTillParams.SuccessState='';
                            serviceParameters.BalanceTillParams.PreviousState='';

                            $state.transitionTo('depository');
                        }                        
                        serviceMessageBroker.TellerTillRefresh();
                        serviceMessageBroker.TellerMenuOptionsRefresh();
                        serviceApplication.LoadHide(false);
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            ); 
    }

    $scope.CloseTill_Init = function(){
        console.log('controllerTillManagement.CloseTill_Init Entry');

        if (serviceParameters.CloseTillParams.PreviousState == '')
        {
            $scope.Stage='Initial';

            serviceApplication.LoadShow('Loading Tills');
            serviceTillManagement.GetOpenBranchTills(false, false)
            .then(
                    function (result) {    
                            $scope.Tills = result;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                        },
                    function (error) {
                            $scope.Response_Success = false;
                            $scope.Response_StatusDescription = error.message;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                            serviceApplication.LoadHide(false);
                            alert(error.message);
                        }
                );

            serviceTillManagement.GetAuthorisors_Manager()
            .then(
                    function (result) {    
                            $scope.TillAuthorisors = result;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                        },
                    function (error) {
                            $scope.Response_Success = false;
                            $scope.Response_StatusDescription = error.message;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                            serviceApplication.LoadHide(false);
                            alert(error.message);
                        }
                );
            serviceApplication.LoadHide(false);
        }
        else
        {
            $scope.Stage='Final';
            $scope.ChequeBinFlag = true;
            $scope.TillAuthorisors=serviceParameters.CloseTillParams.TillAuthorisors;
        }
    }

    $scope.CloseTIll_Select = function(){
        console.log('controllerTillManagement.CloseTill_Select Entry');
        
        //serviceParameters.CloseTillParams.PreviousState = 'depository.tellerbalancetill';
        serviceParameters.CloseTillParams.TillId = $scope.tillIdToClose;
        serviceParameters.CloseTillParams.TillAuthorisors = $scope.TillAuthorisors;

        serviceParameters.BalanceTillParams.PreviousState = 'depository.tellerclosetill';
        serviceParameters.BalanceTillParams.SuccessState = 'depository.tellerclosetill';
        serviceParameters.BalanceTillParams.TillId = $scope.tillIdToClose;

        $state.transitionTo('depository.tellerbalancetill');

        if(!$scope.$$phase) {
            $scope.$apply();
        }
        serviceApplication.LoadHide(false);
    }

    $scope.CloseTill_Execute = function(){
        console.log('controllerTillManagement.CloseTill_Execute Entry');

        if ($scope.Authorisor == undefined)
        {
            $scope.Response_Success = false;
            $scope.Response_StatusDescription = 'Authorisor not selected';
            alert($scope.Response_StatusDescription);
        }
        else
        {
            serviceApplication.LoadShow('Closing Till');
            serviceTillManagement.CloseTill(serviceParameters.CloseTillParams.TillId, $scope.Authorisor, $scope.ChequeBinFlag)
            .then(
                    function (result) {    
                            $scope.Response_Success = result.Success;
                            $scope.Response_StatusDescription = result.ErrorMessage;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }

                            if ($scope.Response_Success)
                            {
                                // CLear down Balance TIll parameters
                                serviceParameters.CloseTillParams.PreviousState = '';
                                serviceParameters.CloseTillParams.TillId = '';
                                serviceParameters.CloseTillParams.TillAuthorisors = null;

                                serviceParameters.BalanceTillParams.TillId='';
                                serviceParameters.BalanceTillParams.SuccessFlag=false;
                                serviceParameters.BalanceTillParams.SuccessState='';
                                serviceParameters.BalanceTillParams.PreviousState='';

                                $state.transitionTo('depository');

                                serviceMessageBroker.TellerTillRefresh();
                                serviceMessageBroker.TellerMenuOptionsRefresh();
                            }

                            serviceApplication.LoadHide(false);
                        },
                    function (error) {
                            $scope.Response_Success = false;
                            $scope.Response_StatusDescription = error.message;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                            serviceApplication.LoadHide(false);
                            alert(error.message);
                        }
                ); 
        }
    }

    $scope.TillTransferOut_Init = function(){
        console.log('controllerTillManagement.TillTransferOut_Init Entry');

        serviceApplication.LoadShow('Loading Transfer Out Settings');

        serviceTillManagement.TillManagement_LoadDenominations()
        .then(
                function (result) {    
                        $scope.Denominations=result;
                        $scope.Response_Success = true;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );

        serviceTillManagement.GetCurrencies()
        .then(
                function (result) {    
                        $scope.Currencies=result;
                        $scope.Response_Success = true;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );

        serviceTillManagement.GetOpenBranchTills(true, true)
        .then(
                function (result) {    
                        $scope.Tills = result;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        alert(error.message);
                    }
            );

        serviceApplication.LoadHide(false);
    }

    $scope.TillTransferOut_Execute = function(){
        console.log('controllerTillManagement.TillTransferOut_Execute Entry');

        serviceApplication.LoadShow('Transfering Out');
        $scope.Denominations.TransferCurrency = $scope.ccyToTransfer;
        serviceTillManagement.TillTransferOut($scope.tillToTransferTo, $scope.Denominations)
        .then(
                function (result) {    
                        $scope.Response_Success = result.Success;
                        $scope.Response_StatusDescription = result.ErrorMessage;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }

                        if ($scope.Response_Success)
                        {
                            $state.transitionTo('depository');
                        }
                        serviceApplication.LoadHide(false);
                        serviceMessageBroker.TellerTillRefresh();
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );
    }

    $scope.TillTransferAcceptance_Init = function(){
        console.log('controllerTillManagement.TillTransferAcceptance_Init Entry');

        serviceApplication.LoadShow('Loading Transfer Acceptance Settings');
        serviceTillManagement.GetTillTransfers()
        .then(
                function (result) {    
                        $scope.TillTransfers=result;
                        $scope.Response_Success = true;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );
    }

    $scope.TillTransferAcceptance_Selected = function(transfer){
        console.log('controllerTillManagement.TillTransferAcceptance_Selected Entry');

        $scope.selectedTransfer = transfer;
    }

    $scope.TillTransferAcceptance_Execute = function(){
        console.log('controllerTillManagement.TillTransferAcceptance_Execute Entry');

        serviceApplication.LoadShow('Accepting Transfer');
        $scope.TillTransfers.selectedTransfer = $scope.selectedTransfer;

        serviceTillManagement.AcceptTillTransfer($scope.TillTransfers)
        .then(
                function (result) {    
                        $scope.Response_Success = result.Success;
                        $scope.Response_StatusDescription = result.ErrorMessage;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }

                        if ($scope.Response_Success)
                        {
                            $state.transitionTo('depository');
                        }
                        serviceApplication.LoadHide(false);
                        serviceMessageBroker.TellerTillRefresh();
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );
    }

    $scope.VaultTransferOut_Init = function(){
        console.log('controllerTillManagement.VaultTransferOut_Init Entry');

        serviceApplication.LoadShow('Loading Transfer Out Settings');

        serviceTillManagement.TillManagement_LoadDenominationsForVault()
        .then(
                function (result) {    
                        $scope.Denominations=result;
                        $scope.Response_Success = true;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );

        serviceTillManagement.GetCurrencies()
        .then(
                function (result) {    
                        $scope.Currencies=result;
                        $scope.Response_Success = true;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );

        serviceTillManagement.GetOpenBranchTills(true, false)
        .then(
                function (result) {    
                        $scope.Tills = result;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        alert(error.message);
                    }
            );

        serviceApplication.LoadHide(false);
    }

    $scope.VaultTransferOut_Execute = function(){
        console.log('controllerTillManagement.VaultTransferOut_Execute Entry');

        if(typeof $scope.userPassword == 'undefined' || $scope.userPassword == '')
        {
            alert('Please enter a password');
        }
        else
        {
            serviceApplication.LoadShow('Transfering Out');
            $scope.Denominations.TransferCurrency = $scope.ccyToTransfer;
            serviceTillManagement.VaultTransferOut($scope.tillToTransferTo, $scope.userPassword, $scope.Denominations)
            .then(
                    function (result) {    
                            $scope.Response_Success = result.Success;
                            $scope.Response_StatusDescription = result.ErrorMessage;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }

                            if ($scope.Response_Success)
                            {
                                $state.transitionTo('depository');
                                alert('Vault Transfer Out: Successfully transfered from vault');
                            }
                            serviceApplication.LoadHide(false);
                            serviceMessageBroker.TellerTillRefresh();
                        },
                    function (error) {
                            $scope.Response_Success = false;
                            $scope.Response_StatusDescription = error.message;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                            serviceApplication.LoadHide(false);
                            alert(error.message);
                        }
                );
        }
    }

    $scope.VaultTransferAcceptance_Init = function(){
        console.log('controllerTillManagement.VaultTransferAcceptance_Init Entry');

        serviceApplication.LoadShow('Loading Transfer Acceptance Settings');
        serviceTillManagement.GetVaultTransfers()
        .then(
                function (result) {    
                        $scope.VaultTransfers=result;
                        $scope.Response_Success = true;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );
    }

    $scope.VaultTransferAcceptance_Selected = function(transfer){
        console.log('controllerTillManagement.VaultTransferAcceptance_Selected Entry');

        $scope.selectedTransfer = transfer;
    }

    $scope.VaultTransferAcceptance_Execute = function(){
        console.log('controllerTillManagement.VaultTransferAcceptance_Execute Entry');

        serviceApplication.LoadShow('Accepting Transfer');
        $scope.VaultTransfers.selectedTransfer = $scope.selectedTransfer;

        serviceTillManagement.AcceptVaultTransfer($scope.VaultTransfers)
        .then(
                function (result) {    
                        $scope.Response_Success = result.Success;
                        $scope.Response_StatusDescription = result.ErrorMessage;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }

                        if ($scope.Response_Success)
                        {
                            $state.transitionTo('depository');
                        }
                        serviceApplication.LoadHide(false);
                        serviceMessageBroker.TellerTillRefresh();
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );
    }

    $scope.BalanceVault_Init = function(){
        console.log('controllerTillManagement.BalanceVault_Init Entry');
        
        serviceApplication.LoadShow('Loading denominations');
        serviceTillManagement.TillManagement_LoadDenominationsForVault()
        .then(
                function (result) {    
                        $scope.Denominations=result;
                        $scope.Response_Success = true;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );

            serviceTillManagement.GetAuthorisors_VaultBalance()
            .then(
                    function (result) {    
                            $scope.VaultAuthorisors = result;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                        },
                    function (error) {
                            $scope.Response_Success = false;
                            $scope.Response_StatusDescription = error.message;

                            if(!$scope.$$phase) {
                                $scope.$apply();
                            }
                            serviceApplication.LoadHide(false);
                            alert(error.message);
                        }
                );

        serviceApplication.LoadHide(false);
    }

    $scope.BalanceVault_Execute = function(){
        console.log('controllerTillManagement.BalanceVault_Execute Entry');

        if (($scope.VaultAuthorisors.selectedFirstAuthorisor != null) && ($scope.VaultAuthorisors.selectedFirstAuthorisor != undefined))
        {
            if (($scope.VaultAuthorisors.selectedSecondAuthorisor != null) && ($scope.VaultAuthorisors.selectedSecondAuthorisor != undefined))
            {
                serviceApplication.LoadShow('Balancing Vault');
                serviceTillManagement.BalanceVault($scope.Denominations, $scope.VaultAuthorisors)
                .then(
                        function (result) {    
                                $scope.Response_Success = result.Success;
                                $scope.Response_StatusDescription = result.ErrorMessage;

                                if(!$scope.$$phase) {
                                    $scope.$apply();
                                }

                                if ($scope.Response_Success)
                                {
                                    $state.transitionTo('depository');
                                    alert('Balance Vault: Successfully balanced vault');
                                }
                                serviceApplication.LoadHide(false);
                            },
                        function (error) {
                                $scope.Response_Success = false;
                                $scope.Response_StatusDescription = error.message;

                                if(!$scope.$$phase) {
                                    $scope.$apply();
                                }
                                serviceApplication.LoadHide(false);
                                alert(error.message);
                            }
                    );
            }
            else
            {
                $scope.Response_Success = false;
                $scope.Response_StatusDescription = 'Second Authorisor not selected';
            }            
        }
        else
        {
            $scope.Response_Success = false;
            $scope.Response_StatusDescription = 'First Authorisor not selected';
        }
    }

    $scope.ReconcileBranch_Execute = function(){
        console.log('controllerTillManagement.ReconcileBranch_Execute Entry');

        serviceApplication.LoadShow('Reconciling Branch Cash');
        serviceTillManagement.ReconcileBranch()
        .then(
                function (result) {
                        console.log(result);
                        $scope.Response_Success = result.Response.Success;
                        $scope.Response_StatusDescription = result.Response.ErrorMessage;

                        $scope.BranchCurrencyTotals = result.EngageCurrencies;
                        $scope.EBSBranchCurrencyTotals = Enumerable.From(result.EBSCurrencies).OrderBy("item => item.FXCurrency").ToArray();
                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }

                        if ($scope.Response_Success)
                        {
                            $state.transitionTo('depository');
                            alert('Reconcile Branch Cash: Successfully reconciled branch');
                        }
                        serviceApplication.LoadHide(false);
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = error.message;

                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );
    }

    $scope.getCurrencyThumbnail = function (currency) {
            return serviceParameters.ApplicationParams.ResourceCurrenciesPath + '/Teller_Currencies/' + currency + '.png';
    }

    $scope.showTills = function (engageItem) {
        if ($scope.active != engageItem.FXCurrency) {
          $scope.active = engageItem.FXCurrency;
        }
        else {
          $scope.active = null;
        }
    };
}]);