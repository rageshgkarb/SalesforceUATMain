caaApp.controller('AddressController', ['$scope', '$timeout',
    function ($scope, $timeout) {

        $scope.init = function (applicant, a, i, PCA_key, hasCustomIndex, customIndex) {
            $scope.applicant = applicant;
            $scope.PCA_key = PCA_key;
            $scope.a = a;
            $scope.i = hasCustomIndex ? customIndex : i;
            $scope.countrycode = $scope.Data.CountryCodes[0];

            $timeout(function () {
                $scope.initPCA();
            }, 1000); //};
        }


        $scope.initPCA = function () {
            var g = $scope.$parent.controls;


            var options = {
                key: $scope.PCA_key
            }

            var fields = [{
                    element: "line1" + $scope.a + $scope.i,
                    field: "Line1"
                }, {
                    element: "line2" + $scope.a + $scope.i,
                    field: "Line2",
                    mode: pca.fieldMode.POPULATE
                }, {
                    element: "city" + $scope.a + $scope.i,
                    field: "City",
                    mode: pca.fieldMode.POPULATE
                }, {
                    element: "county" + $scope.a + $scope.i,
                    field: "ProvinceName",
                    mode: pca.fieldMode.POPULATE
                }, {
                    element: "postcode" + $scope.a + $scope.i,
                    field: "PostalCode"
                }, {
                    element: "country" + $scope.a + $scope.i,
                    field: "CountryName",
                    mode: pca.fieldMode.COUNTRY
                },

                // SS - AEol Requirement
                {
                    element: "countrycode" + $scope.a + $scope.i,
                    field: "CountryCode"
                }
            ];

            $scope.UpdateCountryCode();

            //var control = new pca.Address(fields, options);
            //controls.push(control);

            $scope.addressControl = new pca.Address(fields, options);

            $scope.addressControl.listen("country", function (address) {
                var country = address;

                console.log('country changed');

                if ($scope.i == 0) {
                    $scope.applicant.BillingCountry = address.name;                    
                    $scope.UpdateCountryCode();
                }
                if ($scope.i == 1) {
                    $scope.applicant.ShippingCountry = address.name;
                }
                if ($scope.i == 2) {
                    $scope.applicant.PersonMailingCountry = address.name;
                }
                if ($scope.i == 3) {
                    $scope.applicant.Employer_Country_c = address.name;
                }
            });

            $scope.addressControl.listen("populate", function (address, variations) {

                console.log('populate changed');
                //Current address
                if ($scope.i == 0) {
                    $scope.applicant.BillingCity = address.City;
                    $scope.applicant.BillingPostalCode = address.PostalCode;
                    $scope.applicant.BillingState = address.Province;
                    $scope.applicant.BillingStreet = address.Line1;
                    $scope.applicant.Customer_Address_District_c = address.Line2;
                    $scope.applicant.BillingCountry = address.CountryName;                    
                    $scope.UpdateCountryCode();
                    $scope.applicant.CountryCode = address.CountryCode;
                    //return;
                }

                //Previous address
                if ($scope.i == 1) {
                    $scope.applicant.ShippingCity = address.City;
                    $scope.applicant.ShippingPostalCode = address.PostalCode;
                    $scope.applicant.ShippingState = address.Province;
                    $scope.applicant.ShippingStreet = address.Line1;
                    $scope.applicant.Customer_Previous_Address_District_c = address.Line2;
                    $scope.applicant.ShippingCountry = address.CountryName;
                    //return;
                }

                //Previous Previous address
                if ($scope.i == 2) {
                    $scope.applicant.PersonMailingCity = address.City;
                    $scope.applicant.PersonMailingPostalCode = address.PostalCode;
                    $scope.applicant.PersonMailingState = address.Province;
                    $scope.applicant.PersonMailingStreet = address.Line1;
                    $scope.applicant.Customer_Prev_Previous_Address_District_c = address.Line2;
                    $scope.applicant.PersonMailingCountry = address.CountryName;
                    //return;
                }

                //Employer address
                if ($scope.i == 3 || $scope.i == 4) {
                    $scope.applicant.Employer_Address_Line_3_c = address.City;
                    $scope.applicant.Employer_Post_Code_c = address.PostalCode;
                    $scope.applicant.Employer_Address_Line_4_c = address.Province;
                    $scope.applicant.Employer_Address_Line_1_c = address.Line1;
                    $scope.applicant.Employer_Address_Line_2_c = address.Line2;
                    $scope.applicant.Employer_Country_c = address.CountryName;
                    //return;
                }
                $scope.$apply();

                console.log($scope.countrycode);
            });
        };

        $scope.UpdateCountryCode = function () {
            if ($scope.applicant.BillingCountry != '') {
                var found = $scope.Data.CountryCodes.find((item) => {
                    return item.Value == $scope.applicant.BillingCountry;
                });

                if(found !== null || found !== undefined) {                    
                    $scope.countrycode = found;
                }
            }
        }
    }
]);