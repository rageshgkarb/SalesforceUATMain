baaApp.controller('controllerCore', ['$scope', '$location', '$timeout', '$q', 'serviceApplication',  'serviceParameters', 'serviceMessageBroker',
    function ($scope, $location, $timeout, $q, serviceApplication,serviceParameters,  serviceMessageBroker)
    {

        //serviceParameters


	    $scope.Load = false;
	    $scope.LoadMessage = '';

        $scope.ModalShow = false;
        $scope.ModalTitle = '';
        $scope.ModalType = '';

        $scope.menuOpen = 'false';
        $scope.menuItemSelected = '';
        $scope.subMenuItemSelected = '';

        $scope.StartupArgs = null;

        //Message Listeners---------------------------
        $scope.$on('LoadShow', function(event, args)
        {
			$scope.LoadMessage = args;
    	    $scope.Load = true;
        });

        $scope.$on('LoadHide', function()
        {
			$scope.Load = false;
    	    $scope.LoadMessage = '';
        });

        $scope.$on('ModalShow', function(event, args)
        {
            $scope.ModalTitle = args.Title;
            $scope.ModalType = args.ModalType;
            $scope.ModelShow = true;
            serviceParameters.ApplicationParams.ModalType = args.ModalType;
        });

        $scope.$on('ModalHide', function()
        {
            $scope.ModalTitle = '';
            $scope.ModalType = '';
            $scope.ModelShow = false;
            serviceMessageBroker.ModalClosed(serviceParameters.ApplicationParams.ModalType);
            serviceParameters.ApplicationParams.ModalType = '';

        });
    }]);