public class Teller_Till_Helper implements IBB_Remoting.IGenericRemoting
{
    public IBB_Remoting.GenericResponseBase Call(String methodName, String data)
    {        
        if(methodName.equalsIgnoreCase('GetTillTransfersToday'))
        {
            system.debug('Length:' + data.length());
            //return GetTillTransfersToday(data);
            if(data.length() == 20)
                data = data.replace('"','');
            
            system.debug('sending:' + data);
            
            if(data == '')
                return GetAllTillTransfersToday();
            
            return  GetTillTransfersToday(data);
            //return new IBB_Remoting.GenericResponse(true,'',obj);            
        }
        if(methodName.equalsIgnoreCase('CancellTransferRefresh'))
        {
            Teller_Data.TillTransferCancelRequest clientData = (Teller_Data.TillTransferCancelRequest)
                                                                        JSON.Deserialize(data,Teller_Data.TillTransferCancelRequest.class);
            
            return  CancellTransferAndRefresh(clientData);
            //return new IBB_Remoting.GenericResponse(true,'',obj);            
        }
        if(methodName.equalsIgnoreCase('GetAllTillTransfersToday'))
        {
            return GetAllTillTransfersToday();
        }
        
       
        
        return new IBB_Remoting.GenericResponse(false,'Could not find method ' + methodName,null);
    }
    
    
    public static Teller_Data.TillTransferInfo CancellTransferAndRefresh(Teller_Data.TillTransferCancelRequest data)
    {
        List<Teller_Transaction__c> transfer = [select id from Teller_Transaction__c where id=:data.TransferId and TransferType__c = 'Storage Transfer' and Transfer_Status__c='created']; 
        
        if(transfer.size() != 1)
        {
            Teller_Data.TillTransferInfo returnValue = new Teller_Data.TillTransferInfo();
            returnValue.Success = false;
            
            return returnValue;
        }
        
        transfer[0].Transfer_Status__c = 'Cancelled';
        transfer[0].Cancelled_By__c = UserInfo.getUSerId();
        transfer[0].Cancelled_Date__C = datetime.now();
        update transfer;
        return GetTillTransfersToday(data.TillId);
    }
    
    public static Teller_Data.TillTransferInfo GetTillTransfersToday(ID till)
    {
        system.debug('GetTillTransfersToday Called');
        List<Teller_Transaction__c> transfers = [select Value__c, Transfer_Status__c,Declined_User__c,Declined_User__r.name,Approved_User__c,Approved_User__r.name,Approved_Date__c,Declined_Date__c,From_Storage__c, 
                                                    To_Storage__c,To_Storage__r.name,To_Storage__r.User_Logged_In__r.name,From_Storage__r.User_Logged_In__r.name, From_Storage__r.name, createdby.name,
                                                    To_Storage__r.Storage_Type__c, From_Storage__r.Storage_Type__c,Cancelled_By__r.name,Cancelled_Date__c
                                                    from Teller_Transaction__c
                                                    where TransferType__c = 'Storage Transfer' and (From_Storage__c =:till or To_Storage__c =:till) and createddate >= today
                                                    ];
                                                    
          return FormatTransfers(transfers);                                   
    }
    
    public static Teller_Data.TillTransferInfo GetAllTillTransfersToday()
    {
        //needs to have manager / till manager permission
    
        system.debug('GetTillTransfersToday Called');
        List<Teller_Transaction__c> transfers = [select Value__c, Transfer_Status__c,Declined_User__c,Declined_User__r.name,Approved_User__c,Approved_User__r.name,Approved_Date__c,Declined_Date__c,From_Storage__c, 
                                                    To_Storage__c,To_Storage__r.name,To_Storage__r.User_Logged_In__r.name,From_Storage__r.User_Logged_In__r.name, From_Storage__r.name, createdby.name,
                                                    To_Storage__r.Storage_Type__c, From_Storage__r.Storage_Type__c,Cancelled_By__r.name,Cancelled_Date__c
                                                    from Teller_Transaction__c
                                                    where TransferType__c = 'Storage Transfer' and createddate >= today
                                                    ];
                                                    
          return FormatTransfers(transfers);                                   
    }
    
    
    
    public static Teller_Data.TillTransferInfo FormatTransfers(List<Teller_Transaction__c> transfers)
    {
        Teller_Data.TillTransferInfo data = new Teller_Data.TillTransferInfo();
        data.Success = true;
        
        for(Teller_Transaction__c t : transfers)
        {
            Teller_Data.TillTransfers transfer = new Teller_Data.TillTransfers();
            transfer.TransferId = t.id;
            transfer.Status = t.Transfer_Status__c;
            
            system.debug('Storage type:' + t.From_Storage__r.Storage_Type__c);
            if(t.From_Storage__r.Storage_Type__c.equalsIgnorecase('vault'))
            {
                transfer.FromUserName = 'Vault';                
            }
            else
            {
                transfer.FromUserName = t.From_Storage__r.User_Logged_In__r.name;
            }
            
            if(t.To_Storage__r.Storage_Type__c.equalsIgnorecase('vault'))
            {
                transfer.ToUserName = 'Vault'; 
            }
            else
            {
                transfer.ToUserName = t.To_Storage__r.User_Logged_In__r.name;
            }
                       
            
            transfer.FromName = t.From_Storage__r.name;
            transfer.ToName= t.To_Storage__r.name;
            
            transfer.Value= t.Value__c;
            transfer.FromUser= t.createdby.name;
            transfer.FromId= t.From_Storage__c;
            transfer.ToId= t.To_Storage__c;            
            transfer.ApprovedByName= t.Approved_User__r.name;
            transfer.DeclineByName= t.Declined_User__r.name;
            transfer.CancelledByName= t.Cancelled_By__r.name;
            transfer.ApprovedDate= t.Approved_Date__c;
            transfer.DeclineDate= t.Declined_Date__c;
            transfer.CancelledDate = t.Cancelled_Date__c;
            
            
            
            
            if(t.Transfer_Status__c.equalsIgnoreCase('created'))
            {
                data.Active.add(transfer);
            } 
            if(t.Transfer_Status__c.equalsIgnoreCase('accepted'))
            {
                data.Accepted.add(transfer);
            }
            if(t.Transfer_Status__c.equalsIgnoreCase('declined') || t.Transfer_Status__c.equalsIgnoreCase('cancelled'))
            {
                data.Cancelled.add(transfer);
            }          
            
            
           
        }                                                           
        return data;
    }


    public static List<Teller_Data.TillData> GetOtherTillsInBranch(ID tillId)
    {
        Teller_Depository__c thisTill = [select id, branch__c from Teller_Depository__c where id=:tillId];        
                                                
        List<Teller_Depository__c> tills = [select name, Branch__r.id,cash__c,Storage_Type__c, User_Logged_In__c,User_Logged_In__r.name, status__C,User_Logged_In__r.SmallPhotoUrl,
                                                Num_Cheques__c, Cheques_Value__c
                                                 from Teller_Depository__c where branch__c =: thisTill.branch__c and id !=: tillId];
                
        List<Teller_Data.TillData> user_till_data = new list<Teller_Data.TillData>(); 
        
        for(Teller_Depository__c till : tills)
        {
            Teller_Data.TillData till_data = new Teller_Data.TillData();
            till_data.Name = till.name;
            till_data.Cash = till.cash__c;
            till_data.UserName = till.User_Logged_In__r.name;
            till_data.StorageType= till.Storage_Type__c;
            till_data.Id = till.id;
            user_till_data.add(till_data);        
        }           
        return user_till_data;  
    }

    public static Integer GetOpenTransfersToCount(Id tillId)
    {
        AggregateResult[] transfers = [select count(id)total from Teller_Transaction__c
                                                where To_Storage__c=:tillId];
        Integer count = integer.valueof(transfers[0].get('total'));   
        return count;                                            
    }

    public static Integer GetOpenTransfersFromCount(Id tillId)
    {
        AggregateResult[] transfers = [select count(id)total from Teller_Transaction__c
                                                where From_Storage__c=:tillId];
        Integer count = integer.valueof(transfers[0].get('total'));   
        return count;                                            
    }
    
    public static Teller_Data.GenericResponse Cancel(ID transferId)
    {
        List<Teller_Transaction__c> transfers = [select id from Teller_Transaction__c where id=:transferId];
                
        if(transfers.size() != 1)
            return new Teller_Data.GenericResponse(false,'Could not find transfer record');
            
        Teller_Transaction__c transfer = transfers[0];
 
        transfer.transfer_status__c = 'Cancelled';
        transfer.Declined_Date__c = datetime.now();
        transfer.Declined_User__c = UserInfo.getUserId();               
        update transfer;
        return new Teller_Data.GenericResponse(true,null);
    }
    
    public static Teller_Data.GenericResponse Approve(ID transferId)
    {
        List<Teller_Transaction__c> transfers = [select id from Teller_Transaction__c where id=:transferId];
                
        if(transfers.size() != 1)
            return new Teller_Data.GenericResponse(false,'Could not find transfer record');
            
        Teller_Transaction__c transfer = transfers[0];
 
        transfer.transfer_status__c = 'Complete';
        transfer.Approved_Date__c = datetime.now();
        transfer.Approved_User__c = UserInfo.getUserId();               
        update transfer;
        return new Teller_Data.GenericResponse(true,null);
    }
    
    public static Teller_Data.GenericResponse Approve(ID transferId,string username,String password)
    {
    
        Util_Authorize auth = new Util_Authorize('Accept Transfer');
        if(!auth.Authorize(username,password))
        {
            return new Teller_Data.GenericResponse(false,'Invalid username/password');
        }
            
        List<Teller_Transaction__c> transfers = [select id from Teller_Transaction__c where id=:transferId];
                
        if(transfers.size() != 1)
            return new Teller_Data.GenericResponse(false,'Could not find transfer record');
            
        Teller_Transaction__c transfer = transfers[0];
 
        transfer.transfer_status__c = 'Complete';
        transfer.Approved_Date__c = datetime.now();
        transfer.Approved_User__c = UserInfo.getUserId();               
        update transfer;
        return new Teller_Data.GenericResponse(true,null);
    }









    public class CreateTillTransfer
    {
        private Decimal m_Value{get;set;}
        private ID m_StorageFrom{get;set;}
        private ID m_StorageTo{get;set;}
        private Teller_Data.CreateTillTransfer m_Result{get;set;}
    
        public CreateTillTransfer(Decimal value, ID storageFrom, ID storageTo)
        {
            m_Value = value;
            m_StorageFrom = storageFrom;
            m_StorageTo = storageTo;
            m_Result = new Teller_Data.CreateTillTransfer();
        }
        
        private boolean AddError(String error)
        {
            m_Result.Error = error;
            return false;
        }
                       
        private boolean IsValid()
        {
            //to checks
            
            return true;
        }
        
        public Teller_Data.CreateTillTransfer Create()
        {
            if(!IsValid())
                return m_Result;
        
            Teller_Depository__c tfrom = [select id, name,branch__c from Teller_Depository__c where id=:m_StorageFrom];
            Teller_Depository__c tto= [select id, name,branch__c from Teller_Depository__c where id=:m_StorageTo];        
            
                       
        
            Teller_Transaction__c transfer = new Teller_Transaction__c();
            transfer.Branch__c = tfrom.branch__c;
            transfer.To_Storage__c = m_StorageTo;
            transfer.From_Storage__c = m_StorageFrom;
            transfer.Value__c = m_Value;
            transfer.TransferType__c = 'Storage Transfer';
            transfer.Transfer_Status__c='Created';         
            insert transfer;
            
            m_Result.TransferId = transfer.id;
            return m_Result;            
        }
    }// end class CreateTillTransfer
    
    
}