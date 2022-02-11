public with sharing class HTBXMLCreator {
    private static final HTBSettings__c HTB_SETTINGS = HTBSettings__c.getInstance();
    
    public static Attachment getMonthXMLAttachment(HTB_Reporting_Month__c htbMonth, List<HTB_Reporting_Static__c> newHTBStatics, List<HTB_Reporting_Static__c> updatedHTBStatics, List<HTB_Reporting_Dynamic__c> htbDynamics) {
        Attachment xmlAttachment = null;
        
        String lenderCode = HTB_SETTINGS.LenderCode__c;
        String brandCode = HTB_SETTINGS.BrandCode__c;
        String month = htbMonth.Reporting_Month__c.replaceAll('-', '');
        String filename = HTB_SETTINGS.FilenameFormat__c;
        filename = filename.replaceFirst('\\[LENDERCODE\\]', lenderCode).replaceFirst('\\[BRANDCODE\\]', brandCode).replaceFirst('\\[MONTH\\]', month);
        
        if (htbMonth != null && String.isNotBlank(htbMonth.Id)) {
            String xmlString = getXMLBody(htbMonth, newHTBStatics, updatedHTBStatics, htbDynamics);
            xmlAttachment = getAttachment(xmlString, htbMonth.Id, filename, htbMonth.Reporting_Month__c);
        }
        
        return xmlAttachment;
    }
    
    private static Attachment getAttachment(String bodyString, Id parentId, String filename, String reportingMonth) {
        Attachment att = null;
        
        if (String.isNotBlank(bodyString) && String.isNotBlank(parentId) && String.isNotBlank(filename)) {
            Blob bodyBlob = Blob.valueOf(bodyString);
            att = new Attachment(
                ParentId = parentId, Name = filename + '.xml', IsPrivate = false, Description = 'Help to Buy XML Document for ' + reportingMonth, 
                ContentType = 'document/xml', Body = bodyBlob               
            );
        }
        
        return att;
    }
    
    private static String getXMLBody(HTB_Reporting_Month__c htbMonth, List<HTB_Reporting_Static__c> newHTBStatics, List<HTB_Reporting_Static__c> updatedHTBStatics, List<HTB_Reporting_Dynamic__c> htbDynamics) {
        String xmlBody = '<?xml version="1.0" encoding="UTF-8"?>';                                  //  Set XML version
        xmlBody += '<MGS xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';                   //  Opening <MSG> tag
        xmlBody += getHeaderNode(htbMonth);                                                         //  <Header> tag
        for (HTB_Reporting_Static__c htbStatic : newHTBStatics)                                     //  <StaticData> tags - A(dd)
            xmlBody += getStaticDataNode(htbStatic, 'A');                                               
        for (HTB_Reporting_Static__c htbStatic : updatedHTBStatics)                                 //  <StaticData> tags - C(hange)
            xmlBody += getStaticDataNode(htbStatic, 'C');                                               
        for (HTB_Reporting_Dynamic__c htbDynamic : htbDynamics)                                     //  <DynamicData> tags - A(dd)
            xmlBody += getDynamicDataNode(htbDynamic, 'A');                                             
        xmlBody += getTrailerNode(htbMonth);                                                        //  <Trailer> tag
        xmlBody += '</MGS>';                                                                        //  Closing <MSG> tag
        
        return xmlBody;
    }
    
    private static String getHeaderNode(HTB_Reporting_Month__c htbMonth) {
        String sender = HTB_SETTINGS.Sender__c;
        String receiver = HTB_SETTINGS.Receiver__c;
        String environment = '';
        String mode = '';
        String fileCreated = DateTime.now().format('yyyy-MM-dd') + 'T' + DateTime.now().format('HH:mm:ss') + 'Z';
        String sequence = '';
        
        if (htbMonth != null) {
            environment = htbMonth.Environment__c;
            mode = htbMonth.Mode__c;
            sequence = String.valueOf(htbMonth.Sequence_Number__c);
        }
        
        String headerNode = '<Header><sender>' + sender + '</sender><receiver>' + receiver + '</receiver><environment>' + environment + '</environment>'
            + '<mode>' + mode + '</mode><fileCreated>' + fileCreated + '</fileCreated><sequence>' + sequence + '</sequence></Header>';
        return headerNode;
    }
    
    private static String getStaticDataNode(HTB_Reporting_Static__c htbStatic, String actionCode) {
        String uniqueReference = '';
        String lender = '';
        String brand = '';
        String previousMortgageArrears = '';
        String numberOfCCJs = '';
        String valueOfCCJS = '';
        String bankruptcyOrIVA = '';
        String openingLoanValue = '';
        String openingLoanDate = '';
        String openingLoanExposure = '';
        String originalLoanToValue = '';
        String loanTerm = '';
        String flexibleFeatures = '';
        String initialInterestRate = '';
        String interestRevisionDate = '';
        String interestRateType = '';
        String reversionRate = '';
        String reversionType = '';
        String ercEndDate = '';
        String loanType = '';
        String primaryYearOfBirth = '';
        String primaryBorrowerType = '';
        String primaryBorrowerIncome = '';
        String secondYearOfBirth = '';
        String secondBorrowerIncome = '';
        String thirdYearOfBirth = '';
        String thirdBorrowerIncome = '';
        String fourthYearOfBirth = '';
        String fourthBorrowerIncome = '';
        String propertyType = '';
        String postCode = '';
        String newProperty = '';
        String constructionYear = '';
        String value = '';
        String originalValuationType = '';
        
        if (htbStatic != null) {
            uniqueReference = htbStatic.Unique_Reference__c;
            lender = htbStatic.Lender__c;
            brand = htbStatic.Brand__c;
            previousMortgageArrears = (htbStatic.Previous_mortgage_arrears__c != null) ? String.valueOf(htbStatic.Previous_mortgage_arrears__c) : '';
            numberOfCCJs = (htbStatic.Number_of_CCJs_or_equivalent__c != null) ? String.valueOf(htbStatic.Number_of_CCJs_or_equivalent__c) : '';
            valueOfCCJs = (htbStatic.Value_of_CCJs_or_equivalent__c != null) ? String.valueOf(htbStatic.Value_of_CCJs_or_equivalent__c) : '';
            bankruptcyOrIVA = htbStatic.Bankruptcy_or_IVA_Flag__c;
            openingLoanValue = (htbStatic.Opening_Loan_Value__c != null) ? String.valueOf(htbStatic.Opening_Loan_Value__c) : '';
            openingLoanDate = formatDate(htbStatic.Opening_Loan_origination_date__c);
            openingLoanExposure = (htbStatic.Opening_Loan_Exposure__c != null) ? String.valueOf(htbStatic.Opening_Loan_Exposure__c) : '';
            originalLoanToValue = (htbStatic.Original_Loan_to_Value__c != null) ? String.valueOf(htbStatic.Original_Loan_to_Value__c) : '';
            loanTerm = (htbStatic.Loan_term__c != null) ? String.valueOf(htbStatic.Loan_term__c) : '';
            flexibleFeatures = htbStatic.Flexible_Features_flag__c;
            initialInterestRate = (htbStatic.Initial_Interest_Rate__c != null) ? String.valueOf(htbStatic.Initial_Interest_Rate__c) : '';
            interestRevisionDate = formatDate(htbStatic.Interest_Revision_Date__c);
            interestRateType = (htbStatic.Interest_Rate_Type__c != null) ? String.valueOf(htbStatic.Interest_Rate_Type__c) : '';
            reversionRate = (htbStatic.Reversion_rate__c != null) ? String.valueOf(htbStatic.Reversion_rate__c) : '';
            reversionType = (htbStatic.Reversion_type__c != null) ? String.valueOf(htbStatic.Reversion_type__c) : '';
            ercEndDate = (htbStatic.ERC_End_Date__c != null) ? formatDate(htbStatic.ERC_End_Date__c) : '1111-11-11';
            loanType = (htbStatic.Loan_Type__c != null) ? String.valueOf(htbStatic.Loan_Type__c) : '';
            primaryYearOfBirth = (htbStatic.Primary_Borrower_Year_of_Birth__c != null) ? String.valueOf(htbStatic.Primary_Borrower_Year_of_Birth__c.year()) : '';
            primaryBorrowerType = (htbStatic.Primary_Borrower_type__c != null) ? String.valueOf(htbStatic.Primary_Borrower_type__c) : '';
            primaryBorrowerIncome = (htbStatic.Primary_Borrower_gross_income__c != null) ? String.valueOf(htbStatic.Primary_Borrower_gross_income__c) : '';
            secondYearOfBirth = (htbStatic.X2nd_Borrower_Year_of_Birth__c != null) ? String.valueOf(htbStatic.X2nd_Borrower_Year_of_Birth__c.year()) : '';
            secondBorrowerIncome = (htbStatic.X2nd_Borrower_gross_income__c != null) ? String.valueOf(htbStatic.X2nd_Borrower_gross_income__c) : '';
            // LB Start
            thirdYearOfBirth = (htbStatic.X3rd_Borrower_Year_of_Birth__c != null) ? String.valueOf(htbStatic.X3rd_Borrower_Year_of_Birth__c.year()) : '';
            thirdBorrowerIncome = (htbStatic.X3rd_Borrower_gross_income__c != null) ? String.valueOf(htbStatic.X3rd_Borrower_gross_income__c) : '';
            fourthYearOfBirth = (htbStatic.X4th_Borrower_Year_of_Birth__c != null) ? String.valueOf(htbStatic.X4th_Borrower_Year_of_Birth__c.year()) : '';
            fourthBorrowerIncome = (htbStatic.X4th_Borrower_gross_income__c != null) ? String.valueOf(htbStatic.X4th_Borrower_gross_income__c) : '';
            // LB End
            propertyType = (htbStatic.Property_type__c != null) ? String.valueOf(htbStatic.Property_type__c) : '';
            postCode = htbStatic.Property_postcode__c;
            newProperty = (htbStatic.New_Property__c != null) ? String.valueOf(htbStatic.New_Property__c) : '';
            constructionYear = (htbStatic.Construction_Year__c != null) ? String.valueOf(htbStatic.Construction_Year__c) : '';
            value = (htbStatic.Value__c != null) ? String.valueOf(htbStatic.Value__c) : '';
            originalValuationType = (htbStatic.Original_Valuation_Type__c != null) ? String.valueOf(htbStatic.Original_Valuation_Type__c) : '';
        }
        
        //  Start Node
        String staticDataNode = '<StaticData>';
        
        //  Application Data Node
        staticDataNode += '<ApplicationData>';
        staticDataNode += (String.isNotBlank(actionCode)) ? '<actionCode>' + actionCode + '</actionCode>' : '';
        staticDataNode += (String.isNotBlank(uniqueReference)) ? '<uniqueReference>' + uniqueReference + '</uniqueReference>' : '';
        staticDataNode += (String.isNotBlank(lender)) ? '<lender>' + lender + '</lender>' : '';
        staticDataNode += (String.isNotBlank(brand)) ? '<brand>' + brand + '</brand>' : '';
        staticDataNode += (String.isNotBlank(previousMortgageArrears)) ? '<previousMortgageArrears>' + previousMortgageArrears + '</previousMortgageArrears>' : '';
        staticDataNode += (String.isNotBlank(numberOfCCJs)) ? '<numberOfCCJsOrEquivalent>' + numberOfCCJs + '</numberOfCCJsOrEquivalent>' : '';
        staticDataNode += (String.isNotBlank(valueOfCCJs)) ? '<valueOfCCJsOrEquivalent>' + valueOfCCJs + '</valueOfCCJsOrEquivalent>' : '';
        staticDataNode += (String.isNotBlank(bankruptcyOrIVA)) ? '<bankruptcyOrIVAFlag>' + bankruptcyOrIVA + '</bankruptcyOrIVAFlag>' : '';
        staticDataNode += '</ApplicationData>';
        
        //  Product Data Node
        staticDataNode += '<ProductData>';
        staticDataNode += (String.isNotBlank(openingLoanValue)) ? '<openingLoanValue>' + openingLoanValue + '</openingLoanValue>' : '';
        staticDataNode += (String.isNotBlank(openingLoanDate)) ? '<openingLoanOriginationDate>' + openingLoanDate + '</openingLoanOriginationDate>' : '';
        staticDataNode += (String.isNotBlank(openingLoanExposure)) ? '<openingLoanExposure>' + openingLoanExposure + '</openingLoanExposure>' : '';
        staticDataNode += (String.isNotBlank(originalLoanToValue)) ? '<originalLoantoValue>' + originalLoanToValue + '</originalLoantoValue>' : '';
        staticDataNode += (String.isNotBlank(loanTerm)) ? '<loanTerm>' + loanTerm + '</loanTerm>' : '';
        staticDataNode += (String.isNotBlank(flexibleFeatures)) ? '<flexibleFeaturesFlag>' + flexibleFeatures + '</flexibleFeaturesFlag>' : '';
        staticDataNode += (String.isNotBlank(initialInterestRate)) ? '<initialInterestRate>' + initialInterestRate + '</initialInterestRate>' : '';
        staticDataNode += (String.isNotBlank(interestRevisionDate)) ? '<interestRevisionDate>' + interestRevisionDate + '</interestRevisionDate>' : '';
        staticDataNode += (String.isNotBlank(interestRateType)) ? '<interestRateType>' + interestRateType + '</interestRateType>' : '';
        staticDataNode += (String.isNotBlank(reversionRate)) ? '<reversionRate>' + reversionRate + '</reversionRate>' : '';
        staticDataNode += (String.isNotBlank(reversionType)) ? '<reversionType>' + reversionType + '</reversionType>' : '';
        staticDataNode += (String.isNotBlank(ercEndDate)) ? '<ERCEndDate>' + ercEndDate + '</ERCEndDate>' : '';
        staticDataNode += (String.isNotBlank(loanType)) ? '<loanType>' + loanType + '</loanType>' : '';
        staticDataNode += '</ProductData>';
        
        //  Customer Data Node
        staticDataNode += '<CustomerData>';
        staticDataNode += (String.isNotBlank(primaryYearOfBirth)) ? '<primaryBorrowerYearOfBirth>' + primaryYearOfBirth + '</primaryBorrowerYearOfBirth>' : '';
        staticDataNode += (String.isNotBlank(primaryBorrowerType)) ? '<primaryBorrowerType>' + primaryBorrowerType + '</primaryBorrowerType>' : '';
        staticDataNode += (String.isNotBlank(primaryBorrowerIncome)) ? '<primaryBorrowerGrossIncome>' + primaryBorrowerIncome + '</primaryBorrowerGrossIncome>' : '';
        staticDataNode += (String.isNotBlank(secondYearOfBirth)) ? '<secondBorrowerYearOfBirth>' + secondYearOfBirth + '</secondBorrowerYearOfBirth>' : '';
        staticDataNode += (String.isNotBlank(secondYearOfBirth)) ? '<secondBorrowerGrossIncome>' + secondBorrowerIncome + '</secondBorrowerGrossIncome>' : '';
        //LB Start
        staticDataNode += (String.isNotBlank(thirdYearOfBirth )) ? '<thirdBorrowerYearOfBirth>' + thirdYearOfBirth + '</thirdBorrowerYearOfBirth>' : '';
        staticDataNode += (String.isNotBlank(thirdYearOfBirth )) ? '<thirdBorrowerGrossIncome>' + thirdBorrowerIncome + '</thirdBorrowerGrossIncome>' : '';
        staticDataNode += (String.isNotBlank(fourthYearOfBirth )) ? '<fourthBorrowerYearOfBirth>' + fourthYearOfBirth + '</fourthBorrowerYearOfBirth>' : '';
        staticDataNode += (String.isNotBlank(fourthYearOfBirth )) ? '<fourthBorrowerGrossIncome>' + fourthBorrowerIncome + '</fourthBorrowerGrossIncome>' : '';        
        //LB End   
        staticDataNode += '</CustomerData>';
        
        //  Property Data Node
        staticDataNode += '<PropertyData>';
        staticDataNode += (String.isNotBlank(propertyType)) ? '<propertyType>' + propertyType + '</propertyType>' : '';
        staticDataNode += (String.isNotBlank(postcode)) ? '<propertyPostcode>' + postcode + '</propertyPostcode>' : '';
        staticDataNode += (String.isNotBlank(newProperty)) ? '<newProperty>' + newProperty + '</newProperty>' : '';
        staticDataNode += (String.isNotBlank(constructionYear)) ? '<constructionYear>' + constructionYear + '</constructionYear>' : '';
        staticDataNode += (String.isNotBlank(value)) ? '<value>' + value + '</value>' : '';
        staticDataNode += (String.isNotBlank(originalValuationType)) ? '<originalValuationType>' + originalValuationType + '</originalValuationType>' : '';
        staticDataNode += '</PropertyData>';
        
        //  End Node
        staticDataNode += '</StaticData>';
        
        return staticDataNode;
    }
    
    private static String getDynamicDataNode(HTB_Reporting_Dynamic__c htbDynamic, String actionCode) {
        String uniqueReference = '';
        String lender = '';
        String brand = '';
        String reportingMonth = '';
        String currentBalance = '';
        String currentExposure = '';
        String remainingTerm = '';
        String paymentDue = '';
        String customerPaymentAmount = '';
        String currentInterestRate = '';
        String currentProductRateType = '';
        String indexedPropertyValue = '';
        String currentLTV = '';
        String behaviouralPD = '';
        String behaviouralEAD = '';
        String behaviouralLGD = '';
        String accountStatus = '';
        String collectionStatus = '';
        String monthsInArrears = '';
        String arrearsBalance = '';
        String potentialImpairmentIndicators1 = '';
        String potentialImpairmentIndicators2 = '';
        String potentialImpairmentIndicators3 = '';
        String potentialImpairmentIndicators4 = '';
        String potentialImpairmentIndicators5 = '';
        String potentialImpairmentIndicators6 = '';
        String potentialImpairmentIndicators7 = '';
        String recoveredMoniesAfterClaim = '';
		//Help to Buy XML change
		String RedemptionDate = ''; 
        String PossessionDate = '';
		String DefaultDate = '';
		    
        if (htbDynamic != null) {
            uniqueReference = htbDynamic.Unique_Reference__c;
            lender = htbDynamic.Lender__c;
            brand = htbDynamic.Brand__c;
            reportingMonth = (htbDynamic.Reporting_month__c != null) ? DateTime.newInstance(htbDynamic.Reporting_month__c, Time.newInstance(0,0,0,0)).format('yyyy-MM') : '';
            currentBalance = (htbDynamic.Current_balance__c != null) ? String.valueOf(htbDynamic.Current_balance__c) : '';
            currentExposure = (htbDynamic.Current_exposure__c != null) ? String.valueOf(htbDynamic.Current_exposure__c) : '';
            remainingTerm = (htbDynamic.Remaining_term__c != null) ? String.valueOf(htbDynamic.Remaining_term__c) : '';
            paymentDue = (htbDynamic.Payment_due__c != null) ? String.valueOf(htbDynamic.Payment_due__c) : '';
            customerPaymentAmount = (htbDynamic.Customer_payment_amount__c != null) ? String.valueOf(htbDynamic.Customer_payment_amount__c) : '';
            currentInterestRate = (htbDynamic.Current_interest_rate__c != null) ? String.valueOf(htbDynamic.Current_interest_rate__c) : '';
            currentProductRateType = (htbDynamic.Current_Product_Rate_Type__c != null) ? String.valueOf(htbDynamic.Current_Product_Rate_Type__c) : '';
            indexedPropertyValue = (htbDynamic.Indexed_property_value__c != null) ? String.valueOf(htbDynamic.Indexed_property_value__c.setScale(0)) : '';
            currentLTV = (htbDynamic.Current_LTV__c != null) ? String.valueOf(htbDynamic.Current_LTV__c) : '';
            behaviouralPD = (htbDynamic.Behavioural_PD__c != null) ? String.valueOf(htbDynamic.Behavioural_PD__c) : '';
            behaviouralEAD = (htbDynamic.Behavioural_EAD__c != null) ? String.valueOf(htbDynamic.Behavioural_EAD__c) : '';
            behaviouralLGD = (htbDynamic.Behavioural_LGD__c != null) ? String.valueOf(htbDynamic.Behavioural_LGD__c) : '';
            accountStatus = htbDynamic.Account_status__c;
            collectionStatus = (htbDynamic.Collections_status__c != null) ? String.valueOf(htbDynamic.Collections_status__c) : '';
            monthsInArrears = (htbDynamic.Months_in_arrears__c != null) ? String.valueOf(htbDynamic.Months_in_arrears__c) : '';
            arrearsBalance = (htbDynamic.Arrears_balance__c != null) ? String.valueOf(htbDynamic.Arrears_balance__c) : '';
            potentialImpairmentIndicators1 = htbDynamic.Potential_Impairment_Indicators_1__c;
            potentialImpairmentIndicators2 = htbDynamic.Potential_Impairment_Indicators_2__c;
            potentialImpairmentIndicators3 = htbDynamic.Potential_Impairment_Indicators_3__c;
            potentialImpairmentIndicators4 = htbDynamic.Potential_Impairment_Indicators_4__c;
            potentialImpairmentIndicators5 = htbDynamic.Potential_Impairment_Indicators_5__c;
            potentialImpairmentIndicators6 = htbDynamic.Potential_Impairment_Indicators_6__c;
            potentialImpairmentIndicators7 = htbDynamic.Potential_Impairment_Indicators_7__c;
            recoveredMoniesAfterClaim = (htbDynamic.Recovered_monies_after_claim__c != null) ? String.valueOf(htbDynamic.Recovered_monies_after_claim__c) : '';
			//Help to Buy XML change
			RedemptionDate = (htbDynamic.Redemption_date__c != null) ? String.valueOf(htbDynamic.Redemption_date__c) : '';
			//PossessionDate = (htbDynamic.Possession_date__c != null) ? String.valueOf(htbDynamic.Possession_date__c) : '';
			//DefaultDate = (htbDynamic.Default_date__c != null) ? String.valueOf(htbDynamic.Default_date__c) : '';
        }
        
        //  Start Node
        String dynamicDataNode = '<DynamicData>';
        
        //  Loan Performance Data Node
        dynamicDataNode += '<LoanPerformanceData>';
		//Help to Buy XML change
		if(htbDynamic.oppStageName__c == 'Redeemed')
		{
		 actionCode = 'C';         
		}
		
		// C0687 Changed to send all nodes regardless of value so we send empty nodes everytime
		dynamicDataNode += '<actionCode>' + actionCode + '</actionCode>';
        dynamicDataNode += '<uniqueReference>' + uniqueReference + '</uniqueReference>';
        dynamicDataNode += '<lender>' + lender + '</lender>';
        dynamicDataNode += '<brand>' + brand + '</brand>';
        dynamicDataNode += '<reportingMonth>' + reportingMonth + '</reportingMonth>';
        dynamicDataNode += '<currentBalance>' + currentBalance + '</currentBalance>';
        dynamicDataNode += '<currentExposure>' + currentExposure + '</currentExposure>';
        dynamicDataNode += '<remainingTerm>' + remainingTerm + '</remainingTerm>';
        dynamicDataNode += '<paymentDue>' + paymentDue + '</paymentDue>';
        dynamicDataNode += '<customerPaymentAmount>' + customerPaymentAmount + '</customerPaymentAmount>';
        dynamicDataNode += '<currentInterestRate>' + currentInterestRate + '</currentInterestRate>';
        dynamicDataNode += '<currentProductRateType>' + currentProductRateType + '</currentProductRateType>';
        dynamicDataNode += '<indexedPropertyValue>' + indexedPropertyValue + '</indexedPropertyValue>';
        dynamicDataNode += '<currentLTV>' + currentLTV + '</currentLTV>';
        dynamicDataNode += '<behaviouralPD>' + behaviouralPD + '</behaviouralPD>';
        dynamicDataNode += '<behaviouralEAD>' + behaviouralEAD + '</behaviouralEAD>';
        dynamicDataNode += '<behaviouralLGD>' + behaviouralLGD + '</behaviouralLGD>';
        dynamicDataNode += '<accountStatus>' + accountStatus + '</accountStatus>';
        
		//Help to Buy XML changeindexedPropertyValue
		if(htbDynamic.oppStageName__c == 'Redeemed')
		{
		  dynamicDataNode += '<collectionStatus>' + collectionStatus + '</collectionStatus>';
		  dynamicDataNode += '<redemptionDate>' + RedemptionDate + '</redemptionDate>';
        }
		//dynamicDataNode += '<possessionDate>' + PossessionDate + '</possessionDate>';
		//dynamicDataNode += '<defaultDate>' + DefaultDate + '</defaultDate>';
		// 
		dynamicDataNode += '</LoanPerformanceData>';
        
        //  Loan Arrears Shortfall Node
        dynamicDataNode += '<LoanArrearsShortfall>';
        dynamicDataNode += '<monthsInArrears>' + monthsInArrears + '</monthsInArrears>';
        dynamicDataNode += '<arrearsBalance>' + arrearsBalance + '</arrearsBalance>';
        dynamicDataNode += '<potentialImpairmentIndicators1>' + potentialImpairmentIndicators1 + '</potentialImpairmentIndicators1>';
        dynamicDataNode += '<potentialImpairmentIndicators2>' + potentialImpairmentIndicators2 + '</potentialImpairmentIndicators2>';
        dynamicDataNode += '<potentialImpairmentIndicators3>' + potentialImpairmentIndicators3 + '</potentialImpairmentIndicators3>';
        dynamicDataNode += '<potentialImpairmentIndicators4>' + potentialImpairmentIndicators4 + '</potentialImpairmentIndicators4>';
        dynamicDataNode += '<potentialImpairmentIndicators5>' + potentialImpairmentIndicators5 + '</potentialImpairmentIndicators5>';
        dynamicDataNode += '<potentialImpairmentIndicators6>' + potentialImpairmentIndicators6 + '</potentialImpairmentIndicators6>';
        dynamicDataNode += '<potentialImpairmentIndicators7>' + potentialImpairmentIndicators7 + '</potentialImpairmentIndicators7>';
        dynamicDataNode += '<recoveredMoniesAfterClaim>' + recoveredMoniesAfterClaim + '</recoveredMoniesAfterClaim>';
        dynamicDataNode += '</LoanArrearsShortfall>';
        
        //  End Node
        dynamicDataNode += '</DynamicData>';
        
        return dynamicDataNode;
    }
    
    private static String getTrailerNode(HTB_Reporting_Month__c htbMonth) {
        String transactionCount = '';
        if (htbMonth != null) {
            transactionCount = (htbMonth.Transaction_Count__c != null) ? String.valueOf(htbMonth.Transaction_Count__c) : '';
        }
        
        String trailerNode = '<Trailer><transactionCount>' + transactionCount + '</transactionCount></Trailer>';
        return trailerNode;
    }
    
    private static String formatDate(Date theDate) {
        if (theDate != null)
            return DateTime.newInstance(theDate, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        return '';
    }
}