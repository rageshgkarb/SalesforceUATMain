tellerApp.controller('controllerCore', ['$scope', '$location', '$timeout', '$q', 'serviceTeller', 'serviceApplication', 'serviceCustomer', 'serviceStateTransition', 'serviceParameters', 'serviceMessageBroker',
    function ($scope, $location, $timeout, $q, serviceTeller, serviceApplication, serviceCustomer, serviceStateTransition, serviceParameters, serviceMessageBroker)
{

    serviceParameters.ApplicationParams.ResourcePath = document.getElementById("TellerResourceLocation").innerHTML;
    serviceParameters.ApplicationParams.ResourceDenominationPath = document.getElementById("TellerResourceDenomintationLocation").innerHTML;
    serviceParameters.ApplicationParams.ResourceCurrenciesPath = document.getElementById("TellerResourceCurrenciesLocation").innerHTML;

    $scope.ServiceConsoleCss = serviceParameters.ApplicationParams.ResourcePath + '/Teller_Includes/css/serviceconsole.css';

	$scope.Load = false;
	$scope.LoadMessage = '';

    $scope.ModalShow = false;
    $scope.ModalTitle = '';
    $scope.ModalType = '';
    
    $scope.menuOpen = 'false';
    $scope.menuItemSelected = '';
    $scope.subMenuItemSelected = '';

    $scope.StartupArgs = null;

    $scope.Routes = null;
    
    $scope.headerSearchOpen = false;
    $scope.headerSearchCriteria = '';
    $scope.CustomerSearchData = null;
    $scope.CustomerSearchTimeOut = false;

    $scope.CustomerSearchTemplate = '<span style="height:50px; width:50px; margin-left: -3px; float:left; margin-top: 3px; margin-bottom: 3px;"><img style="box-shadow: 0 0 3px black; border-radius: 50%; height:50px; width:50px;" src="#:data.ImageURL#" onError="this.onerror=null; this.src=\'' + serviceParameters.ApplicationParams.ResourcePath + '/Teller_Includes/media/user_error.png\';"></span>' +
                                    '<div style="overflow: hidden;"><label style="font-size: 16px; font-family: simpleBold; margin-top: 4px; margin-left: 6px; margin-bottom: 0px; font-weight: normal;">#: data.Name #</label><span style="font-weight: normal; margin-left: 3px;">(#: EBSId #)</span><div style="  padding-left: 4px; margin-bottom: 4px; font-weight: normal; overflow: hidden; height: 27px; margin-top: -4px">#: data.Address #</div></div>';
                                    //onError="this.onerror=null; this.src=\''+ serviceParameters.ApplicationParams.ResourcePath + '\'/Teller_Includes/media/user_error.png\')}'

    $scope.CustomerSearchDataSource = new kendo.data.DataSource(
    {
        schema : {data: "Items"},
        serverFiltering: true,     
        serverPaging: true,  
        transport: 
        {
            read: function(options) 
            {
                serviceCustomer.FindCustomer($scope.headerSearchCriteria)
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

    $scope.CustomerSearchAutoCompleteOptions = {
        dataSource: $scope.CustomerSearchDataSource,
        dataTextField: 'Name',
        dataValueField: 'data',
        delay: 500,
        template: $scope.CustomerSearchTemplate,
        select: function(args)
        {
            var dataItem = this.dataItem(args.item.index());
            serviceStateTransition.GotoCustomerSummary(dataItem);
            $timeout(function()
            {
                $scope.headerSearchOpen = false;
                $scope.headerSearchCriteria = '';
            }, 6000);
        }
    }
   
    $scope.GetTellerMenuOptions = function()
    {
        serviceTeller.GetPermittedMenuItems()
            .then(
                function(result) 
                {
                    if (result) 
                    {
                        $scope.Routes = result.TellerFunctionGroups;
                    } 
                    else
                    {
                        $scope.Routes = null;
                    }
                },
                function(error) 
                {
                    alert(error.message);
                }
        );
    }

    $scope.Initialise = function() 
    {        
        $scope.ProcessURLArguments();
        $scope.RemoveCommonCssLink();
        $scope.GetTellerMenuOptions();
        serviceTeller.GetTellerInfo()
        .then(
                function(result) 
                {
                    serviceParameters.TellerParams.Name = result.Name;
                    serviceParameters.TellerParams.Branch = result.Branch;
                    serviceParameters.TellerParams.BranchNumber = result.BranchNumber;
                    serviceParameters.TellerParams.ImageURL = result.ImageURL;
                },
                function(error) 
                {
                    alert(error.message);
                }
        );
    }

    $scope.ProcessURLArguments = function()
    {
        //Check application mode
        //mode=page - single page mode, if not supplied then defaults to app mode        
        var mode = serviceApplication.GetParameterByNameFromURL('mode');
        if(mode == '')
        {
            $scope.SetAppMode();
        }

        var customerId = serviceApplication.GetParameterByNameFromURL('customerId');
        if(customerId != '')
        {
            //route to customer summary
            $scope.StartupArgs = { CustomerId: customerId };
        }
    }

    $scope.SetAppMode = function()
    {
        var links = $('link[rel=stylesheet]');

        for (index = 0; index < links.length; ++index) 
        {
            if(links[index].href.indexOf("Teller_Includes/css/engage_page_mode.css") > -1)
            {
                links[index].remove();
            }
        }
    }

    $scope.RemoveCommonCssLink = function()
    {
        var links = $('link[rel=stylesheet]');

        for (index = 0; index < links.length; ++index) 
        {
            if(links[index].href.indexOf("default/gc/common.css") > -1)
            {
                links[index].remove();
            }
        }
    }

    $scope.menuItemClicked = function(id, state, subMenuItemsCount)
    {
        if (typeof subMenuItemsCount === "undefined" || subMenuItemsCount == 0) 
        {
            $scope.menuOpen = 'false';
        }

        $scope.menuItemSelected == id ? $scope.menuItemSelected = null : $scope.menuItemSelected = id;

        $scope.subMenuItemSelected = null;
        serviceStateTransition.GotoState(state);
    };

    $scope.subMenuItemClicked = function(id, state, args)
    {
        $scope.menuOpen = 'false';
        $scope.subMenuItemSelected = id;
        serviceStateTransition.GotoState(state, args);
    }

    $scope.gotoActivities = function()
    {
        $scope.menuOpen = 'false';
        $scope.menuItemSelected = '4';
        serviceStateTransition.GotoState('activities', 'TestArgs');        
    }

    // $scope.headerSearchClicked = function()
    // {
    //     if($scope.headerSearchOpen)
    //     {
    //         //perform search            
    //         $scope.headerSearchOpen = false;
    //         $scope.headerSearchCriteria = '';
    //         $scope.SearchCustomer('Test');
    //     }
    //     else
    //     {
    //         $scope.headerSearchOpen = true;
    //         //document.getElementById("headerSearchInput").select();          

    //     }
    // };

    $scope.GetSearchHeaderClass = function()
    {
        if($scope.headerSearchOpen)
            return 'headerSearchOpen';
        return '';
    }

    $scope.RefreshCustomerSearchResults = function()
    {
        $scope.CustomerSearchDataSource.read();
        $scope.CustomerSearchTimeOut = false;
    }

    $scope.GotoCustomerSearch = function()
    {

        if($scope.headerSearchOpen)
        {
            //perform search            
            $scope.headerSearchOpen = false;           
            serviceStateTransition.GotoCustomerSearch($scope.headerSearchCriteria);
            $scope.headerSearchCriteria = ''; 
        }
        else
        {
            $scope.headerSearchOpen = true;
            //document.getElementById("headerSearchInput").select();   
        }
    }

    //Events Listeners----------------------------
     // $scope.$watch("headerSearchCriteria", function(newValue, oldValue) 
     // {
     //    if($scope.headerSearchCriteria != '')
     //    {
     //        //var deferred = $q.defer();

            
            
     //        $timeout($scope.RefreshCustomerSearchResults, 300);



     //        // if(!$scope.CustomerSearchTimeOut)
     //        // {
     //        //     $scope.CustomerSearchTimeOut = true;
     //        //     $timeout($scope.RefreshCustomerSearchResults, 400);
     //        // }
     //        // else
     //        // {
     //        //     console.log('timeout not expired');
     //        // }
     //    }
     //    else
     //    {
     //        $scope.CustomerSearchDataSource.data([]);
     //    }
     // });



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

    $scope.$on('TellerMenuOptionsRefresh', function()
    {
        $scope.GetTellerMenuOptions();
    });

    //State Listners------------------------------
    $scope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams)
    {
        if(toState.name == 'home' && $scope.StartupArgs != null)
        {
            var customer = {Id: $scope.StartupArgs.CustomerId, EBSId: ''};
            $scope.StartupArgs = null;
            serviceStateTransition.GotoCustomerSummary(customer);
        }
    });


    // $scope.$on('$viewContentLoading', function(event, viewConfig)
    // {   
    // });

    // $scope.$on('$viewContentLoaded', function(event)
    // {
    // });


}]);



