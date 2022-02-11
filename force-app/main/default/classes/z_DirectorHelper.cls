@IsTest
public class z_DirectorHelper 
{
    public z_DirectorHelper()
    {
        Director = new ProductEventDirector__c();
        Director.Name = 'Test';
        Events = new List<Event__c>();
        FlowEvents = new List<HppObjects.FlowEvent >();
        
        
        
    }
    public Event__c Event{get;set;}
    
    private List<Event__c> Events{get;set;}
    private List<HppObjects.FlowEvent > FlowEvents{get;set;}
    private List<HppObjects.RewindEvent> RewindEvents{get;set;}
    private List<HppObjects.AdhocEvent> AdhocEvents{get;set;}

    public ProductEventDirector__c Director{get;set;}
    
    public void AIPEvent()
    {
        Event__c ev = new Event__c();
        ev.eventtype__c ='Flow';
        ev.name = 'AIP';
        List<HPPObjects.RequiredFields> fields = new List<HPPObjects.RequiredFields>();
        HPPObjects.RequiredFields rf = new HPPObjects.RequiredFields();
        rf.ObjectName='Account';
        rf.Field = 'Name';
        rf.Message = 'Message';
        fields.add(rf);

        HPPObjects.RequiredFields rf2= new HPPObjects.RequiredFields();
        rf2.ObjectName='Opportunity';
        rf2.Field = 'Name';
        rf2.Message = null;
        fields.add(rf2);

        HPPObjects.RequiredFields rf3= new HPPObjects.RequiredFields();
        rf3.ObjectName='HPP_extended_opportunity__c';
        rf3.Field = 'Name';
        rf3.Message = '';
        fields.add(rf3);

        List<HPPObjects.UpdateFields> upfields = new List<HPPObjects.UpdateFields>();
        HPPObjects.UpdateFields uf= new HPPObjects.UpdateFields();
        uf.ObjectName='HPP_extended_opportunity__c';
        uf.Field = 'Occupier__c';
        uf.Value= 'Test';
        uf.UseWhen = 'Completion';
        upfields.add(uf);
        /*
        HPPObjects.UpdateFields uf1= new HPPObjects.UpdateFields();
        uf1.ObjectName='Account';
        uf1.Field = 'LastName';
        uf1.Value= 'Test';
        uf1.UseWhen = 'Completion';
        upfields.add(uf1);
        */

        HPPObjects.UpdateFields uf2= new HPPObjects.UpdateFields();
        uf2.ObjectName='Opportunity';
        uf2.Field = 'Description';
        uf2.Value= 'Test';
        uf2.UseWhen = 'Completion';
        upfields.add(uf2);
        
        ev.UpdateFields__c = Json.serialize(upfields);
        ev.RequiredFields__c = Json.serialize(fields);
        
        List<HPPObjects.Actions> actions = new List<HPPObjects.Actions>();
        HPPObjects.Actions action= new HPPObjects.Actions();
        action.ClassName = 'Actions.FakeAction';
        action.RunWhen = 'Completed';
        action.Sequence = 1;
        action.Name ='Test';
        actions.add(action);
        
        ev.EventActions__c = json.serialize(actions);
        ev.CustomPageLocation__c='test';
        
        Insert ev;
        Events.add(ev);
        HppObjects.FlowEvent fev = new HppObjects.FlowEvent();
        fev.eventid = ev.id;
        fev.EventName = ev.name;
        fev.Sequence = 1;   
        fev.Stage = 'Test';
        fev.Status = 'Test';    
        FlowEvents.add(fev);
        
        
        
        
        if(Event == null)
            Event = ev;
    }
    
    public void ApplicationEvent()
    {
        Event__c ev = new Event__c();
        ev.eventtype__c ='Flow';
        ev.name = 'APP Form';
        Insert ev;
        Events.add(ev);
        HppObjects.FlowEvent fev = new HppObjects.FlowEvent();
        fev.eventid = ev.id;
        fev.EventName = ev.name;
        fev.Sequence = 2;  
        fev.Stage = 'Test';
        fev.Status = 'Test';     
        FlowEvents.add(fev);   
        if(Event == null)
            Event = ev; 
    }
    
    public ProductEventDirector__c Build()
    {
        Director.Flow_Events__c= JSON.Serialize(FlowEvents);
        upsert Director;
        return Director;    
    }
}