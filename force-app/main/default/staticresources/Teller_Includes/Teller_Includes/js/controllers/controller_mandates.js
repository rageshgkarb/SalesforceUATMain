tellerApp.controller('controllerMandates', ['$scope', '$state', 'serviceMandates', 'serviceParameters', function ($scope, $state, serviceMandates, serviceParameters) {

    $scope.thisPageTitle = "Mandate Search";
    $scope.stage = '0';

    $scope.GoBackToSearch = function () {

        if($state.current.name == "mandates.mandate_edit")
        {
            $state.transitionTo('mandates.mandate_view');  
        }
        else
        {
            $scope.stage = '0';
            $scope.thisPageTitle = "Mandate Search";
            $state.transitionTo('mandates.mandates_search');  
        }
    }


    //Account Holder View -------------------------------------------------

    $scope.LoadSignatoriesAndGroups = function() {
        serviceMandates.LoadSignatoriesAndGroups(serviceParameters.MandateParams.Mandate_AccountNum)
            .then(
                    function (result) {
                        $scope.response = result;
                        if ($scope.response.Success) {
                            $scope.thisPageTitle = 'Account Holders for Account: ' + serviceParameters.MandateParams.Mandate_AccountNum;
                        }
                        else {
                            $scope.LoadSignatoriesAndGroupsError = result.ErrorMessage;
                        }

                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                    function (error) {
                        alert(error.message);
                    }
                );
    }

    $scope.SaveSignatories = function() {
        serviceMandates.SaveSignatories($scope.response.SignatoryList)
            .then(
                    function (result) {
                        $scope.response = result;
                        if ($scope.response.Success) {
                            $scope.LoadMandatesAndSignatoriesInternal();
                        }
                        else {
                            alert('Error saving Signatories');
                        }

                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                    function (error) {
                        alert(event.message);
                    }
                );
    }

    $scope.GotoSignatoryGroupEdit = function(mandateId)
    {
        serviceParameters.MandateParams.Mandate_SelectedId = mandateId;
        $state.transitionTo('mandates.mandateaccountholder_edit');
    }


    //Mandate View --------------------------------------------------------

    $scope.LoadMandatesAndSignatories = function () {
        serviceParameters.MandateParams.Mandate_AccountNum = this.SFind;
        $scope.LoadMandatesAndSignatoriesInternal();
    }

    $scope.LoadMandatesAndSignatoriesInternal = function() {
        serviceMandates.LoadMandatesAndSignatories(serviceParameters.MandateParams.Mandate_AccountNum)
            .then(
                    function (result) {
                        $scope.response = result;
                        if ($scope.response.Success) {
                            $scope.stage = '20';
                            $scope.thisPageTitle = 'Mandate: ' + serviceParameters.MandateParams.Mandate_AccountNum;
                            $state.transitionTo('mandates.mandate_view');
                            serviceParameters.MandateParams.Mandate_AccountId = result.AccountWithIBBId;
                        }
                        else {
                            $scope.stage = '99';
                            $scope.FindAccountError = result.ErrorMessage;
                        }

                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                    },
                    function (error) {
                        alert(event.message);
                    }
                );
    }

    $scope.init = function () {
        $scope.stage = '0';
    }

    $scope.DeleteMandate = function(mandateId)
    {
        serviceMandates.DeleteMandate(mandateId) 
            .then(
                    function (result) {
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                        if(result.Success){
                            alert("Mandate deleted Successfully");
                            $scope.LoadMandatesAndSignatoriesInternal();                            
                        }
                    },
                    function (error) {
                        alert(event.message);
                    }
                ); 
    }

    $scope.GotoMandateEdit = function(mandateId)
    {
        serviceParameters.MandateParams.Mandate_SelectedId = mandateId;
        $scope.LoadMandateItems();
    }

    //Mandate Edit-------------------------------------------------------------------------------

    $scope.LoadMandateItems= function()
    {        
        $scope.mandateRuleForm = {};        
        $scope.mandateRuleForm.ruleType = "signatoryGroup";
        $scope.mandateRuleForm.signatory = "";
        $scope.mandateRuleForm.signatoryGroup = "";
        $scope.mandateRuleForm.relationshiptype = "";
        $scope.mandateRuleForm.nofromgroup = "";

        var request = {MandateId: serviceParameters.MandateParams.Mandate_SelectedId, AccountWithIBBId: serviceParameters.MandateParams.Mandate_AccountId}; 
        serviceMandates.LoadMandateItems(request)
            .then(
                    function (result) {
                        $scope.responseMandate = result;
                        if (!$scope.$$phase) {
                            $scope.$apply();
                        }
                        $state.transitionTo('mandates.mandate_edit');
                    },
                    function (error) {
                        alert(event.message);
                    }
                ); 
    }

    $scope.AddMandateRule = function()
    {
        if( $scope.mandateRuleForm.ruleType == 'signatory')
        {
            if (($scope.mandateRuleForm.signatory.Value == null) || ($scope.mandateRuleForm.signatory.Value == '')){
                alert('No signatory selected');
            }
            else
            {
                $scope.responseMandate.MandateItems.push({
                    'SignatoryId' : $scope.mandateRuleForm.signatory.Value,
                    'Signatory' : $scope.mandateRuleForm.signatory.Label
                });
            }
        }
        else if ( $scope.mandateRuleForm.ruleType == 'signatoryGroup')
        {
            if (($scope.mandateRuleForm.signatoryGroup.Value == null) || ($scope.mandateRuleForm.signatoryGroup.Value == '')){
                alert('No signatory group selected');
            }
            else if (($scope.mandateRuleForm.nofromgroup == null) || ($scope.mandateRuleForm.nofromgroup == '')){
                alert('No numbers from group selected');
            }
            else
            {
                $scope.responseMandate.MandateItems.push({
                    'SignatoryGroup' :  $scope.mandateRuleForm.signatoryGroup.Value,
                    'NoFromGroup' : $scope.mandateRuleForm.nofromgroup
                });
            }
        }
        else if ( $scope.mandateRuleForm.ruleType == 'relationship')
        {
            if (($scope.mandateRuleForm.relationshiptype.Value == null) || ($scope.mandateRuleForm.relationshiptype.Value == '')){
                alert('No relationship type selected');
            }
            else if (($scope.mandateRuleForm.nofromgroup == null) || ($scope.mandateRuleForm.nofromgroup == '')){
                alert('No numbers from group selected');
            }
            else
            {
                $scope.responseMandate.MandateItems.push({
                    'RelationshipType' :  $scope.mandateRuleForm.relationshiptype.Value,
                    'NoFromGroup' : $scope.mandateRuleForm.nofromgroup
                });
            }
        }
    }

    $scope.SaveMandateRule = function(closeAfterSave)
    {
        var request = {
            MandateId : $scope.responseMandate.MandateId,
            AccountWithIBBId : serviceParameters.MandateParams.Mandate_AccountId,
            MandateLimit : $scope.responseMandate.MandateLimit,
            MandateItems : new Array()
        };

        var mandateError = false;
        var mandateErrorMessage = '';

        if ((request.MandateLimit == null) || (request.MandateLimit == '')){
            mandateError=true;
            mandateErrorMessage='Mandate Limit not set';
        }
        if ($scope.responseMandate.MandateItems.length < 1){
            mandateError=true;
            mandateErrorMessage='No mandate items have been selected';
        }

        if (!mandateError){
            for( var i = 0; i < $scope.responseMandate.MandateItems.length; i++ ) {

                var mandateItem = {
                    Signatory : $scope.responseMandate.MandateItems[i].Signatory,
                    SignatoryGroup : $scope.responseMandate.MandateItems[i].SignatoryGroup,
                    RelationshipType : $scope.responseMandate.MandateItems[i].RelationshipType,
                    NoFromGroup : $scope.responseMandate.MandateItems[i].NoFromGroup
                };
                
               request.MandateItems[request.MandateItems.length] = mandateItem;
            }

            serviceMandates.SaveMandateItems(request)
                .then(
                        function (result) {                        
                            if (!$scope.$$phase) {
                                $scope.$apply();
                            }

                            if (result.Success){
                                alert("Mandate Rule Saved Successfully");
                                $scope.LoadMandatesAndSignatoriesInternal();
                            }
                            else{
                                alert(result.ErrorMessage);
                            }
                        },
                        function (error) {
                            alert(error.message);
                        }
                    ); 
        }
        else {
            alert(mandateErrorMessage);
        }

    }

    $scope.RemoveMandateRule = function(index)
    {
        // var index = -1;
        // for (var i = 0; i < $scope.responseMandate.MandateItems.length; i++) {
        //     if ($scope.responseMandate.MandateItems[i].MandateItemId == mandateId) {
        //         index = i;
        //         break;
        //     }
        // }

        if (index === -1) {
            alert("Failed to remove Mandate");
        }
        else {
            $scope.responseMandate.MandateItems.splice(index, 1);
        }
    }
}]);