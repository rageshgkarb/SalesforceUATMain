/* Question Controller for binding the data with the view in question.html*/

angular.module("question.controller", [])
    .controller('questionCtrl', ['$scope','$rootScope','questionAnswerFactory','$uibModal',
		function ($scope, $rootScope, questionAnswerFactory, $uibModal) {

        /* Common Variables
        "$scope.loader"-Boolean variable to set to true on page data load 
        "currentlevel"- contains the value for the current level of the question
        "answerset"-contains the value of casetypehelper object/ CaseRecord type Object
        "questionSet"-conatins the value of caseQuestion object
        "flagNone"-Boolean variable se to true when none of the above option clicked
        */

        $scope.loader = true;
        $scope.searchFloat = false;
        $scope.data = {};
        $scope.data.searchRecordText;
        var currentlevel, answerset, questionSet, flagNone = false;
		
		
		/* BOC: SMS Disclaimer */
		$scope.openDisclaimer=function(message,agreeFunc,disagreeFunc){
			 $scope.disclaimerMessage=message;
			 $scope.agreeFunc=agreeFunc;
			 $scope.disagreeFunc=disagreeFunc;
			 var uibModalInstance= $uibModal.open({
			  animation: true,
			  templateUrl: 'myModalContent.html',
			  controller: 'detailsController',
			  size:'lg',
			  resolve: {
				params: function () {
					var params={
						disclaimerMessage:$scope.disclaimerMessage,
						agreeFunc:$scope.agreeFunc,
						disagreeFunc: $scope.disagreeFunc
					};
				  return params;
				}
			  }
			});
		};
		/* EOC: SMS Disclaimer */
		

        /*getAnswerTiles is a function to fetch the answer tiles for first level and when none of the option is selected 
        "answerset"- casetypehelper object/case record type object 
        "pushNone"-  Boolean variable to push option 'None of the above' if true */
        var getAnswerTiles = function (answerset, pushNone) {
            var tiles = [],
                count = 0;
            if (answerset && answerset.records) {
                if (pushNone) {
                    for (var e in answerset.records) {
                        var elem = answerset.records[e];
                        if (!("Parent__c" in elem)) {
                            if (questionAnswerFactory.keyAvailable(elem, false)) {

                                tiles.push({
                                    "name": elem.Option__c,
                                    "id": elem.Id,
                                    "recordName": elem.RecordType__c,
                                    "order": elem.Display_Order__c,
                                    "internalStaff": elem.Internal_Staff__c
                                });
                                count = elem.Display_Order__c + 1;
                            }
                        }
                    }
                    tiles.push({
                        name: "None of the Above",
                        id: "0case",
                        order: count
                    });
                } else {
                    for (var e in answerset.records) {
                        var elem = answerset.records[e];
                        if (questionAnswerFactory.keyAvailable(elem, true)) {
                            tiles.push({
                                "name": elem.Record_Type_Name__c,
                                "id": elem.Id,
                                "recordName": elem.Record_Type_Name__c,
                                "order": elem.Display_Order__c,
                                "internalStaff": elem.Internal_Staff__c
                            });
                        }
                    }
                }
            }
            tiles.sort(function (a, b) {
                return a.order - b.order;
            })
            return tiles;
        }

        /* Function to set the object for record type object in the search box  */

        var setSearchRecordobject = function () {
                $scope.recordObject = [];
                var recordType = questionAnswerFactory.getDataLayer("recordType");
                for (var e in recordType) {
                    var elem = recordType[e];
                    $scope.recordObject.push({
                        "name": elem.name,
                        "recordName": elem.id,
                        "id": 0,

                    });
                }
            }
            /* loadHomeQuestionset is  function to fetch all the level questions from caseQuestion object and to the fetch and populate the first level answers*/
        var loadHomeQuestionset = function () {
            currentlevel = 1;
            $scope.tiles = [];
            $scope.search = false;
            $scope.none = false;
            $scope.prevQuestion = '';
            $scope.isPrevQuestion = false;
            $scope.viewQuesBtn = false;
            questionSet = questionAnswerFactory.getDataLayer("questionsList");
            if (questionSet && questionSet.records) {
                for (var e in questionSet.records) {
                    if (questionSet.records[e].Level__c === currentlevel) {
                        $scope.question = questionSet.records[e].Question__c;
                    }
                }
            }
            answerset = questionAnswerFactory.getDataLayer("caseTypeHelper");
            $scope.tiles = getAnswerTiles(answerset, true);
            setSearchRecordobject();
            $scope.loader = false;
            $scope.$apply();
        }


        /*setDataLayers is a function to fetch the Sobject data from salesforce and save it as an object in the   questionAnswerFactory*/
        var setDataLayers = function () {
            questionAnswerFactory.setDataLayer({
                "key": "recordType",
                "data": window.caseRecord
            });
            var cq = new SObjectModel.CaseQuestion();
            cq.retrieve({}, function (err, records, event) {
                if (err) {
                    $scope.loader = false;
                    $scope.$apply();
                } else {
                    questionAnswerFactory.setDataLayer({
                        "key": "questionsList",
                        "data": event.result
                    });
                    var cr = new SObjectModel.CaseRecordType();
                    cr.retrieve({}, function (err, records, event) {
                        if (err) {
                            $scope.loader = false;
                            $scope.$apply();
                        } else {
                            questionAnswerFactory.setDataLayer({
                                "key": "caseRecordType",
                                "data": event.result
                            });
                            var ch = new SObjectModel.CaseTypeHelper();
                            ch.retrieve({
                                where: {
                                    Is_Active__c: {
                                        eq: true
                                    }
                                },
                                limit: 100
                            }, function (err, records, event) {
                                if (err) {
                                    $scope.loader = false;
                                    $scope.$apply();
                                } else {
                                    questionAnswerFactory.setDataLayer({
                                        "key": "caseTypeHelper",
                                        "data": event.result
                                    });
                                    loadHomeQuestionset();
                                    $scope.$apply();
                                }
                            });
                        }
                    });
                }
            });
        }

        /* call the setDataLayers() on the controller loads*/
        setDataLayers();

        /* getUrl is a function to form th url depending on the different parameters and returns a url to be redirected*/
        var getUrl = function (obj) {
            var base = baseUrl + '/500/e?nooverride=1&retURL=%2F500%2Fo&RecordType=' + $scope.caseId;
            if (obj.internalStaff) {
                // var staffFound, accountIdStaff;
                if (accountIdStaff.length) {
                    base = base + '&def_account_id=' + accountIdStaff;
                }
                if (staffFound.length) {
                    base = base + '&def_contact_id=' + staffFound;
                }
            } else {
                if (accountId.length) {
                    base = base + '&def_account_id=' + accountId;
                }
                if (staffNotFound.length) {
                    base = base + '&def_contact_id=' + staffNotFound;
                }
            }
            var webFormDataName = getParameterByName('WebFormDataName',window.location.search);
			
            if( (webFormDataName) && (WebFormFieldIdOnCase.length) ){
               // base += '&CF00N7E000000cXNs='+webFormDataName; WebFormFieldIdOnCase
			   base += '&' + WebFormFieldIdOnCase +'='+webFormDataName;
            }
            return base + '&ent=Case';
        }

        function getParameterByName(name, url) {
            if (!url) url = window.location.href;
            name = name.replace(/[\[\]]/g, "\\$&");
            var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
                results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, " "));
        }

        /* setCaseCategories is a function to fetch the data from caseRecordtype and populate when none of the above option is selected*/
        var setCaseCategories = function () {
            $scope.question = "Please select your case category";
            nextTask = questionAnswerFactory.getDataLayer("caseRecordType");
            $scope.tiles = getAnswerTiles(nextTask, false);
            $scope.viewQuesBtn = true;
            $scope.$apply();
        }

        /*$scope.nextTask is a function called on the click of the answer tiles if next level answers are founnd then populate the screen with new answer tiles and next level question else redirect to nnew formmed url*/
		$scope.nextTask = function (quesObj) {
			if(quesObj.name=='Customer Complaint'){
				var message="Would you be interested in our free text alert service, which keeps you updated with the progress of your complaint?<br/><br/>";

				message+="If caller answers YES:<br/><br/>";

				message+="Please note that Al Rayan Bank will not charge you for text alerts, and most UK mobile network providers will not charge you to receive text alerts from us.<br/><br/>";

				message+="Charges may apply if you are travelling abroad or using a non UK network provider. Please check with your network provider to clarify if any charges apply.<br/><br/>";

				message+="You can cancel the service at any time by calling our Customer Services team on 0800 4086 407.<br/><br/>";

				message+="Would you like to register for this service now?";

				$scope.openDisclaimer(message,function(){
					$scope.oNextTask(quesObj,'&00ND0000006EuPb=Yes');
				},
				function(){
					$scope.oNextTask(quesObj,'&00ND0000006EuPb=No');
				});
			}
			else{
				
				$scope.oNextTask(quesObj,'');
			}
		};
		
        $scope.oNextTask = function (quesObj,urlSuffix) {
            $scope.prevTiles = $scope.tiles;
            $scope.tiles = [];
            $scope.searchFloat = false;
            $scope.data = {};
            $scope.$apply();
            $scope.prevQues = $scope.question;
			
			
			
			console.log(quesObj);
			
            var nextTask;
            if ((currentlevel == 1) && (quesObj.id == "0case")) {
                $scope.none = true;
                flagNone = true;
                setCaseCategories();
            } else {
                nextTask = questionAnswerFactory.findNextAnswer(quesObj, answerset);
                $scope.tiles = nextTask;
                if ($scope.tiles.length) {
                    $scope.isPrevQuestion = true;
                    currentlevel = currentlevel + 1;
                    $scope.none = true;
                    $scope.prevQuestion = $scope.prevQuestion + quesObj.name + "/";
                    $scope.question = questionSet.records[currentlevel - 1].Question__c;
                    $scope.loader = false;
                } else {
                    if ($scope.search) {
                        $scope.caseId = quesObj.recordName;
                        quesObj = questionAnswerFactory.internalStaffinRecordType(quesObj);
                        //                        console.log(quesObj);
                    } else {
                        var recordType = questionAnswerFactory.getDataLayer("recordType");
                        $scope.caseId = questionAnswerFactory.findCaseCategory(quesObj, recordType);
                        //                        console.log($scope.caseId);
                    }if(quesObj.name == 'Customer Feedback - Respond' || quesObj.name=='Customer Complaint - Respond')//C0786;CMS;Start
					{
						if (accountId == ""){
								accountId = null;
						}
						Visualforce.remoting.Manager.invokeAction(
							'CaseHelperController.redirect',
							accountId,
							quesObj.name,
							function (result, event) {
								if(result.includes("https://"))
								{
									console.log(result);
									window.open(result);
								}else{
									alert(result);
								}
									
							});//C0786;CMS;End
					}else{ 
						var url = getUrl(quesObj);
						$scope.loader = true;
						$scope.$apply();
						window.location.replace(url+urlSuffix);
					}
                }
            }

        }

        /*  $scope.fetchCaseRecord is a function called on click on Case record type buttons to populate the tiles  with availableCase record types */
        $scope.fetchCaseRecord = function () {
            $scope.loader = true;
            $scope.search = true;
            $scope.searchFloat = false;
            $scope.isPrevQuestion = false;
            $scope.question = "Please select your case record type";
            $scope.tiles = [];
            // $scope.data = {};
            var recordType = questionAnswerFactory.getDataLayer("recordType");
            for (var e in recordType) {
                var elem = recordType[e];
                $scope.tiles.push({
                    "name": elem.name,
                    "recordName": elem.id,
                    "id": 0,

                });
            }
            $scope.loader = false;
        }

        /* function to be called on click of searchbox list */
        $scope.callFetchRecordtype = function (obj) {
            $scope.data.searchRecordText = "";
            // $scope.data.searchText = name;
            $scope.search = true;
            $scope.nextTask(obj);

        }

        /*  $scope.goBack  is function called on click of back button*/
        $scope.goBack = function () {
            $scope.data = {};
            currentlevel = currentlevel - 1;
            if (currentlevel == 1) {
                loadHomeQuestionset();
            } else if (currentlevel == 2) {
                $scope.isPrevQuestion = true;
                $scope.prevQuestion = $scope.prevQuestion.split("/")[0] + "/";
                $scope.question = $scope.prevQues;
                // console.log($scope.prevTiles);
                $scope.tiles = $scope.prevTiles;
            } else {
                loadHomeQuestionset();
            }
        }

        /*  $scope.goHome  is function called on click of home button to redirect on salesforce Case Page*/
        $scope.goHome = function () {
            $scope.loader = true;
            $scope.$apply();
            window.location.replace(baseUrl + "/500/o");
        }

        /* function to set FloatDiv variable in case query text change */
        $scope.setFloatDiv = function (val) {
            if (typeof val === "undefined" || val == "" || val == null) {
                $scope.searchFloat = false;
            } else {
                $scope.searchFloat = true;
            }
        }

        /*$scope.findheight is a function to set the css property for the class 'answerBox'*/
        $scope.findheight = function () {
            var height, margin, left;
            $scope.bgLeft;
            if ($scope.tiles.length == 2) {
                // console.log("inside 2");
                $scope.bgLeft = "16.5%";
            } else if ($scope.tiles.length == 1) {
                $scope.bgLeft = "33%";
            } else {
                $scope.bgLeft = "0";
            }
            if ($scope.search) {
                height = "70%";
                margin = "2%";
            } else if (currentlevel == 3) {
                height = "58%";
                margin = "3%";
            } else if (currentlevel == 2) {
                height = "68%";
                margin = "3%";
            }
            return {
                "height": height,
                "min-height": height,
                "margin-top": margin,
            };
        }


    }
	
	]);