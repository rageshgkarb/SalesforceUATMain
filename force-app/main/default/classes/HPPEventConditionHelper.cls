/*
    X1: Automated condition enhancement
*/

public class HPPEventConditionHelper
{
    public List<Special_Condition__c> conditionsData{get;set;}
    private List<Special_condition_item__c> Items{get;set;}
    private Account acc{get;set;}
    private Opportunity opp{get;set;}
    private HPP_extended_opportunity__c exOpp{get;set;}
    public List<ConditionItem> CIList{get;set;}

    
    public Special_condition_item__c GetItem(string id)
    {
        for(Special_condition_item__c  i : Items )
        {
            if(id == i.id)
            return i;
        }
        return null;
    }
    
    
    public void DeleteItem(String id)
    {
        Special_condition_item__c del;
        for(Integer i= 0; i< Items.size();i++)
        {
            if(Items[i].id == id)
            {
                del = Items.remove(i);
                break;
            }
        }
        
        if(del != null)
        {
            delete del;
        }
    }  
    
    //C0760-OfferLetter Enhancements ; Start 
    public void deleteBulkItem(set<string> itemIdSet){
        system.debug('Items'+Items);
        system.debug('itemIdSet'+itemIdSet);
        list<Special_condition_item__c> deleteList = new list<Special_condition_item__c>();
        for(Integer i= 0; i< Items.size();i++)
        {
            if(itemIdSet != null && itemIdSet.size() > 0 && itemIdSet.contains(Items[i].id))
            {
                //deleteList.add(Items.remove(i));
                deleteList.add(Items[i]);
            }
        }
        system.debug('deleteList'+deleteList);
        if(deleteList.size() > 0)
        {
            delete deleteList;
        }    
    }
     //C0760-OfferLetter Enhancements ; End
    
    public HPPEventConditionHelper(Account accData, Opportunity oppData,HPP_extended_opportunity__c exoppData)
    {
        acc = accData;
        opp = oppData;
        exOpp = exoppData;
        
      
        /* X1 Start */
        
        //LB C0304 Start - extra fields selected
        conditionsData= [select id,version__c, category__c, name, Post_Completion__c, Chase_within_months__c, Tags__c,Stand_condition__c,ExPat__c,Premier__c   from Special_Condition__c where active__c = true order by category__c, version__c ];
        Items = [select notes__c, Accepted__c,Post_Completion__c, Chase_within_months__c, ref__c, Accepted_By__c,Added_By__c,Condition_Data__c,Condition_HTML__c,Condition_Letter__c,Credit_Allowed__c,Opportunity__c,Reet_Allowed__c,Special_Condition__c,Special_Condition_Data__c,Special_Condition_Text__c,Pre_or_Post__c from Special_condition_item__c where Opportunity__c =:Opp.id ];
        //LB C0304 End
      
        if(exopp.Auto_Condition_Run__c)
        {
           return; 
        }
        else
        {
            exopp.Auto_Condition_Run__c = true;
            update exopp;
        }
        
      
        system.debug('auto add conditions');
        //check for auto created conditions
        List<Special_condition_item__c> addedConditions = new List<Special_condition_item__c>(); 
        
        system.debug('Interested In: '+ opp.interested_in__c.equalsIgnoreCase('Home Purchase Plan Premier'));
        system.debug('ExPat: ' +  opp.ex_pat__c);
        
        if(opp.interested_in__c.equalsIgnoreCase('Home Purchase Plan Premier') && opp.ex_pat__c.equalsIgnoreCase('Yes'))
        {
            system.debug('load all of the conditions that need to be auto added');
            for(Special_Condition__c sc : conditionsData)
            {
                if(sc.ExPat__c== true && sc.Premier__c == true)
                {
                    boolean alreadyExists = false;
                    system.debug('need to check to see if this condition has already been added');
                    for(Special_condition_item__c item : items)
                    {
                        if(item.Special_Condition__c == sc.id)
                        {
                            alreadyExists = true;
                            break;
                        }
                    }                
                
                    //add condition
                    if(!alreadyExists)
                        AddCondition(sc.id,'PRE'); 
                }                
            }
        }  
        
        
        system.debug('1Interested In: '+ opp.interested_in__c.equalsIgnoreCase('Home Purchase Plan'));
        system.debug('1ExPat: ' +  opp.ex_pat__c);
        if(opp.interested_in__c.equalsIgnoreCase('Home Purchase Plan Premier')  && !opp.ex_pat__c.equalsIgnoreCase('Yes'))
        {
            system.debug('load all of the conditions that need to be auto added');
            for(Special_Condition__c sc : conditionsData)
            {
                system.debug('Checking sc.exPat__c:' + sc.exPat__c + '  sc.Premier__c:' + sc.Premier__c);
                if(sc.Premier__c == true)
                {
                    system.debug('Rule to check');
                
                    boolean alreadyExists = false;
                    system.debug('need to check to see if this condition has already been added');
                    for(Special_condition_item__c item : items)
                    {
                        if(item.Special_Condition__c == sc.id)
                        {
                            alreadyExists = true;
                            break;
                        }
                    }                
                
                    //add condition
                    if(!alreadyExists)
                        AddCondition(sc.id,'PRE'); 
                }                
            }
        } 
        
        
        
        
        system.debug('1Interested In: '+ opp.interested_in__c.equalsIgnoreCase('Home Purchase Plan'));
        system.debug('1ExPat: ' +  opp.ex_pat__c);
        if(!opp.interested_in__c.equalsIgnoreCase('Home Purchase Plan Premier') && opp.ex_pat__c.equalsIgnoreCase('Yes'))
        {
            system.debug('load all of the conditions that need to be auto added');
            for(Special_Condition__c sc : conditionsData)
            {
                system.debug('Checking sc.exPat__c:' + sc.exPat__c + '  sc.Premier__c:' + sc.Premier__c);
                if(sc.exPat__c == true)
                {
                    system.debug('Rule to check');
                
                    boolean alreadyExists = false;
                    system.debug('need to check to see if this condition has already been added');
                    for(Special_condition_item__c item : items)
                    {
                        if(item.Special_Condition__c == sc.id)
                        {
                            alreadyExists = true;
                            break;
                        }
                    }                
                
                    //add condition
                    if(!alreadyExists)
                        AddCondition(sc.id,'PRE'); 
                }                
            }
        } 
        /* X1 End */         
    }  
    

    
    public void Load()
    {
        CIList = new List<ConditionItem>();
        //LB C0304 Start - extra fields selected
        conditionsData= [select id,version__c, category__c, name, Post_Completion__c, Chase_within_months__c, Tags__c,Stand_condition__c,ExPat__c,Premier__c   from Special_Condition__c where active__c = true order by category__c, version__c ];
        Items = [select notes__c, Accepted__c, ref__c,Post_Completion__c, Chase_within_months__c, Accepted_By__c,Added_By__c,Condition_Data__c,Condition_HTML__c,Condition_Letter__c,Credit_Allowed__c,Opportunity__c,Reet_Allowed__c,Special_Condition__c,Special_Condition_Data__c,Special_Condition_Text__c,Pre_or_Post__c from Special_condition_item__c where Opportunity__c =:Opp.id ];
        //LB C0304 End
        CreateObjects();    
    }
    
    public void LoadOpen()
    {
        CIList = new List<ConditionItem>();
        //LB C0304 Start - extra fields selected
        conditionsData= [select id,version__c, category__c, name,Post_Completion__c, Chase_within_months__c,  Tags__c,Stand_condition__c,ExPat__c,Premier__c   from Special_Condition__c where active__c = true order by category__c, version__c ];
        Items = [select notes__c, Accepted__c, ref__c,Post_Completion__c, Chase_within_months__c, Accepted_By__c,Added_By__c,Condition_Data__c,Condition_HTML__c,Condition_Letter__c,Credit_Allowed__c,Opportunity__c,Reet_Allowed__c,Special_Condition__c,Special_Condition_Data__c,Special_Condition_Text__c,Pre_or_Post__c from Special_condition_item__c where Opportunity__c =:Opp.id and (accepted__c != true or Accepted_Date__c= null)  ];
        //LB C0304 End
            
             
             
        CreateObjects();    
    }    
    
    public void CreateObjects()
    {           
           
        
        
    
    
    
        for(Special_condition_item__c i : Items)
        {   
            system.debug('item=> ' + i);
            if(i.Special_Condition_Data__c != null && i.Condition_Data__c != null)
            {
             SpecialConditionAdminController.SpecialConditionItem sci = (SpecialConditionAdminController.SpecialConditionItem)JSON.deserialize(i.Special_Condition_Data__c, SpecialConditionAdminController.SpecialConditionItem.class);
             system.debug('deser=>' + sci);                                       
             ConditionItemData cid  = (ConditionItemData)JSON.deserialize(i.Condition_Data__c, ConditionItemData.class);
             system.debug('loaded item values =>' + cid.Values);
             ConditionItem  ci = new  ConditionItem(acc,opp);
             ci.id = cid.id;
             ci.Values = cid.Values;
             ci.Data = cid.Data;
             ci.Template = cid.Template;
             ci.Name = cid.Name;  
             ci.Ref =i.ref__c;   
             ci.UW_Allowed = i.Credit_Allowed__c;
             ci.Reat_Allowed = i.Reet_allowed__c;
             //LB C0304 Start  
             ci.PostCompletion = i.Post_Completion__c; 
             ci.Chasewithin = i.Chase_within_months__c;
             //LB C0304 End
             ci.PreOrPost = i.Pre_or_Post__c;
             ci.Satisfied = i.Accepted__c;
             ci.Notes = i.notes__c;
                              
             system.debug('Tag Data : ' + cid.Data);  
             system.debug('ItemRef :' + i.ref__c);               
                
             CIList.Add(ci);
           }
        }
    }
    
    public void AddCondition(String SelectedCondition,String preOrPost)
    {
    for(Special_Condition__c sc : conditionsData)
        {
            system.debug('Compare - ' + sc.name + ' : ' +  SelectedCondition);
            if(SelectedCondition.contains(sc.id)) //C0760 Process Optimization 2.0
            //if( sc.id == selectedCondition)
            {            
                Special_condition_item__c newCondition = new Special_condition_item__c();
                newCondition.Opportunity__c = opp.id;
                newCondition.Added_By__c = UserInfo.getUserId();
                newcondition.Special_Condition_Data__c = sc.Tags__c;
                newCondition.Special_Condition__c = sc.id;
                newCondition.Special_Condition_Text__c = sc.Stand_condition__c;  
                newCondition.Pre_or_Post__c = preOrPost;   
                newCondition.Accepted__c = false;    
                newCondition.Credit_Allowed__c = true;
                //LB C0304 Start
                newCondition.Post_Completion__c= sc.Post_Completion__c;
                newCondition.Chase_within_months__c= sc.Chase_within_months__c;
                //LB C0304 End
                
                                                      
                upsert newCondition;
                
                //SOItems.put(newCondition.id,newCondition);
                            
                SpecialConditionAdminController.SpecialConditionItem sci = (SpecialConditionAdminController.SpecialConditionItem)JSON.deserialize(sc.Tags__c, SpecialConditionAdminController.SpecialConditionItem.class);
                              
                
                ConditionItemData ci = new ConditionItemData(); 
                ci.Template = sc.Stand_condition__c;
                ci.Name = sc.Name;                               
                ci.id = newCondition.id; 
                ci.Data = sci; 
                ci.UW_Allowed = false;
                ci.Reat_Allowed =false;
                  
                
                system.debug('Post:' + ci.PostCompletion);
                system.debug('Chase:' + ci.Chasewithin );
                 
                ci.Ref =  newCondition.Ref__c;  
                ci.PreOrPost = preOrPost; 
                ci.Satisfied = false;  
                
                newCondition.Condition_HTML__c = sc.Stand_condition__c;
                update newCondition;                
                ci.Values = new List<ConditionItemValue>(); 
                for(SpecialConditionAdminController.SpecialConditionUserTag t : sci.UserTags)
                {
                    system.debug('Adding item=>' + t.code );
                    ConditionItemValue cv = new ConditionItemValue();
                    cv.Code = t.code;
                    cv.Title = t.Title;                                   
                    ci.Values.add(cv);
                }
                
                newCondition.Condition_Data__c = JSON.Serialize(ci);
                //C0760 ; offer -letter checklist enhancement ; single save ; Start
                String templateData= sc.Stand_condition__c; 
                system.debug('ci.values'+ci.values);
                for(ConditionItemValue coniv : ci.values)
                {                    
                    String value = '____';
                    String replaceToken = '(?i)\\{' + coniv.code + '\\}';            
                    templateData = templateData.replaceAll(replaceToken,value);
                    //templateData = Replace(templateData,coniv.code, value );
                    system.debug('templateData'+templateData);                   
                }  
                newCondition.Condition_Conga_HTML__c = templateData; 
                //C0760 ; offer -letter checklist enhancement ; single save ; End         
                update newCondition;
                
                Load();
                //Items.Add(ci);              
                             
              
            }
        }
        }
    
    public virtual class ConditionItemData
    {
        public string id{get;set;}        
        public List<ConditionItemValue> Values{get;set;}
        public SpecialConditionAdminController.SpecialConditionItem Data{get;set;}
        public String Template{get;set;}
        public String Name{get;set;}
        public String Code{get;set;}
        public Boolean UW_Allowed{get;set;}
        public Boolean Reat_Allowed{get;set;}
        public String Ref{get;set;}
        public String PreorPost{get;set;}
        public Boolean Satisfied{get;set;}
        public String Notes{get;set;}
        public String AcceptedBy{get;set;}
        //LB C0304 Start
        public String Chasewithin{get;set;}
        public Boolean PostCompletion{get;set;}
        public boolean deleteLine{get;set;}  //C0760-OfferLetter Enhancements
        //LB C0304 End
    }
    
    public class ConditionItemValue
    {
        public String Code{get;set;}
        public String Value{get;set;}
        public String Title{get;set;}
    }
    
    
    
     public class ConditionItem  extends ConditionItemData
    {        
        public Account Acc{get;set;}
        public Opportunity Opp{get;set;}
         
        
        public void Save(Special_condition_item__c sci)
        {
            ConditionItemData tempDataItem = new ConditionItemData();
            tempDataItem.id = id;
            tempDataItem.Values = Values;
            tempDataItem.template = template;
            tempDataItem.Data = data; 
            tempDataItem.Name = name;  
            sci.Accepted__c = Satisfied;
            
            if(sci.Accepted__c)
            {
                if(sci.Accepted_By__c == null)
                    sci.Accepted_By__c = UserInfo.getUserId() ;
                    
                if(sci.Accepted_Date__c == null)
                    sci.Accepted_Date__c = date.today();
            } 
            else
            {
                sci.Accepted_By__c =null;
                sci.Accepted_Date__c=null;
            }
            
            sci.Credit_Allowed__c =UW_Allowed;
            sci.Reet_Allowed__c = Reat_Allowed;
            //LB C0304 Start
            sci.Post_Completion__c = PostCompletion;
            sci.Chase_within_months__c = Chasewithin;
            //LB C0304 End
            sci.Condition_Data__c = JSON.Serialize(tempDataItem);
            sci.Condition_HTML__c = HtmlText();
            sci.Condition_Conga_HTML__c = CongaHtmlText();
            update sci;    
        }
        
        public String HTML
        {
            get{
                return HtmlText();
            }
        }
        public ConditionItem(Account accData,Opportunity oppData)
        {
            Acc = accData;
            Opp = oppData;
        }
        
        public ConditionItem(SpecialConditionAdminController.SpecialConditionItem d,String temp,String sName,Account accData,Opportunity oppData)
        {
            Data = d;
            Acc = accData;
            Opp = oppData;
            Template = temp;
            Name = sName;           
            Values = new List<ConditionItemValue>();
        }
        
        public String Replace(String source, String search, String replacement )
        {
            String replaceToken = '(?i)\\{' + search + '\\}';            
            return source.replaceAll(replaceToken, replacement);
        }
        
        
        public String CongaHtmlText()
        {
            String html = Template;            
            for(SpecialConditionAdminController.SpecialConditionTag t : Data.Tags)
            {   
                if(t.ObjectName.equalsIgnoreCase('account'))
                {
                    Object fobj = Acc.get(t.Field);
                    String data = string.valueof(fobj);                    
                    html = Replace(html,t.code, data);
                }
                if(t.ObjectName.equalsIgnoreCase('opportunity'))
                {
                    Object fobj = Opp.get(t.Field);
                    String data = string.valueof(fobj);                    
                    html = Replace(html,t.code, data);
                }                     
            }
            
            for(SpecialConditionAdminController.SpecialConditionUserTag t : Data.UserTags)
            {
                for(ConditionItemValue civ : values)
                {
                    if(civ.code == t.code)
                    {
                        String value = civ.Value;
                        if(value == null || value == '')
                            value = '____';
                    
                        html = Replace(html,t.code, value );
                        break;
                    }                    
                }            
                
            }
            
            return html;
        }
        
        public String HtmlText( )
        {
            String html = Template;     
            
                  
            for(SpecialConditionAdminController.SpecialConditionTag t : Data.Tags)
            {
                if(t.ObjectName.equalsIgnoreCase('account'))
                {
                    Object fobj = Acc.get(t.Field);
                    String data = string.valueof(fobj);                    
                    html = Replace(html,t.code,'<span title="Account: '+t.Field+'" style="color: blue;">' + data  + '</span>');
                }
                if(t.ObjectName.equalsIgnoreCase('opportunity'))
                {
                    Object fobj = Opp.get(t.Field);
                    String data = string.valueof(fobj);                    
                    html = Replace(html,t.code,'<span title="Opportunity : '+t.Field+'" style="color: blue;">' + data  + '</span>');
                }          
            }
            
            system.debug('DataTags=> ' + Data.UserTags); 
            for(SpecialConditionAdminController.SpecialConditionUserTag t : Data.UserTags)
            {
                system.debug('For tag=> ' + t.code + ' values:=> ' + values);
                
                for(ConditionItemValue civ : values)
                {
                    system.debug('For tag=> ' + t.code + ' vs ' + civ.code );
                    if(civ.code == t.code)
                    {
                        String value = civ.Value;
                        if(value == null || value == '')
                            value = '____';
                    
                        html = Replace(html,t.code,'<span title="'+t.Title+'" style="color: red;">' + value + '</span>');
                        break;
                    }                    
                }            
                
            }
            
            return html;
        }
    }

}