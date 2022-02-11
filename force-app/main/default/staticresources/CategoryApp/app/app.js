/*app.js to bootstrap application and defining the routing of the application */

angular.module("caseApp", ['ui.router', 'ngMaterial', 'ngSanitize', 'ngAnimate', 'question.controller', 'question.directives', 'question.services','ui.bootstrap'])
    .run(function () {})
    .config(function ($stateProvider, $urlRouterProvider) {

        $stateProvider
            .state('home', {
                url: "/home",
                templateUrl: "Case_Category/question.html",
                controller: "questionCtrl"
            })

        //for unmatched url redirect to home
        $urlRouterProvider.otherwise("/home");
    })
