/* ------------------------------------------------------------------------------------------------ */
/* C00228 New class to hold the Integration Message Structures                                      */
/* ------------------------------------------------------------------------------------------------ */

public without sharing class IBBMessageStructures
{
    //public HPPDecisionEngineStructure HPPDecisionEngineMessage {get;set;}
    public DecisionEngineStructure DecisionEngineMessage {get;set;}
    
    public IBBMessageStructures ()
    {
        DecisionEngineMessage = new DecisionEngineStructure ();
        //HPPDecisionEngineMessage = new HPPDecisionEngineStructure ();
        
    }
    /*
    public class HPPDecisionEngineStructure 
    {
        public IBBXMLMethods.XmlMessage XmlDERequest {get;set;}
        public IBBXMLMethods.XmlMessage XmlDEResponse {get;set;}
        public HPPDecisionEngineStructure ()
        {
            XmlDERequest = new IBBXMLMethods.XMLMessage ('Request',
                                                        'HPPDecisionEngineRequest',
                                                        'Account',
                                                        'HPPDecisionEngineRequest');
        }
    }
    */
    public class DecisionEngineStructure 
    {
        public IBBXMLMethods.XmlMessage XmlDERequest {get;set;}
        public IBBXMLMethods.XmlMessage XmlDEResponse {get;set;}
        public DecisionEngineStructure ()
        {
            XmlDERequest = new IBBXMLMethods.XMLMessage ('Request',
                                                        'DecisionEngineRequest',
                                                        'Account',
                                                        'DecisionEngineRequest');
        }
    }
}