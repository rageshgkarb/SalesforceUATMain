public class HPPROTSentController extends HPPBaseEventController
{
    public Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
            }
        set;
  }
  
  public HPPROTSentController ()
  {
      LoadRots();
  }
  
  public List<Attachment> Rots{get;set;}
 
    public void LoadRots()
    {
        List<Attachment> lst = [select name, createddate from Attachment where ParentId =:opp.id];
        
        Rots = new List<Attachment>();
        
        for(Attachment att : lst)
        {
            if(att.name.contains('ROT'))
            {
                Rots.add(att);
            } 
        
        }        
    } 
 
  public PageReference upload() 
  {
    attachment.OwnerId = UserInfo.getUserId();
    attachment.ParentId = opp.id; // the record the file is attached to
    attachment.IsPrivate = true;
    
    attachment.name = 'ROT ' + attachment.name;
     
    
 
    try {
      insert attachment;
    } catch (DMLException e) {
      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
      return null;
    } finally {
      attachment = new Attachment(); 
    }
    LoadRots();
    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
    return null;
  }
  
    public PageReference Complete()
    {       
        CompleteEvent();
        return GoToNextEvent();             
    }   
}