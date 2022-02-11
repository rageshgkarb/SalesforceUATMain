caaApp.controller('controllerSelfCertification', ['$scope',  '$window', 'serviceApplicantDetails', '$interval', 'serviceParameters', 'serviceApplication',
    function ($scope, $window, serviceApplicantDetails, $interval, serviceParameters, serviceApplication) {
        $scope.SaveErrors = 0;
        $scope.NewAccountData = {
            'DOB': {}
        };
        $scope.$watch('EventLogId', function () {
            serviceApplication.LoadShow('Fetching customer data');
            serviceApplicantDetails.GetApplicantData($scope.EventLogId, $scope.SessionId)
                .then(
                    function (result) {

                        $scope.Data = result.Data;
						//console.log(JSON.stringify($scope.Data));

                        if (result.URL) {
                            $window.location.href = result.URL.FormatURL();
                            return;
                        }

                        for (var i = 0; i < $scope.Data.CountriesOfBirth.length; i++) {
                            $scope.Data.CountriesOfBirth[i].Value = $scope.Data.CountriesOfBirth[i].Value.replace("&#39;", "'");
                            $scope.Data.CountriesOfBirth[i].Value = $scope.Data.CountriesOfBirth[i].Value.replace("&amp;", "&");
                            $scope.Data.CountriesOfBirth[i].Key = $scope.Data.CountriesOfBirth[i].Key.replace("&#39;", "'");
                            $scope.Data.CountriesOfBirth[i].Key = $scope.Data.CountriesOfBirth[i].Key.replace("&amp;", "&");
                        }

                        for (var i = 0; i < $scope.Data.Nationality.length; i++) {
                            $scope.Data.Nationality[i].Value = $scope.Data.Nationality[i].Value.replace("&#39;", "'");
                            $scope.Data.Nationality[i].Value = $scope.Data.Nationality[i].Value.replace("&amp;", "&");
                            $scope.Data.Nationality[i].Key = $scope.Data.Nationality[i].Key.replace("&#39;", "'");
                            $scope.Data.Nationality[i].Key = $scope.Data.Nationality[i].Key.replace("&amp;", "&");
                        }

                        serviceApplication.LoadHide(false);
                    },
                    function (error) {
                        serviceApplication.LoadHide(false);
                    }
                );
        });

        function endsWith(str, suffix) {
            return str.indexOf(suffix, str.length - suffix.length) !== -1;
        }

		$scope.consoleLog= function(str){
			console.log(str);
		};

		$scope.initTinCount = function(index)
		{
			var tinCount = $scope.Data.Applicants[index].TIN_5_Check_c ? 5 
			: $scope.Data.Applicants[index].TIN_4_Check_c ? 4
			: $scope.Data.Applicants[index].TIN_3_Check_c ? 3
			: $scope.Data.Applicants[index].TIN_2_Check_c ? 2 : 1;
			 return tinCount; 
		}

		$scope.checkTin = function(tinCheck,index)
		{
			switch(tinCheck)
			{
				case 1:

					if($scope.Data.Applicants[index].TIN_1_Check_c=='Yes' || $scope.Data.Applicants[index].TIN_1_Check_c=='No')
					{
						return true;
					}
				break;
				case 2:

					if($scope.Data.Applicants[index].TIN_2_Check_c=='Yes' || $scope.Data.Applicants[index].TIN_2_Check_c=='No')
					{
						return true;
					}
				break;
				case 3:

					if($scope.Data.Applicants[index].TIN_3_Check_c=='Yes' || $scope.Data.Applicants[index].TIN_3_Check_c=='No')
					{
						return true;
					}
				break;
				case 4:

					if($scope.Data.Applicants[index].TIN_4_Check_c=='Yes' || $scope.Data.Applicants[index].TIN_4_Check_c=='No')
					{
						return true;
					}
				break;
				case 5:
						return false;
				break;

			}
			

			return false;
		};

		$scope.removeTin = function(tin,index)
		{
			switch(tin)
			{
				case 2:
					$scope.Data.Applicants[index].TIN_2_Check_c='';
					$scope.Data.Applicants[index].TIN_2_c='';
					$scope.Data.Applicants[index].TIN2_Country_Tax_Residence_c='';
					$scope.Data.Applicants[index].TIN_2_reason_code_c='';
					$scope.Data.Applicants[index].TIN_2_reason_B_explanation_c='';

				break;
				case 3:
					$scope.Data.Applicants[index].TIN_3_Check_c='';
					$scope.Data.Applicants[index].TIN_3_c='';
					$scope.Data.Applicants[index].TIN3_Country_Tax_Residence_c='';
					$scope.Data.Applicants[index].TIN_3_reason_code_c='';
					$scope.Data.Applicants[index].TIN_3_reason_B_explanation_c='';

				break;
				case 4:
					$scope.Data.Applicants[index].TIN_4_Check_c='';
					$scope.Data.Applicants[index].TIN_4_c='';
					$scope.Data.Applicants[index].TIN4_Country_Tax_Residence_c='';
					$scope.Data.Applicants[index].TIN_4_reason_code_c='';
					$scope.Data.Applicants[index].TIN_4_reason_B_explanation_c='';

				break;
				case 5:
					$scope.Data.Applicants[index].TIN_5_Check_c='';
					$scope.Data.Applicants[index].TIN_5_c='';
					$scope.Data.Applicants[index].TIN5_Country_Tax_Residence_c='';
					$scope.Data.Applicants[index].TIN_5_reason_code_c='';
					$scope.Data.Applicants[index].TIN_5_reason_B_explanation_c='';

				break;

			}
			
		}

        $scope.ShowErrors = function () {

            if (!$scope.Data || !$scope.Data.Applicants) return;
            var show = false;
            //$scope.ValidApplicants = {};
            for (var i = 0; i < $scope.Data.Applicants.length; i++) {
                var valid = true;
                for (var property in $scope.myform.$error) {

                    var err = $scope.myform.$error[property];

                    for (var field in err) {
                        if (field === 'remove') break;
                        var ff = err[field];

                        var g = ff.$name;

                        if (endsWith(g, i)) {

                            valid = false;
                            break;
                        }
                    }
                    if (valid == false) break;
                }

                $scope.Data.Applicants[i].Valid = valid;
                if (!valid) show = true;
            }
            return show;
        }

        var timer = $interval(function () {

            $scope.AutoSave = true;

            $scope.SaveData();

        }, 15000);

        $scope.killtimer = function () {
            if (angular.isDefined(timer)) {
                $interval.cancel(timer);
                timer = undefined;
            }
        };


        $scope.ValidationClick = function (index, field) {
            var panel = '#collapse' + index;

            $(panel).collapse('show');

            var fieldVal = '#' + field + index;

            setTimeout(function () {
                $(fieldVal).focus();
            }, 300)

        }


        $scope.DOBCheck = function (index) {
            var dob = $scope.Data.Applicants[index].Date_of_birth_c;
            if (!dob) return;

            var m = parseInt(dob.Month, 10);
            var d = parseInt(dob.Day, 10);
            var y = parseInt(dob.Year, 10);
            var date = new Date(y, m - 1, d);

            var ypsaDate = new Date();
            ypsaDate.setFullYear(ypsaDate.getFullYear() - 16);

            if (date.getFullYear() == y && date.getMonth() + 1 == m && date.getDate() == d) {
                if ($scope.YPSA) {
                    if (index == 0) {
                        if (date < ypsaDate) return 'tooold';
                    } else {
                        if (date > ypsaDate) return 'tooyoung';
                    }
                } else {
                    if (date > ypsaDate) return 'tooyoung';
                }
            }
            return '';
        }

        $scope.openUSHelp = function(size){
            $scope.showUsHelp = !$scope.showUsHelp;

        }

        // $scope.AddExistingApplicant = function (id) {
        //     var item = {
        //         Id: id
        //     };
        //     $scope.AddApplicant(item);
        // }


        $scope.HideComplete = function () {
            if (!$scope.Data || !$scope.Data.Applicants) return false;

            for (var i = 0; i < $scope.Data.Applicants.length; i++) {
                if ($scope.Data.Applicants[i].Correct == 'No') return true;
            }
            return false;
        }

        $scope.Complete = function () {

            if (!$scope.myform.$valid) return;

            for (var i = 0; i < $scope.Data.Applicants.length; i++) {
                if ($scope.DOBCheck(i)) return;

                if (!$scope.Data.Applicants[i].FirstName) return;
                if (!$scope.Data.Applicants[i].LastName) return;
				
				/* START: Remove any unwanted answers before saving */
				if($scope.Data.Applicants[i].TIN_1_Check_c)
				{
					if($scope.Data.Applicants[i].TIN_1_Check_c=='Yes')
					{
						$scope.Data.Applicants[i].TIN_1_reason_code_c='';
						$scope.Data.Applicants[i].TIN_1_reason_B_explanation_c='';
					}
					else
					{
						$scope.Data.Applicants[i].TIN_1_c='';
					}
				}

				if($scope.Data.Applicants[i].TIN_2_Check_c)
				{
					if($scope.Data.Applicants[i].TIN_2_Check_c=='Yes')
					{
						$scope.Data.Applicants[i].TIN_2_reason_code_c='';
						$scope.Data.Applicants[i].TIN_2_reason_B_explanation_c='';
					}
					else
					{
						$scope.Data.Applicants[i].TIN_2_c='';
					}
				}

				if($scope.Data.Applicants[i].TIN_3_Check_c)
				{
					if($scope.Data.Applicants[i].TIN_3_Check_c=='Yes')
					{
						$scope.Data.Applicants[i].TIN_3_reason_code_c='';
						$scope.Data.Applicants[i].TIN_3_reason_B_explanation_c='';
					}
					else
					{
						$scope.Data.Applicants[i].TIN_3_c='';
					}
				}

				if($scope.Data.Applicants[i].TIN_4_Check_c)
				{
					if($scope.Data.Applicants[i].TIN_4_Check_c=='Yes')
					{
						$scope.Data.Applicants[i].TIN_4_reason_code_c='';
						$scope.Data.Applicants[i].TIN_4_reason_B_explanation_c='';
					}
					else
					{
						$scope.Data.Applicants[i].TIN_4_c='';
					}
				}

				if($scope.Data.Applicants[i].TIN_5_Check_c)
				{	
					if( $scope.Data.Applicants[i].TIN_5_Check_c=='Yes')
					{
						$scope.Data.Applicants[i].TIN_5_reason_code_c='';
						$scope.Data.Applicants[i].TIN_5_reason_B_explanation_c='';
					}
					else
					{
						$scope.Data.Applicants[i].TIN_5_c='';
					}
				}
				/* END: Remove any unwanted answers before saving */
            }

            if ($scope.YPSA && $scope.Data.Applicants.length < 2) return;

            var data = {
                'Applicants': angular.copy($scope.Data.Applicants),
                'EventLogId': $scope.EventLogId,
                'Campaign': $scope.Data.Campaign,
                'PaperStatements': $scope.Data.PaperStatements
            }
            serviceApplication.LoadShow('Saving...');
            serviceApplicantDetails.CompleteEvent(data, $scope.SessionId)
                .then(
                    function (result) {

                        if (result.Success) {
                            if (result.URL) {
                                $window.location.href = result.URL.FormatURL();
                                return;
                            }

                            $scope.Duplicates = result.HasDuplicates;
                        }

                        serviceApplication.LoadHide(false);
                    },
                    function (error) {
                        serviceApplication.LoadHide(false);
                    }
                );
        }

        // $scope.CompleteOverride = function () {

        //     for (var i = 0; i < $scope.Data.Applicants.length; i++) {
        //         if ($scope.DOBCheck(i)) return;

        //         if (!$scope.Data.Applicants[i].FirstName) return;
        //         if (!$scope.Data.Applicants[i].LastName) return;
        //     }


        //     var data = {
        //         'Applicants': angular.copy($scope.Data.Applicants),
        //         'EventLogId': $scope.EventLogId,
        //         'Campaign': $scope.Campaign,
        //         'PaperStatements': $scope.Data.PaperStatements
        //     }
        //     serviceApplication.LoadShow('Saving...');
        //     serviceApplicantDetails.CompleteEventOverride(data, $scope.SessionId)
        //         .then(
        //             function (result) {

        //                 if (result.Success) {
        //                     if (result.URL) {
        //                         $window.location.href = result.URL.FormatURL();
        //                         return;
        //                     }

        //                     $scope.Duplicates = result.HasDuplicates;
        //                 }

        //                 serviceApplication.LoadHide(false);
        //             },
        //             function (error) {
        //                 serviceApplication.LoadHide(false);
        //             }
        //         );
        // }

        // $scope.ShowPrevAddress = function (address1, dob) {
        //     if (!address1 || !address1.Day || !address1.Month || !address1.Year || address1.Day == 0 || address1.Month == 0 || address1.Year == 0)
        //         return false;
        //     /*  
        //     if(!IsValidDate(address1.Day,address1.Month,address1.Year) )        
        //         return false;    
        //     */
        //     var m = parseInt(address1.Month, 10);
        //     var d = parseInt(address1.Day, 10);
        //     var y = parseInt(address1.Year, 10);

        //     var date = new Date(y, m - 1, d);

        //     var valid = Date.validateDay(d, y, m - 1);
        //     if (!valid) return false;

        //     var today = new Date().addYears(-3);

        //     var dobDate = new Date().addYears(-3);
        //     if (dob && dob.Day && dob.Month && dob.Year) {
        //         var dm = parseInt(dob.Month, 10);
        //         var dd = parseInt(dob.Day, 10);
        //         var dy = parseInt(dob.Year, 10);
        //         dobDate = new Date(dy, dm - 1, dd);

        //         if (dobDate > today)
        //             today = dobDate;
        //     }
        //     return date > today;
        // }

        // $scope.AddApplicant = function (item) {
        //     //var data = {'Applicants' : angular.copy($scope.Data.Applicants)  , 'EventLogId' : $scope.EventLogId }
        //     //data.AddApplicantId = item.Id;
        //     $scope.ApplicantErrorAlertText = null;
        //     serviceApplication.LoadShow('Adding applicant ' + item.Name);
        //     serviceApplicantDetails.AddApplicant(item.Id, $scope.EventLogId)
        //         .then(
        //             function (result) {
        //                 serviceApplication.LoadHide(false);
        //                 if (result.Success) {
        //                     $scope.Data.Applicants.push(result.Account);
        //                     $('#NewCusModal').modal('hide');

        //                 } else {
        //                     $scope.ApplicantErrorAlertText = result.Error;
        //                 }
        //             },
        //             function (error) {
        //                 $scope.ApplicantErrorAlertText = error.message;
        //                 serviceApplication.LoadHide(false);
        //             }
        //         );

        // }

        $scope.SaveData = function (item) {
            $scope.ErrorAlertText = null;
            if ($scope.Data == null || $scope.Data.Applicants == null) return;

            var data = {
                'Applicants': angular.copy($scope.Data.Applicants),
                'EventLogId': $scope.EventLogId,
                'Campaign': $scope.Campaign,
                'PaperStatements': $scope.Data.PaperStatements
            }

            for (var i = 0; i < data.Applicants.length; i++) {

                if (!data.Applicants[i].FirstName) data.Applicants[i].FirstName = 'New';
                if (!data.Applicants[i].LastName) data.Applicants[i].LastName = 'Account';
            }


            serviceApplicantDetails.SaveData(data, $scope.SessionId)
                .then(
                    function (result) {

                        if (result.Success) {
                            $scope.SaveErrors = 0;
                            $scope.SuccessAlertText = 'Data saved.';
                            $scope.ShowSuccessAlert = true;
                            window.setTimeout(function () {
                                $scope.ShowSuccessAlert = false;
                                $scope.$apply();
                            }, 4000);
                        } else {
                            $scope.ErrorAlertText = result.Error;
                            $scope.SaveErrors += 1;
                            if ($scope.SaveErrors == 3) {
                                $scope.killtimer();
                            }
                        }
                        $scope.AutoSave = false;
                    },
                    function (error) {
                        $scope.SaveErrors += 1;
                        $scope.AutoSave = false;

                        if ($scope.SaveErrors == 3) {
                            $scope.killtimer();
                        }
                    }
                );
        }


        /*
        $scope.ValiationShow = function(item, index){
            
            //var class= '';
            var fieldname = item + index ;
            var field = myform[fieldname];
            
            if(!myform[fieldname].$pristine && myform[fieldname].$invalid)
                return 'has-error'; 
            
            
            
            //return "'has-error': !myform.email{{index+1}}.$pristine && myform.email{{$index+1}}.$invalid";
        }
        */

        // $scope.RemoveApplicant = function (item) {
        //     serviceApplication.LoadShow('Removing applicant :' + item.FirstName + ' ' + item.LastName);
        //     serviceApplicantDetails.RemoveApplicant(item.Id, $scope.EventLogId)
        //         .then(
        //             function (result) {
        //                 serviceApplication.LoadHide(false);
        //                 if (result.Success) {
        //                     $scope.Data.Applicants.splice($scope.Data.Applicants.indexOf(item), 1)

        //                 } else {

        //                 }
        //             },
        //             function (error) {
        //                 serviceApplication.LoadHide(false);
        //             }
        //         );
        // }


        $scope.FindExistingAccounts = function () {
            if (!$scope.SearchValue || !$scope.EventLogId) return;
            serviceApplicantDetails.FindExistingAccounts($scope.SearchValue, $scope.EventLogId)
                .then(
                    function (result) {
                        if (result.Success) {
                            if (result.ExistingAccounts) {
                                $scope.FoundAccounts = result.ExistingAccounts;
                                $('#FindModal').modal();
                            }
                        } else {
                            $scope.FindError = result.Error;
                        }
                    },
                    function (error) {

                    }
                );
        }

        $scope.$on('ngRepeatFinished', function (ngRepeatFinishedEvent) {
            var f = $('#collapse0');
            f.collapse('show');
            $('[data-toggle="popover"]').popover();
            var options = {
                key: $scope.PCA_key
            }
            $scope.controls = [];

            for (var a = 0; a < 4; a++) {
                for (var i = 0; i < 3; i++) {
                    var fields = [{
                            element: "line1" + a + i,
                            field: "Line1"
                        },
                        {
                            element: "line2" + a + i,
                            field: "Line2",
                            mode: pca.fieldMode.POPULATE
                        },
                        {
                            element: "city" + a + i,
                            field: "City",
                            mode: pca.fieldMode.POPULATE
                        },
                        {
                            element: "county" + a + i,
                            field: "ProvinceName",
                            mode: pca.fieldMode.POPULATE
                        },
                        {
                            element: "postcode" + a + i,
                            field: "PostalCode"
                        },
                        {
                            element: "country" + a + i,
                            field: "CountryName",
                            mode: pca.fieldMode.COUNTRY
                        }
                    ];
                }
            }
        });

        $scope.InsideEU = function (app) {
            if (!app || !app.Country_of_nationality_c || !$scope.Data.Nationality) return null;

            for (var i = 0; i < $scope.Data.Nationality.length; i++) {
                var item = $scope.Data.Nationality[i];
                if (item.Key == app.Country_of_nationality_c) {
                    return item.IsEU;
                }
            }
            return null;
        }

        // $scope.SearchOpen = false;
        // $scope.SearchCriteria = '';
        // $scope.SearchResults = [];
        // $scope.SearchButtonPressed = false;
        // $scope.RecentCustomers = [];
        // $scope.HideAutoComplete = false;

        // $scope.SearchTemplate = '<span style="float:left; margin-top: 4px; margin-bottom: 3px;"><img style="box-shadow: 0 0 3px black; border-radius: 50%; height:55px; width:55px;" src="#:data.ImageURL#" onError="this.onerror=null; this.src=\'' + serviceParameters.ApplicationParams.ResourcePath + '/Teller_Includes/media/user_error.png\';"></span>' +
        //     '<div style="overflow: hidden;"><label style="line-height: 1em !important; font-size: 17px; font-family: simpleBold; margin-top: 4px; margin-left: 10px; margin-bottom: 0px; font-weight: normal;">#: data.Name #</label><span style="font-weight: normal; margin-left: 3px; font-size: 17px;">(#: EBSId #)</span><div style="padding-left: 10px; margin-bottom: 4px; font-weight: normal; overflow: hidden; height: 27px; margin-top: -8px; font-size: 14px; line-height: 1em !important;">#: data.Address #</div></div>';

        // $scope.SearchDataSource = new kendo.data.DataSource({
        //     schema: {
        //         data: "Items"
        //     },
        //     serverFiltering: true,
        //     serverPaging: true,
        //     transport: {
        //         read: function (options) {
        //             serviceApplicantDetails.FindCustomer($scope.SearchCriteria)
        //                 .then(
        //                     function (result) {
        //                         options.success(result);

        //                         if (!$scope.$$phase) {
        //                             $scope.$apply();
        //                         }
        //                     },
        //                     function (error) {
        //                         alert(error.message);

        //                     }
        //                 );
        //         }
        //     }

        // });

        // $scope.FindCustomer = function () {
        //     $scope.HideAutoComplete = true;
        //     serviceApplication.LoadShow('Searching for customer: ' + $scope.SearchCriteria);
        //     $scope.SearchButtonPressed = true;
        //     serviceApplicantDetails.FindCustomer($scope.SearchCriteria)
        //         .then(
        //             function (result) {

        //                 $scope.SearchResults = result.Items;
        //                 if (!$scope.$$phase) {
        //                     $scope.$apply();
        //                 }
        //                 serviceApplication.LoadHide(false);
        //             },
        //             function (error) {
        //                 alert(error.message);
        //                 serviceApplication.LoadHide(false);
        //             }
        //         );
        // }

        // $scope.SearchAutoCompleteOptions = {
        //     dataSource: $scope.SearchDataSource,
        //     dataTextField: 'Name',
        //     dataValueField: 'data',
        //     placeholder: "Name, Postcode, Account Number, EBS Id ...",
        //     delay: 500,
        //     template: $scope.SearchTemplate,
        //     select: function (args) {
        //         var dataItem = this.dataItem(args.item.index());
        //         $scope.AddApplicant(dataItem);
        //         $scope.SearchCriteria = '';
        //         serviceParameters.CustomerSearchParams.SearchCriteria = ''
        //     }
        // }

        $scope.Initialise = function () {
            serviceParameters.CustomerParams.Initialise();
            $scope.RecentCustomers = serviceParameters.CustomerSearchParams.GetRecentCustomers();
            if (serviceParameters.CustomerSearchParams.SearchCriteria != '') {
                $scope.SearchCriteria = serviceParameters.CustomerSearchParams.SearchCriteria;
                serviceParameters.CustomerSearchParams.SearchCriteria = '';
                $scope.FindCustomer();
            }
        }

        $scope.InitialiseSearchBar = function () {
            $scope.searchOpen = true;
        }

        $scope.autoCompleteOpen = function (event) {
            if ($scope.HideAutoComplete == true) {
                $scope.HideAutoComplete = false;
                event.preventDefault();
            }
        }

        $scope.CheckExistingCustomer = function (override) {
            $scope.AddError = '';
            serviceApplication.LoadShow('Searching for existing customer');
            serviceApplicantDetails.CheckIsExistingAccount($scope.NewAccountData, $scope.EventLogId, override)
                .then(
                    function (result) {
                        serviceApplication.LoadHide(false);
                        if (result.Success) {
                            if (result.Account) {
                                $scope.Data.Applicants.push(result.Account);
                                $('#NewCusModal').modal('hide');


                            } else {
                                $scope.ExistingAccounts = result.ExistingAccounts;
                                //alert($scope.ExistingAccounts);
                                /*$('#myModal').modal();*/

                            }
                            //$scope.apply();

                            //add new account to the array
                            //var newAccount = {LastName:$scope.NewAccountData.Lastname};

                            //$scope.Data.Applicants.push(newAccount);
                        } else {
                            $scope.IsExistingCustomer = true;
                            $scope.AddError = result.Error;

                        }
                    },
                    function (error) {
                        serviceApplication.LoadHide(false);
                    }
                );
        }
    }
]);


