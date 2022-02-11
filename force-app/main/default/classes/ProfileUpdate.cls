@RestResource(urlMapping='/ProfileUpdate/*')
global with sharing class ProfileUpdate {

    @HttpPost
    global static String updateProfile(String  profileId, String userId,String roleId) {
        system.debug('****'+profileId);
        if(roleID != 'null' && !string.isBlank(roleID)){
            try{
                update new User(Id=userId,userRoleId = roleID);
                return 'Role Updated Successfully';
            }catch(exception e){
                return 'Error while updating role, Please contact system administrator: '+e.getMessage();
            }
        }else{
            try{
                update new User(Id=userId,ProfileId = profileId);
                return 'Profile Updated Successfully';
            }catch(exception e){
                return 'Error while updating profile, Please contact system administrator: '+e.getMessage();
            }
        }
           
        
      }

}