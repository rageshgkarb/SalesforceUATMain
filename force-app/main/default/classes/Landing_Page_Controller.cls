//C0685
public class Landing_Page_Controller  
{
	public String selectedoption{get;set;}
	public String SelectedCampaignName {get; set;}
	public List<SelectOption> CampList = new List<SelectOption>();

	public Landing_Page_Controller()
	{
	
	}
	
	public List<SelectOption> getCampaignName()
	{
		 List<Campaign> Campaigns = [SELECT name  FROM campaign where type = 'Events' and isactive = true];
		 if (Campaigns.size() > 0)
		 {
			 for (campaign camp:Campaigns)
			 {
				CampList.add(new selectoption(Camp.name, Camp.name));
			 }
		 }
		 return CampList;
	}

	public PageReference display()
	{
        pagereference datacollectionform = new pagereference('/apex/data_collection_form?att='+ selectedoption);
		datacollectionform.setRedirect(true);
		return datacollectionform;
    }


}