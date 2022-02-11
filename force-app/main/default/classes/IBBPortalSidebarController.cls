/**********************************************************************
 Purpose:
 --------
 Controller for the IBB Portal Sidebar page
  Used to identify Suspicious Activity by Partner Users in the Portal
  Tactical step until proper solution is put in place
 
 History
 ------- 
 VERSION AUTHOR DATE Description
 1.0 - 24/11/2014   Aidan Hosty    Initial Development

 ***********************************************************************/
 public without sharing class IBBPortalSidebarController 
{
	Set<String> trustedUrls = null;
	Set<String> unTrustedUrls = null;
	
	private User user = null;
	public IBBPortalSidebarController()
	{
		
	}
	
	public String getParameters()
	{
		return ''+ApexPages.currentPage().getParameters();
	}
	
	public String getIFrameOrigin()
	{
		return ApexPages.currentPage().getParameters().get('sdfcIFrameOrigin');
	}
	
	public Boolean getIsSuspiciousActivity()
	{
		String iframeOrigin = getIFrameOrigin().toLowerCase();
		
		// Test if url looks like a direct record url/ id
		if (urlStartsWithFullRecId(iframeOrigin))
		{
			return true;
		}
		
		Set<String> validUrlContents = getTrustedUrls();
		// validUrlContents.add('home'); // Home Page
		// validUrlContents.add('apex'); // VF Pages
		
		Set<String> violationUrlContents = getUnTrustedUrls();
		
		// Could Loop through all metadata and add url prefixes? Dangerous?
		// e.g. .com/prefix/ - these are views and edits 
		// violationUrlContents.add('/006/o');
		// violationUrlContents.add('/006/e');
		// violationUrlContents.add('/006/');
		
		for (String s:validUrlContents)
		{
			if (iframeOrigin.indexOfIgnoreCase(s) != -1)
			{
				return false;
			}
		}
		
		for (String s:violationUrlContents)
		{
			if (iframeOrigin.indexOfIgnoreCase(s) != -1)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public Boolean urlStartsWithFullRecId(String url)
	{
		System.debug('Testing URL '+url);
		// Strip up to .com/ part
		String idValue = '';
		Integer cIndex = url.indexOf('.com/');
		
		if (cIndex > 0)
		{
			idValue = url.subString(cIndex + 5);
			
			System.debug('Value after .com/ is '+idValue);
			
			Integer nextSlashIndex = idValue.indexOf('/');
			Integer questionIndex = idValue.indexOf('?');
			
			//Integer nextSub = Math.min(nextSlashIndex, questionIndex);
			
			System.debug('Next Slash is '+nextSlashIndex);
			System.debug('Next ? is '+questionIndex);
			
			if (nextSlashIndex == -1)
			{
				// There is no slash in the url
				// look for ?
				if (questionIndex == -1)
				{
					// we have neither - 
					// we just have an ID value - if it is 15 or 18 long it's an ID!
					if (idValue.length() == 15 || idValue.length() == 18)
					{
						return true;
					}
				}
				else
				{
					// if the index is 15 or 18 it's after an id value
					if (questionIndex == 15 || questionIndex == 18)
					{
						return true;
					}
				}
			}
			else
			{
				// We have a /
				if (questionIndex == -1)
				{
					// no ? 
					// if slash is at 16 or 19 we have an Id
					if (nextSlashIndex == 15 || nextSlashIndex == 18)
					{
						return true;
					}
				}
				else
				{
					// Need to figure which value is smaller
					Integer smallerVal = Math.min(questionIndex, nextSlashIndex);
					if (smallerVal == 15 || smallerVal == 18)
					{
						return true;
					}
				}
			}
		}
		
		return false;
	}
	
	public User getUser()
	{
		if (user == null)
		{
			user = [Select Id, Username, UserType, ProfileId, Profile.Name, IsPortalEnabled, ContactId From User where Id = : UserInfo.getUserId()];
		}
		
		return user;
	}
	
	public String getUserType()
	{
	 
		return getUser().UserType;
	}
	
	
	public Boolean getIsPartnerPortalUser()
	{
		return getUserType().equalsIgnoreCase('PowerPartner') && getUser().Profile.Name == 'External Flow & IFM Partner User';
	}
	
	
	public Boolean getSendNotificationEmail()
	{
		if (getIsSuspiciousActivity())
		{
			// sentNotificationEmail();
			return true;
		}
		
		return false;
	}
	
	/*
	public void sentNotificationEmail()
	{
		if (true)
		{
			// createITIncident();
			return;
		}
		String emailBody = 'An External user has attempted access to the following page \n'
             + getIFrameOrigin();
        
 		// Define the email
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        // Sets the paramaters of the email
        String subject = 'Partner Portal Access Violation';
        email.setSubject( subject );
        email.setToAddresses( new String[] {'ahosty@salesforce.com'} );
        email.setPlainTextBody( emailBody );
 
		// Send the email
        try{
        	Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        	if (!r[0].isSuccess())
        	{
        		System.debug('ERROR SENDING EMAIL - '+r[0].getErrors());
        	}
        	else
        	{
        		System.debug('SEND EMAIL SUCCESS');
        	}
        } catch (Exception e)
        {
        	System.debug('EXCEPTION SENDING EMAIL - '+e);
        }
        
        // return r;
	}*/
	
	public void createITIncident()
	{
		IT_Incident__c incident = new IT_Incident__c();
		incident.Affected_system__c = 'SF Partner Portal';
		incident.Details_of_incident__c = 'An External user has attempted access to the following page : '+ getIFrameOrigin();
		incident.Date_time_of_incident__c = System.now();
		// Select i.Resolution_actions_being_undertaken__c, i.Date_time_of_incident__c, i.Affected_system__c From IT_Incident__c i
		
		Database.SaveResult res = Database.insert(incident, false);
		
		if (!res.isSuccess())
		{
			System.debug('Error Creating Incident: '+res.getErrors());
		}
	}
	
	public Set<String> getTrustedUrls()
	{
		if (trustedUrls == null)
		{
			trustedUrls = new Set<String>();
			Map<String,Portal_Security_URLS__c> allURLS = Portal_Security_URLS__c.getAll();
			
			for (Portal_Security_URLS__c ps: allURLS.values())
			{
				if (ps.Trusted__c)
				{
					trustedUrls.add(ps.Name);
				}
			}	
		}
		  
		return trustedUrls;
	}
	
	public Set<String> getUnTrustedUrls()
	{
		if (unTrustedUrls == null)
		{
			unTrustedUrls = new Set<String>();
			Map<String,Portal_Security_URLS__c> allURLS = Portal_Security_URLS__c.getAll();
			
			for (Portal_Security_URLS__c ps: allURLS.values())
			{
				if (!ps.Trusted__c)
				{
					unTrustedUrls.add(ps.Name);
				}
			}	
		}
		  
		return unTrustedUrls;
	}
}