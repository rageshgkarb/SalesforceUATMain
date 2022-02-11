caaApp.controller('controllerProductSelection', ['$scope', '$window', '$filter', 'serviceProductSelect', 'serviceApplication',
    function ($scope, $window, $filter, serviceProductSelect, serviceApplication) {
        $scope.ExistingCustomer = null;
		//C0756: Nature and purpose hide for current account in external CAA Starts
		$scope.IsExternalCAA = false;
		if(window.location.href.indexOf("islamic-bank") > -1){
			$scope.IsExternalCAA = true;
		}
		//C0756: Nature and purpose hide for current account in external CAA Ends
        $scope.Product = {
            ShowTransfer: true,
            ShowRegularPayment: true,
            Name: 'Some Product'
        };

        $scope.SelectErrors = [];
		//C0737 Start  
        $scope.UnCheckConsentNone = function(){ 
            $scope.consentNone = false; 
			if(!$scope.consentEmail && !$scope.consentMail && !$scope.consentPhone && !$scope.consentSMS && !$scope.consentNewsletter){ 
                $scope.IsMarketPrefSelected = false; 
            }else{ 
                $scope.IsMarketPrefSelected = true; 
            } 
        }; 
		//C0737 End  
        $scope.UncheckNaturePurpose = function(arg){
            if(arg != $scope.UncheckNaturePurposeVariable){
                if(arg == 'fixed' || arg == 'notice'){
                    $scope.Data.Receive_Salary_Benefits = false;
                }
            $scope.Data.Pay_Bills_Expenses = false;
            $scope.Data.Domestic_Transfers_In_Out = false;
            $scope.Data.International_Transfer_In_Out = false;
            }
            $scope.UncheckNaturePurposeVariable = arg;
        }


        $scope.ProductSelected = function () {
			//C0737 Start 
            if(!$scope.consentEmail && !$scope.consentMail && !$scope.consentPhone && !$scope.consentSMS && !$scope.consentNewsletter && !$scope.consentNone){                 
                $scope.IsMarketPrefSelected = false; 
                return; 
            }else{ 
                $scope.IsMarketPrefSelected = true; 
            } 
			//C0737 End  
            $scope.Data.ProductId = $scope.SelectedProduct.Id;
            $scope.ErrorMessage = null;

            if ($scope.Access == 'fixed')
                $scope.Data.HasRegularPayment = 'no';

            serviceApplication.LoadShow('Processing...');
            // C0697
            serviceProductSelect.SendProductSelected($scope.Data, $scope.SessionId, $scope.consentEmail, $scope.consentMail, $scope.consentPhone, $scope.consentSMS, $scope.consentNewsletter, $scope.consentNone)
                .then(
                    function (result) {
                        if (result.Success) {
                            $scope.URL = result.URL.FormatURL();
                            $window.location.href = $scope.URL.FormatURL();
                        } else {
                            $scope.ErrorMessage = result.Error;
                            serviceApplication.LoadHide(false);
                        }



                    },
                    function (error) {
                        serviceApplication.LoadHide(false);
                    }
                );

        };

		$scope.checkNoContact = function()
		{
			if($scope.consentNone)
			{
				$scope.IsMarketPrefSelected = true;//C0737  
				$scope.consentEmail = false;
				$scope.consentMail = false;
				$scope.consentPhone = false;
				$scope.consentSMS = false;
				$scope.consentNewsletter = false;
			}else{//C0737 Start 
                if(!$scope.consentEmail && !$scope.consentMail && !$scope.consentPhone && !$scope.consentSMS && !$scope.consentNewsletter){ 
                    $scope.IsMarketPrefSelected = false; 
                }else{ 
                    $scope.IsMarketPrefSelected = true; 
                } 
                //C0737 End 
            }  
		};

        $scope.ImageClassSM = function () {
            return ImageClass() + '-sm';
        };

        $scope.ImageClass = function () {
            if ($scope.AccountType == 'current') {
                return 'banner-current';
            }

            if ($scope.AccountType == 'taxfree') return 'banner-taxfree';

            if ($scope.AccountType == 'savings') {
                if (!$scope.Access) return 'banner';

                if ($scope.Data.Over16 && $scope.Data.Over16 == 'no' && ($scope.Access == 'notice' || $scope.Access == 'instant'))
                    return 'banner-ypsa';

                if ($scope.Access == 'notice') return 'banner-notice';
                if ($scope.Access == 'instant') return 'banner-instant';
                if ($scope.Access == 'fixed') return 'banner-fixed';

            }
            return 'banner';
        }


        $scope.SuitableProducts = function () {

            if (!$scope.Data || !$scope.Data.Over16)
                return null;

            var suitableProds = $filter('filter')($scope.products, {
                Category: $scope.AccountType,
                Access: $scope.Access,
                Over16: $scope.Data.Over16
            });

            if (suitableProds != null && suitableProds.length > 0) return 'yes';
            return 'no';
        };






        $scope.SuitableProductsApp = function () {

            if (SuitableProducts() != 'yes') return 'no';

            var suitableProds = $filter('filter')($scope.products, {
                Category: $scope.AccountType,
                Access: $scope.Access,
                Over16: $scope.Data.Over16
            });

            if (suitableProds != null && suitableProds.length > 0) return 'yes';
            return 'no';
        };

        /*
            $scope.AppplcantSuitable = function(accountType, access, over16, applicants) {
                return function(item) {                          
                    if ( item['Category'] == accountType && item['Access'] == access && item['Over16'] == over16 && item['Applicants'] >= applicants 
                    
                    )  {                
                        return true;
                    } else {                
                        return false;
                    }
                }
            };
           */

        $scope.IsSuitableProductsA = function () {

            var suitableProds = $filter('filter')($scope.products, $scope.AppplcantSuitableA());

            if (suitableProds != null && suitableProds.length > 0) return 'yes';
            return 'no';
        };


        $scope.AppplcantSuitableA = function () {
            return function (item) {
                if (!$scope.Data || !$scope.Data.NumberOfApplicants) return false;
                if (
                    item['Category'] == $scope.AccountType && item['Access'] == $scope.Access && item['Over16'] == $scope.Data.Over16 && item['MaxApplicants'] >= $scope.Data.NumberOfApplicants

                ) {
                    return true;
                } else {
                    return false;
                }
            }
        };

        $scope.IsSuitableProductsV = function () {

            var suitableProds = $filter('filter')($scope.products, $scope.AppplcantSuitableV());

            if (suitableProds != null && suitableProds.length > 0) return 'yes';
            return 'no';
        };


        $scope.AppplcantSuitableV = function () {
            return function (item) {
                if (!$scope.Data || !$scope.Data.Deposit) return false;


                if (parseFloat(item['MinDeposit']) <= parseFloat($scope.Data.Deposit) &&


                    item['Category'] == $scope.AccountType && item['Access'] == $scope.Access && item['Over16'] == $scope.Data.Over16 && item['MaxApplicants'] >= $scope.Data.NumberOfApplicants

                ) {
                    return true;
                } else {
                    return false;
                }
            }
        };




        $scope.IsProductValid = function () {
            var SelectErrors = [];

            if (!$scope.Data || !$scope.SelectedProduct)
                return null;

            var valid = true;

            if (!$scope.Data.Deposit || $scope.Data.Deposit == '') {
                valid = false;
                SelectErrors.push('The deposit is too low. The minimum deposit required to open this account is £' + $scope.SelectedProduct.MinDeposit + '.');
            }

            if (parseFloat($scope.Data.Deposit) < parseFloat($scope.SelectedProduct.MinDeposit)) {
                valid = false;
                SelectErrors.push('The deposit is too low. The minimum deposit required to open this account is £' + $scope.SelectedProduct.MinDeposit + '.');

            }

            if (parseFloat($scope.Data.Deposit) > parseFloat($scope.SelectedProduct.MaxDeposit)) {
                valid = false;
                SelectErrors.push('The deposit is too high.  The maximum deposit for this account is £' + $scope.SelectedProduct.MaxDeposit + '.');
            }

            if (!$scope.Data.NumberOfApplicants) {
                valid = false;
                SelectErrors.push('Please select the number of applicants');
            }

            if (parseFloat($scope.Data.NumberOfApplicants) > parseFloat($scope.SelectedProduct.MaxApplicants)) {
                valid = false;
                SelectErrors.push('You have selected too many applicants.  The maximum number of applicants for this account is ' + $scope.SelectedProduct.MaxApplicants + '.');
            }

            if ($scope.Data.Over16 == 'false' && $scope.SelectedProduct.MinAge == "16") {
                valid = false;
                SelectErrors.push('Not suitable for 16 or under');
            }

            if ($scope.Data.Over16 == 'true' && $scope.SelectedProduct.MaxAge == "16") {
                valid = false;
                SelectErrors.push('Not suitable for over 16');
            }

			if ($scope.Data.Source_of_Funds_c == '' || $scope.Data.Source_of_Funds_c == null) {
				valid = false;
                SelectErrors.push('Please select the Source Of Funds');				
            }


            $scope.SelectErrors = SelectErrors;


            //$scope.$apply();  
            return valid;
        };

        $scope.$watch('AccountType', function () {
            if ($scope.AccountType == 'current') {

                $scope.Access = 'instant';
                // $scope.apply();
            }
        });





        serviceProductSelect.GetProductSuitability()
            .then(
                function (result) {
                    $scope.products = result;

                    for (var i = 0; i < $scope.products.length; i++) {
                        $scope.products[i].Name = $scope.products[i].Name.replace("&#39;", "'");
                    }

                },
                function (error) {

                }
            );
			
			serviceProductSelect.getLoadSourceofFundPickLists()
            .then(
                function (result) {
					var arr = [];
					angular.forEach(result, function(val, key){
						arr.push({'Key':val, 'Value':val});
					});
					$scope.SourceofFundsList = arr;
                },
                function (error) {

                }
            );


    }
]);