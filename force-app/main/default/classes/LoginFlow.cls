public class LoginFlow{
    public string selectedProfile{get;set;}
    public string selectedRole{get;set;}
    public Login_Profile_Update__c userProfile;
    public map<string,string> proidToName;
    public map<string,string> roleidToName;
    public map<string,string> proNameToId;
    public Login_Profile_Update__c orgDefault;
    public string currentLoggedInProfile{get;set;}
    public string currentLoggedInRole{get;set;}
    public List<SelectOption> profilesToSelect{get;set;}
    public List<SelectOption> rolesToSelect{get;set;}
    public string currentRole{get;set;}
            
        
    public pagereference updateProfile(){
        system.debug('Selected Profile:'+selectedProfile);
        string respons = updateProfileFuture('005D0000006gRUM',selectedProfile,null);
        system.debug('****'+respons );
        apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,respons));
        if(respons != null && !respons.containsIgnoreCase('Error')){
            currentLoggedInProfile =  proidToName.get(selectedProfile);   
        }
        return null;
       
    }
    public pagereference updateRole(){
        system.debug('Selected Role:'+selectedRole);
        string respons = updateProfileFuture('005D0000006gRUM',null,selectedRole);
        system.debug('****'+respons );
        if(respons != null && !respons.containsIgnoreCase('Error')){
            currentLoggedInRole =  roleidToName.get(selectedRole);   
        }
        apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,respons));
        return null;
       
    }
    @auraEnabled
    public static string updateProfile1(string selectedProfile,string selectedRole){
    
        string respons= updateProfileFuture('005D0000006gRUM',selectedProfile,selectedRole);
        
        return respons;
    }
    
    public pageReference onLoadCheck(){
    
        profilesToSelect = new List<SelectOption>();
        rolesToSelect = new List<SelectOption>();
        orgDefault = Login_Profile_Update__c.getOrgDefaults();
        userProfile = Login_Profile_Update__c.getInstance(UserInfo.getUserId()).Available_Profile__c!= null || Login_Profile_Update__c.getInstance(UserInfo.getUserId()).Available_Roles__c!= null?Login_Profile_Update__c.getInstance(UserInfo.getUserId()):null;
        proidToName = new map<string,string>();
        proNameToId = new map<string,string>();
        roleidToName = new map<string,string>();
        map<string,profile> profileIdToProfile = new map<string,profile>();
       
        pageReference pref = Auth.SessionManagement.finishLoginFlow('/home/home.jsp');
        pref.setRedirect(true);
        if(userProfile  != null){
        
            set<string> profileName = new set<String>();
            set<string> roleName = new set<String>();
            
            if(userProfile.Available_Profile__c != null && userProfile.Available_Profile__c.split(',')!= null)
                profileName.addAll(userProfile.Available_Profile__c.split(','));            
            
          
            if(userProfile.Available_Roles__c != null && userProfile.Available_Roles__c.split(',')!= null)
                roleName.addAll(userProfile.Available_Roles__c.split(','));
            
            for(Profile pro:[SELECT Id,Name,UserLicenseId FROM Profile WHERE name IN:profileName OR id=:userInfo.getProfileId() ORDER BY Name ASC]){
                proidToName.put(pro.id,pro.name);
                proNameToId.put(pro.name,pro.id);                
                profileIdToProfile.put(pro.id,pro);
                if(userInfo.getProfileId() != pro.id){
                    //proList.add(pro);
                    profilesToSelect.add(new selectoption(pro.id,pro.name));
                }
            }  
            for(UserRole role:[SELECT Id,Name FROM UserRole WHERE name IN:roleName OR id=:userInfo.getUserRoleId() ORDER BY Name ASC]){
                if(userInfo.getUserRoleId() != role.id){    
                    //roleList.add(role);
                    rolesToSelect.add(new selectoption(role.id,role.name));
                }else{
                    currentRole = role.name;
                }
                roleidToName.put(role.id,role.name);
            }
            
            currentLoggedInProfile = proidToName.get(userInfo.getProfileId());
            time nowTime = system.now().time(); 
            return null;
            
        }else{
            return pref;        
        }
       
        
    }
    @auraEnabled
    public static wrapperClass onLoadCheck1(){
    
        //profilesToSelect = new List<SelectOption>();
        Login_Profile_Update__c orgDefault = Login_Profile_Update__c.getOrgDefaults();
        Login_Profile_Update__c userProfile = Login_Profile_Update__c.getInstance(UserInfo.getUserId()).Available_Profile__c!= null || Login_Profile_Update__c.getInstance(UserInfo.getUserId()).Available_Roles__c!= null?Login_Profile_Update__c.getInstance(UserInfo.getUserId()):null;
        map<string,string> proidToName = new map<string,string>();
        
        map<string,string> proNameToId = new map<string,string>();
        map<string,profile> profileIdToProfile = new map<string,profile>();
        List<profile> proList= new list<profile>();
        List<UserRole> roleList= new list<UserRole >();
        string currentLoggedInProfile;
        string currentRole;
        
        if(userProfile  != null){
        
            set<string> profileName = new set<String>();
            set<string> roleName= new set<String>();
             
            if(userProfile.Available_Profile__c != null && userProfile.Available_Profile__c.split(',')!= null)
                profileName.addAll(userProfile.Available_Profile__c.split(','));
                
            if(userProfile.Available_Roles__c != null && userProfile.Available_Roles__c.split(',')!= null)
                roleName.addAll(userProfile.Available_Roles__c.split(','));
            
            for(Profile pro:[SELECT Id,Name,UserLicenseId FROM Profile WHERE name IN:profileName OR id=:userInfo.getProfileId() ORDER BY Name ASC]){
                proidToName.put(pro.id,pro.name);
                proNameToId.put(pro.name,pro.id);                
                profileIdToProfile.put(pro.id,pro);
                if(userInfo.getProfileId() != pro.id)
                    proList.add(pro);
            }  
            for(UserRole role:[SELECT Id,Name FROM UserRole WHERE name IN:roleName OR id=:userInfo.getUserRoleId() ORDER BY Name ASC]){
                if(userInfo.getUserRoleId() != role.id)    
                    roleList.add(role);
                else
                    currentRole = role.name;
            }
            currentLoggedInProfile = proidToName.get(userInfo.getProfileId());
            system.debug('***RoleList:'+roleList+'**Role Names:'+roleName);
         
            /*if(userProfile.Time_for_reference__c != null &&  userProfile.Time_for_reference__c.time() > nowTime){
                if(proidToName.containsKey(userInfo.getProfileId()) && userProfile.First_Half_Profile__c.containsIgnoreCase(proidToName.get(userInfo.getProfileId()))){
                    return null;       
                }else{
                    for(string proName:userProfile.First_Half_Profile__c.split(',')){
                        if(proNameToId.containsKey(proName)){
                            //profilesToSelect.add(new SelectOption(proNameToId.get(proName),proName));
                            proList.add(profileIdToProfile.get(proNameToId.get(proName)));
                        }
                    }
                    wrapperClass returnWrapper =  new wrapperClass(proList,currentLoggedInProfile);
                    system.debug('Return:'+returnWrapper);
                    return returnWrapper;
                }                    
            }else if(userProfile.Time_for_reference__c != null &&  userProfile.Time_for_reference__c.time() < nowTime){
                if(proidToName.containsKey(userInfo.getProfileId()) && userProfile.Second_Half_Profile__c.containsIgnoreCase(proidToName.get(userInfo.getProfileId()))){
                    return null;      
                }else{
                    for(string proName:userProfile.Second_Half_Profile__c.split(',')){
                        if(proNameToId.containsKey(proName)){
                            //profilesToSelect.add(new SelectOption(proNameToId.get(proName),proName));
                             proList.add(profileIdToProfile.get(proNameToId.get(proName)));
                        }
                    }
                    wrapperClass returnWrapper =  new wrapperClass(proList,currentLoggedInProfile);
                    system.debug('Return:'+returnWrapper);
                    return returnWrapper;
                }                    
            }else{
                return null;               
            }*/
            wrapperClass returnWrapper =  new wrapperClass(proList,currentLoggedInProfile,roleList,currentRole );
            return returnWrapper ;
        }else{
            return null;        
        }
       
        
    }
    
  
    public static  string updateProfileFuture(string userID,string profileID,string roleID){
         Login_Profile_Update__c orgDefault = Login_Profile_Update__c.getOrgDefaults();
        system.debug('Selected PRofile:'+profileID);
        String remoteURL = orgDefault.End_Point_Url_Only_Admin__c; //'https://alrayanbank--preprodtes.my.salesforce.com/services/apexrest/ProfileUpdate';
        
        HTTPRequest httpRequest = new HTTPRequest();
        string accToken = getRequestToken();
        httpRequest.setHeader('Authorization', 'Bearer ' + accToken);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setBody('{"userId":"'+userId+'","roleId":"'+roleID+'","profileId":"'+profileID+'"}');
        httpRequest.setEndpoint(remoteURL);
        httpRequest.setMethod('POST');
        HTTPResponse httpResponse = new Http().send(httpRequest);
        system.debug('**Resposne**'+httpResponse.getbody() );
        return httpResponse.getbody();
        
    }   
    
     public static string getRequestToken() {
         Login_Profile_Update__c orgDefault = Login_Profile_Update__c.getOrgDefaults();
        string cKey = orgDefault.Client_Id_Only_Admin__c; //'3MVG91LYYD8O4krTpWpEsDzM7mthhjDpbF_CY8_lJdoSYKTDj_677CMCzKMfLiYmKYtnqtW7vmj7bUSSgLfQg';
        string cSecret = orgDefault.Client_Secret_Only_Admin__c; //'C0F6A279A45B7FCF41D135A89B71DBC647596233B935CCDE38D3DB35B7C00086';
        string uName = orgDefault.Username_only_admin__c; //'mohammed.raiyan1@zensar.com.preprodtes';
        string passwd = orgDefault.Password_Only_Admin__c; //'alraiyan4coKcB2iP1USmT1QZNHtpP0Tzs';
        string reqBody = 'grant_type=password&client_id=' + cKey + '&client_secret=' + cSecret + '&username=' + uName + '&password=' + passwd;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqBody);
        req.setMethod('POST');
        req.setEndpoint('https://alrayanbank--preprodtes.my.salesforce.com/services/oauth2/token');
        system.debug('Request:'+req);
        HttpResponse hresp = h.send(req);
        system.debug('Resposne:'+hresp );
        responseWrapper wResp = (responseWrapper) JSON.deserialize(hresp.getBody(), responseWrapper.class);
        system.debug('Instance url' + wResp.instance_url);
        system.debug('session id' + wResp.access_token);
        return wResp.access_token;
    }  
    
    public pagereference Cancel(){
    
                
        pageReference pref = Auth.SessionManagement.finishLoginFlow('/home/home.jsp');
        pref.setRedirect(true);
        return pref;
    }
    
     public class responseWrapper {
        public string id;
        public string access_token;
        public string instance_url;
    } 
    
    public class wrapperClass{
        @AuraEnabled public string currentProfile{get;set;}
        @AuraEnabled public string currentRole{get;set;}
        @AuraEnabled public list<profile> profileList{get;set;}
        @AuraEnabled public list<UserRole> roleList{get;set;}
        public wrapperClass(list<profile> proList,string proName,list<UserRole> lRole,string cRole){
            currentProfile = proName;
            profileList = proList;
            roleList = lRole;
            currentRole = cRole;
        }
        
    }     
        
}