public  class LiabilitiesHelperFunctions {

    public static String GetServerUrl
    {
        get{
            if(GetServerUrl == null)
            {
                List<IBBQuotation__c> quotes = [select conga_url__c from IBBQuotation__c limit 1];    
                if(quotes.size() > 0)
                    GetServerUrl = quotes[0].conga_url__c;                    
            }
            return GetServerUrl ;
        }
    }
    
    public static String SoqlQuery(String name)
    {
         List<SoqlQuery__c> queries = SoqlQuery__c.getall().values();
         for(SoqlQuery__c query : queries)
         {
             if(query.name.equalsIgnoreCase(name))
                 return SoqlQuery(query);
         }
         return null;           
    }
    
    public static String SoqlQuery(SoqlQuery__c obj)
    {
        String s='';        
        
        for(Integer i =1; i <11;i++)
        {
            String field = 'soql_' + i + '__c';
            if(obj.get(field) != null)
            {
                s+= obj.get(field);
            }
        }
        
        
        return s;
    }
    
    public static String GetParam(string param)
    {
        Map<string,string> paramMap = Apexpages.CurrentPage().getParameters();
        for (String paramName : paramMap.keySet()){
            if(paramName.endsWithIgnoreCase(param))
                return paramMap.get(paramName);
        }
        return null;
    }

    public static void SetPageHeader()
    {
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
    }
    
        public static boolean externalWebsiteUser {
        get {
            if (externalWebsiteUser == null){
               try{
                   if(UserInfo.getFirstName().equalsIgnoreCase('External') && UserInfo.getLastName().equalsIgnoreCase('User'))
                   {
                      externalWebsiteUser = true;
                   }
                   else
                   {
                       externalWebsiteUser =false;
                   }
               }
               catch (Exception e) { externalWebsiteUser = false;}
               system.debug('externalWebsiteUser: ' + externalWebsiteUser + ' user:' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName());
            }
            
            return externalWebsiteUser ;
        }
        set;
    }
    
    public static List<IBB_Product_Suitability__c > GetSuitableProducts(Boolean isExternal)
    {
        if(isExternal)
        {
         return [select id,IBB_Product__c, name,Maximum_deposit_amount__c, minimum_deposit_amount__c 
                ,Minimum_age__c,Maximum_age__c,IBB_product__r.Category_of_Product__c,Number_of_applicants__c
                ,Access_to_Funds__c, IBB_product__r.name
                 from IBB_Product_Suitability__c where Show_On_Liabilities_External__c =true order by name];
        }
        else
        {
            return [select id,IBB_Product__c, name,Maximum_deposit_amount__c, minimum_deposit_amount__c 
                    ,Minimum_age__c,Maximum_age__c,IBB_product__r.Category_of_Product__c,Number_of_applicants__c
                    ,Access_to_Funds__c, IBB_product__r.name
                     from IBB_Product_Suitability__c where Show_On_Liabilities__c = true order by name];
        }
    }

    public static IBB_Product_Set__c GetProductSet(String name)
    {
        IBB_Product_Set__c product = [select p.Max_Age__c, p.Min_Age__c,p.max_no_of_applicants__c, p.max_ftv__c, p.max_purchase_price__c, p.min_purchase_price__c
                                ,p.min_finance_amount__c, p.max_finance_amount__c,p.max_no_of_incomes__c, p.income_multiplier__c, p.min_ftv_btl__c,p.max_no_of_btl_prop__c
                                ,p.allow_ccjs__c,p.Max_Term_of_Finance__c,Min_Term_of_Finance__c,p.suitable_employment_types__c, p.suitable_property_types__c, p.type_of_finance__c
                                ,Employment_Type_Error__c,Finance_Type_Error__c,Property_Type_Error__c  from IBB_Product_Set__c p    where p.name =:name  limit 1];
        return product;
    }
    
    
    public static String CheckAge(Decimal maxAge,Decimal minAge,Account acc, Integer applicantNo)
    {
        if(acc == null)
        {
            return null;
        }
    
        Integer age = CalcAge(acc.Date_of_Birth__c);
        
          if(maxAge != null)
           {
               if(age > maxAge)
               {
                    //return 'Applicant '+applicantNo+' age is '+ age+', maximum allowed is  ' +maxAge ;
                    return 'Applicant '+applicantNo+' is aged '+ age+', the maximum age allowed is  ' +maxAge ;
               }
           }
           if(minAge != null)
           {
               if(age < minAge )
               {
                    return 'Applicant '+applicantNo+' is aged '+ age+', the minimum age allowed is  ' +minAge ;
               }    
           }
           return null;
    }
    
    public static Decimal GetValue(BudgetPlannerConfig__c c, Integer depend, Opportunity opp, List<Account> accs)
    { 
        if(Accs.size()==1 && !Opp.Is_Joint_Application__c)
            return c.SingleApp_ONS__c;
            
        if(depend == 0)
            return c.Joint_App_ONS__c;
            
        if(depend == 1)
            return c.Joint_App_1_Dep_ONS__c;
            
        if(depend == 2)
            return c.Joint_App_2_Dep_ONS__c;
            
        if(depend > 2)
            return c.Joint_App_3_Dep_ONS__c;
            
          
        return 0;    
    }
    
    //start - C0568
    public static List<double> hppAfford(Opportunity opp, List<Account> accs, string BPVer){
        List<double> resp=new List<double>();

        MMR_Calculator MMRCalc = new MMR_Calculator(opp);

        Boolean is_BP_V1 = BPVer=='V1' ? true : false;
        Boolean is_BP_V2 = BPVer=='V2' ? true : false;
        
        Integer noCars=0;
        Integer noDepend=0;
        Decimal netIncome = 0;
        
        for(Account a : accs)
        {
            noCars += integer.valueof(a.Number_of_cars__c);
            noDepend += integer.valueof(a.No_of_depenents__c);
            netIncome += a.Net_Monthly_Income__c;
        }
        
        List<BudgetPlannerConfig__c> configs = [select id,SingleApp_ONS__c,Joint_App_ONS__c, Joint_App_1_Dep_ONS__c,Joint_App_2_Dep_ONS__c,Joint_App_3_Dep_ONS__c,Car_Bill__c
                                                from BudgetPlannerConfig__c where V1__c =:is_BP_V1 or V2__c=:is_BP_V2];
        
        double total = 0;
        
        for(BudgetPlannerConfig__c c : configs )
        {
            Decimal figure=GetValue(c,noDepend,opp,accs); 
            if(figure == null)
                figure = 0;          
            if(c.Car_Bill__c)
            {
                figure = figure * noCars;
            }
            total += figure;            
        }
        
        MMRCalc.RateToUse = 5.49; // TODO: This should come from a custom setting

        //hppRepayment = hppRepayment.round();

        MMRCalc.CalculateMonthlyRepayment(false);
        
        resp.add(MMRCalc.MonthlyRepaymentAmortised.round());
        resp.add(total);
        resp.add(netIncome);
        
        
        return resp;
    }
    
    public static List<double> btlAfford(Opportunity opp, List<Account> accs){
        List<double> resp=new List<double>();
        
        MMR_Calculator MMRCalc = new MMR_Calculator(opp);

        // C0644 We haven't chosen a product yet so won't have a Sub Type, check the interested in product instead to set it.
        if(opp.interested_in__c=='Buy To Let Limited Company Purchase Plan')
        {
            MMRCalc.ProductSubType='LC';
        }
                  
        if(opp.Estimated_actual_monthly_rental_income__c==null)
        {
            opp.Estimated_actual_monthly_rental_income__c=0;
        }

        MMRCalc.CalculateMonthlyRepayment(true);
        
        resp.add(MMRCalc.MonthlyRepaymentAmortised.round());
        resp.add(MMRCalc.GrossRentalIncome);
        resp.add(opp.Estimated_actual_monthly_rental_income__c); //taken as net income
              
        system.debug('response:'+resp);
        
        
        return resp;
    }
    
    //end- C0568
    
    

    

   public static List<String> IsEligible(Account mainAccount, Opportunity opp, Account account2, Account account3, Account account4)
   {
        List<String> myList = new List<String>();    
          
        IBB_Product_Set__c productset = GetProductSet(opp.interested_in__c);
         
        Decimal incomeSum=0;

        // C0644 mainAccount may be a Ltd Co. so check for FirstName before attempting to use income
        if(mainAccount != null && mainAccount.FirstName!=null)
        {   
            incomeSum += mainAccount.Net_Monthly_Income__c - mainAccount.Total_monthly_financial_commitments__c;
        }

        if(account2!= null)
        {
            incomeSum += account2.Net_Monthly_Income__c - account2.Total_monthly_financial_commitments__c;
        }
           
        if(account3!= null)
        {
            incomeSum += account3.Net_Monthly_Income__c - account3.Total_monthly_financial_commitments__c;
        }     
           
        if(account4!= null)
        {
            incomeSum += account4.Net_Monthly_Income__c - account4.Total_monthly_financial_commitments__c;
        }
           
        MMR_Calculator MMRCalc = new MMR_Calculator(opp);
                   
           
        Decimal affordabilityLimit = incomeSum * .6;
           
        system.debug('Interested in:'+opp.Interested_in__c);
        //start - C0568
        if ( opp.Interested_in__c.startsWithIgnoreCase('Buy To Let' ))
        {
            // C0644 We haven't chosen a product yet so won't have a Sub Type, check the interested in product instead to set it.
            if(opp.interested_in__c=='Buy To Let Limited Company Purchase Plan')
            {
                MMRCalc.ProductSubType='LC';
            }
                
            // C0635 Now just use the MMR Calculator
            MMRCalc.CalculateMonthlyRepayment(true);
                  
            double expectedRent=opp.Estimated_actual_monthly_rental_income__c;
                  
            if(opp.Estimated_actual_monthly_rental_income__c==null){
                opp.Estimated_actual_monthly_rental_income__c=0;
            }
              
            double GrossRentalIncome=MMRCalc.GrossRentalIncome;
                  
            //system.debug('GrossRentalIncome:'+GrossRentalIncome);
                  
            if(expectedRent<=GrossRentalIncome)
            {
                myList.add('The information you have submitted indicates that the monthly rental income is not sufficient.'); //GrossRentalIncome:'+GrossRentalIncome+', '+((amountOfMonthlyRepayment - aquisition)*RentCoverageRatio)+',  stressedRentCoverageRatio:'+stressedRentCoverageRatio+', ExpectedRent:'+expectedRent+', MonthlyPayment:'+amountOfMonthlyRepayment+', aquisition:'+aquisition+', rentCoverageRatio:'+PRARentCoverageRatio);
            }
                  
        }
        else //end - C0568
        {
            HPPConfigSettings setting = new HPPConfigSettings ('EligibilityRate', 'Decimal');
            Decimal EligibilityRate;
            if(setting.decConfigValue!=null)
            {
                EligibilityRate=setting.decConfigValue;
            }
            else
            {
                EligibilityRate = 6.89; // Default rate used before move to Custom Setting
            }
            
            MMRCalc.RateToUse=EligibilityRate;
            MMRCalc.CalculateMonthlyRepayment(false);
            Decimal monthlyPayment = MMRCalc.MonthlyRepaymentAmortised*1.25;
            System.debug('MMRCalc.MonthlyPaymentAmortised='+MMRCalc.MonthlyRepaymentAmortised);
            System.debug('MMRCalc.MonthlyPaymentRentOnly='+MMRCalc.MonthlyRepaymentRentOnly);
            System.debug('monthlyPayment='+monthlyPayment);
            System.debug('affordabilityLimit='+affordabilityLimit);
            if(monthlyPayment > affordabilityLimit )
            {
                myList.add('The information you have submitted indicates that the finance you required is too great.');
            }
        }
           
        if(productset.Allow_CCJs__c != null && Opp.Have_you_ever_had_a_CCJ_or_been_bankrupt__c != null)
        {
            if(productset.Allow_CCJs__c.equalsIgnoreCase('No') &&  Opp.Have_you_ever_had_a_CCJ_or_been_bankrupt__c)
            {
                myList.add('This product does not allow applicants with CCJ\'s');
            }
        }
           
        if(productset.max_no_of_applicants__c!= null)
        {
            if(opp.Number_of_People_Applying__c >  productset.max_no_of_applicants__c)
            {
                myList.add('Too many applicants - only ' +productset.max_no_of_applicants__c + ' applicants allowed');
            }    
        }
           
        // C0644 mainAccount may be a Ltd Co. so check for FirstName before attempting to use anything
        if(mainAccount != null && mainAccount.FirstName!=null)
        {
            String s = CheckAge(productset.Max_Age__c,productset.Min_Age__c,mainAccount,1);
            if(s!= null)
            mylist.add(s);
            }
        if(account2!= null)
        {
            String s = CheckAge(productset.Max_Age__c,productset.Min_Age__c,account2,2);
            if(s!= null)
            mylist.add(s);
            }
        if(account3!= null)
        {
            String s = CheckAge(productset.Max_Age__c,productset.Min_Age__c,account3,3);
            if(s!= null)
            mylist.add(s);
            }
        if(account4!= null)
        {
            String s = CheckAge(productset.Max_Age__c,productset.Min_Age__c,account4,4);
            if(s!= null)
            mylist.add(s);
            }                          
     
           
        if(productset.Max_Finance_Amount__c!= null)
        {
            if(opp.Finance_Required__c >  productset.Max_Finance_Amount__c)
            {
                myList.add('Maximum finance amount is £'+ productset.Max_Finance_Amount__c);
            }
        }
           
           
        if(productset.Max_Term_Of_finance__c!= null)
        {
            if(opp.Term_of_Finance__c >  productset.Max_Term_Of_finance__c)
            {
                //myList.add('Maximum term of finance amount is '+ productset.Max_Term_Of_finance__c+' years.');
                myList.add('The maximum length of finance offered by Al Rayan Bank for this product is '+ productset.Max_Term_Of_finance__c+' years.');
            }
        }
           
        if(productset.Min_Term_Of_finance__c!= null)
        {
            if(opp.Term_of_Finance__c <  productset.Min_Term_Of_finance__c)
            {
                //myList.add('Minimum term of finance amount is '+ productset.Min_Term_Of_finance__c+' years.');
                myList.add('The minimum length of finance offered by Al Rayan Bank for this product is '+ productset.Min_Term_Of_finance__c+' years.');
            }
        } 
           
        /*   
        if(productset.Min_Finance_Amount__c!= null)
        {
            if(opp.Finance_Required__c <  productset.Min_Finance_Amount__c)
            {
                myList.add('Minimum finance amount is £'+ productset.Min_Finance_Amount__c);
            }
        }*/
         // C0782: REAC changes start
        if(productset.Min_Finance_Amount__c!= null)
        {
            if(opp.Finance_Required__c <  productset.Min_Finance_Amount__c & (!opp.Interested_in__c.Contains('REAC')))
            {
                myList.add('Minimum finance amount is £'+ productset.Min_Finance_Amount__c);
            }
             if(opp.REAC_Amount__c <  productset.Min_Finance_Amount__c & (opp.Interested_in__c.Contains('REAC')))
            {
                myList.add('REAC amount shall be greater than or equal to £'+ productset.Min_Finance_Amount__c);
            }
        }
           // C0782: REAC changes end
           
        if(productset.Max_Purchase_Price__c!= null)
        {
            if(opp.Purchase_price_market_value__c > productset.Max_Purchase_Price__c )
            {
                myList.add('Maximum purchase price is £' +productset.Max_Purchase_Price__c);
            }
        }
           
        if(productset.Min_Purchase_Price__c!= null)
        {
            if(opp.Purchase_price_market_value__c < productset.Min_Purchase_Price__c )
            {
                myList.add('Minimum purchase price is £' +productset.Min_Purchase_Price__c);
            }
        }
           
           
        if( productset.Max_FTV__c != null )
        {
            /* M00024 fix calculation */
            //Integer FTV = Integer.valueof( (100/opp.Purchase_price_market_value__c       ) * opp.Finance_Required__c );
            Decimal FTV = (100/opp.Purchase_price_market_value__c       ) * opp.Finance_Required__c ;         
            FTV = FTV.setScale(2, RoundingMode.HALF_UP);
            /* M00024 end */
               
            if(FTV > productset.Max_FTV__c)
            {
                //myList.add('FTV value is ' + FTV + '%, maximum allowed is ' + integer.valueof( productset.Max_FTV__c )+ '%' );
                myList.add('The maximum finance to value offered by Al Rayan Bank on this product is ' + integer.valueof( productset.Max_FTV__c )+ '%' );
            }
            else
            {
                if(opp.interested_in__c.equalsIgnoreCase('Buy to let'))
                {
                    if(opp.Do_you_currently_own_a_property__c.equalsIgnoreCase('no') )
                    {
                        if(FTV > 65)
                        {
                            myList.add('FTV value is ' + FTV + '%, for buy to let customers who do not own a property for at least 12 months, the maximum allowed is 65%' );         
                        }
                    }
                }
            }
        }
           
        if( productset.Suitable_Employment_Types__c!= null && MainAccount.Employment_Type__c!=null )
        {              
            if(!ContainsOption(MainAccount.Employment_Type__c, productset.Suitable_Employment_Types__c))
                myList.add( productset.Employment_Type_Error__c );
        }
           
        if(MainAccount.Employment_Type__c != null)
        {
        if(MainAccount.Employment_Type__c.containsIgnoreCase('self'))
            {
                if(MainAccount.Do_you_have_2_years_of_accounts__c != null)
                {
                    if(!MainAccount.Do_you_have_2_years_of_accounts__c .equalsIgnoreCase('yes'))
                    {
                        myList.add('If self employed, you must have 3 years of accounts.');
                    }
                }
                else
                {
                myList.add('If self employed, you must have 3 years of accounts.');
                }
            } 
        }
        if( productset.Suitable_Property_Types__c!= null )
        {   
            if(!ContainsOption(opp.Property_type__c, productset.Suitable_Property_Types__c))
                        myList.add(productset.Property_Type_Error__c);   
        }
           
        if( productset.Type_of_Finance__c!= null )
        {              
            if(!ContainsOption(opp.Purpose_of_Finance__c, productset.Type_of_Finance__c ))
                myList.add(productset.Finance_Type_Error__c);
        }
               
        if(myList.size() == 0)
        myList.add('YES');
   
        system.debug(myList.Size());
   
        return myList;
   }
   
   public static Boolean ContainsOption(String value, String validTypes)
   {
        String [] types=validTypes.split(','); 
               
               Boolean found = false;
               
               for(String s : types)
               {
                   s = s.trim();
                   system.debug('Comparing ' + s + ' to ' + value);
                   if(s.equalsIgnoreCase(value.trim()))
                   {
                       system.debug('Found ' + value);
                       return true;
                   }
                       
               }
               return false;         
   }

    public static Integer CalcAge(Date dob)
    {
    Date d = dob;
       Integer totaldays;
       totaldays=  d.daysBetween(system.today());
        return(integer)(math.Floor(totaldays/365.2425));

    }


    public static Data_AddressValidation checkAddressDates(Date currDate, Date prevDate, Date prevprevDate, Date dob, string additionalAddressDetails ){
        
        Data_AddressValidation data = new Data_AddressValidation();
 
        data.allAddressesEntered = true;
        Date todayDate = Date.today();
        if (currDate > todayDate) 
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Date of moving cannot be after today'));
          return null;
        }
        if (prevDate != null && prevDate > todayDate)
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Date of moving cannot be after today'));
          return null;
        }
        if (prevprevDate != null && prevprevDate > todayDate)
        {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Date of moving cannot be after today'));
          return null;
        }
        integer daysAtCurrAddress = currDate.daysBetween(todayDate);
        integer daysAtPrevAddress = (prevDate == null ? 0 : prevDate.daysBetween(todayDate));
        integer daysAtPrevPrevAddress = (prevprevDate == null ? 0 : prevprevDate.daysBetween(todayDate));
        
        integer minimumAddressHistory = 1095;
        Date lifeDate = dob;
        if ( lifeDate != null )
        {
            integer daysAlive = lifeDate.daysBetween(todayDate);
            if ( minimumAddressHistory > daysAlive )
            {
                minimumAddressHistory = daysAlive;
            }
            system.debug( ' minimumAddressHistory='+minimumAddressHistory+' daysAlive='+daysAlive);
        }
        
        if (daysAtCurrAddress < minimumAddressHistory){
            data.showPrevAddress = true;
            data.allAddressesEntered = false;
        }else if (daysAtCurrAddress >= minimumAddressHistory){
            data.showPrevAddress = false;
            data.allAddressesEntered = true;
        }   
        
        if (prevDate == null && daysAtCurrAddress < minimumAddressHistory){
            data.allAddressesEntered = false;
        }
        
        if (prevDate != null && daysAtPrevAddress < minimumAddressHistory){
            data.showPrevPrevAddress = true;
            data.allAddressesEntered = false;
        }else if (prevDate != null && daysAtPrevAddress >= minimumAddressHistory){
            data.showPrevPrevAddress = false;
            data.allAddressesEntered = true;
        }
        
        if (prevprevDate == null && prevDate != null && daysAtPrevAddress < minimumAddressHistory){
            data.allAddressesEntered = false;
        }
         
        if (prevprevDate != null && daysAtPrevPrevAddress < minimumAddressHistory){
            data.showPrevPrevPrevAddress = true; 
            data.allAddressesEntered = false;
        }else if (prevprevDate != null && daysAtPrevPrevAddress >= minimumAddressHistory){
            
            data.allAddressesEntered = true;
        }
        
        if (additionalAddressDetails != null && additionalAddressDetails != '' )
        {
          data.allAddressesEntered = true;
        }
        
        return data;
    }
    
    //Pass the resource name
    public static String GetResourceURL(String resourceName)
    {
        //Fetching the resource
        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

        //Checking if the result is returned or not
        if(resourceList.size() == 1)
        {
           //Getting namespace
           String namespace = resourceList[0].NamespacePrefix;
           //Resource URL
           return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
        }
        else return '';
    }
}