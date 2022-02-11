/* C0635 Removed common functions to BaseEventController class */
public virtual class MMRBaseEventController extends BaseEventController {
    private static aLog.Logger Log = new aLog.Logger('MMRBaseEventController');

    public Boolean ProductSwitch
    {
        get {
            return bopp.recordtype.developername.equalsIgnoreCase('ProductSwitching');
        }
    }

    public Boolean IsPremier
    {
        get
        {
            return ProdSet.name.equalsignorecase('Home Purchase Plan Premier');
        }
    }

    public Boolean IsHelpToBuy
    {
        get
        {
            return ProdSet.name.equalsignorecase('Help to Buy Home Purchase Plan');
        }
    }

    public Boolean IsHelpToBuyInterested
    {
        get
        {
            return bOpp.interested_in__c.equalsignorecase('Help to Buy Home Purchase Plan');
        }
    }

    public Opportunity bopp
    {
        get{
            return BaseOpportunity;
        }
        set{
            BaseOpportunity = value;
        }
    }

    public List<String> ApplicantIds { get; set; }

    public MMRBaseEventController()
    {
        //If an eventid is passed, get the opportunity from the event.  Otherwise look for the opportunity id in the querystring
        //String opportunityId;

        Accounts = new List<Account>();
        if (eventId == null)
        {
            if (oppId == null)
            return;
            opportunityId = oppId;
        }
        else
        {
            LoadEvent();
            if (EventLog == null)
            return;

            opportunityId = EventLog.Opportunity__c;
        }

        Log.debug('OPP id : ' + opportunityId);

        //C0785: HPP - Automatic Valuation Model --- included FTV__c field to query
        //Case: 01938975; Customer overseas credit policy;Start; Added Ex_Pat__c
        bopp = [select id, name,Ex_Pat__c,  IBB_Product__c,Is_Joint_Application__c, interested_in__c, ProductEventDirector__c, finance_required__c, Purchase_price_market_value__c, term_of_finance__c, account.name, Status_HPP_CAA__c, BDM_Lead_Provider__r.name, SellerName__c,Outstanding_Finance_Amount__c, REAC_Amount__c,FTV__c //C0782 included for REAC
                from opportunity
                where id = :opportunityId]; // DataHelper.GetOpportunity(opportunityId)[0];
                
        director = new IBBEvents(bopp.ProductEventDirector__c);
        oDirector = DataHelper.GetDirector(bopp.ProductEventDirector__c) [0];
        //Load product     
        system.debug('load product : ' + bopp.IBB_Product__c);
        if (bopp.IBB_Product__c != null)
        {
            prod = DataHelper.GetProduct(bopp.IBB_Product__c) [0];
        }
        prodSet = [select Conga_Welcome_Letter__c, Execution_only_letter__c, Max_No_of_Applicants__c, ProductSetType__c, IDD_Document__c, name, Conga_Application_Form__c, Conga_AIP_Letter__c, Product_recommendation_rejected_letter__c, Product_recommendation_letter__c from IBB_Product_Set__c where name = :bopp.interested_in__c limit 1];

        lstAccountIds = new List<String> ();
        List<Applicant__c> apps = [select Prospect_Customer__r.id from Applicant__c where Opportunity__r.id = :opportunityId order by Applicant_Number__c];
        for (Applicant__c app : apps)
        {
            lstAccountIds.add(app.Prospect_Customer__r.id);
        }



        /*
          for(Integer i = 0; i< Applicants.Size();i++)
          {       
          Account applicant = DataHelper.GetAccount(Applicants [i].Prospect_Customer__c)[0];
          Applicants[i].Prospect_Customer__r = applicant;
          Accounts.add(applicant);

          }
         */
        NumApplying = lstAccountIds.size();
        CurApp = 1;
    }

    public Integer NumApplying { get; set; }

}