//C0685
public class Data_Collection_Form_Controller  {

	public String campaignname{get;set;}
	public Id attid{get;set;}
	public Id campaignid{get;set;}
	public Boolean hasImage {get;set;}

	public Data_Collection_Form_Controller()
	{
		campaignname = apexpages.currentpage().getparameters().get('att');

		Campaign camp = [select id from Campaign where name = :campaignname and type = 'Events' and IsActive= true limit 1];
		campaignid = camp.Id;

		List<Attachment> att = [select id from Attachment where ParentId = :campaignid limit 1];
		if (att.size()>0)
		{
			for(Attachment a: att)
			{
				attid = a.Id;
				hasImage = true;
			}
		}
		else
		{
			hasImage = false;
		}			
	}

	public PageReference display()
	{
        pagereference pricedrawform = new pagereference('/apex/price_draw_form?att='+ campaignname);
		pricedrawform.setRedirect(true);
		return pricedrawform;
    }

}