/* ------------------------------------------------------------------------------------------------------- */
/* C00228    BAA Decision Engine class for all the properties and dataneeded to process DE calls           */
/* ------------------------------------------------------------------------------------------------------- */

public without sharing class DecisionEngineProperties
{
    public IBBMessageStructures.DecisionEngineStructure MessageStructure {get;set;}
    public DecisionEngineData EngineData {get;set;}
    public DecisionEngineResponse EngineResponse {get;set;}
    public List<DecisionEngineResponse.Reason> EngineReasons {get;set;}
    
    public DecisionEngineProperties (Opportunity Opp, string context)
    {
        IBBMessageStructures messages = new IBBMessageStructures ();
        MessageStructure = messages.DecisionEngineMessage ;
        EngineData = new DecisionEngineData (opp, context);
        EngineResponse = new DecisionEngineResponse();
        EngineReasons = new List<DecisionEngineResponse.Reason>();
    }
}