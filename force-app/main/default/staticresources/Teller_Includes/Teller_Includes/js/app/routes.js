//Routes

tellerApp.config(function($stateProvider, $urlRouterProvider, $uiViewScrollProvider) {

  //$uiViewScrollProvider.useAnchorScroll();
  //$urlRouterProvider.otherwise("/home");
  $stateProvider
    // .state('home', 
    // {
    //     url: "/home",
    //     views:
    //     {
    //       "viewContent": { templateUrl: "apex/teller_splash" }          
    //     } ,
    //     controller: 'CoreController'
    // })

    .state('customers', 
    {
        url: "/customer",
        views:
        {
          "viewContent": { templateUrl: "apex/teller_customersearch" }
        } ,
        controller: 'controllerCustomer'
    })

    .state('customercore', 
    {
        url: "/customer",
        views:
        {
          "viewContent": { templateUrl: "apex/teller_customercore" }
        } ,
        controller: 'controllerCustomerDetails'
    })

        .state('customercore.customersummary', 
        {
            url: "/customersummary?mode=:&id=:",
            views:
            {
              "viewCustomerChild": { templateUrl: "apex/teller_customersummary" }              
            } 
        })

        .state('customercore.customertransaction', 
        {
            url: "",
            views:
            {
              "viewContent": { templateUrl: "apex/teller_customer" },
              "viewCustomerChild": { templateUrl: "apex/teller_function_transaction_new" }
            } 
        })


    .state('customerview', 
    {
        url: "/customer",
        views:
        {
          "viewContent": { templateUrl: "apex/teller_customer" }
        } 
    })

    .state('tillmanagement', 
    {
        url: "/customers",
        views:
        {
          "viewContent": { templateUrl: "apex/teller_till_management" }
        } ,
        controller: ''
    })

    .state('security', 
    {
        url: "/security",
        views:
        {
          "viewContent": { templateUrl: "apex/teller_security" }
        } ,
        controller: ''
    })

    .state('mandates', 
    {
        url: "/mandates",
        views:
        {
          "viewContent": { templateUrl: "apex/teller_mandatescore" }
        } ,
        controller: 'Teller_MandatesController'
    })

        .state('mandates.mandates_search', 
        {
            url: "/mandatessearch",
            views:
            {
              "viewMandateChild": { templateUrl: "apex/teller_mandatessearch" }
            } ,
            controller: 'Teller_MandatesController'
        })

        .state('mandates.mandate_view', 
        {
            url: "/mandateview",
            views:
            {
              "viewMandateChild": { templateUrl: "apex/teller_mandateview" }
            } ,
            controller: 'Teller_MandatesController'
        })

        .state('mandates.mandateaccountholder_edit', 
        {
            url: "/mandateaccountholderedit",
            views:
            {
              "viewMandateChild": { templateUrl: "apex/teller_mandatesaccountholderedit" }
            } ,
            controller: 'Teller_MandatesController'
        })

        .state('mandates.mandate_edit', 
        {
            url: "/mandateedit",
            views:
            {
              "viewMandateChild": { templateUrl: "apex/teller_mandateedit" }
            } ,
            controller: 'Teller_MandatesController'
        })

    .state('depository', 
    {
        url: "/depository", 
        views:
        {
          "viewContent": { templateUrl: "apex/teller_depositorycore" }
        } ,
        controller: ''
    })

        .state('depository.tellerbalancetill', 
        {
            url: "/tellerbalancetill",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_balancetill" }
            } ,
            controller: ''
        })

        .state('depository.tellerbalancevault', 
        {
            url: "/tellerbalancevault",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_balancevault" }
            } ,
            controller: ''
        })

        .state('depository.telleropentill', 
        {
            url: "/telleropentill",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_opentill" }
            } ,
            controller: ''
        })

        .state('depository.tellerclosetill', 
        {
            url: "/tellerclosetill",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_closetill" }
            } ,
            controller: ''
        })

        .state('depository.tellerdenominationschange', 
        {
            url: "/tellerdenominationschange",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_denominationschange" }
            } ,
            controller: ''
        })

        .state('depository.tellertilltransferout', 
        {
            url: "/tellertilltransferout",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_tilltransferout" }
            } ,
            controller: ''
        })

        .state('depository.tellertilltransferacceptance', 
        {
            url: "/tellertilltransferacceptance",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_tilltransferacceptance" }
            } ,
            controller: ''
        })

        .state('depository.tellervaulttransferout', 
        {
            url: "/tellervaulttransferout",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_vaulttransferout" }
            } ,
            controller: ''
        })

        .state('depository.tellervaulttransferacceptance', 
        {
            url: "/tellervaulttransferacceptance",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_vaulttransferacceptance" }
            } ,
            controller: ''
        })

        .state('depository.tellercashovers', 
        {
            url: "/tellercashovers",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_function_transaction_new" }
            } ,
            controller: ''
        })

        .state('depository.tellercashunders', 
        {
            url: "/tellercashunders",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_function_transaction_new" }
            } ,
            controller: ''
        })

        .state('depository.tellerbulkcashdeposit', 
        {
            url: "/tellerbulkcashdeposit",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_function_transaction_new" }
            } ,
            controller: ''
        })

        .state('depository.tellerbulkcashwithdrawal', 
        {
            url: "/tellerbulkcashwithdrawal",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_function_transaction_new" }
            } ,
            controller: ''
        })

        .state('depository.tellervaultovers', 
        {
            url: "/tellervaultovers",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_function_transaction_new" }
            } ,
            controller: ''
        })

        .state('depository.tellervaultunders', 
        {
            url: "/tellervaultunders",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_function_transaction_new" }
            } ,
            controller: ''
        })

        .state('depository.tellerbgccashdeposit', 
        {
            url: "/tellerbgccashdeposit",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_function_transaction_new" }
            } ,
            controller: ''
        })

        .state('depository.tellerfxexchangecash', 
        {
            url: "/tellerfxexchangecash",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_function_transaction_new" }
            } ,
            controller: ''
        })

        .state('depository.tellerreconcilebranch', 
        {
            url: "/tellerreconcilebranch",
            views:
            {
              "viewDepositoryChild": { templateUrl: "apex/teller_reconcilebranch" }
            } ,
            controller: ''
        })

    .state('activities', 
    {
        url: "/activities",        
        views:
        {
          "viewContent": { templateUrl: "apex/teller_activities" }
        } ,
        controller: ''
    })   

    .state('foreignexchange',
    {
        url:"/foreignexchange",
        views:
        {
            "viewContent" : { templateUrl: "apex/teller_foreign_exchange"}
        },
        controller: ''
    })

});