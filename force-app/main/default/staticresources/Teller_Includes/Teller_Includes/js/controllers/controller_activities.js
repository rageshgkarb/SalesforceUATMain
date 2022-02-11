tellerApp.controller('activitiesController', ['$scope', '$timeout', 'serviceReporting', 'serviceApplication', 'serviceParameters',
    function($scope, $timeout, serviceReporting, serviceApplication, serviceParameters) {
        $scope.SearchCriteria = null;
        $scope.TellerActivities = null;
        $scope.TellerActivitiesAnyRemaining = false;
        $scope.PageSize = 40;
        $scope.FilterLists = null;

        $scope.scrollContainer = null;
        $scope.RefreshIndicator = null;
        $scope.RefreshIndicatorReverseCss = false;
        $scope.Refreshing = false;
        $scope.RefreshCompleted = false;
        $scope.scrollContainerStopScroll = false;
        $scope.yStartTouch = 0;

        $scope.TellerName = '';
        $scope.NowDateTime = '';
        $scope.PrintData = null;
        $scope.PrintTemplate = '';
        
        //Quick, Filter, Sort
        $scope.SelectedCard = 'Quick';
        
        $scope.ShowFilterPane = true;
        $scope.ShowResultsPane = true;

        // $scope.SortByOptions = [                        
        //     {text: "Amount", value : 'Activity_Amount__c'},
        //     {text: "Currency", value : 'Activity_Currency__c'},
        //     {text: "Description", value : 'Activity_Description__c'},
        //     {text: "Status", value : 'Status__c'},
        //     {text: "Type", value : 'Activity_Type__c'},
        //     {text: "User", value : 'Created_By_User__c'},
        //     {text: "Activity Date Time", value : 'Activity_Date_Time__c'}
        // ];

        //$scope.SelectedSortBy = null;

        $scope.Initialise = function() {
            
            $scope.ShowResultsPane = (angular.element(document.getElementById("btnFilter")).css('display') == 'none');
            
            $scope.scrollContainer = angular.element(document.getElementById("activitiesContainer"));
            $scope.RefreshIndicator = document.getElementById("RefreshIndicator");

            $scope.scrollContainer.on('touchstart', function(e) {
                if ($scope.scrollContainer.scrollTop() == 0) {
                    $scope.RefreshIndicatorReverseCss = false;
                    $scope.yStartTouch = e.originalEvent.touches[0].pageY;
                    console.log('touchstart:' + $scope.yStartTouch);
                }
            });

            $scope.scrollContainer.on('touchmove', function(e) {
                if ($scope.scrollContainer.scrollTop() == 0) {


                        $scope.scrollContainerStopScroll = true;
                        $scope.$apply();

                    if ($scope.RefreshIndicator.getBoundingClientRect().top < 350) {
                        var yPos = e.originalEvent.touches[0].pageY;
                        console.log('touchmove:' + yPos);
                        $scope.RefreshIndicator.style.marginTop = (e.originalEvent.touches[0].pageY - $scope.yStartTouch) + 'px';
                        $scope.RefreshIndicator.style.opacity = ((yPos - $scope.yStartTouch)/350) * 2;
                        $scope.RefreshIndicator.children[0].style.transform = 'rotate(' + (yPos - $scope.yStartTouch)*1.5 + 'deg)';
                        $scope.$apply();
                    }
                }
            });

            $scope.scrollContainer.on('touchend', function(e) {
                var yPos = e.originalEvent.changedTouches[0].pageY;
                console.log('touchend:' + yPos);
                $scope.scrollContainerStopScroll = false;
                $scope.$apply();

                if ($scope.RefreshIndicator.getBoundingClientRect().top < 350) {
                    $scope.RefreshIndicatorReverseCss = true;
                    $scope.$apply();
                }
                else
                {
                    $scope.Refreshing = true;
                    $scope.$apply();
                    serviceReporting.GetTellerActivityAudit($scope.SearchCriteria)
                    .then(
                        function(result) {                            
                            $scope.TellerActivities = result;
                            $scope.RefreshCompleted = true;
                            $scope.$apply();
                            $scope.RefreshIndicatorReset();
                        },
                        function(error) {
                            alert(error.message); 
                            $scope.RefreshCompleted = true; 
                            $scope.$apply();
                            $scope.RefreshIndicatorReset();                          
                        }
                    );
                }
            });

            $scope.scrollContainer.on('scroll', function(e) {
                console.log('scrolling');
                if($scope.scrollContainerStopScroll == true)
                {
                    console.log('prevent scroll');
                    e.preventDefault();
                    $scope.$apply();
                }
            });

            $scope.InitialiseSearchCriteria();
        }

        $scope.RefreshIndicatorReset = function()
        {
            $timeout(function()
                { 
                     $scope.RefreshIndicator.style.marginTop = '0px';
                     $scope.RefreshIndicator.style.opacity = 0;
                     $scope.Refreshing = false;
                     $scope.RefreshCompleted = false;
                     $scope.$apply();
                }, 500);
        }

        $scope.InitialiseSearchCriteria = function() {

            serviceApplication.LoadShow('Intialising...');
            serviceReporting.InitialiseSearchCriteria($scope.PageSize, 0)
                .then(
                    function(result) 
                    {
                        serviceApplication.LoadHide();
                        $scope.SearchCriteria = result;
                        $scope.SearchCriteria.OrderByFieldName = 'Activity_Date_Time__c';        
                        
                        if(typeof serviceParameters.TellerParams.BranchNumber != 'undefined' && serviceParameters.TellerParams.BranchNumber != '')
                            $scope.SearchCriteria.Branch_Number = serviceParameters.TellerParams.BranchNumber;
                        
                        var nowDate = new Date().getDate() + '/';
                        var nowMonth = (new Date().getMonth() +1);
                        if(nowMonth.toString().length == 1)
                            nowDate += '0';
                        nowDate += (new Date().getMonth() +1) + '/' + new Date().getFullYear();

                        $scope.SearchCriteria.From_Activity_Date_Time = nowDate + ' 00:00';
                        $scope.SearchCriteria.To_Activity_Date_Time = nowDate + ' 23:59';
                        $scope.SearchCriteria.Status = 'Complete';

                        $scope.InitialiseFilterLists();
                    },
                    function(error) {
                        alert(error.message);
                        serviceApplication.LoadHide();
                    }
            );
        }

         $scope.InitialiseFilterLists = function() {

            serviceApplication.LoadShow('Intialise filter lists...');
            serviceReporting.InitialiseFilterLists()
                .then(
                    function(result) 
                    {
                        serviceApplication.ParseHTMLList(result.TransactionTypes, ['Name']);                        
                        serviceApplication.ParseHTMLList(result.Branches, ['Name']); 
                        serviceApplication.ParseHTMLList(result.Tellers, ['Name']); 
                        serviceApplication.ParseHTMLList(result.Tills, ['Name']); 
                        serviceApplication.ParseHTMLList(result.Status);
                        serviceApplication.ParseHTMLList(result.Currencies);

                        $scope.FilterLists = result;
                        serviceApplication.LoadHide();     
                        $scope.InitialiseKendoEvents();   
                        $scope.GetTellerActivityAudit();                    
                    },
                    function(error) {
                        alert(error.message);
                        serviceApplication.LoadHide();
                    }
            );
        }

        $scope.InitialiseSortBy = function()
        {
            var sortByElement = angular.element(document.getElementsByClassName('kendoInputSortBy')[0]);
            var highlight = angular.element(sortByElement.parent().children()[4]);
            highlight.addClass('md_label_active');
        }

        $scope.SetupKendoInputEvents = function(kendoInputName, isDateTime)
        {
            var kendoInput = angular.element(document.getElementsByClassName(kendoInputName)[1]);
            kendoInput.on('focus', $scope.OnKendoInputFocus);            
            kendoInput.on('blur', $scope.OnKendoInputBlur);

            if(isDateTime)
                kendoInput.data('kendoDateTimePicker').bind('change', $scope.OnKendoDateTimeChanged);
        }

        $scope.InitialiseKendoEvents = function() {
            $scope.SetupKendoInputEvents('kendoInputUser', false);
            $scope.SetupKendoInputEvents('kendoInputBranch', false);
            $scope.SetupKendoInputEvents('kendoInputTill', false);
            $scope.SetupKendoInputEvents('kendoInputCurrency', false);
            $scope.SetupKendoInputEvents('kendoInputStatus', false);
            $scope.SetupKendoInputEvents('kendoInputActivityType', false);
            $scope.SetupKendoInputEvents('kendoInputTransactionType', false);
            $scope.SetupKendoInputEvents('kendoInputSortBy', false);
            $scope.SetupKendoInputEvents('kendoInputToDateTime', true);
            $scope.SetupKendoInputEvents('kendoInputFromDateTime', true);   
            $scope.SetupKendoInputEvents('kendoInputNoticeWithdrawalType', false);       
        }

        $scope.OnKendoInputFocus = function(e) {
            var highlight = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('md_label')[0]);
            highlight.addClass('md_label_active');
            var bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-combobox')[0]);
            if(bar.length == 0)
            {
                bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-datetimepicker')[0]);                 
            }
            bar.addClass('kendo-focused');
        }

        $scope.OnKendoInputBlur = function(e) {
            if (e.currentTarget.value.length == 0) {
                var highlight = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('md_label')[0]);
                highlight.removeClass('md_label_active');
            }
            var bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-combobox')[0]);
            if(bar.length == 0)
            {
                bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-datetimepicker')[0]);                 
            }
            bar.removeClass('kendo-focused');
        }

        $scope.OnKendoDateTimeChanged = function(e)
        {
            var kendoInput = angular.element(e.sender.element);
            var label = angular.element(kendoInput.parent().parent().parent().children()[4]);
            label.addClass('md_label_active');
        }

        $scope.OnSortClicked = function()
        {
            if($scope.SearchCriteria.OrderDescending == true)
            {
                $scope.SearchCriteria.OrderDescending = false;
            }
            else
            {
                $scope.SearchCriteria.OrderDescending = true;
            }
        }

        $scope.GetTellerActivityAudit = function()
        {
            serviceApplication.LoadShow('Getting Teller Activity');
            $scope.SearchCriteria.PageSize = $scope.PageSize;
            $scope.SearchCriteria.PageOffset = 0;
            $scope.ToggleFilterPane();
            serviceReporting.GetTellerActivityAudit($scope.SearchCriteria)
                .then(
                    function(result) {
                        serviceApplication.LoadHide();
                        $scope.TellerActivities = result;
                        if(result.length == $scope.PageSize)
                        {
                            $scope.TellerActivitiesAnyRemaining = true;
                        }
                        else
                        {
                            $scope.TellerActivitiesAnyRemaining = false;
                        }
                    },
                    function(error) {
                        alert(error.message);
                        serviceApplication.LoadHide();
                    }
            );
        }

        $scope.OpenActivity = function(object)
        {
            serviceParameters.ActivityParams.SelectedActivityReferenceId = object.Object_Id__c;
            serviceParameters.ActivityParams.SelectedActvityType = object.Activity_Type__c;
            serviceApplication.ModalShow('Activity Details', 'Activity');
        }

        $scope.SetKendoComboBox = function(kendoInputName, value)
        {
            var kendoInput = angular.element(document.getElementsByClassName(kendoInputName)[1]);
            kendoInput.val(value);
        }

        $scope.ClearKendoComboBox = function(kendoInputName)
        {
            var kendoInput = angular.element(document.getElementsByClassName(kendoInputName)[1]);
            kendoInput.val("");
            var label = angular.element(kendoInput.parent().parent().parent().children()[4]);
            label.removeClass('md_label_active');
        }

        $scope.ActivateKendoComboBox = function(kendoInputName)
        {
            var kendoInput = angular.element(document.getElementsByClassName(kendoInputName)[1]);
            var label = angular.element(kendoInput.parent().parent().parent().children()[4]);
            label.addClass('md_label_active');
        }

        $scope.ClearFilterAndSortOptions = function()
        {            
            $scope.SearchCriteria.Branch_Number = '';
            $scope.ClearKendoComboBox('kendoInputBranch');
          
            $scope.SearchCriteria.From_Activity_Amount = null;
            $scope.SearchCriteria.To_Activity_Amount = null;
            
            $scope.SearchCriteria.Activity_Currency = null;
            $scope.ClearKendoComboBox('kendoInputCurrency');
           
            $scope.SearchCriteria.Description = null;

            $scope.SearchCriteria.Status = null;
            $scope.ClearKendoComboBox('kendoInputStatus');
          
            $scope.SearchCriteria.Activity_Type = null;
            $scope.ClearKendoComboBox('kendoInputActivityType');
            
            $scope.SearchCriteria.Created_By_User_Id = null;
            $scope.ClearKendoComboBox('kendoInputUser');
            
            $scope.SearchCriteria.To_Activity_Date_Time = null;
            $scope.ClearKendoComboBox('kendoInputToDateTime');
           
            $scope.SearchCriteria.From_Activity_Date_Time = null;
            $scope.ClearKendoComboBox('kendoInputFromDateTime');
           
            $scope.SearchCriteria.Till_Name = null;
            $scope.ClearKendoComboBox('kendoInputTill');
           
            $scope.SearchCriteria.Credit_Account = null;
            $scope.SearchCriteria.Debit_Account = null;

            $scope.SearchCriteria.Transaction_Type = null;
            $scope.ClearKendoComboBox('kendoInputTransactionType');
        }

        $scope.GetNextPage = function()
        {
            serviceApplication.LoadShow('Getting Teller Activity');
            $scope.SearchCriteria.PageSize = $scope.PageSize;
            $scope.SearchCriteria.PageOffset += $scope.SearchCriteria.PageSize;
            serviceReporting.GetTellerActivityAudit($scope.SearchCriteria)
                .then(
                    function(result) {
                        serviceApplication.LoadHide();
                        if(result.length == $scope.PageSize)
                        {
                            $scope.TellerActivitiesAnyRemaining = true;
                        }
                        else
                        {
                            $scope.TellerActivitiesAnyRemaining = false;
                        }
                        $scope.TellerActivities = $scope.TellerActivities.concat(result);
                    },
                    function(error) {
                        alert(error.message);
                        serviceApplication.LoadHide();
                    }
            );

        }

        $scope.PrintTelllerActivityAuditForToday = function()
        {
            serviceApplication.LoadShow('Getting Teller Activity');

            serviceReporting.GetActivityAuditPrintTemplate()
                .then(
                    function(result) {
                        $scope.PrintTemplate = $("<p/>").html(result).text();
                        $scope.$apply();
                        serviceReporting.GetCurrentTellerActivityForToday()
                            .then(
                                function(result) {

                                    $scope.TellerName = serviceParameters.TellerParams.Name;
                                    $scope.NowDateTime = new Date();
                                    $scope.PrintData = result;
                                    $scope.$apply();
                                    serviceApplication.LoadHide();
                                    var elementToPrint = document.getElementById('printoutSection');
                                    serviceApplication.PrintHTML(elementToPrint.innerHTML);                                    
                                },
                                function(error) {
                                    alert(error.message);
                                    serviceApplication.LoadHide();
                                }
                        );
                    },
                    function(error) {
                        alert(error.message);
                        serviceApplication.LoadHide();
                    }
            );

        }

        $scope.PrintTelllerActivityAudit = function()
        {
            serviceApplication.LoadShow('Getting Teller Activity');

            serviceReporting.GetActivityAuditPrintTemplate()
                .then(
                    function(result) {
                        $scope.PrintTemplate = $("<p/>").html(result).text();
                        $scope.$apply();

                        var criteria = $scope.SearchCriteria;
                        criteria.PageSize = null;
                        criteria.PageOffset = null;
                        serviceReporting.GetTellerActivityAudit(criteria)
                            .then(
                                function(result) {

                                    $scope.TellerName = serviceParameters.TellerParams.Name;
                                    $scope.NowDateTime = new Date();
                                    $scope.PrintData = result;
                                    $scope.$apply();
                                    serviceApplication.LoadHide();
                                    var elementToPrint = document.getElementById('printoutSection');
                                    serviceApplication.PrintHTML(elementToPrint.innerHTML);                                    
                                },
                                function(error) {
                                    alert(error.message);
                                    serviceApplication.LoadHide();
                                }
                        );
                    },
                    function(error) {
                        alert(error.message);
                        serviceApplication.LoadHide();
                    }
            );

        }
        
        $scope.ToggleFilterPane = function()
        {
            $scope.ShowFilterPane = $scope.ShowFilterPane == false ? true : false;
            $scope.ShowResultsPane = $scope.ShowResultsPane == false ? true : false;
        }   
        
        $scope.ExecuteSearch = function(search)
        {
            $scope.SearchCriteria = angular.copy(search);
            $scope.GetTellerActivityAudit();            
        } 

        //Message Listener -----------------------------------------------------------------
        
        $scope.$on('breakpointChange', function(event, breakpoint, oldClass) {
            
            switch(breakpoint.class)
            {
                case 'xs':
                {
                    $scope.ShowFilterPane = false;
                    $scope.ShowResultsPane = true;
                    break;
                }   
                case 'sm':
                {
                    $scope.ShowFilterPane = true;
                    $scope.ShowResultsPane = true;
                    break;
                }
            }
        });        
        
        $scope.$on('ActivitiesRefresh', function(event, args)
        {
            $scope.GetTellerActivityAudit();
        });   
         
    }
]);
