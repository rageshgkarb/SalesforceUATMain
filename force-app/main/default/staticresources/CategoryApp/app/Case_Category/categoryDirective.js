angular.module("question.directives", [])
    .directive('questionAnswer', function (questionAnswerFactory, $rootScope, $timeout) {
        return {
            restrict: 'EA',
            templateUrl: 'Case_Category/quesAns.html',
            scope: false,
            link: function (scope, element, attrs) {

            }

        }
    })
