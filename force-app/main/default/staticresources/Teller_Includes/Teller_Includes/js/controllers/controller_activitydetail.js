tellerApp.controller('controllerActivityDetail', ['$scope', '$timeout', '$stateParams', 'serviceParameters', 'serviceReporting', 'serviceApplication', 'serviceTransactions', 'serviceMessageBroker', 'serviceStateTransition',
    function($scope, $timeout, $stateParams, serviceParameters, serviceReporting, serviceApplication, serviceTransactions, serviceMessageBroker, serviceStateTransition) 
{
	$scope.ActivityDetails = null;
    $scope.TransactionDisplayFlags = null;
    $scope.TransactionStatus = '';
    $scope.TransactionId = null;
    $scope.CancelButtonPressed = false;
    
    $scope.SubDialogType = '';
    $scope.SubDialogNotes = '';
    $scope.SubDialogPassword = '';
    $scope.SubDialogButtonText = '';
    $scope.SubDialogTitle = '';
    
    $scope.pageData = null;
    $scope.NowDateTime = null;
    $scope.TellerName = serviceParameters.TellerParams.Name;
    $scope.TellerImageURL = serviceParameters.TellerParams.ImageURL;
    $scope.Branch = serviceParameters.TellerParams.Branch;

    $scope.AccountPanelBarOptions = 
    { 
        expandMode: "single",     
    };
    
    $scope.Initiate = function() {            
            serviceApplication.LoadShow('Getting Teller Activity Details');
            serviceReporting.GetActivityItem(serviceParameters.ActivityParams.SelectedActvityType,
                                             serviceParameters.ActivityParams.SelectedActivityReferenceId)
                .then(
                    function(result) {
                        serviceApplication.LoadHide();                        
                        $scope.ActivityDetails = result;

                        if($scope.ActivityDetails.Name == 'Transaction')
                        {
                            $scope.TransactionStatus = $scope.FindActivityDetailItem('Transaction_Status__c').Value;
                            $scope.TransactionId = $scope.FindActivityDetailItem('Id').Value;
                            $scope.TransactionDisplayFlags = $scope.ActivityDetails.DisplayFlags;
                        }
                    },
                    function(error) {
                        alert(error.message);
                        serviceApplication.LoadHide();
                    }
            );
        }

    $scope.OnExpand = function(e)
    {
        e.item.style.height = "inherit";
    }

    $scope.OnCollapse = function(e)
    {
        e.item.style.height = "auto";
    }

    $scope.Close = function()
    {
        serviceApplication.ModalHide();
    }

    $scope.FindActivityDetailItem = function(itemName)
    {
        var index = 0;
        var foundItem = null;
        var found = false;

        do
        {
            var item = $scope.ActivityDetails.Details[index];
            if(item.Name == itemName)
            {
                foundItem = $scope.ActivityDetails.Details[index];
                found = true;
            }
            else
            {
                index ++;
            }
        }
        while(index + 1 < $scope.ActivityDetails.Details.length + 1 && found == false)

        return foundItem;
    }

    $scope.RePrint = function()
    {
        
    }

    $scope.CancelTransaction = function()
    {
        if($scope.CancelButtonPressed == false)
        {
            $scope.CancelButtonPressed = true;
            serviceApplication.LoadShow('Processing cancellation request');
            serviceTransactions.CancelTellerTransaction($scope.TransactionId)
            .then(
                        function(result) {
                            serviceApplication.LoadHide();   
                            $scope.Initiate();
                            serviceMessageBroker.TellerActivitiesRefresh();
                            $scope.CancelButtonPressed = false;
                            $scope.$apply();

                            if(result.Success == false)
                            {
                                alert(result.ErrorMessage); 
                            }
                            else
                            {
                                alert('cancellation completed successfully');
                            }
                        },
                        function(error) {
                            alert(error.message);
                            serviceApplication.LoadHide();
                            $scope.CancelButtonPressed = false;
                        }
                );
        }
    }

    $scope.PopoutAccountHistory = function(signatoryItem)
    {
        if(typeof signatoryItem.SfdcUrl != 'undefined' && signatoryItem.SfdcUrl != '')
        {
            window.open(signatoryItem.SfdcUrl.replace('&amp;', '&'));
        }
    }
    
    $scope.GotoCustomer = function(signatoryItem)
    {
        if(typeof signatoryItem.Value.Account_Holder__r.Prospect_Customer__r.Id != 'undefined')
        {
            var customer = {
                             Id: signatoryItem.Value.Account_Holder__r.Prospect_Customer__r.Id, 
                             EBSId: '',
                             DOB: '',
                             Address: '',
                             ImageURL: signatoryItem.Value.Photo_Image_URL__c.replace('//', '/').replace('//', '/'),
                             Name: signatoryItem.Value.Account_Holder__r.Prospect_Customer__r.Name,
                             PostCode: ''
                           };
            
            serviceStateTransition.GotoCustomerSummary(customer);
            $scope.Close();
        }
    }

    $scope.SubDialogShow = function(dialogType)
    {
        if(dialogType == 'authorise')
        {
            $scope.SubDialogType = 'authorise';
            $scope.SubDialogButtonText = 'AUTHORISE';
            $scope.SubDialogTitle = 'Authorise';
        }
        else
        {
            $scope.SubDialogType = 'decline';
            $scope.SubDialogButtonText = 'DECLINE';
            $scope.SubDialogTitle = 'Decline';
        }

        $scope.SubDialogNotes = '';
        $scope.SubDialogPassword = '';
    }
    
    $scope.GenerateAfterHostReciept = function()
    {
        var tfunction = null;
        var trans = null;
        var details = Enumerable.From($scope.ActivityDetails.Details);
        
        var result = details.Where("i => i.Name == 'Teller_Function__c'");       
        if(result.Count() > 0)
        {
            tfunction = result.FirstOrDefault();
        }
            
        result = details.Where("i => i.Name == 'Id'");
        if(result.Count() > 0)
        {
            trans = result.FirstOrDefault();
        }            
        
        if(trans != null && tfunction != null)
        {
            serviceApplication.LoadShow('Generating Transaction Reciept');
            serviceTransactions.LoadFunctionPageDataByTransactionId(trans.Value)
            .then(
                function(result)
                {
                    if(result)
                    {        
                        $scope.pageData = result;  
                        serviceApplication.LoadShow('Generating Transaction Reciept');                      
                        serviceTransactions.GetFunctionPrintTemplate(tfunction.Value, 'After host')
                        .then(
                            function(result)
                            {
                                if(result != '')
                                {
                                    $scope.NowDateTime = new Date();
                                    $scope.ActivityDetails.PrintedReciept = result;
                                    if(!$scope.$$phase) {
                                        $scope.$apply();
                                    }
                                    
                                    $timeout(function()
                                    {   
                                       if(!$scope.$$phase)
                                       {
                                            $scope.$apply();
                                       }
                                       serviceApplication.LoadShow('Generating Transaction Reciept');
                                       var elementToPrint = document.getElementById('printoutSectionActivityDetail');
                                       var reciept_text = elementToPrint.innerText;
                                       serviceTransactions.UpdateTellerTransactionPrintedReciept(trans.Value ,reciept_text)
                                       .then(
                                         function(result)
                                         {
                                             $scope.Initiate();
                                             serviceApplication.LoadHide();
                                         },
                                         function(error){
                                             serviceApplication.LoadHide();
                                         }
                                       );

                                    }, 500);    
                                }
                                
                                serviceApplication.LoadHide();
                            },
                            function(error)
                            {
                                serviceApplication.LoadHide();
                            }
                        );
                    }
                    
                    serviceApplication.LoadHide();
                },
                function(error)
                {
                    serviceApplication.LoadHide();
                }
            );
        }           
    }

    $scope.SubDialogSendToHostClick = function()
    {
        serviceApplication.LoadShow('Processing transaction');
        serviceReporting.SendTransactionToHost(serviceParameters.ActivityParams.SelectedActivityReferenceId)
        .then(
            function(result)
                {
                    if(result.Success)
                    {
                        $scope.TransactionDisplayFlags = result;                        
                        serviceApplication.LoadHide();
                        $scope.SubDialogType = '';
                        $scope.SubDialogNotes = '';
                        $scope.SubDialogPassword = '';
                        serviceMessageBroker.TellerActivitiesRefresh();                        
                        $scope.GenerateAfterHostReciept();
                    }
                    else
                    {
                        serviceApplication.LoadHide();
                        alert(result.ErrorCode + ':' + result.ErrorMessage);
                    }
                },
                function(error)
                {
                    alert(error.message);
                    serviceApplication.LoadHide();
                }
        );
    }

    $scope.SubDialogActionClick = function()
    {
        if($scope.SubDialogType == 'authorise')
        {
            //add logic to authorise
            $scope.SubDialogType = '';
            serviceApplication.LoadShow('Processing transaction');
            serviceReporting.ApproveTransaction(serviceParameters.ActivityParams.SelectedActivityReferenceId, this.SubDialogPassword, this.SubDialogNotes)
            .then(

                function(result)
                {
                    if(result.Success)
                    {
                        $scope.TransactionDisplayFlags = result;                        
                        serviceApplication.LoadHide();                        
                        $scope.SubDialogNotes = '';
                        $scope.SubDialogPassword = '';
                        serviceMessageBroker.TellerActivitiesRefresh();                        
                    }
                    else
                    {
                        serviceApplication.LoadHide();
                        alert(result.ErrorCode + ':' + result.ErrorMessage);
                    }
                },
                function(error)
                {
                    alert(error.message);
                    serviceApplication.LoadHide();
                }

            );
        }
        else
        {
            //add logic to decline
            $scope.SubDialogType = '';
            serviceApplication.LoadShow('Processing transaction');
            serviceReporting.DeclineTransaction(serviceParameters.ActivityParams.SelectedActivityReferenceId, this.SubDialogPassword, this.SubDialogNotes)
            .then(

                function(result)
                {
                    if(result.Success)
                    {
                        $scope.TransactionDisplayFlags = result;                        
                        serviceApplication.LoadHide();
                        $scope.SubDialogNotes = '';
                        $scope.SubDialogPassword = '';
                        serviceMessageBroker.TellerActivitiesRefresh();
                    }
                    else
                    {
                        serviceApplication.LoadHide();
                        alert(result.ErrorCode + ':' + result.ErrorMessage);
                    }
                },
                function(error)
                {
                    alert(error.message);
                    serviceApplication.LoadHide();
                }

            );
        }

    }

    $scope.SubDialogCancel = function()
    {
        $scope.SubDialogType = '';
        $scope.SubDialogNotes = '';
        $scope.SubDialogPassword = '';
    }
} 

]);