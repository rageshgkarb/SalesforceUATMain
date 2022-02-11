hppApp.controller('HPPEventAdhocPaymentController', ['$scope', '$window', '$timeout','serviceHPPEventAdHocPaymentControllerNew','serviceApplication',
            function($scope, $window, $timeout,HPPEventAdHocPaymentControllerNew,serviceApplication) 
		{
		$scope.cardTypes = [];
		$scope.cardTypes.push({"key":'', "value":'Please select'});
		$scope.cardTypes.push({"key":'Visa Debit', "value":'Visa Debit'});
		$scope.cardTypes.push({"key":'Electron', "value":'Electron'});
		$scope.cardTypes.push({"key":'Maestro', "value":'Maestro'});
		$scope.cardTypes.push({"key":'MasterCard Debit', "value":'MasterCard Debit'});
		$scope.cardTypes.push({"key":'MasterCard', "value":'MasterCard'});
		$scope.cardTypes.push({"key":'Visa', "value":'Visa'});

		$scope.TakePayment = function()
		{
			serviceApplication.LoadShow('Processing...');
			$scope.Errors = null;
			var data = {'IsRemainderAdminFee' : $scope.IsRemainderAdminFee, 'OppId' : $scope.OppId, 'SelectedCardId' : $scope.SelectedCard.CardId, 'PaymentValue' : $scope.Data.AdminFee};

			serviceHPPEventTakeCardPayment.TakePayment(data)
                .then(
                    function(result){
		
                        if(result.Success)
                        {
		 
				$scope.AdminFeeTaken = true;
                        }
                        else
                        {
				$scope.Errors = result.Errors;
                        }
			serviceApplication.LoadHide(false);
                    },
                    function(error){
                        $scope.State = 'ERROR';
			serviceApplication.LoadHide(false);
                    }
                   );

		}

		$scope.TakeOtherPayment = function()
		{
			serviceApplication.LoadShow('Processing...');
			$scope.Errors = null;
			

			serviceHPPEventTakeCardPayment.TakeOtherPayment($scope.OppId, $scope.IsRemainderAdminFee, $scope.Data.Payment,$scope.Data.AdminFee)
                .then(
                    function(result){
		
                        if(result.Success)
                        {
		 		$scope.AdminFeeTaken = true;

                        }
                        else
                        {
				$scope.Errors = result.Errors;
                        }
			serviceApplication.LoadHide(false);
                    },
                    function(error){
                        $scope.State = 'ERROR';
			serviceApplication.LoadHide(false);
                    }
                   );
		}

		$scope.Complete = function()
		{
			serviceApplication.LoadShow('Processing...');
			$scope.Errors = null;
			

			serviceHPPEventTakeCardPayment.Complete($scope.OppId, $scope.IsRemainderAdminFee, $scope.EventLogId)
                .then(
                    function(result){
		
                        if(result.Success)
                        {
		 		$window.location.href = result.Url.FormatURL();

                        }
                        else
                        {
				$scope.Errors = result.Errors;
				serviceApplication.LoadHide(false);
                        }
			
                    },
                    function(error){
                        $scope.State = 'ERROR';
			serviceApplication.LoadHide(false);
                    }
                   );
		}





		$scope.Save = function()
                    {                   
			$scope.SaveCardErrors = null;
			serviceApplication.LoadShow('Processing...');
			$scope.NewCard.ContactId = $scope.ContactId;
			$scope.NewCard.AccountId = $scope.AccountId;
   
			serviceHPPEventTakeCardPayment.SaveCard($scope.NewCard)
                .then(
                    function(result){
                        if(result.Success)
                        {
				 
				 $scope.NewCard.CardId = result.CardId;
				 $scope.NewCard.CardNumber = result.CardName;

				$scope.SelectedCard = $scope.NewCard;
                    
                        $scope.Data.Cards.push($scope.NewCard); 
                        
                        $scope.NewCard = {};   
                        $scope.ShowNewCard = false;  

                        }
                        else
                        {
				$scope.SaveCardErrors = result.Errors;
                        }
			serviceApplication.LoadHide(false);
                    },
                    function(error){
			serviceApplication.LoadHide(false);
                        $scope.State = 'ERROR';
                    }
                   );




                                            
                    
                    }
                    
                    $scope.SelectCard = function(card)
                    {
                        $scope.SelectedCard = card;
                    }
                    
                    $scope.CreateNewCard = function()
                    {
                        $scope.NewCard = {};
                        $scope.NewCard.BillingStreet = $scope.Data.Address.BillingStreet;
                        $scope.NewCard.BillingCity = $scope.Data.Address.BillingCity;
                        $scope.NewCard.BillingCounty = $scope.Data.Address.BillingCounty;
                        $scope.NewCard.BillingPostCode = $scope.Data.Address.BillingPostCode;
                        $scope.NewCard.BillingCountry = $scope.Data.Address.BillingCountry;
                        
                        $scope.ShowNewCard = true;
			$scope.SaveCardErrors = null;
                    }


                
	$scope.SaveNewCard = function(){


		

		serviceHPPEventTakeCardPayment.SaveCard(md)
                .then(
                    function(result){
                        if(result.Success)
                        {
	

                        }
                        else
                        {

                        }
                    },
                    function(error){
                        $scope.State = 'ERROR';
                    }
                   );


	};


}]);