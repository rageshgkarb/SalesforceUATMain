tellerApp.service('serviceStateTransition', ['$q', '$rootScope', '$state' , 'serviceParameters', 'serviceMessageBroker',
    function ($q, $rootScope, $state, serviceParameters, serviceMessageBroker) {

        this.GotoState = function(state)
        {
            if(typeof state == 'undefined' || state == '')
            {
                console.log('GotoState - Warning: unable to route as state name is empty');
            }
            else
            {
                $state.transitionTo(state);
            }
        }

        this.GotoState = function(state, args)
        {
            if(typeof state == 'undefined' || state == '')
            {
                console.log('GotoState - Warning: unable to route as state name is empty');
            }
            else
            {
                serviceParameters.StateParams.Params = args;
                $state.transitionTo(state);
            }
        }

        this.GotoCustomerSearch = function(searchCriteria)
        {
            serviceParameters.CustomerSearchParams.SearchCriteria = searchCriteria;

            if($state.current.name == 'customers')
            {
                $state.go($state.current, {}, {reload: true});
            }
            else
            {
                $state.transitionTo('customers');
            }
            
        }

        this.GotoCustomerSummary = function(customer)
        {
            serviceParameters.CustomerParams.Initialise();
            serviceParameters.CustomerParams.SelectedId = customer.Id;
            serviceParameters.CustomerParams.SelectedEBSId = customer.EBSId;
            
            if(typeof customer.Name != 'undefined' && typeof customer.Address != 'undefined')
            {
                serviceParameters.CustomerSearchParams.AddRecentCustomer(customer);
            }

            if($state.current.name == 'customercore.customersummary')
            {
                serviceMessageBroker.CustomerRefresh();
            }
            else
            {
                $state.transitionTo('customercore.customersummary');
            }
        }

        this.GetCurrentStateParam = function(state, param)
        {
            if($state.current.name == state)
            {
                if(typeof $state.params[param] != 'undefined')
                {
                    return $state.params[param];
                }

                return '';
            }

            return '';
        }
}]);