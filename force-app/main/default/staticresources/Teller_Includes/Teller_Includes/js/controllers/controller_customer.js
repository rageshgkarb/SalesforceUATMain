tellerApp.controller('controllerCustomer', ['$scope', '$state', '$stateParams', 'serviceCustomer', 'serviceApplication', 'serviceParameters', 'serviceStateTransition',
    function ($scope, $state, $stateParams, serviceCustomer, serviceApplication, serviceParameters, serviceStateTransition) {
    
    $scope.SearchOpen = false;
    $scope.SearchCriteria = '';
    $scope.SearchResults = [];
    $scope.SearchButtonPressed = false;
    $scope.RecentCustomers = [];
    $scope.HideAutoComplete = false;

    $scope.SearchTemplate = '<span style="float:left; margin-top: 4px; margin-bottom: 3px;"><img style="box-shadow: 0 0 3px black; border-radius: 50%; height:55px; width:55px;" src="#:data.ImageURL#" onError="this.onerror=null; this.src=\'' + serviceParameters.ApplicationParams.ResourcePath + '/Teller_Includes/media/user_error.png\';"></span>' +
                            '<div style="overflow: hidden;"><label style="line-height: 1em !important; font-size: 17px; font-family: simpleBold; margin-top: 4px; margin-left: 10px; margin-bottom: 0px; font-weight: normal;">#: data.Name #</label><span style="font-weight: normal; margin-left: 3px; font-size: 17px;">(#: EBSId #)</span><div style="padding-left: 10px; margin-bottom: 4px; font-weight: normal; overflow: hidden; height: 27px; margin-top: -8px; font-size: 14px; line-height: 1em !important;">#: data.Address #</div></div>';

    $scope.SearchDataSource = new kendo.data.DataSource(
    {
        schema : {data: "Items"},
        serverFiltering: true,     
        serverPaging: true,  
        transport: 
        {
            read: function(options) 
            {
                serviceCustomer.FindCustomer($scope.SearchCriteria)
                    .then(
                        function(result) 
                        {                            
                            serviceApplication.ParseHTMLList(result.Items, ['Name', 'Address']);
                            options.success(result);
                            
                            if (!$scope.$$phase) 
                            {
                                $scope.$apply();
                            }
                        },
                        function(error) {
                            alert(error.message);

                        }
                );
            }
        }

    });

    $scope.SearchAutoCompleteOptions = {
        dataSource: $scope.SearchDataSource,
        dataTextField: 'Name',
        dataValueField: 'data',
        placeholder: "Name, Postcode, Account Number, EBS Id ...",
        delay: 500,
        template: $scope.SearchTemplate,
        select: function(args)
        {
            var dataItem = this.dataItem(args.item.index());
            $scope.GotoCustomer(dataItem);
        }
    }

    $scope.Initialise = function()
    {
        serviceParameters.CustomerParams.Initialise();
        $scope.RecentCustomers = serviceParameters.CustomerSearchParams.GetRecentCustomers();
        if(serviceParameters.CustomerSearchParams.SearchCriteria != '')
        {
            $scope.SearchCriteria = serviceParameters.CustomerSearchParams.SearchCriteria;
            serviceParameters.CustomerSearchParams.SearchCriteria = '';
            $scope.FindCustomer();
        }
    }

    $scope.InitialiseSearchBar = function()
    {
        $scope.searchOpen = true;
    }

    $scope.autoCompleteOpen = function(event)
    {
        if($scope.HideAutoComplete == true)
        {
            $scope.HideAutoComplete = false;
            event.preventDefault();
        }
    }

    $scope.FindCustomer = function () {
        $scope.HideAutoComplete = true;
        serviceApplication.LoadShow('Searching for customer: ' + $scope.SearchCriteria);
        $scope.SearchButtonPressed = true;
        serviceCustomer.FindCustomer($scope.SearchCriteria)
            .then(
                    function (result) {

                        $scope.SearchResults = result.Items;
                        if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                    },
                    function (error) {
                        alert(error.message);
                        serviceApplication.LoadHide(false);
                    }
                );
    }

    $scope.GotoCustomer = function(customer){        
        serviceStateTransition.GotoCustomerSummary(customer);
    }

}])








