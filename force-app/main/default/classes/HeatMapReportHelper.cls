public with sharing class HeatMapReportHelper {

    public BU getHierarchy(Id topLevel){
        BU tree;
        Map<Id,grc__Business_Unit__c> BUs = new Map<Id, grc__Business_Unit__c>([select id, name, grc__Parent_Business_Unit__c from grc__Business_Unit__c order by grc__Parent_Business_Unit__r.name limit 50000]);
        if(topLevel != null)
            tree = new BU(BUs.get(topLevel), BUs.values(), 0);
        else{
            for(grc__Business_Unit__c BU : BUs.values()){
                if(BU.grc__Parent_Business_Unit__c == null){
                    tree = new BU(BU, BUs.values(), 0);
                    break;
                }
            }
        }
          
        return tree;
    }
    
    public Map<Id, BU> getHierarchy(Set<Id> buIds)
    {
    	Map<Id, BU> trees = new Map<Id, BU>();
    	
    	Map<Id,grc__Business_Unit__c> BUs = new Map<Id, grc__Business_Unit__c>([SELECT Id, Name, grc__Parent_Business_Unit__c
    																			FROM grc__Business_Unit__c order by grc__Parent_Business_Unit__r.name
    																			limit 50000]);
    	
    																		
    	for(Id buId : buIds)
    	{    
    		if(BUs.get(buId) != null)
    		{		
	            BU tree = new BU(BUs.get(buId), BUs.values(), 0);
	            trees.put(buId, tree);
    		}
    	}
    	
    	for(Id buId : trees.keySet())
    	{
    		for(Id buIdCheck : trees.keySet())
    		{ 
    			if(buId != buIdCheck)
    			{
	    			List<BU> tempBus = flattenTree(trees.get(buIdCheck));
	    			
	    			for(BU b : tempBus)
	    			{
	    				if(buId == b.me.Id)
	    				{
	    					trees.remove(buId);
	    				}
	    			}
    			}
    		}
    	}
    	
    	return trees;
    }
    
    public List<BU> getHierachyFlat(Id topLevel){
        BU tree = getHierarchy(topLevel);        
        
        return flattenTree(tree);
    }
    
    public Map<Id, List<Bu>> getHierachyFlat(Set<Id> buIds)
    {
    	Map<Id, BU> trees = getHierarchy(buIds);
    	
    	Map<Id, List<BU>> output = new Map<Id, List<Bu>>();    	
    	
    	for(Id buId : trees.keySet())
    	{
    		output.put(buId, flattenTree(trees.get(buId)));
    	}    	
    	
    	return output;
    }
    
    public List<BU> flattenTree(BU branch)
    {
    	List<BU> flatBusinessUnits = new List<BU>(); 
        if (branch != null)
        {
            flatBusinessUnits.add(branch);
            for(BU child : branch.Children)
            {
                flatBusinessUnits.addAll(flattenTree(child));
            }
        }
        return flatBusinessUnits;        
    }
    
    public with sharing class BU{
        public List<BU> Children = new List<BU>();
        public integer level {get; private set;}
        public boolean Selected{get;set;}
        public boolean HasChildren{get;set;}
        public grc__Business_Unit__c me{get; private set;}
        public BU(grc__Business_Unit__c me, List<grc__Business_Unit__c> BUs, integer level){        	
            this.me = me;
            Selected = false;
            HasChildren = false;
            this.level = level;
            for(grc__Business_Unit__c unit : BUs){             	           	
                if(unit.grc__Parent_Business_Unit__c == me.Id){
                    Children.add(new BU(unit, BUs, level+1));
                    HasChildren = true;
                }
            }
        }
        
    }
     @isTest
	public static void testVariables()
	{
		User usr = [Select Id from User where Id = :UserInfo.getUserId()];
 		Set<id> buIds = new Set<Id>();
	    System.RunAs(usr)
	    {
	    	Test.startTest();	
			
			grc__Business_Unit__c bus1 = new grc__Business_Unit__c(name='bus1', Risk__Sharing_Group_Name__c = 'bus1');
			insert bus1;
			
			grc__Business_Unit__c bus2 = new grc__Business_Unit__c(name='bus1', Risk__Sharing_Group_Name__c = 'bus2',grc__Parent_Business_Unit__c = bus1.id);
			insert bus2;
            
            grc__Business_Unit__c bus3 = new grc__Business_Unit__c(name='bus1', Risk__Sharing_Group_Name__c = 'bus3',grc__Parent_Business_Unit__c = bus1.id);
			insert bus3;
		    
		    HeatMapReportHelper hmp = new HeatMapReportHelper();
			buIds.add(bus1.id);
			buIds.add(bus2.id);
			buIds.add(bus3.id);
			hmp.getHierarchy(bus1.id);
			
			hmp.getHierarchy(buIds);
			
			List<BU> buWrap = hmp.getHierachyFlat(bus1.id);
			
			hmp.getHierachyFlat(buIds); 
			
			hmp.flattenTree(buWrap[0]);
			Test.stopTest();
	    }
	}	
}