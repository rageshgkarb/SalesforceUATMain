tellerApp.controller('controllerOnlineBanking', ['$scope', '$window', 'serviceCustomer', 'serviceApplication', 'serviceAccounts', 'serviceParameters',
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
            var kendoInput = angular.element( $scope.container.find('.kendoInputToDate')[1]);//LB was 0
            kendoInput.on('focus', $scope.OnKendoInputFocus);            
            kendoInput.on('blur', $scope.OnKendoInputBlur);
            var label = angular.element(kendoInput.parent().children()[4]);
            if($scope.DateTo.length > 0)
            {
                label.addClass('md_label_active');
            }

            kendoInput = angular.element( $scope.container.find('.kendoInputFromDate')[1]);
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
			
			if(!$scope.Transactions) return;
			
			
			var items = $scope.Transactions;		
			if(!$scope.tranFilter && !$scope.tranFilterAmount) return items;
			
			var lst = [];
			
			
			
			for (var i = 0, len = items.length; i < len; i++) {
			  var tranItem = items[i];

			  
			  var add = true;
			  //var filter = filterItems[x];
			  var filterAmount = $scope.tranFilterAmount;
			  
			  tranItem.strAmount= tranItem.Amount.toFixed(2).toString();
			  
			  
			  
			  
			  if(filterAmount){
				filterAmount = filterAmount.replace('£','');  
				filterAmount = filterAmount.replace(',','');
				  
				if(tranItem.strAmount.substring(0,tranItem.strAmount.length).indexOf(filterAmount) == -1 )
					add = false;
			  }
			  
			  //if($scope,tranFilter){
			//	  var filterItems = $scope.tranFilter.toLowerCase().split(',');
				  
				  
				  
			//  }		
			  
				
			  if($scope.tranFilter && add){						
				var filter = $scope.tranFilter.toLowerCase();		
				  //for(var x = 0; x < filterItems.length; x++){
					  if(tranItem.Memo.toLowerCase().indexOf(filter) == -1  
							&&  tranItem.PayAccountNo.toLowerCase().indexOf(filter) == -1 
							&&  tranItem.PayBranchNo.toLowerCase().indexOf(filter) == -1 
							&&  tranItem.PayeeName.toLowerCase().indexOf(filter) == -1 
							&&  tranItem.PayeeRef.toLowerCase().indexOf(filter) == -1
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

        $scope.GetOnlineBankingPayments = function() {
            if($scope.FilterOpen)
            {
                $scope.FilterOpen = false;
                $window.onclick = null;
            }
            $scope.Loading = true;
            //$scope.$apply();
            serviceCustomer.GetIFMTransactions($scope.AccountId, $scope.DateFrom, $scope.DateTo)
                .then(
                    function(result) {
                        $scope.Transactions = result.Data;
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

        $scope.$on('RefreshOnlineBankingPayments', function()
        {
            $scope.GetOnlineBankingPayments();
        });
    }
 ]);