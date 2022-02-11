tellerApp.service('serviceMessageBroker', ['$q', '$rootScope', function ($q, $rootScope) {

	this.CustomerAccountsRefresh = function()
	{
		$rootScope.$emit('CustomerAccountsRefresh');
        $rootScope.$broadcast('CustomerAccountsRefresh');
	}

	this.CustomerRefresh = function()
	{
		$rootScope.$emit('CustomerRefresh');
		$rootScope.$broadcast('CustomerRefresh');
	}

	this.TellerActivitiesRefresh = function()
	{
		$rootScope.$emit('ActivitiesRefresh');
		$rootScope.$broadcast('ActivitiesRefresh');
	}

	this.TransactionHistoryRefresh = function(scope)
	{
		scope.$broadcast('RefreshTransactionHistory');
	}
	
	this.OnlineBankingPaymentsRefresh = function(scope)
	{
		scope.$broadcast('RefreshOnlineBankingPayments');
	}
	
	this.AccountMandatesRefresh = function(scope)
	{
		scope.$broadcast('RefreshAccountMandates');
	}
	
	this.AccountActivityRefresh = function(scope)
	{
		scope.$broadcast('RefreshAwaitingAuthorisation');
	}
	this.DealInfoRefresh = function(scope)
	{
		scope.$broadcast('RefreshDealInfo');
	}

	this.TellerTillRefresh = function()
	{
		$rootScope.$emit('TellerTillRefresh');
		$rootScope.$broadcast('TellerTillRefresh');
	}

	this.TellerMenuOptionsRefresh = function()
	{
		$rootScope.$emit('TellerMenuOptionsRefresh');
		$rootScope.$broadcast('TellerMenuOptionsRefresh');
	}

	this.ModalShow = function(title, modalType){
        $rootScope.$broadcast('ModalShow', {Title: title, ModalType: modalType});      
    }

    this.ModalHide = function(){
        $rootScope.$broadcast('ModalHide');
    }

	this.ModalClosed = function(modalType)
	{
		$rootScope.$emit('ModalClosed', modalType);
		$rootScope.$broadcast('ModalClosed', modalType);
	}

	this.LoadShow = function(message)
	{
		$rootScope.$broadcast('LoadShow', message);
	}

	this.LoadHide = function()
	{
		$rootScope.$broadcast('LoadHide');
	}

	this.LoadHideComplete = function()
	{
		$rootScope.$emit('LoadHideComplete');
		$rootScope.$broadcast('LoadHideComplete');
	}

}]);