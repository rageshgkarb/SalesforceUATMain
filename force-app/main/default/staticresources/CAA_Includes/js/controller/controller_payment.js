caaApp.controller('controllerPayment', ['$scope','$window','servicePayment','$sce','serviceApplication','serviceParameters',
        function ($scope,$window,servicePayment,$sce,serviceApplication,serviceParameters) 
        {
	
		$scope.cardTypes = [];
		$scope.cardTypes.push({"key":'', "value":'Please select'});
		$scope.cardTypes.push({"key":'Visa Debit', "value":'Visa Debit'});
		$scope.cardTypes.push({"key":'Electron', "value":'Electron'});
		$scope.cardTypes.push({"key":'Maestro', "value":'Maestro'});
		$scope.cardTypes.push({"key":'MasterCard Debit', "value":'MasterCard Debit'});
		$scope.cardTypes.push({"key":'MasterCard', "value":'MasterCard'});
		$scope.cardTypes.push({"key":'Visa', "value":'Visa'});

		$cardData = {CardType: ''};

		//C0638

		//$scope.caseTypes = [];
		//$scope.caseTypes.push({"key":'', "value":'Please select'});
		//$scope.caseTypes.push({"key":'Suspended-Cancel', "value":'Suspended-Cancel'});
		//$scope.caseTypes.push({"key":'Suspended-Release', "value":'Suspended-Release'});

		//$caseData = {CaseType: ''};
		//

        	window.uploadDone=function(e){

	$scope.State = 'MAKINGPAYMENT';

  $scope.$apply();
	
	$scope.MakePayment();

}


window.threeDSecureResponse=function(md,pares){

	$scope.ThreeDResponse = e;
	$scope.SystemError = '';

	/*Update the value on the server */

	servicePayment.updateACSResponse(md,pares,$scope.TransactionId)
                .then(
                    function(result){
                        if(result.Success)
                        {
			    $scope.updateACSResponse = result;

                        }
                        else
                        {

                        }
                    },
                    function(error){
                        $scope.State = 'ERROR';
                    }
                   );


  $scope.$apply();
}

$scope.CallAJE= function(){
                if(!$scope.EventLogId) return null;  
		
		if(!$scope.SessionId)
			serviceApplication.LoadShow('Processing...');
              
                
                servicePayment.CallAJE($scope.EventLogId, $scope.SessionId)
                .then(
                    function(result){
                        if(result.Success && !$scope.SessionId)
                        {			    
			    $scope.AJECompleted = true;
                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }
                            else
                            {   
                             	$scope.AJECompleted = false;
				$scope.AJEError = result.Error;
				serviceApplication.LoadHide(false);
                            } 
                        }
                        else
                        {
				if(!$scope.SessionId)
					serviceApplication.LoadHide(false);
				$scope.ErrorMessage = 'Account not setup';
                        }
                    },
                    function(error){
                    	$scope.ErrorMessage = error;
			if(!$scope.SessionId)
				serviceApplication.LoadHide(false);
                    }
                   );
            }


$scope.FTDSetup= function(){
                if(!$scope.EventLogId) return null;                
                serviceApplication.LoadShow('Processing...');
                servicePayment.FTDSetup($scope.EventLogId)
                .then(
                    function(result){
                        if(result.Success)
                        {
				$scope.SuccessMessage = 'Completed';
                            if(result.URL)
                            {
                                $window.location.href = result.URL.FormatURL();
                            }
                            else
                            {                                
				serviceApplication.LoadHide(false);
                            } 
                        }
                        else
                        {
				serviceApplication.LoadHide(false);
				$scope.ErrorMessage = 'Account not setup';
                        }
                    },
                    function(error){
                    	$scope.ErrorMessage = error;
			serviceApplication.LoadHide(false);
                    }
                   );
            }

	$scope.MakePayment= function(){
                //if(!$scope.EventLogId || !$scope.SessionId) return null;
		if(!$scope.EventLogId) return null;
		$scope.Submitted = true;
                $scope.SystemError = '';

		if(!$scope.myform.$valid) return;
                
                servicePayment.MakePayment($scope.cardData,$scope.TransactionId, $scope.EventLogId, $scope.SessionId)
                .then(
				 function(result){
					if(result.Data && result.Data.State)
						$scope.State = result.Data.State;

						if(result.Success && result.Data && !result.Data.ErrorType)
						{
							/* C0610 Start - NVM API CODE*/												
							if($scope.State == 'ACCEPTED')
							{								
								servicePayment.ResumeCallRecording($scope.TransactionId, $scope.EventLogId, $scope.SessionId);							 
							}
							/* C0610 End */

							if(result.Data.CallAJE)
							{
								$scope.AJEStatus = '1';
								$scope.CallAJE();
							}

							// C0551 Do not auto complete the FTD when a payment is received
							/*if($scope.State == 'ACCEPTED' && $scope.IsFTD)
							{
								$scope.FTDSetup();
							}*/
							
							$scope.Response = result.Data;			    

							if($scope.State == '3DAUTH' )
							{
								$scope.currentProjectUrl = $sce.trustAsResourceUrl					($scope.Response.Url);
							}

                        }
                        else
                        {
							$scope.SystemError = true;	
                        }
                    },
                    function(error){
                    	$scope.State = 'ERROR';
                    }
                   );
            }
	
	//C0638
	
	/*$scope.CreateCase= function(){

        serviceApplication.LoadShow('Processing...');

		if(!$scope.EventLogId) return null;
		$scope.Submitted = true;
        $scope.SystemError = '';				
		if(!$scope.myform.$valid) return;	
	
                servicePayment.CreateCase($scope.caseData)
                .then(
				 function(result)
				 {
						if(result.Success)
						{
						    $scope.SystemError = false;
							serviceApplication.LoadHide(false);
                        }
                        else
                        {
							$scope.SystemError = true;	
							serviceApplication.LoadHide(false);
                        }
                    },
                    function(error){
                    	$scope.State = 'ERROR';
						serviceApplication.LoadHide(false);
                    }
                   );
            }*/
	//
	

            $scope.Is3dSecure= function()
			{
                if(!$scope.TransactionId) return null;
                $scope.SystemError = '';
				$scope.State = 'Checking3D';
                
                servicePayment.Is3dSecure($scope.cardData,$scope.TransactionId)
                .then(
                    function(result){
                        if(result.Success && result.Data && !result.Data.ErrorType)
                        {
			    $scope.ThreeDSecureData = result.Data;


			if(result.Data.Enrolled && result.Data.Enrolled == 'Y' )
			{
				$scope.currentProjectUrl = $sce.trustAsResourceUrl					($scope.ThreeDSecureData.Url);
				$scope.State = '3DAuth';
			}
			else
			{
				/* MAKE PAYMENT */
			}

                            
                        }
                        else
                        {
				$scope.SystemError = true;	
                        }
                    },
                    function(error){
                    	
                    }
                   );
            }



            
            
        }
    ]);


caaApp.directive('iframeOnload', [function(){
return {
    scope: {
        callBack: '&iframeOnload'
    },
    link: function(scope, element, attrs){
        element.on('load', function(){
            return scope.callBack();
        })
    }
}}])