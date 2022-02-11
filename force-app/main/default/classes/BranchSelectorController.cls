public with sharing class BranchSelectorController extends CMSBaseController {
	
	public PageReference goToCMSApprovals(){
		PageReference cmsApprovals = Page.CMSApprovals;
		return cmsApprovals;
	}
	
}