global class HPPPostCompletionActionController
{
    public List<ActionItem> Items {get;set;}
    public List<ActionItem> ItemsClosed {get;set;}
    public List<ActionItem> ItemsCompleted {get;set;}    
    public Boolean ExistingProductSwitch {get;set;}        
    public ID ParentOpportunityId {get;set;}    
    
    public Account_With_IBB__c AccWithIBB{get;set;}
    public IBB_Product__c CurrentProduct{get;set;}
    public IBB_Product__c Prod{get;set;}
    public IBB_Product_set__c ProdSet{get;set;}
    public List<Opportunity> ExistingOpps{get;set;}
    //public decimal MarketValue{get;set;}
    public Boolean AllowStart {get;set;}
    public Opportunity MasterOpp {get;set;}
    
    @RemoteAction
    public static SwitchData GetData(ID oppId)
    {
        SwitchData response = new SwitchData();    
        if(oppId == null) return null;  
        
        Opportunity MasterOpp = [SELECT Purchase_price_market_value__c, ibb_product__c, ibb_product__r.name, account_with_ibb__c,
                                    ibb_product__r.ibb_product_set__r.ProductSetType__c, ibb_product__r.expiry_date_of_fixed_product__c
                            FROM Opportunity
                            WHERE id=:oppId];
                            
        response.IsBTL = MasterOpp.ibb_product__r.ibb_product_set__r.ProductSetType__c.equalsIgnoreCase('BTL');    
        Date d = MasterOpp.ibb_product__r.expiry_date_of_fixed_product__c; 
        if(d != null)   
        {                            
            response.ExpiryDate = d.format();
            response.SuggestedSwitchDate = d.addDays(1) > system.today() ? d.addDays(1).format() : date.today().format();
            response.DaysTillExpiry = date.today().daysBetween(d);
        }
        else
        {
            response.SuggestedSwitchDate =  date.today().format();
        }
        
        
  
                            
        response.ProductName = MasterOpp.ibb_product__r.name;
        response.PropertyValue = string.valueOf(MasterOpp.Purchase_price_market_value__c);
        response.NewMarketValue = string.valueof(MasterOpp.Purchase_price_market_value__c);
        
        List<account_with_ibb__c > lstAcc= [select id, name,Available_Balance__c ,Monthly_Repayment__c from account_with_ibb__c where id=:MasterOpp.account_with_ibb__c];
        
        
        //Load the post completion records
        List<Post_Completion__c> postItems = [SELECT id, name, status__c, Action__c, Application_Opportunity__c, Application_Opportunity__r.name 
                                                FROM Post_Completion__c
                                                WHERE Master_Opportunity__c =:oppId];
        
        for(Post_Completion__c postItem : postItems)
        {
            ActionItem actionItem = new ActionItem();
            actionItem.Name = postItem.Name;
            actionItem.Status = postItem.Status__c;
            actionItem.Action = postItem.Action__c;
            actionItem.ID = postItem.ID;
            actionItem.OppId = postItem.Application_Opportunity__c;
            actionItem.OpportunityName = postItem.Application_Opportunity__r.name;        
        
            if(postItem.Action__c.equalsIgnoreCase('Product Switch') && postItem.status__c.equalsIgnoreCase('Open'))
            {
                response.OpenItems.add(actionItem);
            }
            
            if(postItem.Action__c.equalsIgnoreCase('Product Switch') && postItem.status__c.equalsIgnoreCase('Closed'))
            {
                response.ClosedItems.add(actionItem);
            }  
            
            if(postItem.Action__c.equalsIgnoreCase('Product Switch') && postItem.status__c.equalsIgnoreCase('Completed'))
            {
                response.CompletedItems.add(actionItem);
            }   
        } 
        
        if(lstAcc.size() > 0 && response.OpenItems.size() ==0)
        {
            response.Balance = lstAcc[0].Available_Balance__c;
            response.Account = lstAcc[0].name.substring(0,4) + '-' + lstAcc[0].name.substring(4,10) + '-' + lstAcc[0].name.substring(10,13);
            
            try
            {
                //Get new property value
                Teller_Integration_EBS.FTVRequest request = new Teller_Integration_EBS.FTVRequest();
                Teller_Integration_Data.FTVResponse ftvData = request.GetFTVData(lstAcc[0].name);
                
                system.debug(ftvData.Data);
                
                response.FTV = ftvData.Data.iFTV;
                response.FTVValue = ftvData.Data.iCurrentValue;
                response.NewMarketValue =  ftvData.Data.iCurrentValue;            
                response.CurrentRepayment = ftvData.Data.CurrentRepayment;
                
                if(string.isNotBlank(ftvData.Data.RemainingTerm))
                {
                    integer remainingMonths = integer.valueOf(ftvData.Data.RemainingTerm);
                    
                    integer years = remainingMonths / 12;
                    integer months = remainingMonths -  (years * 12);           
                    
                    response.RemainingTerm = years + ' years, ' + months + ' months';
                }
            }
            catch(Exception ex)
            {
            }
        }        
        
        return response;        
        
        /*    
        ProdSet = [select id, name,Product_Switch_Director__c from ibb_product_set__c where id=: CurrentProduct.IBB_Product_set__c];      
        */     
    }
    
    public PageReference ProductSwitch()
    {
        return null;
    }
    
    
    @RemoteAction
    public static String StartSwitch(ID oppId,Decimal value, String requiresAdvice, String sDate)
    {
        //return string.valueof(value) + '::' + oppId;
        //Update market value
        Trigger_Helper.TriggerItem accItem = new Trigger_Helper.TriggerItem();
        accItem.Name = 'Opportunity';
        accItem.IgnoreTrigger =true ;        
        Trigger_Helper.Items.add(accItem);
        
        Trigger_Helper.TriggerItem oItem = new Trigger_Helper.TriggerItem();
        oItem .Name = 'HPP_extended_opportunity__c';
        oItem .IgnoreTrigger =true ;        
        Trigger_Helper.Items.add(oItem );
        
        
    
        //Clone opportunity and extended opp        
        Opportunity opp = DataHelper.GetOpportunity(oppId)[0];        
        HPP_extended_opportunity__c exOpp = DataHelper.GetHPPExtendedOpportunityByOpp(oppId)[0];        
        
        ibb_product_set__c ProdSet = [select id, name,Product_Switch_Director__c, Product_Switch_Advice_Director__c from ibb_product_set__c where 
                                        id in (select ibb_product_set__c from ibb_product__c where id =:opp.ibb_product__c)];      
        
        List<account_with_ibb__c > lstAcc= [select id, name,Available_Balance__c ,Monthly_Repayment__c from account_with_ibb__c where id=:opp.account_with_ibb__c];
        if(lstAcc.size() == 0) return null;
        
        Post_Completion__c postAction = new Post_Completion__c();
        postAction.Master_Opportunity__c = opp.id;
        
        opp.Switched_From_Opp__c = opp.id;
        opp.id = null;
        opp.closeDate = date.today();
        opp.ProductEventDirector__c = requiresAdvice == 'Yes' ? ProdSet.Product_Switch_Advice_Director__c : ProdSet.Product_Switch_Director__c;
        opp.STagename = 'New';        
        opp.Finance_required__c = lstAcc[0].Available_Balance__c *-1;
        opp.Name =  Opp.name + ' Product Switch';
        opp.Account_with_ibb__c = null;
        opp.Product_Switch_Date__c = date.today();
        opp.IBBQuotation__c = null;
        opp.IBB_Product__c = null;
        opp.Purchase_price_market_value__c = value;
        opp.Attachment_Offer_Letter__c = null;
        opp.Attachment_Welcome_Letter__c = null;  
        opp.ownerid = UserInfo.getUserId();
        
                
        exOpp.id = null;
        exOpp.Admin_Fee_AJE__c = null;
        exOpp.AdminFeeReceived__c = null;
        exOpp.AdminFeeValue__c = null;
        //exOpp.ownerid = UserInfo.getUserId();
        
        REcordType rt = [select id from recordtype where developername = 'ProductSwitching' and SobjectType='Opportunity' ];
        opp.recordtypeid = rt.id;
        
        Trigger_Helper.TriggerItem itemOpp = new Trigger_Helper.TriggerItem();
        itemOpp.Name = 'Opportunity';
        itemOpp.IgnoreAudit = true;
        itemOpp.IgnoreTrigger = true;
        Trigger_Helper.Items.add(itemOpp);
        
        insert opp;
        exOpp.Opportunity__c = opp.id;
        insert exOpp;
        
        postAction.Application_Opportunity__c = opp.id;
        postAction.Status__c = 'Open';
        postAction.Action__c = 'Product Switch';
        insert postAction;
         
        
        
        //clone applicants
        List<Applicant__c> applicants = DataHelper.GetApplicants(oppId);
        
        for(Applicant__c app : applicants)
        {
            app.id = null;
            app.opportunity__c = opp.id;
            //app.ownerid = UserInfo.getUserId();
        }
        insert applicants;
        
       
        //Create new flow
         IBBEvents ibbEvent = new IBBEvents(opp.ProductEventDirector__c);
          ibbEvent.CreateFirstEvent(opp.id);        
          
          EventLog__c ev= ibbEvent.GetCreatedEvent();
          
          
                 
          if(ibbEvent .GetCreatedEventLocation() != null)
          {
              String url = ibbEvent .GetCreatedEventLocation() + '?id=' +ev.id;
              system.debug('URL: '+ url );
              return url;
          }
          else
          {
              return '/apex/HPPBOEvent?id=' + ev.id;
          }       
    
        return 'new url';
          //return new PageReference( 'www.google.co.uk');
    }    
   

 
    global class SwitchData
    {
        public String ProductName {get;set;}
        public Decimal Balance {get;set;}
        public String PropertyValue {get;set;}
        public String Account {get;set;}
        public String  FTVValue {get;set;}
        public String FTV {get;set;}
        public String NewMarketValue {get;set;}
        public Boolean IsBTL {get;set;}
        public String ExpiryDate {get;set;}
        public String SuggestedSwitchDate {get;set;}
        public Decimal DaysTillExpiry{get;set;}
        public String CurrentRepayment{get;set;}
        public String RemainingTerm {get;set;}
    
        public List<ActionItem> OpenItems {get;set;}
        public List<ActionItem> ClosedItems {get;set;}
        public List<ActionItem> CompletedItems {get;set;}
        
        public SwitchData()
        {
            OpenItems = new List<ActionItem>();
            ClosedItems = new List<ActionItem>();
            CompletedItems = new List<ActionItem>();
        }
    }
    
    public class ActionItem
    {
        public String Name {get;set;}
        public String Status {get;set;}
        public String ID {get;set;}
        public String OppId {get;set;}
        public String OpportunityId {get;set;}
        public String OpportunityName {get;set;}
        public String Action {get;set;}
        public String Type {get;set;}
    }
}