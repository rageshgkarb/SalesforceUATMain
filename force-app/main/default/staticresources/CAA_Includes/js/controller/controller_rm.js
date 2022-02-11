caaApp.controller('controllerRMDetails', ['$scope','$rootScope','$window','serviceRMDetails','$interval','serviceParameters','serviceApplication','serviceEBS',
    function ($scope,$rootScope,$window,serviceRMDetails,$interval,serviceParameters,serviceApplication,serviceEBS) 
    {
      $scope.SaveErrors = 0;
      $scope.$watch('EventLogId', function () {
      serviceApplication.LoadShow('Fetching customer data');
      serviceRMDetails.GetApplicantData($scope.EventLogId,$scope.SessionId)
          .then(
            function(result){
                $scope.Data= result.Data;
				if(result.URL)
                {
						$window.location.href = result.URL.FormatURL();
                    	return;
                }

        				for(var i = 0 ; i < $scope.Data.SourceOfFundsCountry.length; i++)
        				{
        					$scope.Data.SourceOfFundsCountry[i].Value = $scope.Data.SourceOfFundsCountry[i].Value.replace("&#39;","'");
        					$scope.Data.SourceOfFundsCountry[i].Value = $scope.Data.SourceOfFundsCountry[i].Value.replace("&amp;","&");
        					$scope.Data.SourceOfFundsCountry[i].Key = $scope.Data.SourceOfFundsCountry[i].Key.replace("&#39;","'");
        					$scope.Data.SourceOfFundsCountry[i].Key = $scope.Data.SourceOfFundsCountry[i].Key.replace("&amp;","&");
        				}

	             serviceApplication.LoadHide(false);                 
			     },
			     function(error){
				      serviceApplication.LoadHide(false);
			     }
			   );   
      });     

    function endsWith(str, suffix) {
      return str.indexOf(suffix, str.length - suffix.length) !== -1;
    }


	$scope.ShowErrors = function()
	{
		try
		{
			if(!$scope.Data || !$scope.Data.Applicants) return;
			var show = false;
			//$scope.ValidApplicants = {};
			for(var i = 0; i < $scope.Data.Applicants.length;i++)
			{
				var valid = true;
				for (var property in $scope.myform.$error) {
    				
						var err = $scope.myform.$error[property];
						for(var field in err)
						{
							if(field === 'remove')break;
							var ff = err[field];

						

							var g = ff.$name;
							if(endsWith(g,i)){
							valid = false;
							break;
							}	
						}
						if(valid == false) break;
    				
				}


				$scope.Data.Applicants[i].Valid = valid;
				if(!valid) show = true;
			}
			return show;
		}
		catch(errr) {
			var gg = 1;
		}
	}



   var timer=$interval(function(){


       $scope.AutoSave = true;

       $scope.SaveData();

   },15000);

   $scope.killtimer=function(){
       if(angular.isDefined(timer))
       {
          $interval.cancel(timer);
          timer=undefined;
      }
  };        

  $scope.SaveData= function(item) {
      $scope.ErrorAlertText = null;
      if($scope.Data == null || $scope.Data.Applicants == null) return;

      var data = {'Applicants' : angular.copy($scope.Data.Applicants)  , 'EventLogId' : $scope.EventLogId, 'Campaign' : $scope.Campaign, 'PaperStatements' : $scope.Data.PaperStatements }
      serviceRMDetails.SaveData(data,$scope.SessionId)
      .then(
        function(result){

            if(result.Success)
            {
             $scope.SaveErrors = 0;
             $scope.SuccessAlertText = 'Data saved.';
             $scope.ShowSuccessAlert= true;
             window.setTimeout(function() {
               $scope.ShowSuccessAlert=false; $scope.$apply();
           }, 4000);
         }
         else
         {
             $scope.ErrorAlertText = result.Error;
             $scope.SaveErrors += 1;
             if($scope.SaveErrors == 3)
             {
                $scope.killtimer();
            }
        }
        $scope.AutoSave = false;
      },
      function(error){
		 $scope.SaveErrors += 1;
		 $scope.AutoSave = false;

		 if($scope.SaveErrors == 3)
		 {
			$scope.killtimer();
		 }
      }
	);  
 }
  
  
  
  
  
  
  $scope.ValidationClick = function(index, field){
    var panel = '#collapse' + index; 

    $(panel).collapse('show');

    var fieldVal = '#' + field + index;

    setTimeout(function(){$(fieldVal).focus();}, 300)

  }


  $scope.PasswordVerification = function(authorisor){

        if(authorisor.Password == '' || authorisor.Password == null)
        {
            $scope.Response_StatusDescription = 'Password cannot be empty';
            return;
        }

        $scope.working = true;
        serviceApplication.LoadShow('Verifying Password'); 
        serviceRMDetails.PasswordVerification(authorisor.Username, authorisor.Password)
        .then(
                function (result) {
                        console.log(JSON.stringify(result));
						if(result.Success == true)
                        {
                            authorisor.Verified = true;
                        }
                        else
                        {
							authorisor.IncorrectPassword = true;
                            $scope.Response_StatusDescription = 'Incorrect Password';
                        }

                        $scope.working = false;
                         if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                    },
                function (error) {
                        $scope.Response_Success = false;
                        $scope.working = false;
                        $scope.Response_StatusDescription = error.message;
                         if(!$scope.$$phase) {
                            $scope.$apply();
                        }
                        serviceApplication.LoadHide(false);
                        alert(error.message);
                    }
            );
     }


$scope.HideComplete = function()
{
	if($scope.isFCU) return true;

	if($scope.isBranch && !($scope.ManagerAuthorisors && $scope.ManagerAuthorisors.selectedAuthorisor && $scope.ManagerAuthorisors.selectedAuthorisor.Verified))
	{
	 return true;
	}
	
	if(!$scope.Data || !$scope.Data.Applicants) return false;

	for(var i = 0; i < $scope.Data.Applicants.length;i++)
	{
		if($scope.Data.Applicants[i].Correct == 'No') return true;
	}
	return false;
}

$scope.Complete = function(){
	if(!$scope.myform.$valid) return;

	if($scope.YPSA && $scope.Data.Applicants.length < 2) return;

	var approvalUser = '';
	if($scope.ManagerAuthorisors && $scope.ManagerAuthorisors.selectedAuthorisor && $scope.ManagerAuthorisors.selectedAuthorisor.Verified)
	{
		approvalUser=$scope.ManagerAuthorisors.selectedAuthorisor.AuthorisorId; 
	}

    var data = {'Applicants' : angular.copy($scope.Data.Applicants)  , 'EventLogId' : $scope.EventLogId, 'Campaign' : $scope.Data.Campaign, 'PaperStatements' : $scope.Data.PaperStatements, 'ApprovalUser' : approvalUser, 'isEDD' : $scope.isEDD }

	serviceApplication.LoadShow('Saving...');
    serviceRMDetails.CompleteEvent(data,$scope.SessionId)
    .then(
        function(result){
			if(result.Success)
            {
				if(result.URL && $scope.isABranch && $scope.isBranch && approvalUser!='')
				{
					$window.location.href = result.URL.FormatURL();
					return;
				}
				
				serviceApplication.LoadHide(false);
				$rootScope.PleaseWaitAddOn = 'This may take up to a minute';
				serviceApplication.LoadShow('RM...');
				serviceRMDetails.CallRM($scope.EventLogId,$scope.SessionId,($scope.isRMT || $scope.isEDD || $scope.canEDD),$scope.isABranch)
				.then(
				function(result){
					$scope.canEDD = result.isEDD;
					if((!result.isRMT || result.isFCU) || (result.isRMT && $scope.isRMT))
					{
						if(result.URL || result.CallEBS)
						{
							if(result.CallEBS)
							{
								$scope.CallEBS();
							}
							else
							{
								$window.location.href = result.URL.FormatURL();
								return;
							}
						}
						else
						{
							if(result.isFCU)
							{
								$scope.isFCU = true;
								$scope.RMAlertText = 'We are currently processing your application, you will be contacted shortly';
								$scope.isBranch = false;
							}
							else
							{
								$scope.isFCU = false;
								if(result.isRMT && result.isEDD)
								{
									$scope.isBranch = true;
									if(result.ManagerAuthorisors)
									{
										$scope.ManagerAuthorisors =  result.ManagerAuthorisors;
										$scope.ManagerAuthorisors.selectedAuthorisor = '';
										$scope.ManagerAuthorisors.selectedAuthorisor.Verified = false;
									}
								}
							}
						}
					}
					else
					{
						$scope.isRMT = true;
					}
					$rootScope.PleaseWaitAddOn = '';
					serviceApplication.LoadHide(false);
				},
				function(error){
					serviceApplication.LoadHide(false);
				}
				);
				
                $scope.Duplicates = result.HasDuplicates;
            }
           
        },
        function(error){
		   serviceApplication.LoadHide(false); 
       }
       );

		$scope.CallEBS= function(){
                if(!$scope.EventLogId) return null;
                
				serviceApplication.LoadShow('RM...');
                serviceEBS.CallEBSDE($scope.EventLogId,$scope.SessionId)
                .then(
                    function(result){
					    if(result.Success)
                        {
							if(result.Data)
							{
								if(result.Data.Complete)
								{
									$scope.CompleteExternal();
									return;
								}
								else
								{
									$scope.Error = ' ';						
								}

								if(result.Data.NextEventUrl)
								{
									$window.location.href = result.Data.NextEventUrl.FormatURL();
								}
							}

                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }                             
                        }
						else
						{
							$scope.Error = ' ';
						}
                        
						serviceApplication.LoadHide(false);
                },
                function(error){
						serviceApplication.LoadHide(false);
                }
               );
        }

		$scope.CompleteExternal= function(){
			if(!$scope.EventLogId) return null;
                
			serviceEBS.CompleteExternal($scope.EventLogId,$scope.SessionId)
			.then(
				function(result){
					if(result.Success  && result.Data && result.Data.NextEventUrl)
					{
						$window.location.href = result.Data.NextEventUrl.FormatURL();
						return;
					}
					else
					{
						$scope.Error = ' ';
					}
                        
					serviceApplication.LoadHide(false);
				},
				function(error){
					serviceApplication.LoadHide(false);
				});
		}   
}


$scope.$on('ngRepeatFinished', function(ngRepeatFinishedEvent) {
var f = $('#collapse0');
f.collapse('show');


$('[data-toggle="popover"]').popover();
  
    $scope.controls=[];
});

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
            serviceRMDetails.FindCustomer($scope.SearchCriteria)
            .then(
                function(result) 
                {
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

$scope.CheckExistingCustomer = function(override) {
$scope.AddError = '';
  serviceApplication.LoadShow('Searching for existing customer');
  serviceRMDetails.CheckIsExistingAccount($scope.NewAccountData, $scope.EventLogId, override)
  .then(
    function(result){
     serviceApplication.LoadHide(false);
     if(result.Success)
     {
        if(result.Account)
        {
            $scope.Data.Applicants.push(result.Account);
            $('#NewCusModal').modal('hide');
	    
	
        }
        else
        {
            $scope.ExistingAccounts = result.ExistingAccounts;
        }
     }
     else
     {
        $scope.IsExistingCustomer = true;
		    $scope.AddError = result.Error;
     }
  	},
  	function(error){
  		serviceApplication.LoadHide(false);
  	}
  	);  
  }
}
]);