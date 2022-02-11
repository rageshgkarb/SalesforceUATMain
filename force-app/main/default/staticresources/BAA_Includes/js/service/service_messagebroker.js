    baaApp.service('serviceMessageBroker', ['$q', '$rootScope', function ($q, $rootScope) {

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