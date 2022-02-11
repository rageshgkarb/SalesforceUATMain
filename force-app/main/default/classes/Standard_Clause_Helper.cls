/* ----------------------------------------------------------------------------------------------------`*/
/* C0???																								*/
/* ----------------------------------------------------------------------------------------------------`*/


public class Standard_Clause_Helper
{
    private Opportunity opp {get;set;}
	private HPP_extended_opportunity__c ExOpp {get;set;} // C0???

    public Standard_Clause_Helper(string oppId)
    {
        opp = [select id,
										Full_name_of_guarantor__c,
										Guarantor_property__c,
										Staff_HPP__c,
										Offer_letter_panel_non_panel__c,
										Purpose_of_finance__c,IBB_Product_Code__c,
										IBB_Product__r.IBB_Product_Set__r.name,
										IBB_Product__r.ProductSubType__c,
										Is_there_a_guarantor__c,
										IBB_Product__r.Warning_Clause_Offer_Letter__c
										, Fee_Assisted__c,Cashback_Eligibility__c
										,Discounted_product_expiry_date__c
										,Offer_letter_discount_end_date__c
										,Sort_Code__c
										,Account_Number__c		// C0???
            from opportunity where id=:oppId];
			
		/* C0??? Start */
		ExOpp = [select id,AdminFeeValue__c,Al_Rayan_Valuation_Contribution__c
					 
					FROM HPP_extended_opportunity__c WHERE Opportunity__r.id=:oppId];     
		/* C0??? End */     
    }

    public void Run()
    {
        //delete all items
        
        //try
        //{
        
        List<Clause_Item__c > oldItems = [select id from Clause_Item__c where opportunity__c =:opp.id];
        delete oldItems ;
    
        List<Standard_Clause__c> items = new List<Standard_Clause__c>();

		/* C0644 Start  */
		if(Opp.IBB_Product__r.ProductSubType__c=='LC')
		{
			string BTLLCPurpose = 'BTLLC '+Opp.Purpose_of_finance__c;
			items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c =:'BTLLC' and (type2__c =: opp.Offer_letter_panel_non_panel__c or type2__c = null) and active__c = true]); 
			items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c =:BTLLCPurpose and (type2__c =: opp.Offer_letter_panel_non_panel__c or type2__c = null) and active__c = true]); 
			
			//System.debug('BTLLC Clauses : '+itemsBTLLC.size());
			//integer i=1/0;
			
			/* Start - BTLLC Rent Only */
			if(Opp.IBB_Product_Code__c.equalsIgnoreCase('BRO'))
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='BTLLC Rent Only' and active__c = true]);
			/* End - BTLLC Rent Only */    
		}
		else /* C0644 End*/
		{
			List<Standard_Clause__c> items1= [select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c =: Opp.Purpose_of_finance__c and type2__c = null ];
			items.addAll(items1);
        
			/* C0??? start */
			if (opp.Fee_Assisted__c == 'Y' )
			{
			
			 List<Standard_Clause__c> items3= [select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c = 'Refinancing Fee Assisted' and (type2__c =: opp.Offer_letter_panel_non_panel__c or type2__c = null) and active__c = true]; // C0???
				items.addAll(items3);
			/* C0??? end */
			}
			else
			{
			List<Standard_Clause__c> items2= [select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c =: Opp.Purpose_of_finance__c and type2__c =: opp.Offer_letter_panel_non_panel__c  ]; // C0???
			items.addAll(items2);
			}

		
        
			if(Opp.IBB_Product__r.IBB_Product_Set__r.name == 'Home Purchase Plan')
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='HPP' and active__c = true]);
            
			/* Start - Extra condition for adding clauses */    
			if(Opp.IBB_Product__r.IBB_Product_Set__r.name.equalsIgnoreCase('Buy to Let Purchase Plan') && Opp.Purpose_of_finance__c.equalsIgnoreCase('Refinancing'))
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='BTL Refinance' and active__c = true]);
			/* End - Extra condition for adding clauses*/    

			  /* C00252 start */
			  if(Opp.Staff_HPP__c == 'Yes')
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='Staff' and active__c = true]);         
			  /* C00252 end */ 
          
			   /* C00252 start */
			  if(Opp.Staff_HPP__c == 'No')
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='Non Staff' and active__c = true]);         
			  /* C00252 end */  

			  /* C0??? start *
			  if(Opp.Fee_assisted__c == 'Yes')
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='Refinancing Fee Assist' and active__c = true]);  
		  
			  //if(Opp.Fee_assisted__c == 'No')
				//items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='Refinancing Fee Assist' and active__c = true]);    
			  * C0??? end */
            
				 if(Opp.IBB_Product__r.IBB_Product_Set__r.name == 'Help to Buy Home Purchase Plan')
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='HPP' and active__c = true]);
            
				if(Opp.IBB_Product__r.IBB_Product_Set__r.name == 'Home Purchase Plan Premier')
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='HPP' and active__c = true]);
            
				if(Opp.IBB_Product__r.IBB_Product_Set__r.name == 'Home Purchase Plan Premier')
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='HPPP' and active__c = true]);
            
            
			if(Opp.IBB_Product__r.IBB_Product_Set__r.name == 'Buy to Let Purchase Plan')
				items.addAll([select id,Standard_Clause__c,Clause_section__c, name from Standard_Clause__c where Type__c ='BTL' and active__c = true]);
       
        
			if(Opp.Is_there_a_guarantor__c)
				items.addAll([select id,Standard_Clause__c, name,Clause_section__c from Standard_Clause__c where Type__c ='Guarantor' and active__c = true]);        
        
        
			system.debug('Letter value:' +Opp.IBB_Product__r.Warning_Clause_Offer_Letter__c);
        
			if(Opp.IBB_Product__r.Warning_Clause_Offer_Letter__c != null)
				 items.addAll([select id,Standard_Clause__c, name, Clause_section__c from Standard_Clause__c where id=:Opp.IBB_Product__r.Warning_Clause_Offer_Letter__c and active__c = true]);      

		}
    
                        
        
        List<Clause_Item__c> clauses = new List<Clause_Item__c>();
        for(Standard_Clause__c item : items)
        {
            clauses.add(CreateItem(item));            
        }
        insert clauses;
        //}
        //catch(Exception ex)
        //{
            //system.debug('FATAL: ' + ex.getMessage());
        //}
    }
    
    public Clause_Item__c CreateItem(Standard_Clause__c item )
    {
        Clause_Item__c clause = new Clause_Item__c();
        clause.opportunity__c = opp.id;
        clause.Clause_section__c = item.Clause_section__c;
        
        
        clause.Clause_HTML__c = item.Standard_Clause__c;
        
        // Pre-Merge Merges...
		
		if(Opp.Full_name_of_guarantor__c!= null)
        clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[Full_name_of_guarantor__c]', Opp.Full_name_of_guarantor__c);
        
        if(Opp.Guarantor_property__c != null)
        clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[Guarantor_property__c]', Opp.Guarantor_property__c);
        
		/* C0??? start */
		if(Opp.Fee_Assisted__c=='Y')
		{
			// Opportunity fields
			if(Opp.Cashback_Eligibility__c!= null)
			clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[Cashback_Eligibility__c]', string.valueOf(Opp.Cashback_Eligibility__c));
			
			if(Opp.Discounted_product_expiry_date__c!= null)
			{
				clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[Discounted_product_expiry_date__c]', Opp.Discounted_product_expiry_date__c.format());
			}
			else
			{
				clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[Discounted_product_expiry_date__c]', '');
			}
			
			
			if(Opp.Offer_letter_discount_end_date__c!= null)
			{
				clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[Offer_letter_discount_end_date__c]', string.valueOf(Opp.Offer_letter_discount_end_date__c));
			}
			else
			{
				clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[Offer_letter_discount_end_date__c]', '');
			}
			
			if(Opp.Account_Number__c!= null)
			clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[Account_Number__c]', string.valueOf(Opp.Account_Number__c));
			if(Opp.Sort_Code__c!= null)
			clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[Sort_Code__c]', string.valueOf(Opp.Sort_Code__c));

			// Extended Opportunity fields
			if(ExOpp.AdminFeeValue__c!= null)
			{
				clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[ExOpp.AdminFeeValue__c]', string.valueOf(ExOpp.AdminFeeValue__c));
			}
			else
			{
				clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[ExOpp.AdminFeeValue__c]', '0.00');
			}
			
			if(ExOpp.Al_Rayan_Valuation_Contribution__c!= null)
			clause.Clause_HTML__c = clause.Clause_HTML__c.replace('[ExOpp.Al_Rayan_Valuation_Contribution__c]', string.valueOf(ExOpp.Al_Rayan_Valuation_Contribution__c));
			
		} 
		/* C0??? end */
        return clause;
    }
}