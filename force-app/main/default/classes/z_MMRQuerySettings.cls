@IsTest
public class z_MMRQuerySettings
{
    public static void CreateAll()
    {
        List<SOQLQuery__c> lst = new List<SOQLQuery__c>();
        
        
        SOQLQuery__c q1 = new SOQLQuery__c();
        q1.name='MMR_AIP_Applicant';
        q1.soql_1__c = 'select name,Salutation, ispersonaccount, id, firstname, lastname,Gross_Annual_Income__c,Net_Monthly_Income__c,Marital_Status__c ,Number_of_cars__c,No_of_depenents__c';
        lst.add(q1);
        
        //C0639 - SBC - Add Disclaimer in AIP - added Is_Disclaimer_Read__c to the query below
        SOQLQuery__c q2 = new SOQLQuery__c();
        q2.name='MMR_AIP_Opp';
        q2.soql_1__c = 'select id , name,Purchase_price_market_value__c,Term_of_Finance__c,Finance_Required__c,Is_Joint_Application__c,Number_of_People_Applying__c,Is_Disclaimer_Read__c';
        lst.add(q2);
        
        SOQLQuery__c q3 = new SOQLQuery__c();
        q3.name='MMR_App_Additional';
        q3.soql_1__c = 'select id,Advice_at_POS__c,How_was_sale_made__c, Service_at_POS__c';
        lst.add(q3);
        
        SOQLQuery__c q4 = new SOQLQuery__c();
        q4.name='MMR_App_Additional_Ex';
        q4.soql_1__c = 'select id, Paying_full_value__c, Tenure__c, Property_guarantee__c , Remaining_leasehold_term__c, Full_lease_term__c, Property_Type__c, Property_details__c, No_of_bedrooms__c, If_a_flat_how_many_storeys_high__c,';
        q4.soql_2__c='What_floor_is_the_flat_located_on__c,Is_property_above_commercial_premise__c, Is_the_property_expublic_sector__c, Are_you_buying_from_a_family_member__c, Is_there_an_element_of_Gift_involved__c, Is_the_property_your_main_residence__c,';
        q4.soql_3__c='Shared_ownership__c, Construction_Type_Roof__c, Construction_type_walls__c, Will_property_be_let_using_AST__c, Length_of_AST__c, Property_let_to_family_or_company__c, Estate_agent_contact_name__c, Estate_agent_company_name__c,';
        q4.soql_4__c='Estate_agent_contact_telephone_number__c, Solicitor_company_name__c, Solicitor_contact_name__c, Solicitor_postcode__c, Solicitor_street__c, Solicitor_city__c, Solicitor_country__c, Solicitor_contact_telephone_number__c, Solicitor_email_address__c,';
        q4.soql_5__c='Additional_Information__c, Over_17_will_occupy_property__c';
        lst.add(q4);
        
        SOQLQuery__c q5 = new SOQLQuery__c();
        q5.name='MMR_FF_Addresses';
        q5.soql_1__c = 'select id,name, BillingPostalCode,BillingStreet,BillingCity,BillingCountry, Date_moved_to_address__c,ShippingPostalCode,ShippingStreet,ShippingCity,ShippingCountry,Date_moved_to_previous_address__c,PersonMailingPostalCode,PersonMailingStreet,  ';
        q5.soql_2__c = 'PersonMailingCity,PersonMailingCountry,Date_moved_to_prev_previous_address__c,Customer_Address_House_No__c, isPersonaccount';
        lst.add(q5);
        
        SOQLQuery__c q6 = new SOQLQuery__c();
        q6.name='MMR_FF_Credit';
        q6.soql_1__c = 'select id, name,Ever_been_in_arrears_with_any_loans__c ,Additional_information_about_fin_details__c ,AppliedMortgageElsewhere__c,Have_you_had_a_debt_relief__c,Please_provide_details_of_any_IVA_s__c,Have_you_had_any_IVA__c,Date_discharged_v1__c,    ';
        q6.soql_2__c='Date_of_bankrutcy__c,Have_you_ever_been_made_bankrupt__c,Default_against_you__c,Have_you_ever_had_a_CCJ__c,Please_provide_detail_of_arrears__c ,Have_any_arrear_s_worsened_in_last_6mth__c ,Date_arrears_repaid__c ,Date_of_highest_arrears__c ,';
        q6.soql_3__c='Number_of_months_in_arrears__c ,Amount_in_arrears__c, ispersonaccount';
        lst.add(q6);
        
        SOQLQuery__c q7 = new SOQLQuery__c();
        q7.name='MMR_FF_Credit_CCJ';
        q7.soql_1__c = 'select id,name,Account__c,CCJ_date_of_CCJ__c,CCJ_amount_of_CCJ__c,CCJ_date_repaid__c,CCJ_certificate_held__c,CCJ_Reason__c  ';
        lst.add(q7);
        
        SOQLQuery__c q8 = new SOQLQuery__c();
        q8.name='MMR_FF_Credit_Default';
        q8.soql_1__c = 'select id, Account__c,Default_date__c,Default_amount__c,Default_date_repaid__c,Default_reason__c';
        lst.add(q8);
        
        SOQLQuery__c q9 = new SOQLQuery__c();
        q9.name='MMR_FF_Execution';
        q9.soql_1__c = 'select id, name,Customer_prompt_for_execution_only__c,Debt_Consolidation_main_purpose__c,Mortgage_professional__c,Income_exceed_300k__c,Assets_over_3m__c,Execution_Only_Reason__c,Require_advice__c    ';
        lst.add(q9);
        
        SOQLQuery__c q10 = new SOQLQuery__c();
        q10.name='MMR_FF_Financial';
        q10.soql_1__c = 'select id, name,Personal_savings_value__c,Date_of_current_account_opened__c,Name_of_where_main_bank_accounts_held__c,Other_account_number__c,Other_bank_sort_code__c,IsPersonAccount   ';
        lst.add(q10);
        
        SOQLQuery__c q11 = new SOQLQuery__c();
        q11.name='MMR_FF_Financial_Debts';
        q11.soql_1__c = 'select id,name,ApplicantDebt__c, Owner_of_debt__c,Type_of_debt__c,Debt_Lender_Name__c,Start_date__c,Monthly_repayment__c,Outstanding_balance__c,PaidOffDebt__c,Will_this_debt_be_paid_off_by_this_app__c,Secured_on_property__c,Cleared_before_HPP_starts__c';
        lst.add(q11);
        
        SOQLQuery__c q12 = new SOQLQuery__c();
        q12.name='MMR_FF_Income';
        q12.soql_1__c = 'select id, name, Employment_Type__c,Other_Employment_Type__c,Employment_Status__c,Occupation__c ,Nature_of_Employers_Your_Business__c,Date_Employment_Commenced__c,Share_holding_in_the_business__c,When_was_the_business_established__c,Employer_Name__c,';
        q12.soql_2__c = 'Employer_Country__c,Employer_Post_Code__c,Employer_Address_Line_1__c,Employer_Address_Line_2__c,Employer_Address_Line_3__c,Employer_Address_Line_4__c,Gross_Annual_Income__c,Net_Monthly_Income__c,Guaranteed_bonus__c,Regular_Bonus__c,';       
        q12.soql_3__c = 'Guaranteed_Commission__c,Regular_Commission__c,Guaranteed_Overtime__c,Regular_Overtime__c,Guaranteed_Shift_Allowance__c,Regular_Shift_Allowance__c,Car_Allowance__c,Large_Town_Allowance__c,How_do_you_receive_your_salary__c,How_often_are_you_paid__c,';       
        q12.soql_4__c = 'Has_Second_Employment__c,Is_the_customer_an_expat__c,Is_the_customer_going_to_return_in_the_n__c,Customer_Asset_Value__c,Customer_profile_Type__c,';       
        q12.soql_5__c = 'Employment_Type_2__c, Other_Employment_Type2__c, Employment_Status_2__c, Occupation_2__c, Nature_of_Business_2__c, Date_Employment_Commenced_2__c, Share_holding_in_the_business_c__c, When_was_the_business_established2__c, Employers_Name__c,';       
        q12.soql_6__c = 'Employers_Country__c, Employers_Post_Code__c, Employers_Address_Line_1__c, Employers_Address_Line_2__c, Employers_Address_Line_3__c, Employers_Address_Line_4__c, Gross_Annual_Income_2__c, Net_Monthly_Income_2__c, Guaranteed_bonus_2__c,';       
        q12.soql_7__c = 'Regular_Bonus2__c, Guaranteed_Commission2__c, Regular_Commission2__c, Guaranteed_Overtime2__c, Regular_Overtime2__c, Guaranteed_Shift_Allowance2__c, Regular_Shift_Allowance2__c, Car_Allowance2__c, Large_Town_Allowance2__c,';       
        q12.soql_8__c = 'How_do_you_receive_your_salary_2__c, How_often_are_you_paid2__c, Do_you_have_another_income_eg_pension__c, Source_of_income__c, If_yes_to_other_income_please_give_value__c, If_retired_what_is_annual_pension__c, Do_you_have_2_years_of_accounts__c,';       
        q12.soql_9__c = 'Do_you_have_3_yrs_of_self_ass_tax_form__c, Year_1_Gross_Dividend_Income__c, Year_1_Net_Profit__c, Year_2_Gross_Dividend_Income__c, Year_2_Net_Profit__c, Year_3_Gross_Dividend_Income__c, Year_3_Net_Profit__c, Accountant_name__c, Accountant_Firm__c,';       
        q12.soql_10__c = 'Accountant_Street__c,Non_standard_income__c , Accountant_Town_City__c, Accountant_PostCode__c, Accountant_Phone__c, Additional_employment_information__c, ispersonaccount';       
        lst.add(q12);
        
        SOQLQuery__c q13 = new SOQLQuery__c();
        q13.name='MMR_FF_Ownership';
        q13.soql_1__c = 'select id, name,Home_Details__c ,Other_home_details__c,What_is_your_currt_monthly_rent_payment__c,Name_of_landlord__c,Do_you_have_an_existing_mortgage__c,Lender_name__c,Have_you_previously_had_a_mortgage__c,When_did_you_redeem_your_mortgage__c,   ';
        q13.soql_2__c = 'Mortgage_account_number__c,How_long_have_you_being_with_lender__c,Purchase_price__c,Amount_financed__c,How_much_is_outstanding_on_mortgage__c,Current_monthly_mortgage_payment__c,Home_Telephone_No__c,Other_properties_do_you_currently_own__c,';
        q13.soql_3__c = 'BTL_Properties__c,Is_mortgage_paid_by_time_HPP_completed__c,Asset_SellingPrice__c, ispersonaccount';
        lst.add(q13);
        
        SOQLQuery__c q14 = new SOQLQuery__c();
        q14.name='MMR_FF_PersonalDetails';
        q14.soql_1__c = 'select id,name, salutation,lastname,firstname,gender__c,isPersonAccount,Middle_Name__pc,Date_of_Birth__c,Home_Telephone_No__c,PersonEmail,No_of_depenents__c,Planned_retirement_age__c,phone,Marketing_Preference__c';
        lst.add(q14);
        
        SOQLQuery__c q15 = new SOQLQuery__c();
        q15.name='MMR_FF_Property';
        q15.soql_1__c = 'select id, name, First_line_of_address__c,PersonAccount__c,Estimated_value__c,Date_purchased__c,ExisitingMortgageHPPLender__c,Amount_of_monthly_repayment__c,IsBTLProperty__c,Amount_of_monthly_rent_received__c   ';
        lst.add(q15);
        
        SOQLQuery__c q16 = new SOQLQuery__c();
        q16.name='MMR_FF_PropertyAddress';
        q16.soql_1__c = 'select id, Purchase_price_market_value__c, Term_of_Finance__c, Finance_required__c, Purpose_of_Finance__c, First_time_buyer__c, New_property_country__c, New_property_postcode__c, New_property_street__c, New_property_city__c';
        lst.add(q16);
        
        SOQLQuery__c q17 = new SOQLQuery__c();
        q17.name='MMR_Suitability';
        q17.soql_1__c = 'select id, Sharia_compliant_products__c,Letter_sharia_compliant__c,Lump_sum_payments__c,Letter_lump_sum__c,No_early_repayment_charges__c,Letter_Early_Repayment__c,Stability_in_payments__c,';
        q17.soql_2__c = 'Letter_payment_stability__c,Income_change__c,Letter_income_change__c,Payments_increased__c,Letter_payments_increased__c,Payments_low_as_possible__c,Letter_low_payments__c,Expenditure_change__c,Letter_expenditure_change__c,Moving_house_soon__c,';
        q17.soql_3__c = 'Letter_moving_house__c,HPP_into_retirement__c,Letter_HPP_into_retirement__c,X1st_priority__c,X2nd_priority__c,X3rd_priority__c,Product_recommendation__c,Reason__c,Term_of_Finance__c,Allocated_disposable_income__c ,Letter_allocated_disposable_income__c,';
        q17.soql_4__c = 'Term_in_mind__c,Reason_for_term__c,Alternate_product__c,IBB_Product__c,Execution_only__c,Finance_Required__c,Purchase_price_market_value__c,FTV__c,Purpose_of_Finance__c,Letter_Low_Up_Front_Costs__c,Low_Up_Front_Costs__c,';
        q17.soql_5__c = 'Sharia_compliant_products2__c,Low_Up_Front_Cost_Formula__c,Consent_Obtained__c';
        lst.add(q17);
        
        SOQLQuery__c q18 = new SOQLQuery__c();
        q18.name='MMR_Suitability_Accept';
        q18.soql_1__c = 'select id, product__r.name, term_of_finance__c, Reason__c,Attachment_Offer_Letter__c,IBBQuotation__c, Product_recommendation__r.name,Alternate_product__c,IBB_Product__c';
        lst.add(q18);
        
        SOQLQuery__c q19 = new SOQLQuery__c();
        q19.name='MMR_Suitability_Decline';
        q19.soql_1__c = 'select id, finance_required__c, term_of_finance__c, Reason_for_decline__c,Alternate_product__c,IBBQuotation__c,Reason_alternate_product__c,Opportunity.Product__r.name,Alternate_product__r.name,IBB_Product__c    ';
        lst.add(q19);
        
        SOQLQuery__c q20 = new SOQLQuery__c();
        q20.name='MMR_App_Details';
        q20.soql_1__c = 'select id, ibb_product__r.name,Purpose_of_Finance__c,Finance_Required__c,Term_of_Finance__c,Purchase_price_market_value__c,New_property_country__c , New_property_postcode__c, New_property_street__c, New_property_city__c, Interested_in__c,';
        q20.soql_2__c = 'Misc_property_info__c, If_BTL_financing_owned_property_12mths__c, Refinance_date_property_purchased__c';
        lst.add(q20);

        SOQLQuery__c q21 = new SOQLQuery__c();
        q21.name='MMR_APP_Applicant';
        q21.soql_1__c = 'select name, ispersonaccount, id, firstname, lastname,Gross_Annual_Income__c,Net_Monthly_Income__c,Marital_Status__c ,Number_of_cars__c,No_of_depenents__c, Salutation';
        lst.add(q21);



        insert lst;
     
    
    }
    
   

}