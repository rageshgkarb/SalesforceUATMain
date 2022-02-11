tellerApp.controller('controllerTransactionStepFxDenoms', ['$scope',
    function ($scope) {

        $scope.Init = function() {
            $scope.displayDenominationsSummary = true;
        }

        if (typeof $scope.pageData != 'undefined' && $scope.pageData != null && $scope.pageData.FXData != null) {
            $scope.pageData.FXData.DepositDenominations.TotalSelectedValue = 0;
            $scope.pageData.FXData.WithdrawalDenominations.TotalSelectedValue = 0;
            $scope.pageData.FXData.RemainderDenominations.TotalSelectedValue = 0;
            $scope.SelectedTab = 'deposit';
            $scope.FxDenominationsCache = JSON.parse(JSON.stringify($scope.pageData.FXData));
        }

        $scope.$watch('pageData.FXData.DepositDenominations.TransactionDenonminations', function () {
            $scope.pageData.FXData.DepositDenominations.TotalSelectedValue = 0;
            $scope.pageData.FXData.DepositDenominations.TransactionDenonminations.forEach(function (item) {
                if (typeof item.change != 'undefined' && item.change != null && item.change != '') {
                    if (item.change == 'TotalValue') {
                        item.NumberSelected = parseInt(item.TotalValue * 100) / parseInt(item.DenominationValue * 100);
                        $scope.UpdateFxNoInTill('Deposit', item);
                    }
                    else if (item.change == 'NumberSelected') {
                        item.TotalValue = item.NumberSelected * item.DenominationValue;
                        $scope.UpdateFxNoInTill('Deposit', item);
                    }
                }

                item.change = null;
                $scope.pageData.FXData.DepositDenominations.TotalSelectedValue += item.TotalValue;
            }
            )

        }, true);

        $scope.$watch('pageData.FXData.WithdrawalDenominations.TransactionDenonminations', function () {
            $scope.pageData.FXData.WithdrawalDenominations.TotalSelectedValue = 0;
            $scope.pageData.FXData.WithdrawalDenominations.TransactionDenonminations.forEach(function (item) {
                if (typeof item.change != 'undefined' && item.change != null && item.change != '') {
                    if (item.change == 'TotalValue') {
                        item.NumberSelected = parseInt(item.TotalValue * 100) / parseInt(item.DenominationValue * 100);
                        $scope.UpdateFxNoInTill('Withdrawal', item);
                    }
                    else if (item.change == 'NumberSelected') {
                        item.TotalValue = item.NumberSelected * item.DenominationValue;
                        $scope.UpdateFxNoInTill('Withdrawal', item);
                    }
                }

                item.change = null;
                $scope.pageData.FXData.WithdrawalDenominations.TotalSelectedValue += item.TotalValue;
            }
            )

        }, true);

        $scope.$watch('pageData.FXData.RemainderDenominations.TransactionDenonminations', function () {
            $scope.pageData.FXData.RemainderDenominations.TotalSelectedValue = 0;
            $scope.pageData.FXData.RemainderDenominations.TransactionDenonminations.forEach(function (item) {
                if (typeof item.change != 'undefined' && item.change != null && item.change != '') {
                    if (item.change == 'TotalValue') {
                        item.NumberSelected = parseInt(item.TotalValue * 100) / parseInt(item.DenominationValue * 100);
                        $scope.UpdateFxNoInTill('Remainder', item);
                    }
                    else if (item.change == 'NumberSelected') {
                        item.TotalValue = item.NumberSelected * item.DenominationValue;
                        $scope.UpdateFxNoInTill('Remainder', item);
                    }
                }

                item.change = null;
                $scope.pageData.FXData.RemainderDenominations.TotalSelectedValue += item.TotalValue;
            }
            )

        }, true);

        $scope.OnTabSelected = function (tabName) {
            $scope.SelectedTab = tabName;
        }

        $scope.UpdateFxNoInTill = function (denomType, item) {
            var denom = $scope.GetFxDenominationFromCache(denomType, item.DenominationValue);
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

                $scope.SyncDenomTills(denomType, item);
            }
        }

        $scope.GetFxDenominationFromCache = function (denomType, denominationValue) {
            var result = null;
            if ($scope.FxDenominationsCache[denomType + 'Denominations'].TransactionDenonminations != null) {
                $scope.FxDenominationsCache[denomType + 'Denominations'].TransactionDenonminations.forEach(function (item) {
                    if (item.DenominationValue == denominationValue) {
                        result = item;
                    }
                });

                return result;
            }
        }

        $scope.SyncDenomTills = function (denomType, item) {
            var denomTypes = ['Deposit', 'Withdrawal', 'Remainder'];
            var toSync = Enumerable.From(denomTypes).Where("x => x !== '" + denomType + "'").ToArray();
            toSync.forEach(function (dtype) {
                $scope.SyncDenomTill(dtype, item);
            });
        }

        $scope.SyncDenomTill = function (denomType, item) {
            if ($scope.pageData.FXData[denomType + 'Currency'] === item.DenominationCurrency) {
                var denom = Enumerable.From($scope.pageData.FXData[denomType + 'Denominations'].TransactionDenonminations)
                    .Where("x => x.DenominationValue == " + item.DenominationValue).First();
                if (denom !== null) {
                    denom.NoInTill = item.NoInTill;
                }
            }
        }

        $scope.onIncrementDenomination = function (denomination, denomType) {
            if (denomType == 'Deposit') {
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
            $scope.UpdateFxNoInTill(denomType, denomination);
        }

        $scope.onDecrementDenomination = function (denomination, denomType) {
            if (denomType == 'Deposit') {
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
            $scope.UpdateFxNoInTill(denomType, denomination);
        }

    }]);
