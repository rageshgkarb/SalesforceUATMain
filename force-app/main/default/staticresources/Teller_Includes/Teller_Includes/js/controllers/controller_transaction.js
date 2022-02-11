tellerApp.controller('controllerTransaction', ['$rootScope', '$scope', '$timeout', '$location', '$stateParams', '$state', '$filter', 'serviceParameters', 'serviceTransactions', 'serviceCustomer', 'serviceMandates', 'serviceApplication', 'serviceMessageBroker', 'serviceTillManagement',
    function ($rootScope, $scope, $timeout, $location, $stateParams, $state, $filter, serviceParameters, serviceTransactions, serviceCustomer, serviceMandates, serviceApplication, serviceMessageBroker, serviceTillManagement) {
        $scope.CreditAccountNoDisplay = '';
        $scope.DebitAccountNoDisplay = '';
        $scope.PrintTemplate = '';
        $scope.PrintedReciept = '';
        $scope.NowDateTime = null;
        $scope.TellerName = serviceParameters.TellerParams.Name;
        $scope.TellerImageURL = serviceParameters.TellerParams.ImageURL;
        $scope.Branch = serviceParameters.TellerParams.Branch;
        $scope.CreditAccounts = null;
        $scope.DenominationsCache = null;
        $scope.transactionContentFocus = false;

        $scope.ShowSecondAuthorisor = false;
        $scope.ShowThirdAuthorisor = false;
        $scope.ShowForthAuthorisor = false;

		$scope.LargeCashDepositAggregate = 0;
		$scope.LargeCashDepositAggregateMessage='';


        // Controller listeners 
        $scope.$watch('pageData.Denominations.TransactionDenonminations', function () {

            if ($scope.displayDenominations == true) {
                $scope.pageData.Denominations.TotalSelectedValue = 0;

                $scope.pageData.Denominations.TransactionDenonminations.forEach(function (item) {
                    if (typeof item.change != 'undefined' && item.change != null && item.change != '') {
                        if (item.change == 'TotalValue') {
                            item.NumberSelected = parseInt(item.TotalValue * 100) / parseInt(item.DenominationValue * 100);
                            var denom = $scope.GetDenominationFromCache(item.DenominationValue);
                            $scope.UpdateNoInTill(item);
                        }
                        else if (item.change == 'NumberSelected') {
                            item.TotalValue = item.NumberSelected * item.DenominationValue;
                            var denom = $scope.GetDenominationFromCache(item.DenominationValue);
                            $scope.UpdateNoInTill(item);
                        }
                    }

                    item.change = null;
                    $scope.pageData.Denominations.TotalSelectedValue += item.TotalValue;
                }
                )
            };
        }, true);

        $scope.$watch('pageData.WithdrawalCurrency', function () {

            if ($scope.displayWithdrawalCurrency == true) {
                if (($scope.pageData.WithdrawalCurrency != '') && ($scope.pageData.TransactionAmount != '') && ($scope.displayExchangeRate == true)) {
                    $scope.pageData.CashCurrency = $scope.pageData.WithdrawalCurrency;
                    $scope.CalculateFX();
                }
            };
        }, true);

        $scope.$watch('pageData.DepositCurrency', function () {

            if ($scope.displayDepositCurrency == true) {
                if (($scope.pageData.DepositCurrency != '') && ($scope.pageData.TransactionAmount != '') && ($scope.displayExchangeRate == true)) {
                    $scope.pageData.CashCurrency = $scope.pageData.displayDepositCurrency;
                    $scope.CalculateFX();
                }
            };
        }, true);

        $scope.$watch('pageData.TransactionAmount', function () {

            if (($scope.displayCreditAccountNo == true) && (($scope.displayDebitAccountNo == true)) && ($scope.displayExchangeRate == true) && ($scope.pageData.TransactionAmount != '')) {
                if (($scope.pageData.CreditAccountNo.length == 8) || ($scope.pageData.CreditAccountNo.length == 13)) {
                    $scope.CalculateFX();
                }
            };

            if (($scope.displayDepositCurrency == true) || ($scope.displayWithdrawalCurrency == true)) {
                if ((($scope.pageData.DepositCurrency != '') && ($scope.pageData.TransactionAmount != '') && ($scope.displayExchangeRate == true)) ||
                    (($scope.pageData.WithdrawalCurrency != '') && ($scope.pageData.TransactionAmount != '') && ($scope.displayExchangeRate == true))) {
                    $scope.CalculateFX();
                }
            };

			$scope.TransactionAggregateLargeCashTotal();

        }, true);

        $scope.$watch('pageData.CreditAccountNo', function () {

            if (($scope.displayCreditAccountNo == true) && ($scope.displayDebitAccountNo == true) && ($scope.displayExchangeRate == true)) {
                if (($scope.pageData.CreditAccountNo.length == 8) || ($scope.pageData.CreditAccountNo.length == 13)) {
                    $scope.CalculateCurrencies();
                }
            };
        }, true);

        $scope.CalculateCurrencies = function () {
            // Call SF to get Currencies of Accounts
            var accountNos = [$scope.pageData.DebitAccountNo, $scope.pageData.CreditAccountNo];

            serviceTransactions.GetAccountCurrencies(accountNos)
                .then(
                function (result) {

                    var creditAccountCCYSet = false;
                    var debitAccountCCYSet = false;
                    $scope.pageData.CreditAccountCurrency = '';
                    $scope.pageData.DebitAccountCurrency = '';
                    for (var i = 0; i <= result.CurrencyList.length - 1; i++) {
                        if (($scope.pageData.CreditAccountNo == result.CurrencyList[i].AccountNo) ||
                            ($scope.pageData.CreditAccountNo == result.CurrencyList[i].ExternalAccountNo)) {
                            $scope.pageData.CreditAccountCurrency = result.CurrencyList[i].AccountCurrency;
                            creditAccountCCYSet = true;
                        } else if (($scope.pageData.DebitAccountNo == result.CurrencyList[i].AccountNo) ||
                            ($scope.pageData.DebitAccountNo == result.CurrencyList[i].ExternalAccountNo)) {
                            $scope.pageData.DebitAccountCurrency = result.CurrencyList[i].AccountCurrency;
                            debitAccountCCYSet = true;
                        }
                    }
                    $scope.Response_Success = false;
                    $scope.Response_StatusDescription = '';

                    if (!creditAccountCCYSet) { $scope.Response_StatusDescription = 'Credit Account Currency could not be found'; }
                    else if (!debitAccountCCYSet) { $scope.Response_StatusDescription = 'Debit Account Currency could not be found'; }
                    else { $scope.Response_Success = true; }

                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    alert(error.message);
                }
                );
        }

        $scope.CalculateFX = function () {
            // Calculate Exchange Rate
            var buyCCY;
            var sellCCY;
            var multiOrDivide = 'M';
            $scope.pageData.ExchangeRate = 0.0;
            if ($scope.displayDepositCurrency == true) {
                // FX Cash Deposit
                buyCCY = $scope.pageData.DepositCurrency;
                sellCCY = $scope.pageData.AccountCurrency;
                multiOrDivide = 'M';
            }
            else if ($scope.displayWithdrawalCurrency == true) {
                // FX Cash Withdrawal
                buyCCY = $scope.pageData.AccountCurrency;
                sellCCY = $scope.pageData.WithdrawalCurrency;
                multiOrDivide = 'D';
            }
            else if (($scope.displayCreditAccountNo == true) && ($scope.displayExchangeRate == true)) {
                // FX Account Transfer
                buyCCY = $scope.pageData.DebitAccountCurrency;
                sellCCY = $scope.pageData.CreditAccountCurrency;
                multiOrDivide = 'M';
            }

            buyCCY = buyCCY.trim().toUpperCase();
            sellCCY = sellCCY.trim().toUpperCase();
            $scope.pageData.ExchangeRate = 0.0;
            $scope.pageData.ExchangeAmount = 0.00;

            for (var i = 0; i <= $scope.pageDefinition.FXRates.FXRateDetail.length - 1; i++) {
                if (($scope.pageDefinition.FXRates.FXRateDetail[i].BuyCurrency == buyCCY) && ($scope.pageDefinition.FXRates.FXRateDetail[i].SellCurrency == sellCCY)) {
                    $scope.pageData.ExchangeRate = $scope.pageDefinition.FXRates.FXRateDetail[i].ExchangeRate;
                }
                if (($scope.pageDefinition.FXRates.FXRateDetail[i].SellCurrency == buyCCY) && ($scope.pageDefinition.FXRates.FXRateDetail[i].BuyCurrency == sellCCY)) {
                    $scope.pageData.ReverseExchangeRate = $scope.pageDefinition.FXRates.FXRateDetail[i].ExchangeRate;
                }
            }

            var exchAmount = String($scope.pageData.ExchangeRate * $scope.pageData.TransactionAmount);

            if (multiOrDivide == 'D') {
                exchAmount = String($scope.pageData.TransactionAmount / $scope.pageData.ExchangeRate);
            }

            if (exchAmount.lastIndexOf(".") > 0) { exchAmount = exchAmount.slice(0, exchAmount.lastIndexOf(".") + 3); } // Only want 2dps not rounding
            $scope.pageData.ExchangeAmount = Number(exchAmount);
        }

        // ***** VF Remoting Calls *****

        $scope.LoadFunctionPageData = function () {
            serviceApplication.LoadHide();
            console.log('controller_transaction.LoadFunctionPageData Entry');
            console.log('serviceParameters.StateParams: ' + serviceParameters.StateParams);

            if ((serviceParameters.StateParams.Params == null) || (serviceParameters.StateParams.Params == 'undefined')) {
                var functionId = serviceParameters.TransactionParams.FunctionId;
                var accountNo = serviceParameters.TransactionParams.Account.Name;
                $scope.SourceTransition = 'customercore.customersummary';
            }
            else {
                var functionId = serviceParameters.StateParams.Params;
                var accountNo = null;
                $scope.SourceTransition = 'depository';

                // Clear StateParams
                serviceParameters.Clear_StateParams();
            }

            if (serviceParameters.FXExchangeCash != null) {
                $scope.pageData = JSON.parse(JSON.stringify(serviceParameters.FXExchangeCash));
                serviceParameters.FXExchangeCash = null;
                if (!$scope.$$phase) {
                    $scope.$apply();
                }
            }

            $scope.testing = 'N';
            console.log('$scope.testing: ' + $scope.testing);
            console.log('serviceParameters.TransactionParams.Account: ' + serviceParameters.TransactionParams.Account);
            $scope.working = true;


            serviceApplication.LoadShow('Initialising transaction defintion');

            if (serviceParameters.TransactionParams.AccountList != null) {
                $scope.CreditAccounts = [];
                var cacc = Enumerable.From(serviceParameters.TransactionParams.AccountList).Where("a => a.EligibleTransferToField == true").Select("b => b.AccountNo").ToArray();
                Enumerable.From(cacc).ForEach(function (value, index) {
                    if (serviceParameters.TransactionParams.Account.Name != value) {
                        var item = { value: value, label: $filter('filter_accountNumber')(value) };
                        $scope.CreditAccounts.push(item);
                    }
                });
            }

            serviceTransactions.LoadFunctionPageDefinitionData(functionId, accountNo, serviceParameters.TransactionParams.Account)
                .then(
                function (result) {
                    console.log('controllerTransaction.LoadFunctionPageDefinitionData Entry');
					$scope.pageDefinition = result;
                    $scope.CurrentStageOrder = 0;
                    $scope.Response_Success = true;
                    // Need to setup page for next/initial stage
                    setupPageForNextStage();
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.Response_StatusDescription = error.message;
                    serviceApplication.LoadHide(false);
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    alert(error.message);
                }
                );

            serviceApplication.LoadShow('Initialising transaction data');
            serviceTransactions.LoadFunctionPageData(functionId, accountNo, serviceParameters.TransactionParams.Account)
                .then(
                function (result) {
                    console.log('controllerTransaction called serviceTransactions.LoadFunctionPageData Entry');
					if (($scope.pageData == undefined) || ($scope.pageData.FunctionId == undefined)) {
                        $scope.pageData = result;
						$scope.pageData.TransactionAmount = '';
                    }

					//console.log(JSON.stringify(result));

                    // if($scope.pageData.CreditAccountNo != '')
                    //     $scope.CreditAccountNoDisplay =  $filter('filter_accountNumber')($scope.pageData.CreditAccountNo);
                    // if($scope.pageData.DebitAccountNo != '')
                    //     $scope.DebitAccountNoDisplay = $filter('filter_accountNumber')($scope.pageData.DebitAccountNo);
                    $scope.working = false;
                    $scope.Response_Success = true;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    serviceApplication.LoadHide(false);
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    alert(error.message);
                }
                );
        }

        $scope.LoadDenominations = function () {
            console.log('controller_transaction.LoadDenominations Entry');
            $scope.working = true;

            serviceApplication.LoadShow('Loading denominations');
            var cashCCY = $scope.pageData.AccountCurrency;
            if ($scope.displayDepositCurrency == true) { cashCCY = $scope.pageData.DepositCurrency; }
            else if ($scope.displayWithdrawalCurrency == true) { cashCCY = $scope.pageData.WithdrawalCurrency; }

            if ($scope.pageDefinition.IsVaultFunction) {
                serviceTillManagement.TillManagement_LoadCurrencyDenominationsForVault(cashCCY)
                    .then(
                    function (result) {
                        $scope.pageData.Denominations = result;
                        if (result.Success) {
                            $scope.DenominationsCache = JSON.parse(JSON.stringify($scope.pageData.Denominations.TransactionDenonminations));
                            $scope.Response_Success = true;
                        }
                        else {
                            $scope.Response_Success = false;
                            $scope.Response_StatusDescription = result.ErrorCode + ' - ' + result.ErrorDescription;
                        }
                        $scope.working = false;
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                    },
                    function (error) {
                        $scope.Response_Success = false;
                        $scope.working = false;
                        $scope.Response_StatusDescription = error.message;
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
                    );
            }
            else {
                serviceTransactions.LoadDenominations($scope.pageData.DepositoryId, cashCCY)
                    .then(
                    function (result) {
                        $scope.pageData.Denominations = result;
                        if (result.success) {
                            $scope.DenominationsCache = JSON.parse(JSON.stringify($scope.pageData.Denominations.TransactionDenonminations));
                            $scope.Response_Success = true;
                        }
                        else {
                            $scope.Response_Success = false;
                            $scope.Response_StatusDescription = result.ErrorCode + ' - ' + result.ErrorDescription;
                        }
                        $scope.working = false;
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                    },
                    function (error) {
                        $scope.Response_Success = false;
                        $scope.working = false;
                        $scope.Response_StatusDescription = error.message;
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
                    );
            }
        }

        $scope.LoadSignatories = function () {
            console.log('controller_transaction.LoadSignatories Entry');
            $scope.working = true;

            var accountNo = $scope.pageData.CreditAccountNo;
            if ($scope.pageData.MandateCheckedAgainst.indexOf('Debit') > -1) {
                accountNo = $scope.pageData.DebitAccountNo;
            }

            serviceApplication.LoadShow('Loading signatories');
            serviceCustomer.LoadSignatories(accountNo)
                .then(
                function (result) {
                    $scope.signatoriesResponse = result;
                    $scope.selectedSignatories = [];

                    if (!$scope.signatoriesResponse.Success) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = result.ErrorMessage;
                    }
                    else {
                        $scope.Response_Success = true;
                    }
                    $scope.working = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }

        $scope.MandatesCheck = function () {
            console.log('controller_transaction.MandatesCheck Entry');

            $scope.working = true;
            serviceApplication.LoadShow('Checking mandates');
            serviceMandates.CheckMandates($scope.pageData)
                .then(
                function (result) {
                    if (result.Response_Success) {
                        $scope.Response_Success = true;
                        moveToNextStage();
                    }
                    else {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = result.Response_StatusDescription;
                    }

                    $scope.pageData = result;
                    $scope.working = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }

        $scope.ProcessStage = function (stageId) {
            console.log('controller_transaction.ProcessStage Entry');

            var data = $scope.pageData;
            $scope.working = true;

            serviceApplication.LoadShow('Processing transaction');
            serviceTransactions.ProcessStage(data, stageId)
                .then(
                function (result) {
                    if (!result.Response_Success) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = result.Response_StatusDescription;
                        $scope.pageData.Response_Code = result.Response_Code;
                        if (result.ManagerAuthorisors != undefined) {
                            if ($scope.pageData.ManagerAuthorisors == undefined || $scope.pageData.ManagerAuthorisors == null) {
                                $scope.pageData.ManagerAuthorisors = result.ManagerAuthorisors;
                            }
                        }
                    }
                    else {
                        $scope.pageData = result;
                        $scope.Response_Success = true;
                        moveToNextStage();
                    }

                    $scope.working = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }

        $scope.CreateTransactionRecord = function () {
            console.log('controller_transaction.CreateTransactionRecord Entry');
            $scope.pageData.TransactionAmount = $scope.pageData.TransactionAmount == '' ? '00.00' : $scope.pageData.TransactionAmount;
            var data = $scope.pageData;
            $scope.working = true;
            serviceApplication.LoadShow('Creating transaction');
            serviceTransactions.CreateTransactionRecord(data)
                .then(
                function (result) {
                    if (!result.Response_Success) {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = result.Response_StatusDescription;
                    }
                    else {
                        $scope.pageData = result;
                        $scope.Response_Success = true;
                        moveToNextStage();
                    }

                    $scope.working = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }

        $scope.DenominationsCheck = function () {
            console.log('controller_transaction.DenominationsCheck Entry');

            $scope.working = true;
            serviceApplication.LoadShow('Checking denominations');
            serviceTransactions.CheckDenominations($scope.pageData)
                .then(
                function (result) {

                    $scope.checkDenominationsResponse = result;
                    if ($scope.checkDenominationsResponse.Success) {
                        $scope.Response_Success = true;
                        moveToNextStage();
                    }
                    else {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = result.ErrorMessage;
                    }

                    $scope.working = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }

        $scope.FXDenominationsCheck = function () {
            console.log('controller_transaction.FXDenominationsCheck Entry');

            $scope.working = true;
            serviceApplication.LoadShow('Checking FX denominations');
            serviceTransactions.CheckFXDenominations($scope.pageData)
                .then(
                function (result) {

                    $scope.checkFXDenominationsResponse = result;
                    if ($scope.checkFXDenominationsResponse.Success) {
                        $scope.Response_Success = true;
                        moveToNextStage();
                    }
                    else {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = result.ErrorMessage;
                    }

                    $scope.working = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }

        $scope.LoadLimits = function () {
            console.log('controller_transaction.LoadLimits Entry');

            $scope.working = true;
            serviceApplication.LoadShow('Loading limits');
            serviceTransactions.LoadLimits($scope.pageData)
                .then(
                function (result) {

                    if (result.LimitCheckRequired) {
                        $scope.LimitData = result;
                        $scope.Response_Success = true;

                        if ($scope.LimitData.SecondAuthorisors != undefined) {
                            $scope.LimitData.SecondAuthorisor = '';
                            $scope.LimitData.SecondAuthorisor.Verified = false;
                            $scope.AddToAuthorisorCache('SecondAuthorisor', $scope.LimitData.SecondAuthorisors);
                            $scope.ShowSecondAuthorisor = true;
                        }
                        if ($scope.LimitData.ThirdAuthorisors != undefined) {
                            $scope.LimitData.ThirdAuthorisor = '';
                            $scope.LimitData.ThirdAuthorisor.Verified = false;
                            $scope.AddToAuthorisorCache('ThirdAuthorisor', $scope.LimitData.ThirdAuthorisors);
                            $scope.ShowThirdAuthorisor = true;
                        }
                        if ($scope.LimitData.FourthAuthorisors != undefined) {
                            $scope.LimitData.FourthAuthorisor = '';
                            $scope.LimitData.FourthAuthorisor.Verified = false;
                            $scope.AddToAuthorisorCache('FourthAuthorisor', $scope.LimitData.FourthAuthorisors);
                            $scope.ShowForthAuthorisor = true;
                        }
                    }
                    else {
                        moveToNextStage();
                    }

                    $scope.working = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }

        $scope.GetManagerAuthorisors = function () {
            serviceTillManagement.GetManagerAuthorisors()
                .then(
                function (result) {
                    $scope.pageData.ManagerAuthorisors = result;
                },
                function (error) {
                    $scope.pageData.ManagerAuthorisors = null;
                }
                );
        }

        $scope.PasswordVerification = function (authorisor) {
            console.log('controller_transaction.PasswordVerification Entry');

            if (authorisor.Password == '' || authorisor.Password == null) {
                $scope.Response_StatusDescription = 'Password cannot be empty';
                return;
            }

            $scope.working = true;
            serviceApplication.LoadShow('Verifying Password');
            serviceTransactions.PasswordVerification(authorisor.Username, authorisor.Password)
                .then(
                function (result) {
                    if (result.Success == true) {
                        authorisor.Verified = true;
                    }
                    else {
                        authorisor.IncorrectPassword = true;
                        $scope.Response_StatusDescription = 'Incorrect Password';
                    }

                    $scope.working = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }

        $scope.SubmitForApproval = function () {
            console.log('controller_transaction.SubmitForApproval Entry');

            $scope.working = true;
            serviceApplication.LoadShow('Submitting for Approval');

            var limits = angular.copy($scope.LimitData);
            if (limits.SecondAuthorisor == '') {
                limits.SecondAuthorisor = null;
            }

            if (limits.ThirdAuthorisor == '') {
                limits.ThirdAuthorisor = null;
            }

            if (limits.FourthAuthorisor == '') {
                limits.FourthAuthorisor = null;
            }

            serviceTransactions.SubmitForApproval($scope.pageData, limits)
                .then(
                function (result) {
                    if (result.Response_Success == true) {
                        $scope.Response_Success = true;
                        $scope.working = false;

                        $state.transitionTo('customercore.customersummary');
                    }
                    else {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = result.Response_StatusDescription;
                    }

                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }

        $scope.PreApprovedCase = function (authorisorNo, authorisorId) {
            console.log('controller_transaction.PreApprovedCase');
            console.log('testing, testing ...');
            $scope.working = true;
            $scope.AuthorisorNo = authorisorNo;

            serviceParameters.PreCaseSelection.pageData = $scope.pageData;
            serviceParameters.PreCaseSelection.AuthorisorNo = authorisorNo;
            serviceParameters.PreCaseSelection.AuthorisorId = authorisorId;

            serviceApplication.LoadShow('Loading Pre Approved Cases');

            serviceApplication.ModalShow('Pre Approved Cases', 'PreApprovedCases');

            serviceApplication.LoadHide(false);
        }

        $scope.$on('ModalClosed', function (event, args) {
            //Check to ensure it’s the dialog that was opened by this controller
            if (args == 'PreApprovedCases') {
                // do your stuff here which needs to be done after the dialog is closed.

                if (serviceParameters.PreCaseSelection.CaseId != null) {
                    if ($scope.AuthorisorNo == 3) {
                        $scope.LimitData.ThirdAuthorisor.CaseRecord = serviceParameters.PreCaseSelection.CaseId;
                        $scope.LimitData.ThirdAuthorisorPreApprovedCase = serviceParameters.PreCaseSelection.CaseNo;
                        $scope.LimitData.ThirdAuthorisor.Verified = true;
                    }
                    else if ($scope.AuthorisorNo == 4) {
                        $scope.LimitData.FourthAuthorisor.CaseRecord = serviceParameters.PreCaseSelection.CaseId;
                        $scope.LimitData.FourthAuthorisorPreApprovedCase = serviceParameters.PreCaseSelection.CaseNo;
                        $scope.LimitData.FourthAuthorisor.Verified = true;
                    }
                }

                // Tidy up
                serviceParameters.PreCaseSelection.AccountNo = null;
                $scope.working = false;
            }
        });


        $scope.LimitCheck = function () {
            console.log('controller_transaction.LimitCheck Entry');

            $scope.working = true;
            serviceApplication.LoadShow('Checking limits');
            serviceTransactions.LimitCheck($scope.pageData, $scope.LimitData)
                .then(
                function (result) {
                    if (result.Response_Success == true) {
                        $scope.Response_Success = true;
                        moveToNextStage();
                    }
                    else {
                        $scope.Response_Success = false;
                        $scope.Response_StatusDescription = result.Response_StatusDescription;
                    }

                    $scope.working = false;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    $scope.Response_Success = false;
                    $scope.working = false;
                    $scope.Response_StatusDescription = error.message;
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                    serviceApplication.LoadHide(false);
                    alert(error.message);
                }
                );
        }


        // ***** Page Validation Functions *****


        var updateSelected = function (action, id) {
            if (action == 'add' && $scope.selectedSignatories.indexOf(id) == -1) { $scope.selectedSignatories.push(id); }
            if (action == 'remove' && $scope.selectedSignatories.indexOf(id) != -1) { $scope.selectedSignatories.splice($scope.selectedSignatories.indexOf(id), 1); }
        };

        $scope.updateSelection = function ($event, id) {
            var checkbox = $event.target;
            var action = (checkbox.checked ? 'add' : 'remove');
            updateSelected(action, id);
        };

        $scope.updateSelectedSignatories = function (id) {
            if ($scope.selectedSignatories.indexOf(id) == -1) {
                updateSelected('add', id);
            }
            else {
                updateSelected('remove', id);
            }
        }

        $scope.getSelectedClass = function (entity) {
            return $scope.isSelected(entity.id) ? 'selected' : '';
        };

        $scope.isSelected = function (id) {
            return $scope.selectedSignatories.indexOf(id) >= 0;
        };

        $scope.CheckMandates = function () {
            console.log('teller_function_transaction.CheckMandates Entry');

            var accountNo = $scope.pageData.CreditAccountNo;
            if ($scope.pageData.MandateCheckedAgainst.indexOf('Debit') > -1) {
                accountNo = $scope.pageData.DebitAccountNo;
            }

            $scope.pageData.SelectedSignatoryId = new Array();
            $scope.pageData.SelectedSignatoryId = $scope.selectedSignatories;


            // Perform validation checks
            var validationErrors = false;
            var validationErrorMessage = '';
            if ($scope.pageData.AccountNo == '') {
                validationErrors = true;
                validationErrorMessage = 'Account Number has not been set';
            }
            else if ($scope.pageData.TransactionAmount === '') {
                validationErrors = true;
                validationErrorMessage = 'Transaction Amount has not been set';
            }
            else if ($scope.pageData.SelectedSignatoryId.length < 1) {
                validationErrors = true;
                validationErrorMessage = 'No Customer has been selected';
            }

            if (!validationErrors) {
                $scope.Response_Success = true;
                $scope.MandatesCheck();
            }
            else {
                $scope.Response_Success = false;
                $scope.Response_StatusDescription = validationErrorMessage;
            }
        }

        $scope.CheckDenominations = function () {
            // Perform validation checks
            var validationErrors = false;
            var validationErrorMessage = '';

            $scope.pageData.Denominations.TransactionAmount = $scope.pageData.TransactionAmount;

            if (parseFloat($scope.pageData.Denominations.TotalSelectedValue.toFixed(2)) != $scope.pageData.Denominations.TransactionAmount) {
                validationErrors = true;
                validationErrorMessage = 'Denominations selected do not add up to Transaction Amount';
            }

            if (!validationErrors) {
                $scope.Response_Success = true;
                $scope.DenominationsCheck();
            }
            else {
                $scope.Response_Success = false;
                $scope.Response_StatusDescription = validationErrorMessage;
            }
        }

        $scope.CheckFXExchangeCash = function () {
            // Denomination Checks need to go here
            $scope.FXDenominationsCheck();
        }

		// C0671 Aggregate Limit Calc
		$scope.TransactionAggregateLargeCashTotal = function() {
			if(isNaN(parseFloat($scope.pageData.TransactionAmount)))
			{
				$scope.LargeCashDepositAggregate=0;
				$scope.LargeCashDepositAggregateMessage='';
			}
			else
			{
				$scope.LargeCashDepositAggregate=parseFloat($scope.pageData.TransactionAmount)+$scope.pageData.LargeCashDepositAggregate;
				if($scope.pageData.TransactionAmount < $scope.pageData.LargeCashDepositLimit && $scope.LargeCashDepositAggregate>=$scope.pageData.LargeCashDepositLimit)
				{
					$scope.LargeCashDepositAggregateMessage = ' - Aggregate Cash Deposit limit reached';
				}
				else
				{
					$scope.LargeCashDepositAggregateMessage = '';
				}
			}
		}

        $scope.CheckLimits = function () {
            var verified = true;

            if ($scope.ShowSecondAuthorisor && (($scope.LimitData.SecondAuthorisor == '') || ($scope.LimitData.SecondAuthorisor.Verified == false))) {
                verified = false;
            }
            if ($scope.ShowThirdAuthorisor && (($scope.LimitData.ThirdAuthorisor == '') || ($scope.LimitData.ThirdAuthorisor.Verified == false))) {
                verified = false;
            }
            if ($scope.ShowForthAuthorisor && (($scope.LimitData.FourthAuthorisor == '') || ($scope.LimitData.FourthAuthorisor.Verified == false))) {
                verified = false;
            }

            if (verified) {
                $scope.LimitCheck();
            }
            else {
                $scope.Response_Success = false;
                $scope.Response_StatusDescription = 'Not all authorisors have been verified';
            }
        }

        // ***** Page Functions *****

        $scope.previousButtonEventHandler = function () {
            // Cancel
            console.log('teller_function_transaction.previousButtonEventHandler Entry');
            $state.transitionTo($scope.SourceTransition);
        }

        $scope.nextButtonEventHandler = function (overrideLoadCheck) {
            console.log('teller_function_transaction.nextButtonEventHandler Entry');

            if (!overrideLoadCheck) {
                if (serviceApplication.LoadOpen()) {
                    console.log('Load Open - exiting method');
                    return;
                }
            }

            // Process Current Stage
            var currentStageObject = getStageObject($scope.CurrentStageOrder);
            switch (currentStageObject.MappingStageName) {
                case 'Initial':
                    $scope.CreateTransactionRecord();
                    break;
                case 'Denominations':
                    $scope.CheckDenominations();
                    break;
                case 'FXDenominations':
                    $scope.CheckFXExchangeCash();
                    break;
                case 'MandateCheck':
                    $scope.CheckMandates();
                    break;
                case 'LimitCheck':
                    $scope.CheckLimits();
                    break;
                case 'SendToEBS':
                    $scope.ProcessStage(currentStageObject.StageId);
                    break;
                case 'Print':
                    $scope.NowDateTime = new Date();
                    $timeout(function () {
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }

                        var elementToPrint = document.getElementById('printoutSection');
                        $scope.pageData.PrintedReciept = elementToPrint.innerHTML;
                        serviceApplication.PrintHTML($scope.pageData.PrintedReciept);
                        if (currentStageObject.AllowRePrint) {
                            serviceTransactions.UpdateTellerTransactionPrintedReciept($scope.pageData.TransactionId, $scope.pageData.PrintedReciept)
                                .then(
                                function (result) {
                                },
                                function (error) {
                                    if (!$scope.$$phase) {
                                        $scope.$apply();
                                    }
                                    alert(error.message);
                                }
                                );

                        }
                    });

                    moveToNextStage();
                    break;
                case 'Completion':
                    $state.transitionTo($scope.SourceTransition);
                    break;
            }

            $scope.ResetFocusOnTransactionContent();
        }

        $scope.ResetFocusOnTransactionContent = function () {
            $scope.transactionContentFocus == true ? $scope.transactionContentFocus = false : $scope.transactionContentFocus = true;
            $scope.transactionContentFocus == false ? $scope.transactionContentFocus = true : $scope.transactionContentFocus = true;
        }

        function moveToNextStage() {
            if ($scope.Response_Success) {
                // If Process Stage successful, perform Pre-Stage Checks for Next Stage
                var nextStageObject = getStageObject($scope.CurrentStageOrder + 1);
                switch (nextStageObject.MappingStageName) {
                    case 'Initial':
                        break;
                    case 'Denominations':
                        $scope.LoadDenominations();
                        break;
                    case 'FXDenominations':
                        break;
                    case 'MandateCheck':
                        $scope.LoadSignatories();
                        break;
                    case 'LimitCheck':
                        $scope.LoadLimits();
                        break;
                    case 'SendToEBS':
                        break;
                    case 'Completion':
                        serviceMessageBroker.CustomerRefresh();
                        break;
                }

                // If Pre-Stage Checks for Next Stage successful
                if ($scope.Response_Success) {
                    if (nextStageObject.AlwaysShow == false) {
                        // Perform Checks whether stage needs to be shown or not
                    }
                    setupPageForNextStage();
                }
                else {
                    // Display Errors

                }
            }
            else {
                // Display Errors

            }
        }

        function setupPageForNextStage() {
            $scope.CurrentStageOrder += 1;
            var currentStageObject = getStageObject($scope.CurrentStageOrder);
            $scope.CurrentStageName = currentStageObject.MappingStageName;
            var previousStageObject = null;

            if ($scope.CurrentStageOrder > 1) {
                previousStageObject = getStageObject($scope.CurrentStageOrder - 1);
            }

            if (currentStageObject == null) {
                // Stage not present
                // ??? To Do ???
            }
            else {
                switch (currentStageObject.MappingStageName) {
                    case 'Initial':
                        disablePreviousStage(previousStageObject);
                        displayCurrentStageFields(currentStageObject);
                        $scope.displayInitial = true;
                        break;
                    case 'Denominations':
                        disablePreviousStage(previousStageObject);
                        displayCurrentStageFields(currentStageObject);
                        $scope.displayDenominations = true;
                        $scope.displayDenominationsSummary = true;
                        break;
                    case 'FXDenominations':
                        disablePreviousStage(previousStageObject);
                        displayCurrentStageFields(currentStageObject);
                        $scope.displayFXDenominations = true;
                        $scope.displayFXDenominationsSummary = true;
                        break;
                    case 'MandateCheck':
                        disablePreviousStage(previousStageObject);
                        displayCurrentStageFields(currentStageObject);
                        $scope.displayMandateCheck = true;
                        $scope.displayMandateCheckSummary = true;
                        break;
                    case 'LimitCheck':
                        disablePreviousStage(previousStageObject);
                        displayCurrentStageFields(currentStageObject);
                        $scope.displayLimitCheck = true;
                        break;
                    case 'SendToEBS':
                        disablePreviousStage(previousStageObject);
                        displayCurrentStageFields(currentStageObject);
                        $scope.displaySendToEBS = true;
                        break;
                    case 'Completion':
                        disablePreviousStage(previousStageObject);
                        displayCurrentStageFields(currentStageObject);
                        $scope.displayCompletion = true;
                        break;
                    case 'Print':
                        disablePreviousStage(previousStageObject);
                        if (currentStageObject.TemplateHTML.length) {

                            $scope.PrintTemplate = $("<p/>").html(currentStageObject.TemplateHTML).text();

                            if (!$scope.$$phase) {
                                $scope.$apply();
                            }
                        }
                        $scope.displayPrintMessage = true;
                        break;

                }

                // Other Settings

                // Previous Button Title
                $scope.PreviousButtonTitle = currentStageObject.PreviousButtonTitle;
                $scope.displayPreviousButton = currentStageObject.ShowPreviousButton;
                // Previous Button Routing

                // Next Button Title
                $scope.NextButtonTitle = currentStageObject.NextButtonTitle;
                // Next Button Routing

                if (currentStageObject.AutoExecute) {
                    $timeout(function () {
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }

                        $scope.nextButtonEventHandler(true);
                    });
                }

            }
        }

        function getStageObject(stageOrder) {
            var stageObject = null;

            for (i = 0; i < $scope.pageDefinition.Stages.length; i++) {
                if ($scope.pageDefinition.Stages[i].StageOrder == stageOrder) {
                    stageObject = $scope.pageDefinition.Stages[i];
                }
            }

            return stageObject;
        }

        function disablePreviousStage(previousStageObject) {
            if (previousStageObject != null) {

                // Disable fields withing Previous Stage
                for (i = 0; i < $scope.pageDefinition.Fields.length; i++) {
                    if ($scope.pageDefinition.Fields[i].MappingStageName == previousStageObject.MappingStageName) {
                        disableField($scope.pageDefinition.Fields[i]);
                    }
                }


                if (!previousStageObject.KeepOnScreen) {
                    switch (previousStageObject.MappingStageName) {
                        case 'Initial':
                            $scope.displayInitial = false;
                            break;
                        case 'Denominations':
                            $scope.displayDenominations = false;
                            break;
                        case 'FXDenominations':
                            $scope.displayFXDenominations = false;
                            break;
                        case 'MandateCheck':
                            $scope.displayMandateCheck = false;
                            break;
                        case 'LimitCheck':
                            $scope.displayLimitCheck = false;
                            break;
                        case 'SendToEBS':
                            $scope.displaySendToEBS = false;
                            break;
                        case 'Completion':
                            $scope.displayCompletion = false;
                            break;
                        case 'Print':
                            $scope.displayPrintMessage = false;
                            break;
                    }
                }
            }
        }

        function displayCurrentStageFields(currentStageObject) {
            for (i = 0; i < $scope.pageDefinition.Fields.length; i++) {
                if ($scope.pageDefinition.Fields[i].MappingStageName == currentStageObject.MappingStageName) {
                    displayField($scope.pageDefinition.Fields[i]);
                }
            }
        }

        function disableField(field) {
            switch (field.MappingField_Name) {
                case 'CreditAccountNo':
                    $scope.disableCreditAccountNo = true;
                    break;
                case 'CreditAccountCCY':
                    $scope.disableCreditAccountCCY = true;
                    break;
                case 'DebitAccountNo':
                    $scope.disableDebitAccountNo = true;
                    break;
                case 'DebitAccountCCY':
                    $scope.disableDebitAccountCCY = true;
                    break;
                case 'MyCreditAccounts':
                    $scope.disableMyCreditAccounts = true;
                    break;
                case 'AccountName':
                    $scope.disableAccountName = true;
                    break;
                case 'TransactionAmount':
                    $scope.disableTransactionAmount = true;
                    break;
                case 'ChargeAmount':
                    $scope.disableChargeAmount = true;
                    break;
                case 'PaymentPurpose':
                    $scope.disablePaymentPurpose = true;
                    break;
                case 'AmountType':
                    $scope.disableAmountType = true;
                    break;
                case 'PaymentDetails':
                    $scope.disablePaymentDetails = true;
                    break;
                case 'BeneficiaryDetails':
                    $scope.disableBeneficiaryDetails = true;
                    break;
                case 'BeneficiaryAccountNo':
                    $scope.disableBeneficiaryAccountNo = true;
                    break;
                case 'BeneficiarySortCode':
                    $scope.disableBeneficiarySortCode = true;
                    break;
                case 'TransferType':
                    $scope.disableTransferType = true;
                    break;
                case 'NoOfCheques':
                    $scope.disableNoOfCheques = true;
                    break;
                case 'ChequeSerialNo':
                    $scope.disableChequeSerialNo = true;
                    break;
                case 'ChequeType':
                    $scope.disableChequeType = true;
                    break;
                case 'IssuingBank':
                    $scope.disableIssuingBank = true;
                    break;
                case 'Reference':
                    $scope.disableReference = true;
                    break;
                case 'NarrativeLines':
                    $scope.disableNarrativeLines = true;
                    break;
                case 'AdditionalNotes':
                    $scope.disableAdditionalNotes = true;
                    break;
                case 'ValueDate':
                    $scope.disableValueDate = true;
                    break;
                case 'ExchangeAmount':
                    $scope.disableExchangeAmount = true;
                    break;
                case 'ExchangeRate':
                    $scope.disableExchangeRate = true;
                    break;
                case 'WithdrawalCurrency':
                    $scope.disableWithdrawalCurrency = true;
                    break;
                case 'DepositCurrency':
                    $scope.disableDepositCurrency = true;
                    break;
            }
        }

        function displayField(field) {
			//console.log(JSON.stringify(field));
            switch (field.MappingField_Name) {
                case 'CreditAccountNo':
                    $scope.displayCreditAccountNo = field.Visible;
                    $scope.labelCreditAccountNo = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableCreditAccountNo = false; } else { $scope.disableCreditAccountNo = true; }
                    break;
                case 'CreditAccountCCY':
                    $scope.displayCreditAccountCCY = field.Visible;
                    $scope.labelCreditAccountCCY = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableCreditAccountCCY = false; } else { $scope.disableCreditAccountCCY = true; }
                    break;
                case 'DebitAccountNo':
                    $scope.displayDebitAccountNo = field.Visible;
                    $scope.labelDebitAccountNo = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableDebitAccountNo = false; } else { $scope.disableDebitAccountNo = true; }
                    break;
                case 'DebitAccountCCY':
                    $scope.displayDebitAccountCCY = field.Visible;
                    $scope.labelDebitAccountCCY = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableDebitAccountCCY = false; } else { $scope.disableDebitAccountCCY = true; }
                    break;
                case 'MyCreditAccounts':
                    $scope.displayMyCreditAccounts = field.Visible;
                    $scope.labelMyCreditAccounts = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableMyCreditAccounts = false; } else { $scope.disableMyCreditAccounts = true; }
                    break;
                case 'AccountName':
                    $scope.displayAccountName = field.Visible;
                    $scope.labelAccountName = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableAccountName = false; } else { $scope.disableAccountName = true; }
                    break;
                case 'TransactionAmount':
                    $scope.displayTransactionAmount = field.Visible;
                    $scope.labelTransactionAmount = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableTransactionAmount = false; } else { $scope.disableTransactionAmount = true; }
                    break;
                case 'ChargeAmount':
                    $scope.displayChargeAmount = field.Visible;
                    $scope.labelChargeAmount = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableChargeAmount = false; } else { $scope.disableChargeAmount = true; }
                    break;
                case 'PaymentPurpose':
                    $scope.displayPaymentPurpose = field.Visible;
                    $scope.labelPaymentPurpose = field.MappingField_Label;
                    $scope.paymentPurposeValues = field.MappingField_Picklist;
                    //$scope.pageData.PaymentPurpose=field.MappingField_PicklistDefault;
                    if (field.Enabled) { $scope.disablePaymentPurpose = false; } else { $scope.disablePaymentPurpose = true; }
                    break;
                case 'AmountType':
                    $scope.displayAmountType = field.Visible;
                    $scope.labelAmountType = field.MappingField_Label;
                    $scope.amountTypeValues = field.MappingField_Picklist;
                    //$scope.pageData.AmountType=field.MappingField_PicklistDefault;
                    if (field.Enabled) { $scope.disableAmountType = false; } else { $scope.disableAmountType = true; }
                    break;
                case 'PaymentDetails':
                    $scope.displayPaymentDetails = field.Visible;
                    $scope.labelPaymentDetails = field.MappingField_Label;
                    if (field.Enabled) { $scope.disablePaymentDetails = false; } else { $scope.disablePaymentDetails = true; }
                    break;
                case 'BeneficiaryDetails':
                    $scope.displayBeneficiaryDetails = field.Visible;
                    $scope.labelBeneficiaryDetails = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableBeneficiaryDetails = false; } else { $scope.disableBeneficiaryDetails = true; }
                    break;
                case 'BeneficiaryAccountNo':
                    $scope.displayBeneficiaryAccountNo = field.Visible;
                    $scope.labelBeneficiaryAccountNo = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableBeneficiaryAccountNo = false; } else { $scope.disableBeneficiaryAccountNo = true; }
                    break;
                case 'BeneficiarySortCode':
                    $scope.displayBeneficiarySortCode = field.Visible;
                    $scope.labelBeneficiarySortCode = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableBeneficiarySortCode = false; } else { $scope.disableBeneficiarySortCode = true; }
                    break;
                case 'TransferType':
                    $scope.displayTransferType = field.Visible;
                    $scope.labelTransferType = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableTransferType = false; } else { $scope.disableTransferType = true; }
                    break;
                case 'NoOfCheques':
                    $scope.displayNoOfCheques = field.Visible;
                    $scope.labelNoOfCheques = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableNoOfCheques = false; } else { $scope.disableNoOfCheques = true; }
                    break;
                case 'ChequeSerialNo':
                    $scope.displayChequeSerialNo = field.Visible;
                    $scope.labelChequeSerialNo = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableChequeSerialNo = false; } else { $scope.disableChequeSerialNo = true; }
                    break;
                case 'ChequeType':
                    $scope.displayChequeType = field.Visible;
                    $scope.labelChequeType = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableChequeType = false; } else { $scope.disableChequeType = true; }
                    break;
                case 'IssuingBank':
                    $scope.displayIssuingBank = field.Visible;
                    $scope.labelIssuingBank = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableIssuingBank = false; } else { $scope.disableIssuingBank = true; }
                    break;
                case 'Reference':
                    $scope.displayReference = field.Visible;
                    $scope.labelReference = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableReference = false; } else { $scope.disableReference = true; }
                    break;
                case 'NarrativeLines':
                    $scope.displayNarrativeLines = field.Visible;
                    $scope.labelNarrativeLines = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableNarrativeLines = false; } else { $scope.disableNarrativeLines = true; }
                    break;
                case 'AdditionalNotes':
                    $scope.displayAdditionalNotes = field.Visible;
                    $scope.labelAdditionalNotes = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableAdditionalNotes = false; } else { $scope.disableAdditionalNotes = true; }
                    break;
                case 'ValueDate':
                    $scope.displayValueDate = field.Visible;
                    $scope.labelValueDate = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableValueDate = false; } else { $scope.disableValueDate = true; }
                    break;
                case 'NoticeWithdrawalType':
                    $scope.displayNoticeWithdrawalType = field.Visible;
                    $scope.labelNoticeWithdrawalType = field.MappingField_Label;
                    $scope.NoticeWithdrawalTypeValues = field.MappingField_Picklist;
                    //$scope.pageData.NoticeWithdrawalType="Notice";//field.MappingField_PicklistDefault;
                    if (field.Enabled) { $scope.disableValueDate = false; } else { $scope.disableValueDate = true; }
                    break;
                case 'ExchangeAmount':
                    $scope.displayExchangeAmount = field.Visible;
                    $scope.labelExchangeAmount = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableExchangeAmount = false; } else { $scope.disableExchangeAmount = true; }
                    break;
                case 'ExchangeRate':
                    $scope.displayExchangeRate = field.Visible;
                    $scope.labelExchangeRate = field.MappingField_Label;
                    if (field.Enabled) { $scope.disableExchangeRate = false; } else { $scope.disableExchangeRate = true; }
                    break;
                case 'WithdrawalCurrency':
                    $scope.displayWithdrawalCurrency = field.Visible;
                    $scope.labelWithdrawalCurrency = field.MappingField_Label;
                    $scope.withdrawalCurrencyValues = field.MappingField_Picklist;
                    if (field.Enabled) { $scope.disableWithdrawalCurrency = false; } else { $scope.disableWithdrawalCurrency = true; }
                    break;
                case 'DepositCurrency':
                    $scope.displayDepositCurrency = field.Visible;
                    $scope.labelDepositCurrency = field.MappingField_Label;
                    $scope.depositCurrencyValues = field.MappingField_Picklist;
                    if (field.Enabled) { $scope.disableDepositCurrency = false; } else { $scope.disableDepositCurrency = true; }
                    break;
				// C0671 Start
				case 'LargeCashCase': 
					$scope.displayLargeCashCase=field.Visible;
					$scope.labelLargeCashCase=field.MappingField_Label;
					$scope.labelLargeCashCaseAggregate = ' - Aggregate exceeds limit';
					if(field.Enabled){$scope.disableLargeCashCase=false;}else{$scope.disableLargeCashCase=true;}
					break;
				/*case 'LargeCashBankWrap': 
					$scope.displayLargeCashBankWrap=field.Visible;
					$scope.labelLargeCashBankWrap=field.MappingField_Label;
					$scope.LargeCashBankWrapValues = field.MappingField_Picklist;
					$scope.LargeCash=true;
					if(field.Enabled){$scope.disableLargeCashBankWrap=false;}else{$scope.disableLargeCashBankWrap=true;}
					break;
				case 'LargeCashSource': 
					$scope.displayLargeCashSource=field.Visible;
					$scope.labelLargeCashSource=field.MappingField_Label;
					if(field.Enabled){$scope.disableLargeCashSource=false;}else{$scope.disableLargeCashSource=true;}
					break;
				case 'LargeCashEvidence': 
					$scope.displayLargeCashEvidence=field.Visible;
					$scope.labelLargeCashEvidence=field.MappingField_Label;
					if(field.Enabled){$scope.disableLargeCashEvidence=false;}else{$scope.disableLargeCashEvidence=true;}
					break;
				case 'LargeCashIntention': 
					$scope.displayLargeCashIntention=field.Visible;
					$scope.labelLargeCashIntention=field.MappingField_Label;
					if(field.Enabled){$scope.disableLargeCashIntention=false;}else{$scope.disableLargeCashIntention=true;}
					break;
				case 'LargeCashCustomerBehavior': 
					$scope.displayLargeCashCustomerBehavior=field.Visible;
					$scope.labelLargeCashCustomerBehavior=field.MappingField_Label;
					if(field.Enabled){$scope.disableLargeCashCustomerBehavior=false;}else{$scope.disableLargeCashCustomerBehavior=true;}
					break;
				case 'LargeCashSavingTime': 
					$scope.displayLargeCashSavingTime=field.Visible;
					$scope.labelLargeCashSavingTime=field.MappingField_Label;
					if(field.Enabled){$scope.disableLargeCashSavingTime=false;}else{$scope.disableLargeCashSavingTime=true;}
					break;
				case 'LargeCashFromSalary': 
					$scope.displayLargeCashFromSalary=field.Visible;
					$scope.labelLargeCashFromSalary=field.MappingField_Label;
					if(field.Enabled){$scope.disableLargeCashFromSalary=false;}else{$scope.disableLargeCashFromSalary=true;}
					break;
				case 'LargeCashCustomerProfileFit': 
					$scope.displayLargeCashCustomerProfileFit=field.Visible;
					$scope.labelLargeCashCustomerProfileFit=field.MappingField_Label;
					$scope.LargeCashCustomerProfileFitValues = field.MappingField_Picklist;
					if(field.Enabled){$scope.disableLargeCashCustomerProfileFit=false;}else{$scope.disableLargeCashCustomerProfileFit=true;}
					break;
				case 'LargeCashCustomerRiskRating': 
					$scope.displayLargeCashCustomerRiskRating=field.Visible;
					$scope.labelLargeCashCustomerRiskRating=field.MappingField_Label;
					$scope.LargeCashCustomerRiskRatingValues = field.MappingField_Picklist;
					if(field.Enabled){$scope.disableLargeCashCustomerRiskRating=false;}else{$scope.disableLargeCashCustomerRiskRating=true;}
					break;
				case 'LargeCashOnBoardCheck': 
					$scope.displayLargeCashOnBoardCheck=field.Visible;
					$scope.labelLargeCashOnBoardCheck=field.MappingField_Label;
					$scope.LargeCashOnBoardCheckValues = field.MappingField_Picklist;
					if(field.Enabled){$scope.disableLargeCashOnBoardCheck=false;}else{$scope.disableLargeCashOnBoardCheck=true;}
					break;*/
				// C0671 End
            }
        }

        //Page Events
        // $scope.onEnterNextButtonEventHandler = function(e)
        // {
        //     alert(e);
        // }


        //Limit - Authorisor checking
        $scope.AuthorisorCache = null;

        $scope.AddToAuthorisorCache = function (authoriserLevel, authorisors) {
            if ($scope.AuthorisorCache == null) {
                $scope.AuthorisorCache = [];
            }

            var item = { level: authoriserLevel, authorisors: authorisors };
            $scope.AuthorisorCache.push(item);
        }


        $scope.GetAuthorisorsToRemove = function (authorisorLevel) {
            var toRemove = [];

            switch (authorisorLevel) {
                case 'ForthAuthorisor':
                    {
                        if (typeof $scope.LimitData.ThirdAuthorisor != 'undefined' && $scope.LimitData.ThirdAuthorisor != null && $scope.LimitData.ThirdAuthorisor != '') {
                            toRemove.push($scope.LimitData.ThirdAuthorisor);
                        }

                        if (typeof $scope.LimitData.SecondAuthorisor != 'undefined' && $scope.LimitData.SecondAuthorisor != null && $scope.LimitData.SecondAuthorisor != '') {
                            toRemove.push($scope.LimitData.SecondAuthorisor);
                        }
                        break;
                    }

                case 'ThirdAuthorisor':
                    {
                        if (typeof $scope.LimitData.FourthAuthorisor != 'undefined' && $scope.LimitData.FourthAuthorisor != null && $scope.LimitData.FourthAuthorisor != '') {
                            toRemove.push($scope.LimitData.FourthAuthorisor);
                        }

                        if (typeof $scope.LimitData.SecondAuthorisor != 'undefined' && $scope.LimitData.SecondAuthorisor != null && $scope.LimitData.SecondAuthorisor != '') {
                            toRemove.push($scope.LimitData.SecondAuthorisor);
                        }
                        break;
                    }

                case 'SecondAuthorisor':
                    {
                        if (typeof $scope.LimitData.ThirdAuthorisor != 'undefined' && $scope.LimitData.ThirdAuthorisor != null && $scope.LimitData.ThirdAuthorisor != '') {
                            toRemove.push($scope.LimitData.ThirdAuthorisor);
                        }

                        if (typeof $scope.LimitData.FourthAuthorisor != 'undefined' && $scope.LimitData.FourthAuthorisor != null && $scope.LimitData.FourthAuthorisor != '') {
                            toRemove.push($scope.LimitData.FourthAuthorisor);
                        }

                        break;
                    }
            }

            return toRemove;
        }



        $scope.UpdateAuthorisorCollections = function (changedAuthorisor) {
            var toRemove = null;

            toRemove = $scope.GetAuthorisorsToRemove('SecondAuthorisor');
            $scope.RemoveDuplicateAuthorisors(toRemove, 'SecondAuthorisor', 'SecondAuthorisors');

            toRemove = $scope.GetAuthorisorsToRemove('ThirdAuthorisor');
            $scope.RemoveDuplicateAuthorisors(toRemove, 'ThirdAuthorisor', 'ThirdAuthorisors');

            toRemove = $scope.GetAuthorisorsToRemove('ForthAuthorisor');
            $scope.RemoveDuplicateAuthorisors(toRemove, 'ForthAuthorisor', 'ForthAuthorisors');
        }


        $scope.RemoveDuplicateAuthorisors = function (auothorisorIds, authorisorLevel, removeFrom) {
            var query = '';

            if (auothorisorIds.length > 0)
                query = 'item => ';

            for (index = 0; index < auothorisorIds.length; index++) {
                query += 'item.AuthorisorId != "' + auothorisorIds[index].AuthorisorId + '" ';
                if (index != auothorisorIds.length - 1 && auothorisorIds.length > 1) {
                    query += " && "
                }
            }

            var iAuthorisorCache = Enumerable.From($scope.AuthorisorCache);
            var lists = iAuthorisorCache.Where('item => item.level == "' + authorisorLevel + '"').ToArray();

            if (lists != null && lists.length > 0) {
                var auths = Enumerable.From(lists[0].authorisors);

                if (auths.Count() > 0) {
                    var result = null;
                    if (query != '') {
                        result = auths.Where(query);
                    }
                    else {
                        result = auths;
                    }
                }

                $scope.LimitData[removeFrom] = result.ToArray();
            }
        }



        // $scope.RemoveDuplicateAuthorisors = function(changedAuthorisor)
        // {
        //     var toRemove = [];
        //     if(typeof $scope.LimitData.ForthAuthorisor != 'undefined' &&  $scope.LimitData.ForthAuthorisor != null && $scope.LimitData.ForthAuthorisor != '')
        //     {
        //         toRemove.push($scope.LimitData.ForthAuthorisor);
        //     }

        //     if(typeof $scope.LimitData.ThirdAuthorisor != 'undefined' && $scope.LimitData.ThirdAuthorisor != null && $scope.LimitData.ThirdAuthorisor != '')
        //     {
        //         toRemove.push($scope.LimitData.ThirdAuthorisor);                
        //     }

        //     if(typeof $scope.LimitData.SecondAuthorisor != 'undefined' && $scope.LimitData.SecondAuthorisor != null && $scope.LimitData.SecondAuthorisor != '')
        //     {
        //         toRemove.push($scope.LimitData.SecondAuthorisor);                
        //     }

        //     var query = '';

        //     if(toRemove.length > 0)
        //         query = 'item => ';

        //     for(index = 0; index < toRemove.length; index++)
        //     {
        //          query += 'item.AuthorisorId != "' + toRemove[index].AuthorisorId + '" ';
        //          if(index != toRemove.length - 1 && toRemove.length > 1)
        //          {
        //             query += " && "
        //          }
        //     }

        //     var iAuthorisorCache = Enumerable.From($scope.AuthorisorCache);
        //     var lists = iAuthorisorCache.Where('item => item.level != "' + changedAuthorisor + '"').ToArray();

        //     if(lists != null && lists.length > 0)
        //     {
        //         lists.forEach(function(item) 
        //         {
        //             var auths = Enumerable.From(item.authorisors);
        //             if(auths.Count() > 0)
        //             {
        //                 var result = null;
        //                 if(query != '')
        //                 {
        //                     result = auths.Where(query);
        //                 }
        //                 else
        //                 {
        //                     result = auths;
        //                 }

        //                 switch(item.level)
        //                 {
        //                     case 'ForthAuthorisor':
        //                     {    
        //                         $scope.LimitData.FourthAuthorisors = result.ToArray();
        //                     }

        //                     case 'ThirdAuthorisor':
        //                     {
        //                         $scope.LimitData.ThirdAuthorisors = result.ToArray();
        //                     } 

        //                     case 'SecondAuthorisor':
        //                     {    
        //                         $scope.LimitData.SecondAuthorisors = result.ToArray();        
        //                     }          
        //                 }

        //             }   
        //         });
        //     }
        // }

        $scope.GetAuthorisosrsFromCache = function (authoriserLevel) {
            $scope.UpdateAuthorisorCollections(authoriserLevel);
        }


        //Denominations Cache Methods

        $scope.UpdateNoInTill = function (item) {
            var denom = $scope.GetDenominationFromCache(item.DenominationValue);
            if (denom != null) {
                if ($scope.pageData.TransactionAddingToDepository) {
                    item.NoInTill = item.NumberSelected + denom.NoInTill;
                }
                else {
                    if (item.NumberSelected > denom.NoInTill) {
                        item.NumberSelected = 0;
                        item.NoInTill = denom.NoInTill;
                        item.TotalValue = 0.00;
                    }
                    else {
                        item.NoInTill = denom.NoInTill - item.NumberSelected;
                    }
                }
            }
        }

        $scope.GetDenominationFromCache = function (denominationValue) {
            var result = null;
            if ($scope.DenominationsCache != null) {
                $scope.DenominationsCache.forEach(function (item) {
                    if (item.DenominationValue == denominationValue) {
                        result = item;
                    }
                });

                return result;
            }
        }


        //Limit UI Events
        $scope.onAuthorisorChanged = function (e, propertyName) {
            //$scope.LimitData[propertyName] = e.sender.dataItem().toJSON();
            //$scope.LimitData[propertyName].Verified = false;


            if (e.sender.input.val() != '' && typeof e.sender.dataItem() == 'undefined') {
                return;
            }

            if (e.sender.input.val() == '' && typeof e.sender.dataItem() == 'undefined') {
                $scope.LimitData[propertyName] = null;
                $scope.GetAuthorisosrsFromCache(propertyName);

                $timeout(function () {
                    e.sender.input.val('');
                    e.sender.input.blur();
                    if (!$scope.$$phase) {
                        $scope.$apply();
                    }
                }, 50);

            }

            //e.sender.dataSource.data() datasource
            if (typeof e.sender.dataItem() != 'undefined') {
                $scope.LimitData[propertyName] = e.sender.dataItem().toJSON();
                //$scope.LimitData[propertyName] = JSON.stringify(e.sender.dataItem());
                $scope.LimitData[propertyName].Verified = false;
                $scope.GetAuthorisosrsFromCache(propertyName);
            }

            if (!$scope.$$phase) {
                $scope.$apply();
            }
        }

        //Mandate UI Events
        $scope.onManagerChanged = function (e, propertyName) {
            //e.sender.dataSource.data() datasource
            $scope.pageData.ManagerAuthorisors[propertyName] = e.sender.dataItem().toJSON();
            //$scope.pageData.ManagerAuthorisors[propertyName] = JSON.stringify(e.sender.dataItem());
            $scope.pageData.ManagerAuthorisors[propertyName].Verified = false;
        }

        //Denominations UI Events

        $scope.getDenominationThumbnail = function (denomination) {
            var imageName = denomination.DenominationValue.toString().replace('.', '');
            return serviceParameters.ApplicationParams.ResourceDenominationPath + '/Teller_Denominations/' + denomination.DenominationCurrency + '/' + imageName + '.png';
        }

        $scope.onIncrementDenomination = function (denomination) {
            if ($scope.pageData.TransactionAddingToDepository) {
                denomination.NoInTill++;
                denomination.NumberSelected++;
            }
            else {

                if (denomination.NoInTill == 0) {
                    return;
                }

                denomination.NoInTill--;
                denomination.NumberSelected++;
            }

            denomination.TotalValue = denomination.NumberSelected * denomination.DenominationValue;
            var denom = $scope.GetDenominationFromCache(denomination.DenominationValue);
            $scope.UpdateNoInTill(denomination);
        }

        $scope.onDecrementDenomination = function (denomination) {
            if ($scope.pageData.TransactionAddingToDepository) {
                if (denomination.NumberSelected == 0) {
                    return;
                }

                denomination.NoInTill--;
                denomination.NumberSelected--;
            }
            else {
                if (denomination.NumberSelected == 0) {
                    return;
                }

                denomination.NoInTill++;
                denomination.NumberSelected--;
            }

            denomination.TotalValue = denomination.NumberSelected * denomination.DenominationValue;
            var denom = $scope.GetDenominationFromCache(denomination.DenominationValue);
            $scope.UpdateNoInTill(denomination);
        }

        $scope.onSetAmountFocus = function ($event) {
            var element = null;
            if ($event.toElement.children.length > 0) {
                element = $event.toElement.children[1];
            }
            else {
                element = $event.toElement.parentNode.children[1];
            }

            if (window.getSelection) {
                window.getSelection().removeAllRanges();
                var range = document.createRange();
                range.selectNodeContents(element);
                window.getSelection().addRange(range);
            }
        }
    }]);