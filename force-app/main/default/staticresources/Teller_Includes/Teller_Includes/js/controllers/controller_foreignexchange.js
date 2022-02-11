tellerApp.controller('controllerForeignExchange', ['$scope', '$stateParams', '$timeout', 'serviceApplication', 'serviceTransactions', 'serviceParameters', 'serviceStateTransition',
    function ($scope, $stateParams, $timeout, serviceApplication, serviceTransactions, serviceParameters, serviceStateTransition) {

        $scope.RatesTableHeaders = null;
        $scope.RatesTableBody = null;
        $scope.ExchangeRates = null;

        $scope.FromCcy = {
            Currency: null,
            Symbol: null,
            Amount: 0.00
        }

        $scope.ToCcy = {
            Currency: null,
            Symbol: null,
            Amount: 0.00,
            RawAmount: 0.00,
            TillAmount: 0.00,
            RemainderAmount: 0.00,
            NotificationMsg: ''
        }

        $scope.Branches = null;
        $scope.SelectedBranchNumber = null;
        $scope.DisableCashExchange = true;

        $scope.watcherToCcyAmount = null;
        $scope.watcherFromCcyAmount = null;


        $scope.InitialiseWatchers = function () {
            $scope.watcherToCcyAmount = $scope.$watch('ToCcy.Amount', function (newValue, oldValue) { $scope.PropertyChanged(newValue, oldValue, 'To'); });
            $scope.watcherFromCcyAmount = $scope.$watch('FromCcy.Amount', function (newValue, oldValue) { $scope.PropertyChanged(newValue, oldValue, 'From'); });
        }

        $scope.DisableWatchers = function () {
            $scope.watcherToCcyAmount();
            $scope.watcherFromCcyAmount();
        }

        $scope.PropertyChanged = function (newValue, oldValue, ToFromCCY) {
            if (newValue !== oldValue) {
                $scope.DisableCashExchange = true;

                if (ToFromCCY == 'To') { 
                    $scope.FromCcy.Amount = 0.00; 
                }
                else { 
                    $scope.ToCcy.Amount = 0.00; 
                }
            }
        }

        $scope.Initialise = function () {
            $scope.InitialiseWatchers();
            //serive call to get country list and rates table.
            console.log('fx init');
            serviceApplication.LoadShow('Loading foreign exchange rates');
            serviceTransactions.GetFXRates().then(
                function (result) {
					
                    serviceApplication.LoadHide();
					
					/* C0566 */
					$scope.isExpired=result.isExpired;
					$scope.lastModified=result.DateLastMaintained;
                    /* C0566 */
					
					$scope.PrepareRatesTable(result.FXRateDetail);
                    $scope.ExchangeRates = result.FXCurrencies;
                    $scope.Branches = result.Branches;
                    $scope.ClearKendoComboBox('kendoFXBranch');
                    $scope.ClearKendoComboBox('kendoToCcy');
                    $scope.ClearKendoComboBox('kendoFromCcy');
                    $scope.SelectedBranchNumber = result.DefaultBranchNumber;
                },
                function (error) {
                    serviceApplication.LoadHide();
                }
            );
        }

        $scope.PrepareRatesTable = function (source) {
            $scope.RatesTableHeaders = Enumerable.From(source).OrderBy("item => item.SellCurrency").Distinct("item => item.SellCurrency").Select("item => item.SellCurrency").ToArray();
            $scope.RatesTableBody = Enumerable.From(source).OrderBy("item => item.SellCurrency").ToArray();
        }

        $scope.Calculate = function () {
            //make service call to calculate the rate.
            console.log($scope.FromCcy);
            console.log($scope.ToCcy);
            serviceApplication.LoadShow('Calculating...');
            serviceTransactions.CalculateFXAmounts($scope.FromCcy.Amount, $scope.FromCcy.Currency, $scope.ToCcy.Amount, $scope.ToCcy.Currency, $scope.SelectedBranchNumber).then(
                function (result) {
                    $scope.DisableWatchers();
                    serviceApplication.LoadHide();
                    $scope.ToCcy.Amount = result.FXData.WithdrawalAmount;
                    $scope.ToCcy.RawAmount = result.FXData.WithdrawalAmount;
                    $scope.ToCcy.TillAmount = result.FXData.TillWithdrawalAmount;
                    $scope.ToCcy.RemainderAmount = result.FXData.RemainderAmount;
                    $scope.ToCcy.RemainderCurrencySymbol = result.FXData.RemainderCurrencySymbol;
                    $scope.FromCcy.Amount = result.FXData.DepositAmount;
                    $scope.ExchangeCashFunctionId = result.FunctionId;
                    serviceParameters.FXExchangeCash = result;
                    console.log(result);
                    serviceApplication.LoadHide();
                    $scope.DisableCashExchange = !result.FXData.EnableExchangeCash;
                    $scope.InitialiseWatchers();
                    if (result.FXData.MessageText != undefined){
                        $scope.ToCcy.NotificationMsg = result.FXData.MessageText;
                    }
                    else{
                        $scope.ToCcy.NotificationMsg='';
                    }
                },
                function (error) {
                    serviceApplication.LoadHide();
                    console.log(error);
                }
            );
        }

        $scope.getCurrencyThumbnail = function (currency) {
            return serviceParameters.ApplicationParams.ResourceCurrenciesPath + '/Teller_Currencies/' + currency + '.png';
        }

        $scope.gotoFXCashExchange = function () {
            serviceApplication.LoadShow('Creating Transaction ...');
            serviceParameters.TransactionParams.FunctionId = $scope.ExchangeCashFunctionId;
            serviceStateTransition.GotoState('depository.tellerfxexchangecash', $scope.ExchangeCashFunctionId);            
        }

        $scope.onClickRateItem = function (params) {
            console.log(params);

            $scope.SetKendoComboBox('kendoFromCcy', params.BuyCurrency);
            var frmCcy = $scope.GetCurrency(params.BuyCurrency);
            $scope.FromCcy.Currency = params.BuyCurrency;
            $scope.FromCcy.Amount = 0.00;
            $scope.FromCcy.Symbol = frmCcy.CurrencySymbol;

            $scope.SetKendoComboBox('kendoToCcy', params.SellCurrency);
            var toCcy = $scope.GetCurrency(params.SellCurrency);
            $scope.ToCcy.Currency = params.SellCurrency;
            $scope.ToCcy.Amount = 0.00;
            $scope.ToCcy.Symbol = toCcy.CurrencySymbol;
        }

        $scope.SetKendoComboBox = function (kendoInputName, value) {
            var kendoInput = angular.element(document.getElementsByClassName(kendoInputName)[1]);
            kendoInput.val(value);
        }

        $scope.ClearKendoComboBox = function (kendoInputName) {
            var kendoInput = angular.element(document.getElementsByClassName(kendoInputName)[1]);
            kendoInput.val("");
            var label = angular.element(kendoInput.parent().parent().parent().children()[4]);
            label.removeClass('md_label_active');
        }

        $scope.onCurrencyChanged = function (e, property, className) {
            console.log($scope.FromCcy);
            var ccy = $scope.GetCurrency($scope[property]['Currency'])
            if (ccy != null) {
                $scope[property]['Currrency'] = ccy.FXCurrency;
                $scope[property]['Symbol'] = ccy.CurrencySymbol;
                $scope[property]['Amount'] = 0;
            }
            else {
                $scope[property]['Currrency'] = null;
                $scope[property]['Symbol'] = null;
                $scope[property]['Amount'] = 0;
                $scope.SetKendoComboBox(className, null);
            }

            if (property.indexOf('From') > -1) {
                $scope.ToCcy.Amount = 0;
                $scope.ToCcyRawAmount = 0.00;
                $scope.ToCcyTillAmount = 0.00;
                $scope.ToCcyRemainderAmount = 0.00;
            }
        }

        $scope.GetCurrency = function (currency) {
            return Enumerable.From($scope.ExchangeRates).Where("ccy => ccy.FXCurrency == '" + currency + "'").FirstOrDefault();
        }

        $scope.DisableCalculate = function () {
            if (($scope.ToCcy.Amount !== null && $scope.ToCcy.Amount !== 0)
                || ($scope.FromCcy.Amount !== null && $scope.FromCcy.Amount !== 0)) {
                return false;
            }
            return true;
        }

    }]);