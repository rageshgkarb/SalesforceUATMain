tellerApp.controller('controllerTransactionHistory', ['$scope', '$window', 'serviceCustomer', 'serviceApplication', 'serviceAccounts', 'serviceParameters',
    function ($scope, $window, serviceCustomer, serviceApplication, serviceAccounts, serviceParameters) 
    {
        $scope.AccountId = null;
        $scope.CustomerName = null;
        $scope.FilterOpen = false;
        $scope.Filtered = false;
        $scope.container = null;

        $scope.DateTo = null;
        $scope.DateFrom = null;
        $scope.Transactions = null;
        $scope.Loading = false;

        $scope.PrintTemplate = '';
        $scope.TellerName = '';
        $scope.NowDateTime = '';
        $scope.Branch = serviceParameters.TellerParams.Branch;

     //    $scope.gridDataSource = new kendo.data.DataSource({
     //        serverFiltering: true,
     //        schema: {
     //            model: {
     //                fields: {
     //                    itemPostingDate: {
     //                        type: "string"
     //                    },
     //                    itemDesc: {
     //                        type: "string"
     //                    },
     //                    itemRunningBalance: {
     //                        type: "number"
     //                    }
     //                }
     //            }

     //        },
     //        transport: {
     //            read: function(options) {

     //                if ($scope.AccountId != null) {
     //                    var fromDate = '';
     //                    var toDate = '';
     //                    if (options != null && options.data.filter != null) {
     //                        fromDate = options.data.filter.filters[0].value;
     //                        toDate = options.data.filter.filters[1].value;
     //                    }

     //                    if (fromDate == '' && toDate == '') {
     //                        var currentDate = new Date();
     //                        toDate = currentDate.getDate() + "/" + currentDate.getMonth() + "/" + currentDate.getFullYear();
     //                        currentDate.setMonth(currentDate.getMonth() - 3);
     //                        fromDate = currentDate.getDate() + "/" + currentDate.getMonth() + "/" + currentDate.getFullYear();
     //                    }

     //                    serviceCustomer.GetTransactionHistory($scope.AccountId, fromDate, toDate)
     //                        .then(
     //                            function(result) {
     //                                options.success(result);
     //                                if (!$scope.$$phase) {
     //                                    $scope.$apply();
     //                                }
     //                            },
     //                            function(error) {
     //                                alert(error.message);
     //                            }
     //                    );
     //                }
     //                else {
     //                 options.success(null);
     //                    if (!$scope.$$phase) {
     //                     $scope.$apply();
     //                    }
     //                }
     //            }
     //        }
     //    });

        // $scope.mainGridOptions = {
        //  autoBind: false,
  //           dataSource: $scope.gridDataSource,
  //           sortable: true,   
  //           filterable: 
  //           {
  //               operators: {
  //                   string: {
  //                               startswith: "From",
  //                               endswith: "To"
  //                           }
  //               }
  //           },        
  //           columns: [
  //            {
  //               field: "itemPostingDate",
  //               title: "Date",
  //               width: "100px",
  //               format: "{0:dd/MM/yyyy HH:mm tt}",
  //               filterable: {
  //                               ui: "datetimepicker"
  //                           },
  //               sortable: false
  //           },
  //           {
  //               field: "itemDesc",
  //               title: "Description",
  //               filterable : false,
  //               sortable: false

  //           },
  //           {
  //               field: "itemRunningBalance",
  //               title: "Value",
  //               format: "{0:c}",
  //               width: "150px",
  //               filterable : false,
  //               sortable: false
  //           }]
  //       };

        $scope.kendofilterInit = function(e)
        {
             var beginOperator = e.container.find("[data-role=dropdownlist]:eq(0)").data("kendoDropDownList");
            beginOperator.value("startswith");
            beginOperator.trigger("change");

            var endOperator = e.container.find("[data-role=dropdownlist]:eq(2)").data("kendoDropDownList");
            endOperator.value("endswith");
            endOperator.trigger("change");

            var logicalComp = e.container.find("[data-role=dropdownlist]:eq(1)").data("kendoDropDownList");
            logicalComp.element.parent().addClass('ng-hide');

            //e.container.on("click", "[type='submit']", function(e) { $scope.kendoFilterChanged(e); });
        }

        $scope.GetContainerClassName = function()
        {
            return $scope.AccountId + '_container';
        }

        $scope.Initialise = function(accountId, customerName)
        {
            $scope.AccountId = accountId;
            $scope.CustomerName = customerName;

            var today = new Date();
            $scope.DateTo = today.getDate() + '/' + (today.getMonth() + 1) + '/' + today.getFullYear();
            today.setMonth(today.getMonth() - 3);
            $scope.DateFrom = today.getDate() + '/' + (today.getMonth() + 1) + '/' + today.getFullYear();            
            $scope.Filtered = true;
        }

        $scope.InitialiseKendoInputs = function()
        {           
            $scope.container = angular.element(document.getElementsByClassName($scope.AccountId + '_container')[0]);
            //var popup = angular.element(container.find('.filterpopup')[0]);
            var kendoInput = angular.element( $scope.container.find('.kendoInputToDate')[0]);
            kendoInput.on('focus', $scope.OnKendoInputFocus);            
            kendoInput.on('blur', $scope.OnKendoInputBlur);
            var label = angular.element(kendoInput.parent().children()[4]);
            if($scope.DateTo.length > 0)
            {
                label.addClass('md_label_active');
            }

            kendoInput = angular.element( $scope.container.find('.kendoInputFromDate'));
            kendoInput.on('focus', $scope.OnKendoInputFocus);            
            kendoInput.on('blur', $scope.OnKendoInputBlur);
            label = angular.element(kendoInput.parent().children()[4]);
            if($scope.DateFrom.length > 0)
            {
                label.addClass('md_label_active');
            }
        }

        $scope.OnKendoInputFocus = function(e) {
            var highlight = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('md_label')[0]);
            highlight.addClass('md_label_active');
            var bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-datepicker')[0]);
            bar.addClass('kendo-focused');
        }

        $scope.OnKendoInputBlur = function(e) {
            if (e.currentTarget.value.length == 0) {
                var highlight = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('md_label')[0]);
                highlight.removeClass('md_label_active');
            }
            var bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-datepicker')[0]);
            bar.removeClass('kendo-focused');
        }

        $scope.OnKendoDateTimeChanged = function(e)
        {
            var kendoInput = angular.element(e.sender.element);
            var label = angular.element(kendoInput.parent().parent().parent().children()[4]);
            label.addClass('md_label_active');

            if(e.sender.element[0].className.indexOf('kendoInputToDate') > -1)
            {
                $scope.DateTo = e.sender._oldText;
            }

            if(e.sender.element[0].className.indexOf('kendoInputFromDate') > -1)
            {
                $scope.DateFrom = e.sender._oldText;
            }
        }

        $scope.ShowHideFilterPopup = function($event)
        {
            if($scope.FilterOpen)
            {
                $scope.FilterOpen = false;
                $window.onclick = null;
            }
            else
            {
                $scope.FilterOpen = true;
                $event.stopPropagation();
                $window.onclick = function(event)
                {
                    var location = ($scope.container.find('.filterpopup')[0]).getBoundingClientRect();
                    if(event.x > location.left && event.x < location.right && event.y > location.top && event.y < location.bottom)
                    {
                        //do nothing as click occured within filter popup
                    }
                    else
                    {
                        var close = true;
                        var calendars = document.getElementsByClassName('k-animation-container');
                        if(calendars.length > 0)
                        {
                            angular.forEach(calendars, function(calendar)
                            {
                                if(calendar.style.display != 'none')
                                {
                                    var clocation = calendar.getBoundingClientRect();
                                    if(event.x > clocation.left && event.x < clocation.right && event.y > clocation.top && event.y < clocation.bottom)
                                    {
                                        close = false;
                                    }
                                }                                
                            });

                        }

                        if(close)
                        {
                            $scope.FilterOpen = false;
                            $scope.$apply();
                            $window.onclick = null;
                        }
                    }
                }
            }
        }

        $scope.Print = function()
        {
            $scope.Loading = true;
            serviceAccounts.GetMiniStatementPrintTemplate()
            .then(
                    function(result) {
                        $scope.TellerName = serviceParameters.TellerParams.Name;
                        $scope.NowDateTime = new Date();
                        $scope.PrintTemplate = $("<p/>").html(result).text();
                        $scope.Loading = false;
                        
                        console.log($scope.$$phase);

                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }

                        $scope.$apply();
                        $scope.container = angular.element(document.getElementsByClassName($scope.AccountId + '_container')[0]);
                        var ministatement = $scope.container.find('.MiniStatement')[0];
                        serviceApplication.PrintHTML(ministatement.innerHTML);

                    },
                    function(error) {
                        alert(error.message);
                        $scope.Loading = false;
                    }
                );
        }

        $scope.OnClear = function()
        {
            $scope.DateTo = '';
            $scope.DateFrom = '';
            $scope.Filtered = false;

            var kendoInput = angular.element( $scope.container.find('.kendoInputToDate')[0]);
            var label = angular.element(kendoInput.parent().children()[4]);
            label.removeClass('md_label_active');

            kendoInput = angular.element( $scope.container.find('.kendoInputFromDate'));
            label = angular.element(kendoInput.parent().children()[4]);
            label.removeClass('md_label_active');
        }
		
		$scope.GetFilteredTransactions = function(){
			
			if(!$scope.Transactions || !$scope.Transactions.ResponseRoot || 
				!$scope.Transactions.ResponseRoot.transactionDetailsField) return;
			
			
			var items = $scope.Transactions.ResponseRoot.transactionDetailsField;			
			if(!$scope.tranFilter && !$scope.tranFilterAmount) return items;
			
			var lst = [];
			
			
			
			for (var i = 0, len = items.length; i < len; i++) {
			  var tranItem = items[i];

			  
			  var add = true;
			  //var filter = filterItems[x];
			  var filterAmount = $scope.tranFilterAmount;
			  
			  
			  
			  if(filterAmount){
				filterAmount = filterAmount.replace('£','');  
				filterAmount = filterAmount.replace(',','');
				  
				if(tranItem.MoneyInField.substring(0,tranItem.MoneyInField.length-4).indexOf(filterAmount) == -1 && tranItem.MoneyOutField.substring(0,tranItem.MoneyOutField.length-4).indexOf(filterAmount) == -1 )
					add = false;
			  }
			  
			  //if($scope,tranFilter){
			//	  var filterItems = $scope.tranFilter.toLowerCase().split(',');
				  
				  
				  
			//  }		
			  
				
			  if($scope.tranFilter && add){						
				var filter = $scope.tranFilter.toLowerCase();		
				  //for(var x = 0; x < filterItems.length; x++){
					  if(tranItem.NarrativeLine1Field.toLowerCase().indexOf(filter) == -1  
							&&  tranItem.NarrativeLine2Field.toLowerCase().indexOf(filter) == -1 
							&&  tranItem.NarrativeLine3Field.toLowerCase().indexOf(filter) == -1 
							&&  tranItem.NarrativeLine4Field.toLowerCase().indexOf(filter) == -1 
							&&  tranItem.TransactionReferenceField.toLowerCase().indexOf(filter) == -1
							){
						add = false;  		  
					}				  
				  //}
				}
			  
			  //all
			  if(add){
				  lst.push(tranItem);  
			  }
			  
			  
			  
			}
			
			return lst;
		}

        $scope.GetTransactionHistory = function() {
            if($scope.FilterOpen)
            {
                $scope.FilterOpen = false;
                $window.onclick = null;
            }
            $scope.Loading = true;
            //$scope.$apply();
            serviceCustomer.GetTransactionHistory($scope.AccountId, $scope.DateFrom, $scope.DateTo)
                .then(
                    function(result) {
                        $scope.Transactions = result;
                        $scope.Loading = false;
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                    function(error) {
                        alert(error.message);
                        $scope.Loading = false;
                    }
            );
        }

        //-- Listeners -----------------------------------------------------------

        $scope.$on('RefreshTransactionHistory', function()
        {
            $scope.GetTransactionHistory();
        });
    }
 ]);