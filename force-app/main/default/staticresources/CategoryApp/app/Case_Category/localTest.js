/*contains the local data for the local testing */
var setLocaldata = function () {
    var que = {
        "type": "Case_Question__mdt",
        "size": 3,
        "records": {
            "0": {
                "Question__c": "What are you going to do today?",
                "Level__c": 1,
                "Id": "m007E000000003oQAA"
            },
            "1": {
                "Question__c": "Is this case related to?",
                "Level__c": 2,
                "Id": "m007E000000003tQAA"
            },
            "2": {
                "Question__c": "Please select a relevant option from the dropdown",
                "Level__c": 3,
                "Id": "m007E000000003yQAA"
            }
        },
        "success": true
    };
    questionAnswerFactory.setDataLayer({
        "key": "questionsList",
        "data": que
    });



    var casehelper = {
        "type": "Case_Type_Helper__c",
        "size": 38,
        "records": {
            "0": {
                "Display_Order__c": 1,
                "Internal_Staff__c": false,
                "Is_Active__c": true,
                "Option__c": "Log a case on behalf of a customer",
                "Id": "a5W7E0000004C93UAE"
            },
            "1": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 1,
                "Internal_Staff__c": false,
                "Is_Active__c": true,
                "Option__c": "Account Services",
                "Id": "a5W7E0000004C98UAE"
            },
            "2": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 2,
                "Internal_Staff__c": false,
                "Is_Active__c": true,
                "Option__c": "HPP",
                "Id": "a5W7E0000004C9DUAU"
            },
            "3": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 3,
                "Internal_Staff__c": false,
                "RecordType__c": "Card Disputes",
                "Is_Active__c": true,
                "Option__c": "Card Dispute",
                "Id": "a5W7E0000004C9EUAU"
            },
            "4": {
                "Display_Order__c": 11,
                "Internal_Staff__c": false,
                "RecordType__c": "Deceased Estate",
                "Is_Active__c": true,
                "Option__c": "Log a Case about a deceased customer",
                "Id": "a5W7E0000004C9FUAU"
            },
            "5": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 4,
                "Internal_Staff__c": false,
                "Is_Active__c": true,
                "Option__c": "Refund",
                "Id": "a5W7E0000004C9IUAU"
            },
            "6": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 5,
                "Internal_Staff__c": false,
                "Is_Active__c": true,
                "Option__c": "Payments",
                "Id": "a5W7E0000004C9NUAU"
            },
            "7": {
                "Display_Order__c": 2,
                "Internal_Staff__c": false,
                "Is_Active__c": true,
                "Option__c": "Log a Case to a Specific Department",
                "Id": "a5W7E0000004C9SUAU"
            },
            "8": {
                "Display_Order__c": 3,
                "Internal_Staff__c": false,
                "Is_Active__c": true,
                "Option__c": "Raise an IT Case",
                "Id": "a5W7E0000004C9XUAU"
            },
            "9": {
                "Display_Order__c": 5,
                "Internal_Staff__c": false,
                "RecordType__c": "Change Advisory Team Form",
                "Is_Active__c": true,
                "Option__c": "Raise a CAT Form",
                "Id": "a5W7E0000004C9cUAE"
            },
            "10": {
                "Parent__c": "a5W7E0000004C98UAE",
                "Display_Order__c": 1,
                "Internal_Staff__c": false,
                "RecordType__c": "Cash ISA",
                "Is_Active__c": true,
                "Option__c": "Cash ISAs",
                "Id": "a5W7E0000004C9hUAE"
            },
            "11": {
                "Display_Order__c": 6,
                "Internal_Staff__c": false,
                "RecordType__c": "FCU Case",
                "Is_Active__c": true,
                "Option__c": "Log a Case to FCU",
                "Id": "a5W7E0000004C9rUAE"
            },
            "12": {
                "Display_Order__c": 4,
                "Internal_Staff__c": false,
                "RecordType__c": "Password Reset",
                "Is_Active__c": true,
                "Option__c": "Reset my EBS Password",
                "Id": "a5W7E0000004C9wUAE"
            },
            "13": {
                "Display_Order__c": 7,
                "Internal_Staff__c": false,
                "RecordType__c": "Risk Reporting Form",
                "Is_Active__c": true,
                "Option__c": "Report a Risk",
                "Id": "a5W7E0000004CA1UAM"
            },
            "14": {
                "Display_Order__c": 8,
                "Internal_Staff__c": false,
                "RecordType__c": "SAR",
                "Is_Active__c": true,
                "Option__c": "Raise a SAR",
                "Id": "a5W7E0000004CA6UAM"
            },
            "15": {
                "Display_Order__c": 10,
                "Internal_Staff__c": false,
                "RecordType__c": "Training Requisition Form",
                "Is_Active__c": true,
                "Option__c": "Log a Training Request",
                "Id": "a5W7E0000004CAGUA2"
            },
            "16": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 6,
                "Internal_Staff__c": false,
                "RecordType__c": "Collections",
                "Is_Active__c": true,
                "Option__c": "Collections",
                "Id": "a5W7E0000004CALUA2"
            },
            "17": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 7,
                "Internal_Staff__c": false,
                "RecordType__c": "Complaint",
                "Is_Active__c": true,
                "Option__c": "Customer Complaint",
                "Id": "a5W7E0000004CAQUA2"
            },
            "18": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 8,
                "Internal_Staff__c": false,
                "RecordType__c": "Customer Compliment",
                "Is_Active__c": true,
                "Option__c": "Customer Compliment",
                "Id": "a5W7E0000004CAVUA2"
            },
            "19": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 9,
                "Internal_Staff__c": false,
                "RecordType__c": "Customer Services",
                "Is_Active__c": true,
                "Option__c": "Something keyed over phone",
                "Id": "a5W7E0000004CAaUAM"
            },
            "20": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 10,
                "Internal_Staff__c": false,
                "RecordType__c": "FSCS Queries/Requests",
                "Is_Active__c": true,
                "Option__c": "FSCS Query",
                "Id": "a5W7E0000004CAfUAM"
            },
            "21": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 11,
                "Internal_Staff__c": false,
                "RecordType__c": "KYC Required",
                "Is_Active__c": true,
                "Option__c": "KYC Required?",
                "Id": "a5W7E0000004CAkUAM"
            },
            "22": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 12,
                "Internal_Staff__c": false,
                "RecordType__c": "Transaction Approval Request",
                "Is_Active__c": true,
                "Option__c": "Transaction requiring approval?",
                "Id": "a5W7E0000004CApUAM"
            },
            "23": {
                "Parent__c": "a5W7E0000004C93UAE",
                "Display_Order__c": 13,
                "Internal_Staff__c": false,
                "RecordType__c": "Unrecognised Transactions",
                "Is_Active__c": true,
                "Option__c": "Unrecognised Transaction?",
                "Id": "a5W7E0000004CAuUAM"
            },
            "24": {
                "Parent__c": "a5W7E0000004C9SUAU",
                "Display_Order__c": 1,
                "Internal_Staff__c": false,
                "RecordType__c": "Credit",
                "Is_Active__c": true,
                "Option__c": "Credit",
                "Id": "a5W7E0000004CAzUAM"
            },
            "25": {
                "Parent__c": "a5W7E0000004C9SUAU",
                "Display_Order__c": 2,
                "Internal_Staff__c": false,
                "RecordType__c": "Finance",
                "Is_Active__c": true,
                "Option__c": "Finance",
                "Id": "a5W7E0000004CB4UAM"
            },
            "26": {
                "Parent__c": "a5W7E0000004C9XUAU",
                "Display_Order__c": 1,
                "Internal_Staff__c": true,
                "RecordType__c": "IT Change Requests",
                "Is_Active__c": true,
                "Option__c": "Change to a System",
                "Id": "a5W7E0000004CB9UAM"
            },
            "27": {
                "Parent__c": "a5W7E0000004C9XUAU",
                "Display_Order__c": 2,
                "Internal_Staff__c": true,
                "RecordType__c": "IT System Access",
                "Is_Active__c": true,
                "Option__c": "New/Change/Remove to a user&#39;s access",
                "Id": "a5W7E0000004CBEUA2"
            },
            "28": {
                "Parent__c": "a5W7E0000004C9XUAU",
                "Display_Order__c": 3,
                "Internal_Staff__c": true,
                "RecordType__c": "IT Standard",
                "Is_Active__c": true,
                "Option__c": "Any other type of IT Case",
                "Id": "a5W7E0000004CBJUA2"
            },
            "29": {
                "Parent__c": "a5W7E0000004C98UAE",
                "Display_Order__c": 2,
                "Internal_Staff__c": false,
                "RecordType__c": "Account Services",
                "Is_Active__c": true,
                "Option__c": "Others",
                "Id": "a5W7E0000004CBOUA2"
            },
            "30": {
                "Parent__c": "a5W7E0000004C9DUAU",
                "Display_Order__c": 1,
                "Internal_Staff__c": false,
                "RecordType__c": "HPP Manual valuation",
                "Is_Active__c": true,
                "Option__c": "Manual Valuation",
                "Id": "a5W7E0000004CBTUA2"
            },
            "31": {
                "Parent__c": "a5W7E0000004C9DUAU",
                "Display_Order__c": 2,
                "Internal_Staff__c": false,
                "RecordType__c": "HPP Sales support",
                "Is_Active__c": true,
                "Option__c": "HPP Sales Support",
                "Id": "a5W7E0000004CBYUA2"
            },
            "32": {
                "Parent__c": "a5W7E0000004C9DUAU",
                "Display_Order__c": 3,
                "Internal_Staff__c": false,
                "RecordType__c": "HPP/HPS Product Switch",
                "Is_Active__c": true,
                "Option__c": "Product Switch",
                "Id": "a5W7E0000004CBdUAM"
            },
            "33": {
                "Parent__c": "a5W7E0000004C9DUAU",
                "Display_Order__c": 4,
                "Internal_Staff__c": false,
                "RecordType__c": "HPP Acquisition Payments/Redemptions",
                "Is_Active__c": true,
                "Option__c": "Redemption/Acquistion payment",
                "Id": "a5W7E0000004CBiUAM"
            },
            "34": {
                "Parent__c": "a5W7E0000004C9IUAU",
                "Display_Order__c": 1,
                "Internal_Staff__c": false,
                "RecordType__c": "HPP Fees Refund",
                "Is_Active__c": true,
                "Option__c": "HPP Related Refund",
                "Id": "a5W7E0000004CBnUAM"
            },
            "35": {
                "Parent__c": "a5W7E0000004C9IUAU",
                "Display_Order__c": 2,
                "Internal_Staff__c": false,
                "RecordType__c": "Refund",
                "Is_Active__c": true,
                "Option__c": "Other Refund",
                "Id": "a5W7E0000004CBsUAM"
            },
            "36": {
                "Parent__c": "a5W7E0000004C9NUAU",
                "Display_Order__c": 1,
                "Internal_Staff__c": false,
                "RecordType__c": "International Payment",
                "Is_Active__c": true,
                "Option__c": "International Payment",
                "Id": "a5W7E0000004CBxUAM"
            },
            "37": {
                "Parent__c": "a5W7E0000004C9NUAU",
                "Display_Order__c": 2,
                "Internal_Staff__c": false,
                "RecordType__c": "Payments Processing",
                "Is_Active__c": true,
                "Option__c": "Others",
                "Id": "a5W7E0000004CC2UAM"
            }
        },
        "success": true
    }
    questionAnswerFactory.setDataLayer({
        "key": "caseTypeHelper",
        "data": casehelper
    });
    var crType = {
        "type": "Case_Record_Type__mdt",
        "size": 9,
        "records": {
            "0": {
                "IsActive__c": true,
                "Record_Type_Name__c": "BAA CASE",
                "Id": "m017E000000003yQAA"
            },
            "1": {
                "IsActive__c": true,
                "Record_Type_Name__c": "CAA CASE",
                "Id": "m017E0000000043QAA"
            },
            "2": {
                "IsActive__c": true,
                "Record_Type_Name__c": "Engage Transaction",
                "Id": "m017E0000000048QAA"
            },
            "3": {
                "IsActive__c": true,
                "Record_Type_Name__c": "Standard",
                "Id": "m017E000000004cQAA"
            },
            "4": {
                "IsActive__c": true,
                "Record_Type_Name__c": "Expired Offer Letter",
                "Id": "m017E000000004DQAQ"
            },
            "5": {
                "IsActive__c": true,
                "Record_Type_Name__c": "Failed eKYC Referral",
                "Id": "m017E000000004IQAQ"
            },
            "6": {
                "IsActive__c": true,
                "Record_Type_Name__c": "Further Information",
                "Id": "m017E000000004NQAQ"
            },
            "7": {
                "IsActive__c": true,
                "Record_Type_Name__c": "HPP CAA_Case",
                "Id": "m017E000000004SQAQ"
            },
            "8": {
                "IsActive__c": true,
                "Record_Type_Name__c": "Operations",
                "Id": "m017E000000004XQAQ"
            }
        },
        "success": true
    };
    questionAnswerFactory.setDataLayer({
        "key": "caseRecordType",
        "data": crType
    });


    var recordType = [{
        "id": "012D0000000QWm1IAG",
        "name": "Account Services"
                }, {
        "id": "012D0000000Qna9IAC",
        "name": "BAA CASE"
                }, {
        "id": "012D0000000KJujIAG",
        "name": "CAA CASE"
                }, {
        "id": "012D0000000QifiIAC",
        "name": "Further Information"
                }, {
        "id": "012D0000000QgybIAC",
        "name": "HPP Acquisition Payments/Redemptions"
                }, {
        "id": "012D0000000QlZwIAK",
        "name": "HPP CAA_CASE"
                }, {
        "id": "012D0000000Qj5JIAS",
        "name": "HPP Fees Refund"
                }, {
        "id": "012D0000000QmYHIA0",
        "name": "HPP Manual Valuation"
                }, {
        "id": "012D0000000QjsWIAS",
        "name": "HPP Sales Support"
                }, {
        "id": "012D0000000QkVjIAK",
        "name": "HPP/HPS Product Switch"
                }, {
        "id": "012D0000000QWmDIAW",
        "name": "IT Change Requests"
                }, {
        "id": "012D0000000QWmEIAW",
        "name": "IT Standard"
                }, {
        "id": "012D0000000QWmFIAW",
        "name": "IT System Access"
                }, {
        "id": "012D0000000QckJIAS",
        "name": "International Payment"
                }, {
        "id": "012D0000000QYcfIAG",
        "name": "KYC Required"
                }, {
        "id": "012D0000000QeumIAC",
        "name": "Operations"
                }, {
        "id": "012D0000000QoY4IAK",
        "name": "Password Reset"
                }, {
        "id": "012D0000000QWmGIAW",
        "name": "Payments Processing"
                }, {
        "id": "012D0000000QWm5IAG",
        "name": "Refund"
                }, {
        "id": "012D0000000QpLpIAK",
        "name": "Risk Reporting Form"
                }, {
        "id": "012D0000000Qi7rIAC",
        "name": "SAR"
                }, {
        "id": "012D0000000QjeUIAS",
        "name": "SAR FCU Only"
                }, {
        "id": "012D0000000QWmHIAW",
        "name": "Standard"
                }, {
        "id": "012D0000000Qi81IAC",
        "name": "Training Requisition Form"
                }, {
        "id": "012D0000000QqA9IAK",
        "name": "Transaction Approval Request"
                }, {
        "id": "012D0000000QbSAIA0",
        "name": "Unrecognised Transactions"
                }];

    questionAnswerFactory.setDataLayer({
        "key": "recordType",
        "data": recordType
    });

}
setLocaldata();
loadHomeQuestionset();
