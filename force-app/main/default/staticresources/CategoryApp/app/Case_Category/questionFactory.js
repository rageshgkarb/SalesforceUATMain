/* questionAnswerFactory is a factory to set ,get and parse the object */
angular.module('question.services', [])
    .factory('questionAnswerFactory', function () {
        var categoryObj = {}; //Object to store Sobject data from salesforce

        /*Seter function to set the  Sobject data in categoryObj */
        var setDataLayer = function (dataObj) {
            categoryObj[dataObj.key] = dataObj.data;
        }

        /*Getter function to get the  Sobject data in categoryObj */
        var getDataLayer = function (key) {
            return categoryObj[key];
        }

        /* Function to return boolean value true if the Record_Type_Name__c/RecordType__c of Case tyep helper /Case Record type Object is present in AvailabaleCaserecord*/
        var keyAvailable = function (obj, none) {
            var bool = false;
            var recordObj = getDataLayer("recordType");
            if (none) {
                for (var e in recordObj) {
                    if (recordObj[e] && recordObj[e].name) {
                        if (recordObj[e].name.toLowerCase() == obj.Record_Type_Name__c.toLowerCase()) {
                            bool = true;
                        }
                    }
                }
            } else {
                for (var e in recordObj) {
                    if (recordObj[e] && recordObj[e].name) {
                        if (obj.RecordType__c == null || recordObj[e].name.toLowerCase() == obj.RecordType__c.toLowerCase()) {
                            bool = true;
                        }
                    }

                }
            }
            return bool;
        }

        /* Function to find the next level answers from CasetypeHelper Object and returns an object  */
        var findNextAnswer = function (quesObj, myObj) {
            var nextLevelAns = [];
            for (var e in myObj.records) {
                var elem = myObj.records[e];
                if ((quesObj.id == elem.Parent__c) && keyAvailable(elem)) {
                    nextLevelAns.push({
                        "name": elem.Option__c,
                        "id": elem.Id,
                        "recordName": elem.RecordType__c,
                        "order": elem.Display_Order__c,
                        "internalStaff": elem.Internal_Staff__c
                    });
                }

            }
            return nextLevelAns;
        }


        /* Function to find the RecordType id */
        var findCaseCategory = function (quesObj, myObj) {
            var caseCategory;
            for (var e in myObj) {
                var elem = myObj[e];
                if (quesObj && quesObj.recordName && elem.name) {
                    if (quesObj.recordName.toLowerCase() == elem.name.toLowerCase()) {
                        caseCategory = elem.id;
                    }
                }

            }
            return caseCategory;
        }

        /*  Function to  set the internal Satff value in the availablecaseRecord type object in correspondence to the case type helper object*/
        var internalStaffinRecordType = function (obj) {
            var caseHelper = getDataLayer("caseTypeHelper"),
                quesObj = obj;
            for (var e in caseHelper.records) {
                var elemCase = caseHelper.records[e];
                if (elemCase && elemCase.RecordType__c && quesObj && quesObj.name) {
                    if (elemCase.RecordType__c && (quesObj.name.toLowerCase() == elemCase.RecordType__c.toLowerCase())) {
                        quesObj.internalStaff = elemCase.Internal_Staff__c;
                    }
                }

            }
            return quesObj;

        }

        return {
            setDataLayer: setDataLayer,
            getDataLayer: getDataLayer,
            findNextAnswer: findNextAnswer,
            findCaseCategory: findCaseCategory,
            keyAvailable: keyAvailable,
            internalStaffinRecordType: internalStaffinRecordType
        }
    })
