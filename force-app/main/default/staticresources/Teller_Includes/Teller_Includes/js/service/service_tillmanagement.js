tellerApp.service('serviceTillManagement', ['$q', '$rootScope', function ($q, $rootScope) {

    this.BalanceTill = function(denominations)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.BalanceTill(denominations, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.BalanceVault = function(denominations, vaultAuthorisors)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.BalanceVault(denominations, vaultAuthorisors, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.ReconcileBranch = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.ReconcileBranch(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.TillManagement_LoadDenominations = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.TillManagement_LoadDenominations(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.TillManagement_LoadDenominationsForCurrency = function(ccyOfTransaction)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.TillManagement_LoadDenominationsForCurrency(ccyOfTransaction, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.TillManagement_LoadDenominationsForTill = function(depositoryId)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.TillManagement_LoadDenominationsForTill(depositoryId, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.TillManagement_LoadDenominationsForVault = function(depositoryId)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.TillManagement_LoadDenominationsForVault(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.TillManagement_LoadCurrencyDenominationsForVault = function(denomCurrency)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.TillManagement_LoadCurrencyDenominationsForVault(denomCurrency, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.DenominationsChange = function(denominationsReceived, denominationsGiven)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.DenominationsChange(denominationsReceived, denominationsGiven, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    } 

    this.CloseTill = function(tillId, authorisor, chequeBinFlag)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.CloseTill(tillId, authorisor, chequeBinFlag, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }    

    this.OpenTill = function(tillId)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.OpenTill(tillId, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.GetCurrencies = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetCurrencies(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.GetOpenBranchTills = function(omitUserTill, getVault)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetOpenBranchTills(omitUserTill, getVault, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.GetClosedBranchTills = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetClosedBranchTills(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.TillTransferOut = function(till, denominations)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.TillTransferOut(till, denominations, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.VaultTransferOut = function(tillToTransferTo, password, denominations)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.VaultTransferOut(tillToTransferTo, password, denominations, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.GetTillTransfers = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetTillTransfers(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.AcceptTillTransfer = function(tillTransfers)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.AcceptTillTransfer(tillTransfers, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }    

    this.GetAuthorisors_Manager = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetManagerAuthorisors(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }    

    this.GetAuthorisors_VaultBalance = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetVaultBalanceAuthorisors(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    } 

    this.GetVaultTransfers = function()
    {
        var deferred = $q.defer();
        Teller_Core_Controller.GetVaultTransfers(function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }

    this.AcceptVaultTransfer = function(vaultTransfers)
    {
        var deferred = $q.defer();
        Teller_Core_Controller.AcceptVaultTransfer(vaultTransfers, function (result, event) {
            
            if (event.status) {
                deferred.resolve(result);
            }
            else {
                deferred.reject(event);
            }   
        });

        return deferred.promise;
    }    

}]);