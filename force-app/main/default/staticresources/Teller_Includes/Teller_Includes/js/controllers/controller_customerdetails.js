tellerApp.controller('controllerCustomerDetails', ['$window', '$location', '$scope', '$state', '$stateParams', 'serviceCustomer', 'serviceApplication', 'serviceParameters', 'serviceAccounts', 'serviceStateTransition',
    function ($window, $location, $scope, $state, $stateParams, serviceCustomer, serviceApplication, serviceParameters, serviceAccounts, serviceStateTransition) 
    {
        $scope.CustomerDetails = null;
        $scope.CustomerDetailsDisplayAddress = '';
        $scope.ReasonList = ['1', '2'];
        $scope.ImageUrl = null;
        $scope.SignatureUrl = null;
        $scope.Alerts = null;
        $scope.ShowAlerts = false;
        $scope.CustomerLoaded = false;
        $scope.Accounts = null;
        $scope.ShowViewReason = true;
        $scope.PreviousViewReason = '';
        $scope.SelectedViewReason = '';
        $scope.LoadComplete = false;
        $scope.ShowCustomerCore = false;
		$scope.PendingOnlineBankingAction = false;
        $scope.MarketingPrefs = {  HasEmail: false, HasMail: false, HasPhone: false, HasSMS: false, Selected: ''};

        $scope.LastViewName = '';
        $scope.LastViewDate = null;
        $scope.LastViewImageUrl = null;

        $scope.DetailsSubMenuOpen = false;

        $scope.ContactEditable = false;
        $scope.CustomerDetailsCache = null;
        
        $scope.mobileMode = false;
        $scope.account = null;
        
        //$scope.AccountPanelBarOptions = { expandMode: "single" };

        $scope.InitialiseCustomer = function () {
            
            if(window.innerWidth < 767)
            {
                $scope.mobileMode = true;
            }

            if(typeof $stateParams.id != 'undefined' && $stateParams.id != '')
            {
                serviceParameters.CustomerParams.SelectedId = $stateParams.id;
				console.log('$stateParams.id='+$stateParams.id);
            }
            else
            {
                if(serviceParameters.CustomerParams.SelectedId === null || serviceParameters.CustomerParams.SelectedId === '')
                {
                    serviceStateTransition.GotoCustomerSearch('');
                    return;
                }
            }

            $scope.ShowCustomerCore = true;
            $scope.Accounts = null;
            serviceApplication.LoadShow('Loading customer details');
            serviceCustomer.GetCustomerDetails(serviceParameters.CustomerParams.SelectedId)
                .then(
                    function (result) {

                        var summarysection = angular.element(document.getElementById("customerSummarySection"));
                        summarysection[0].scrollTop = 0;

                        $scope.CustomerDetails = result.Details;
                        $scope.CustomerDetailsDisplayAddress = ((typeof result.Details.BillingStreet != 'undefined') ? result.Details.BillingStreet : '') + ', ' + ((typeof result.Details.Customer_Address_District__c != 'undefined') ? result.Details.Customer_Address_District__c : '') + ', ' +  ((typeof result.Details.BillingCity != 'undefined') ? result.Details.BillingCity : '') + ', ' + ((typeof result.Details.BillingPostalCode != 'undefined') ? result.Details.BillingPostalCode : '');
                        $scope.ReasonList = result.ReasonPickList;                        
                        $scope.ShowViewReason = result.ShowReason;
                        $scope.PreviousViewReason = ((result.CurrentReason == null) ? '' : result.CurrentReason);
                        $scope.SelectedViewReason = 'Engage Transaction';
                        $scope.ImageUrl = result.ImageURL.replace("&quot;", "");
                        $scope.SignatureUrl = result.SignatureURL.replace("&quot;", "");
                        
                        $scope.LastViewName = result.LastViewByName;
                        $scope.LastViewDate = result.LastViewByDateTime;
                        $scope.LastViewImageUrl = result.LastViewByImageURL;

                        // C0697 new fields
						$scope.MarketingPrefs.HasEmail = result.Details.Contact_by_Email_New__c;
                        $scope.MarketingPrefs.HasMail = result.Details.Contact_by_Post_New__c;
                        $scope.MarketingPrefs.HasPhone = result.Details.Contact_by_Telephone_New__c;
                        $scope.MarketingPrefs.HasSMS = result.Details.Contact_by_SMS_New__c;
						$scope.MarketingPrefs.HasNewsletter = result.Details.Contact_by_Newsletter_New__c;
						$scope.MarketingPrefs.HasNone = result.Details.No_Contact__c;
						$scope.MarketingPrefs.NoProfiling = (result.Details.Contact_by_Profiling_New__c == null ? true : !result.Details.Contact_by_Profiling_New__c);
                        //$scope.UpdateMarketingInfoUI();

                        $scope.CustomerLoaded = true;

                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }

                        serviceApplication.LoadShow('Checking customer alerts');
                        serviceCustomer.GetCustomerAlerts(serviceParameters.CustomerParams.SelectedId)
                            .then(
                                function (result) {
                                    $scope.Alerts = result;
                                    //angular.forEach($scope.Alerts, function(val, key){

                                    // C0768 GS 16/07/2019 Addition of PEP_Associate__c and Extreme check
                                    if($scope.CustomerDetails.Status__c=="Dormant" && (($scope.CustomerDetails.Pep__c == true || $scope.CustomerDetails.PEP_Associate__c == 'Yes') || ($scope.CustomerDetails.Customer_Risk_Rating__c == 'High' || $scope.CustomerDetails.Risk_Rating__c == 'High' || $scope.CustomerDetails.Risk_Rating__c == 'Extreme'))) {
                                        $scope.Alerts = [{Title:"Warning", Data:"This is a High Risk/ PEP Account, which required full EDD and requires MLRO approval for activation" }];
                                        if (result.length > 0)
                                            $scope.ShowAlerts = true;

                                        if (!$scope.$$phase) {
                                            $scope.$apply();
                                        }
                                    }
                                    serviceApplication.LoadHide(false);
                                },
                                function (error) {
                                    alert(error.message);
                                    serviceApplication.LoadHide(false);
                                }
                        );
                        serviceApplication.LoadHide(false);

                        //load accounts if reason has already been provided
                        if($scope.ShowViewReason == false)
                        {
                            $scope.GetAccountsDetails();
                        }

                    },
                    function (error) {
                        alert(error.message);
                        serviceApplication.LoadHide(false);
                        $scope.CustomerLoaded = true;
                    }
            );
        }

        /*$scope.UpdateMarketingInfoUI = function()
        {
            $scope.MarketingPrefs.Selected = '';
            $scope.MarketingPrefs.Selected += ($scope.MarketingPrefs.HasEmail == false ? 'Email, ' : '');
            $scope.MarketingPrefs.Selected += ($scope.MarketingPrefs.HasMail == false ? 'Mail, ' : '');
            $scope.MarketingPrefs.Selected += ($scope.MarketingPrefs.HasPhone == false ? 'Phone, ' : '');
            $scope.MarketingPrefs.Selected += ($scope.MarketingPrefs.HasSMS == false ? 'SMS, ' : '');
            $scope.MarketingPrefs.Selected = $scope.MarketingPrefs.Selected.replace(/,\s*$/, "");

            if (!$scope.$$phase) {
                $scope.$apply();
            }
        }*/
		
		
		
		$scope.OnlineBankingFunction = function(functionType) {
			if(!serviceParameters.CustomerParams.SelectedId) return;
			
			$scope.PendingOnlineBankingAction = true;
			console.log('Before OnlineBankingFunction-'+serviceParameters.CustomerParams.SelectedId);
			serviceCustomer.OnlineBankingFunction(serviceParameters.CustomerParams.SelectedId,functionType)
                            .then(
                                function (result) {
								
                                    $scope.UserInfo = result; 
									console.log('Result from OnlineBankingFunction-'+JSON.stringify(result)); 
									$scope.PendingOnlineBankingAction = false;
									$scope.ShowOnlineBankingFunctions = false;
                                    if (!$scope.$$phase) {
                                        $scope.$apply();
                                    }                                    
                                },
                                function (error) {
                                    alert(error.message);                                    
                                }
                        );
		}
		
		$scope.GetCustomerUserInfo = function() {
			if(!serviceParameters.CustomerParams.SelectedId) return;
			console.log('Before GetCustomerUserInfo-'+serviceParameters.CustomerParams.SelectedId);
			serviceCustomer.GetCustomerUserInfo(serviceParameters.CustomerParams.SelectedId)
                            .then(
                                function (result) {
								
                                    $scope.UserInfo = result;                                    
									console.log('Result from GetCustomerUserInfo-'+JSON.stringify(result));
                                    if (!$scope.$$phase) {
                                        $scope.$apply();
                                    }                                    
                                },
                                function (error) {
                                    alert(error.message);                                    
                                }
                        );
		}


        $scope.GetCustomerStatusTileClass = function() {
            if($scope.CustomerDetails != null && $scope.CustomerDetails.Status__c != null)
            {                
                switch($scope.CustomerDetails.Status__c ) {
                    case "Normal":
                    case "Customer":
                        return "tileColourGreen";
                    case "Prospect":
                        return "tileColourBlue";
                    case "Dormant":
                        return "tileColourAmber";
                    case "Closed":
                        return "tileColourRed";
                }
            }
            return "";
        }

        $scope.GetAccountStatusTileClass = function(status) {
            switch(status)
            {
                case "Active":
                  return "tileColourGreen";
                case "Blocked":
                    return "tileColourRed";
                case "Inactive":
                  return "tileColourAmber";
                case "Closed":
                   return "tileColourGray";
            }
        }

        $scope.GetAlertsTileClass = function() {
            if($scope.Alerts != null && $scope.Alerts.length != null)
            {
                if($scope.Alerts.length == 0)
                    return "tileColourGreen";

                if($scope.Alerts.length == 1)
                    return "tileColourAmber";

                if($scope.Alerts.length > 1)
                    return "tileColourRed";
            }
            return "";
        }

        $scope.GetLastUpdateDateTileClass = function() {            
        }

        $scope.GetChangeImgClass = function() {
            if($scope.ShowViewReason == false)
            {
                return "customerImgShow";
            }
            else
            {
                return "";
            }
        }

        $scope.GetAccountsDetails = function() {
            $scope.LoadComplete = false;
            serviceApplication.LoadShow('Loading customer account details');
            serviceParameters.TransactionParams.ClearAccountList();
            serviceAccounts.GetAccountDetailsWithReasonCheck($scope.CustomerDetails.Id, $scope.CustomerDetails.EBS_ID__c)
                .then(
                    function (result) {
                        if(result != null)
                        {
                            //console.log(JSON.stringify(result));
							$scope.Accounts = result;   
                            $scope.CacheCustomerActiveAccountList();                     
                            $scope.Accounts.accountSfdcUrl = $scope.Accounts.accountSfdcUrl.replace('&amp;', '&');                        
                            $scope.ShowViewReason = false;
                        }
                        serviceApplication.LoadHide(false);
                    },
                    function (error) {
                        alert(error.message);
                        serviceApplication.LoadHide(false);
                    }
            );
        }
		
		//C0737 Start 
        $scope.UnCheckConsentNone = function(){ 
            $scope.MarketingPrefs.HasNone = false;  
            if(!$scope.MarketingPrefs.HasEmail && !$scope.MarketingPrefs.HasMail && !$scope.MarketingPrefs.HasPhone && !$scope.MarketingPrefs.HasSMS && !$scope.MarketingPrefs.HasNewsletter){  
                $scope.IsMarketPrefSelected = false;  
            }else{ 
                $scope.IsMarketPrefSelected = true;  
            } 
        }; 
        //C0737 End  

		$scope.checkNoContact = function()
		{
			if($scope.MarketingPrefs.HasNone)
			{
				$scope.MarketingPrefs.HasNewsletter=false;
				$scope.MarketingPrefs.HasEmail=false;
				$scope.MarketingPrefs.HasSMS=false;
				$scope.MarketingPrefs.HasMail=false;
				$scope.MarketingPrefs.HasPhone=false;
				$scope.IsMarketPrefSelected = true; // C0737 
            }else{
				//C0737 Start  
                if(!$scope.MarketingPrefs.HasEmail && !$scope.MarketingPrefs.HasMail && !$scope.MarketingPrefs.HasPhone && !$scope.MarketingPrefs.HasSMS && !$scope.MarketingPrefs.HasNewsletter){  
                    $scope.IsMarketPrefSelected = false;  
                }else{  
                    $scope.IsMarketPrefSelected = true;  
                }  
                //C0737 End  
            }  
		}

        $scope.onClickSubmitReason = function()
        {
            $scope.LoadComplete = false;
            serviceApplication.LoadShow('Processing account view reason');
            serviceCustomer.SubmitViewingReason($scope.CustomerDetails.Id, $scope.PreviousViewReason, $scope.SelectedViewReason)
            .then
            (
                function (result) {
                    $scope.GetAccountsDetails();
                    serviceApplication.LoadHide(false);
                },
                function (error) {
                    alert(error.message);
                    serviceApplication.LoadHide(false);
                }
            );            
        }

        $scope.GotoCustomerAccounts = function() {
           $scope.GetAccountsDetails();
        }

        $scope.GotoCustomerSearch = function() {
            $state.transitionTo('customersearch');
        }

        $scope.PopoutAccountDetails = function()
        {
            $scope.DetailsSubMenuOpen = false;
            window.open($scope.Accounts.accountSfdcUrl);
        }
        $scope.PopoutDSXDetails = function()
        { 
            $scope.DetailsSubMenuOpen = false;
            window.open("http://dsxlive1/DSXSearchDisplay/Default.aspx?template=All Docs by Customer&Customer Number="+$scope.CustomerDetails.EBS_ID__c+"&GetPDFFile=true");
        }
        $scope.PopoutAccountDSXDetails = function(account)
        { 
            $scope.DetailsSubMenuOpen = false;
            window.open("http://dsxlive1/DSXSearchDisplay/Default.aspx?template=All Docs by Account&Account Number="+ account +"&GetPDFFile=true");
        }
        $scope.gotoAnchor = function(account) {            

            var element = 'anchor' +  ( (typeof account.Name != 'undefined') ? account.Name : account);  
            var parent = angular.element(document.getElementById("horizontalScrollList"));
            var section = angular.element(document.getElementsByClassName(element)[0]);
            var left = section[0].offsetLeft - 30;
            parent.scrollLeftAnimated(left, 700);
            
            if($scope.mobileMode)
            {
                $scope.account = account; 
            }                    
        }; 

        $scope.gotoCameraDialog = function()
        {
            if(!$scope.ShowViewReason)
                serviceApplication.ModalShow('Photo', 'Camera');
        }  

        $scope.gotoScanDialog = function()
        {
            if(!$scope.ShowViewReason)
                serviceApplication.ModalShow('Signature', 'Scanner');
        }

        $scope.GetCustomerSummaryClass = function()
        {
            if($scope.Accounts != null)
                return "customerScrollSection";
            else 
                return "customerSummarySection";
        }

        $scope.OpenCloseSubMenu = function()
        {
            if($scope.DetailsSubMenuOpen)
                $scope.DetailsSubMenuOpen = false;
            else
                $scope.DetailsSubMenuOpen = true;
        }

        $scope.GotoJointAccountHolder = function(account)
        {
            if(account != null)
            {
                serviceStateTransition.GotoCustomerSummary(account);
            }
        }

        $scope.OnEditContactDetails = function()
        {
            $scope.CustomerDetailsCache = JSON.parse(JSON.stringify($scope.CustomerDetails));
            $scope.ContactEditable = true;
        }

        $scope.OnCancelContactDetailsEdit = function()
        {
            $scope.CustomerDetails = $scope.CustomerDetailsCache;
            $scope.ContactEditable = false;
        }

        $scope.OnSaveMarketingPrefs = function()
        {
			//C0737 Start 
            if(!$scope.MarketingPrefs.HasEmail && !$scope.MarketingPrefs.HasMail && !$scope.MarketingPrefs.HasPhone && !$scope.MarketingPrefs.HasSMS && !$scope.MarketingPrefs.HasNewsletter && !$scope.MarketingPrefs.HasNone){ 
                $scope.IsMarketPrefSelected = false; 
                return; 
            }else{ 
                $scope.IsMarketPrefSelected = true; 
            }//C0737 End  

            serviceApplication.LoadShow('Updating marketing preferences');
            
            // C0697 - Extended for extra fields
			serviceCustomer.UpdateMarketingPreferences(serviceParameters.CustomerParams.SelectedId, $scope.MarketingPrefs.HasEmail, $scope.MarketingPrefs.HasMail, $scope.MarketingPrefs.HasPhone, $scope.MarketingPrefs.HasSMS, $scope.MarketingPrefs.HasNewsletter, $scope.MarketingPrefs.HasNone,$scope.MarketingPrefs.NoProfiling)
            .then(
                    function (result){
                        if(result.Success == false)
                        {
                            alert(result.Error);  
                        }     

                        //$scope.UpdateMarketingInfoUI();                 

                        serviceApplication.LoadHide(false);

                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                     function (error) {
                        alert(error.message);
                        serviceApplication.LoadHide(false);
                    }
                );
        }  
        

        $scope.OnSaveContactDetails = function()
        {
            // pass data to save routine.
            serviceApplication.LoadShow('Updating customer details');

            serviceApplication.CreateWebLog($scope.CustomerDetails.Id)
             .then(
                    function (result) {
                         serviceCustomer.UpdateCustomerDetailsInEBS($scope.CustomerDetails, result)
                         .then(
                                 function (result) {                                            
                                    if(result.Success == false)
                                    {
                                        alert('Customer Contact Details update failed in EBS- ' + result.Error);
                                        $scope.CustomerDetailsCache = null;
                                        $scope.ContactEditable = false;
                                        serviceApplication.LoadHide(false);
                                    }
                                    else
                                    {
                                        serviceCustomer.UpdateCustomerDetails($scope.CustomerDetails)
                                        .then(
                                                function (result){
                                                    if(result.Success == false)
                                                    {
                                                        alert(result.Error);  
                                                    }
                                                    else
                                                    {
                                                        $scope.CustomerDetailsCache = null;
                                                        $scope.ContactEditable = false;
                                                    }

                                                    serviceApplication.LoadHide(false);

                                                    if (!$scope.$$phase) {
                                                        $scope.$apply();
                                                    }
                                                },
                                                 function (error) {
                                                    alert(error.message);
                                                    serviceApplication.LoadHide(false);
                                                }
                                            );
                                    }
                                   
                                },
                                function (error) {
                                    alert(error.message);
                                    serviceApplication.LoadHide(false);
                                }
                            );                                        
                    },
                    function (error) {
                        alert(error.message);
                        serviceApplication.LoadHide(false);
                    }
                );
        }
        
        $scope.CacheCustomerActiveAccountList = function()
        {
            serviceParameters.TransactionParams.ClearAccountList();
            if($scope.Accounts != 'undefined' && $scope.Accounts != null && $scope.Accounts.active != 'undefined' && $scope.Accounts.active.length > 0)
            {
                var cache = Enumerable.From($scope.Accounts.active).Select("a => {AccountNo: a.AccountNo, EligibleTransferToField: a.EligibleTransferToField}").ToArray();
                if(cache != 'undefined' && cache.length > 0)
                {
                    serviceParameters.TransactionParams.AccountList = cache;
                }
            }
        }

        //Toolbar Buttons ----------------------------------------------------------------------------------------

        $scope.onClickRefresh = function()
        {
            $scope.InitialiseCustomer();
            if($scope.ShowViewReason == false)
            {
                $scope.GetAccountsDetails();
            }
        }

        //Message Listeners --------------------------------------------------------------------------------------

        $scope.$on('CustomerAccountsRefresh', function()
        {
            $scope.GetAccountsDetails();
        }); 

        $scope.$on('CustomerRefresh', function()
        {
            $scope.InitialiseCustomer();
        });

        $scope.$on('LoadHideComplete', function()
        {
            $scope.LoadComplete = true;
        });  
        
        $scope.$on('breakpointChange', function(event, breakpoint, oldClass) {
            
            switch(breakpoint.class)
            {
                case 'xs':
                {
                    $scope.mobileMode = true;
                    $scope.account = null;
                    break;
                }   
                case 'sm':
                {
                    $scope.mobileMode = false;
                    $scope.account = null;
                    break;
                }
                default:
                {
                    $scope.mobileMode = false;
                    $scope.account = null;
                }
            }
        });         
    }
])