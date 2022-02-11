//Directive to provide a printable Html element
//usage: <button style="float:right;" arb-Print="arbPrint" print-element-id="elementIdToPrint">Print</button>
tellerApp.directive('arbPrint', ['$window', function ($window) {

  var directive = {
    restrict: 'A',
    link: function (scope, element, attrs) {
      function printElement(event) {
        var elementToPrint = document.getElementById(attrs.printElementId);
        if (elementToPrint) {
          var popupWindow = $window.open('', '_blank', 'width=800, height=600, directories=no, location=no, status=no');
          popupWindow.document.childNodes[0].innerHTML = '<html><head><link rel="stylesheet" type="text/css" href="test.css" /></head><body>' + elementToPrint.innerHTML + '</html>';
          popupWindow.print();
          popupWindow.document.close();
          popupWindow.close();
        }
        else {
          var stringToPrint = $("<p/>").html(attrs.printHtmlString).text();
          if (stringToPrint) {
            var popupWindow = $window.open('', '_blank', 'width=800, height=600, directories=no, location=no, status=no');
            popupWindow.document.childNodes[0].innerHTML = '<html><head><link rel="stylesheet" type="text/css" href="test.css" /></head><body>' + stringToPrint + '</html>';
            popupWindow.print();
            popupWindow.document.close();
            popupWindow.close();
          }
          else {
            alert('Error: Print template is corrupt');
          }
        }
      }

      element.on('click', printElement);
    }
  };
  return directive;
}]);


//Directive to bind to dynamic HTML and re-compile to bind to angular controller 
//usage: <div  arb-Dynamic-Html="arbDynamicHtml" dynamic-template="{{property}}"></div>
tellerApp.directive('arbDynamicHtml', ['$compile', 'serviceApplication', function ($compile, serviceApplication) {

 	var directive = {
    link: function (scope, element, attrs) {

      function compileTemplate(htmlText) {
        element.html(htmlText);
        $compile(element.contents())(scope);
      }

      attrs.$observe('dynamicTemplate', function (value) {
        if (value != '') {
          var result = serviceApplication.ParseHTML(value);
          compileTemplate(result);
        }
      });

    }
  };
 	return directive;
}]);

//Directive to set focus on a control bound to an attribute value
//usage as an attribute on a control: arb-focus="headerSearchOpen" 
tellerApp.directive('arbFocus', ['$timeout', function ($timeout) {
  return {
    link: function (scope, element, attrs) {

      function setFocus(value) {
        if (typeof value != 'undefined' && value != '' && value != 'false') {

          console.log('value=', value);
          element[0].focus();

          var delay = 250;

          if (element[0].attributes != null) {
            var result = element[0].attributes.getNamedItem('arb-Focus-Delay');
            if (result != null) {
              delay = result.value;
            }
          }

          $timeout(function () {
            element.focus();
          }, delay);
        }
      }

      scope.$watch(attrs.arbFocus, function (value) {
        setFocus(value);
        // if(value === true) { 

        //   console.log('value=',value);
        //   element[0].focus(); 

        //   var delay = 250;

        //   if(element[0].attributes != null)
        //   {
        //       var result = element[0].attributes.getNamedItem('arb-Focus-Delay');
        //       if(result != null)
        //       {
        //         delay = result.value;
        //       }
        //   }

        //   $timeout(function() {
        //     element.focus();
        //   }, delay);
        // }
      });

      attrs.$observe('arbFocus', function (value) {
        setFocus(value);
      });
    }
  };
}]);

//Directive to capture enter key press
//usage as an attribute:
tellerApp.directive('arbEnter', function () {
  return function (scope, element, attrs) {
    element.bind("keydown keypress", function (event) {
      if (event.which === 13) {
        scope.$apply(function () {
          scope.$eval(attrs.arbEnter);
        });

        event.preventDefault();
      }
    });
  };
});

//Directive to handle UI events for material select box
//usage: arb-Material-Select="arbMaterialSelect"
tellerApp.directive('arbMaterialSelect', ['$timeout', function ($timeout) {
  return function (scope, element, attrs, ngModel) {


    $timeout(function () {

      var k_input = angular.element(element.parent().children()[0].children[0]);
      k_input.on('blur', function (e) {
        if (e.currentTarget.value.length == 0) {
          var highlight = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('md_label')[0]);
          highlight.removeClass('md_label_active');
        }
        var bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-combobox')[0]);
        if (bar.length == 0) {
          bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-datetimepicker')[0]);
        }
        bar.removeClass('kendo-focused');
      });

      k_input.on('focus', function (e) {
        var highlight = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('md_label')[0]);
        highlight.addClass('md_label_active');
        var bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-combobox')[0]);
        if (bar.length == 0) {
          bar = angular.element(e.currentTarget.parentElement.parentElement.parentElement.getElementsByClassName('k-datetimepicker')[0]);
        }
        bar.addClass('kendo-focused');
      });

    }, 1500);

  };
}]);

//Directive to handle UI events for material select box wathes changes on mdel property and updates the UI
//usage: arb-Material-Select-Value="model.proerty"
tellerApp.directive('arbMaterialHighlightValue', ['$timeout', function ($timeout) {
  return function (scope, element, attrs, ngModel) {
    if (typeof attrs.arbMaterialHighlightValue != 'undefined' && attrs.arbMaterialHighlightValue != null) {
      attrs.$observe('arbMaterialHighlightValue', function (value) {
        var kendo = element.data("kendoComboBox");
        if (typeof kendo != 'undefined') {
          kendo.value(value);
        }

        if (value != null || value != '') {
          var highlight = angular.element(element[0].parentElement.parentElement.parentElement.getElementsByClassName('md_label')[0]);
          if (value != '' || value != null || typeof value != 'undefined') {
            highlight.addClass('md_label_active');
          }
          else {
            highlight.removeClass('md_label_active');
          }
        }
      });
    }
  }
}]);

tellerApp.directive('arbMaterialSelectDisable', [function () {
  return function (scope, element, attrs, ngModel) {
    if (typeof attrs.arbMaterialSelectDisable != 'undefined' && attrs.arbMaterialSelectDisable != null) {
      attrs.$observe('arbMaterialSelectDisable', function (value) {
        var kendo = element.data("kendoComboBox");
        if (typeof kendo != 'undefined') {
          if (value == 'false') {
            kendo.enable();
          }
          else {
            kendo.enable(false);
          }
        }
      });
    }
  }
}]);

//Directive to bind changes to property
//usage: contenteditable="true" ng-model="property" type="number"
tellerApp.directive('contenteditable', ['$sce', '$filter', function ($sce, $filter) {
  return {
    restrict: 'A', // only activate on element attribute
    require: '?ngModel', // get a hold of NgModelController
    link: function (scope, element, attrs, ngModel) {
      if (!ngModel) return; // do nothing if no ng-model

      var isBlur = false;

      // var updateTillCountDenomination = null;
      // if (typeof attrs.updateTillCount != 'undefined')
      //   updateTillCountDenomination = attrs.updateTillCount;

      // Specify how UI should be updated
      ngModel.$render = function () {
        element.html($sce.getTrustedHtml(ngModel.$viewValue || ''));
      };

      // Listen for change events to enable binding
      element.on('blur change', function (event) {

        isBlur = false;
        if (event.type == 'blur') {
          isBlur = true;
        }
        scope.$evalAsync(read);
      });
      read(); // initialize

      ngModel.$render = function () {

        if (attrs.type == 'currency' || attrs.type == 'none') {
          // var currencySymbol = '';
          // if(typeof attrs.currency != 'undefined' && attrs.currency != '')
          // {
          //   currencySymbol = attrs.currency;
          // }

          element.html($filter('number')(ngModel.$viewValue, '2'));
        }
        else {
          element.html(ngModel.$viewValue);
        }
      };

      // Write data to the model
      function read() {
        console.log(ngModel.$modelValue);
        var html = element.html();
        // When we clear the content editable the browser leaves a <br> behind
        // If strip-br attribute is provided then we strip this out
        if (attrs.stripBr && html == '<br>') {
          html = '';
        }

        if (attrs.type == 'integer') {
          html = parseInt(html);
          if (isNaN(html)) {
            html = 0;
          }
        }

        if (attrs.type == 'number') {
          html = parseFloat(html);
          if (isNaN(html)) {
            html = 0;
          }
        }

        if (attrs.type == 'currency') {
          html = parseFloat(html);
          if (isNaN(html)) {
            html = 0;
          }
        }

        if (attrs.type == 'none') {         
          if (isNaN(parseFloat(html)))
            return;
        }

        if (typeof attrs.change != 'undefined' && attrs.change != '') {
          if (typeof attrs.sourcename != 'undefined' && attrs.sourcename != '') {
            if (attrs.sourcename == 'denomItem' && typeof scope.denomItem != 'undefined' && scope.denomItem != null) {
              if (isBlur && attrs.change == 'TotalValue' && typeof attrs.denomvalue != 'undefined' && attrs.denomvalue != '') {
                var dValue = parseFloat(attrs.denomvalue);
                if (html < dValue) {
                  html = 0;
                }
                else {
                  var val = parseInt(html * 100) / parseInt(dValue * 100);
                  if (val - Math.floor(val) != 0) {
                    html = 0;
                  }
                }
              }

              scope.denomItem.change = attrs.change;
            }
          }
        }

        ngModel.$setViewValue(html);

        if (isBlur)
          ngModel.$render();
      }
    }
  };
}]);


tellerApp.directive('arbAccountNumberInput', function ($filter, $browser) {
  return {
    require: 'ngModel',
    link: function (scope, element, attrs, ngModelCtrl) {


      if (attrs.arbAccountNumberInput == 'true') {
        var listener = function () {
          element.val($filter('filter_accountNumber')(ngModelCtrl.$viewValue, false))
        }

        // // This runs when we update the text field
        // ngModelCtrl.$parsers.push(function(viewValue) {
        //     return viewValue.replace(/,/g, '');
        // })

        // This runs when the model gets updated on the scope directly and keeps our view in sync
        ngModelCtrl.$render = function () {
          element.val($filter('filter_accountNumber')(ngModelCtrl.$viewValue, false))
        }

        element.bind('change', listener);
        element.bind('keydown', listener);

        element.bind('paste cut', function () {
          $browser.defer(listener)
        })
      }
    }

  }
});

tellerApp.directive('arbInputFilterOnLeave', function ($filter, $browser) {
  return {
    require: 'ngModel',
    link: function (scope, element, attrs, ngModelCtrl) {


      if (typeof attrs.arbInputFilter != 'undefined' && attrs.arbInputFilter != '') {

        var args = (typeof attrs.arbInputFilterArgs != 'undefined' | attrs.arbInputFilterArgs != null | attrs.arbInputFilterArgs != '') ? attrs.arbInputFilterArgs : false;

        var listener = function () {
          if (typeof ngModelCtrl.$viewValue != 'undefined' || ngModelCtrl.$viewValue != null)
            element.val($filter(attrs.arbInputFilter)(ngModelCtrl.$viewValue, args));
        }

        ngModelCtrl.$render = function () {
          if (typeof ngModelCtrl.$viewValue != 'undefined' || ngModelCtrl.$viewValue != null)
            element.val($filter(attrs.arbInputFilter)(ngModelCtrl.$viewValue, args));
        }

        element.bind('blur', listener);
        element.bind('focus', listener);

        element.bind('paste cut', function () {
          $browser.defer(listener)
        })
      }
    }

  }
});

tellerApp.directive('arbInputFilter', function ($filter, $browser) {
  return {
    require: 'ngModel',
    link: function (scope, element, attrs, ngModelCtrl) {


      if (typeof attrs.arbInputFilter != 'undefined' && attrs.arbInputFilter != '') {

        var args = (typeof attrs.arbInputFilterArgs != 'undefined' | attrs.arbInputFilterArgs != null | attrs.arbInputFilterArgs != '') ? attrs.arbInputFilterArgs : false;

        var listener = function () {
          if (typeof ngModelCtrl.$viewValue != 'undefined' || ngModelCtrl.$viewValue != null)
            element.val($filter(attrs.arbInputFilter)(ngModelCtrl.$viewValue, args));
          if (attrs.arbInputFilter == 'number' && element.val() == '') {
            ngModelCtrl.$viewValue = 0;
            element.val($filter(attrs.arbInputFilter)(ngModelCtrl.$viewValue, args));
          }
        }

        // // This runs when we update the text field
        // ngModelCtrl.$parsers.push(function(viewValue) {
        //     return viewValue.replace(/,/g, '');
        // })

        // This runs when the model gets updated on the scope directly and keeps our view in sync
        ngModelCtrl.$render = function () {
          if (typeof ngModelCtrl.$viewValue != 'undefined' || ngModelCtrl.$viewValue != null)
            element.val($filter(attrs.arbInputFilter)(ngModelCtrl.$viewValue, args));
          if (attrs.arbInputFilter == 'number' && element.val() == '') {
            ngModelCtrl.$viewValue = 0;
            element.val($filter(attrs.arbInputFilter)(ngModelCtrl.$viewValue, args));
          }
        }

        if (typeof attrs.arbInputFilterOnLeave != 'undefined' && attrs.arbInputFilterOnLeave != null && attrs.arbInputFilterOnLeave == 'true') {
          element.bind('blur', listener);
          element.bind('focus', listener);
        }
        else {
          element.bind('change', listener);
          element.bind('keydown', listener);
        }

        element.bind('paste cut', function () {
          $browser.defer(listener)
        })
      }
    }

  }
});


tellerApp.directive('arbInputParseHtml', ["serviceApplication", function () {
  return {
    require: 'ngModel',
    link: function (scope, element, attrs, ngModelCtrl) {
      var args = false;
      if (typeof attrs.arbInputParseHtml != 'undefined' | attrs.arbInputParseHtml != null | attrs.arbInputParseHtml != '') {
        args = attrs.arbInputParseHtml == 'false' ? false : true;
      }
      if (args == true) {
        scope.$watch(function () {
          return ngModelCtrl.$modelValue;
        }, function (newValue) {
          var result = jQuery.parseHTML(newValue);
          if (result != null) {
            element.val(result[0].data);
          }
        });
      }
    }

  }
}]);

tellerApp.directive('arbSelectOnClick', [function () {
  return {
    restrict: 'A',
    link: function (scope, element, attrs) {
      var focusedElement;
      if (attrs['arbSelectOnClick'] == 'true') {
        element.on('click', function () {
          if (focusedElement != this) {
            this.select();
            focusedElement = this;
          }
        });
        element.on('blur', function () {
          focusedElement = null;
        });
      }
    }
  };
}]);


//http://codereview.stackexchange.com/questions/61638/custom-angular-directive-for-data-binding-on-teleriks-kendo-ui
//Directive to data bind the object in a kendo selection control
// Usage: k-data-bind="modelproperty"
tellerApp.directive("kDataBind", ["$parse", function ($parse) {
  return {
    restrict: "A",
    scope: false,
    link: function (scope, element, attributes, controller) {
      var getter = $parse(attributes.kDataBind),
        setter = getter.assign,
        // the property for the kendo data value field, if it is given. this
        // property is needed by some of the widgets so that it can compare selected
        // information to that stored in the widget's bound data source, and pull full
        // objects out without trouble.
        property = $parse(attributes.kDataValueField)() || null,

        // a function to fire when the widget changes, encapsulated here
        // simply to provide more consistency.
        onChange = function (t, f, event) {
          t.bind(event || 'change', function (e) {
            scope.$apply(function () {
              f(e);
            });
          });
        },

        // a function to fire when the model value changes, encapsulated here
        // simply to provide more consistency.
        onWatch = function (f) {
          scope.$watch(getter, function (n, o) {
            f(n, o);
          });
        },

        // a function to fire when the widget is finished rendering, encapsulated here
        // simply to provide more consistency. This is the best place to cause the
        // widget to 'default' to a state that mirrors the data it is bound to on the model
        onRendered = function (f) {
          scope.$on('kendoRendered', function () {
            f();
          });
        };

      scope.$on('kendoWidgetCreated', function (event, target) {
        // first, make sure we're interacting with the actual widget we
        // want to work on, and not a different one - since this event is
        // raised for every kendo widget on the page
        if ($(target.element)[0] === $(element)[0]) {
          // determine behavior based on the specific widget. This is necessary because
          // each widget may be different. For example, the kendoDropDownList accepts information
          // using the .select(n) function, but the kendoMultiSelect only takes information using
          // the .value(arr) function. 

          // we are using onWatch and onChange purely for matters of consistency. The goal is to
          // keep as much of the code re-usable as possible for the sake of trying to tighten the
          // behaviors between each other. 
          switch (target.options.name) {
            case "DropDownList":
            case "ComboBox":
              (function () {
                onWatch(function (n, o) {
                  target.select(function (dataItem) {
                    return dataItem[property] === n[property];
                  });
                });
                onChange(target, function (e) {
                  //setter(scope, e.sender.dataItem().toJSON());
                  setter(scope, e.sender.dataItem().stringify());
                });
              })();
              break;
            case "MultiSelect":
              (function () {
                onWatch(function (n, o) {
                  var values = $.map(getter(scope), function (val, i) {
                    return val[property];
                  }); target.value(values);
                });
                onChange(target, function (e) {
                  setter(scope, target.dataItems().slice(0));
                });
                onRendered(function () {
                  var values = $.map(getter(scope), function (val, i) {
                    return val[property];
                  }); target.value(values);
                });
              })();
              break;
            case "AutoComplete":
              (function () {
                onChange(target, function (e) {
                  //setter(scope, e.sender.dataItem(e.item.index()).toJSON());
                  setter(scope, e.sender.dataItem(e.item.index()).stringify());
                }, 'select');
              })();
              break;
            case "DatePicker":
            case "DateTimePicker":
            case "TimePicker":
              (function () {
                onWatch(function (n, o) {
                  target.value(kendo.parseDate(n));
                });
                onChange(target, function (e) {
                  //setter(scope, e.sender.value().toJSON());
                  setter(scope, e.sender.value().stringify());
                });
                onRendered(function () {
                  target.value(kendo.parseDate(getter(scope)));
                });
              })();
              break;
            case "Grid":
              (function () {
                onChange(target, function (e) {
                  //setter(scope, e.sender.dataItem(e.sender.select()).toJSON());
                  setter(scope, e.sender.dataItem(e.sender.select()).stringify());
                });
              })();
              break;
            case "ColorPalette":
            case "MaskedTextBox":
            case "NumericTextBox":
            case "Slider":
            case "Editor":
              (function () {
                onWatch(function (n, o) {
                  target.value(n);
                });
                onChange(target, function (e) {
                  setter(scope, e.sender.value());
                });
                onRendered(function () {
                  target.value(getter(scope));
                });
              })();
              break;
            case "ListView":
              (function () {
                onChange(target, function (e) {
                  var data = target.dataSource.view(),
                    selected = $.map(target.select(), function (item) {
                      return data[$(item).index()];
                    });
                  setter(scope, selected);
                });
              })();
              break;
          }
        }

      });
    }
  }
}]);

/*!
 * angularjs-breakpoint v0.0.1
 *
 * BREAKPOINT DIRECTIVE FOR RESPONSIVE WEBSITES
 *
 *  http://snapjay.github.com/angularjs-breakpoint/
 *  Apply as a attribute of the body tag. Set
 *  breakpoint="{1250:'break1250', 1000:'break1000',1120:'break1120'}
 *
 *  Values are available on scope as
 *  {{breakpoint.class}} = current set class
 *  {{breakpoint.windowSize}} = current width of window
 */

tellerApp.directive('breakpoint', ['$window', '$rootScope', function ($window, $rootScope) {
  return {
    restrict: "A",
    link: function (scope, element, attr) {
      scope.breakpoint = { class: '', windowSize: $window.innerWidth }; // Initialise Values

      var breakpoints = (scope.$eval(attr.breakpoint));
      var firstTime = true;

      angular.element($window).bind('resize', setWindowSize);

      scope.$watch('breakpoint.windowSize', function (windowWidth, oldValue) {
        setClass(windowWidth);
      });

      scope.$watch('breakpoint.class', function (newClass, oldClass) {
        if (newClass != oldClass || firstTime) {
          broadcastEvent(oldClass);
          firstTime = false;
        }
      });

      function broadcastEvent(oldClass) {
        $rootScope.$broadcast('breakpointChange', scope.breakpoint, oldClass);
      }

      function setWindowSize() {
        scope.breakpoint.windowSize = $window.innerWidth;
        if (!scope.$$phase) scope.$apply();
      }

      function setClass(windowWidth) {
        var setClass = breakpoints[Object.keys(breakpoints)[0]];
        for (var breakpoint in breakpoints) {
          if (breakpoint < windowWidth) setClass = breakpoints[breakpoint];
          element.removeClass(breakpoints[breakpoint]);
        }
        element.addClass(setClass);
        scope.breakpoint.class = setClass;
        if (!scope.$$phase) scope.$apply();
      }
    }
  }
}]);



