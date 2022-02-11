/* ------------------------------------------------------------------------------- */
/* C00094 14/10/2013    New class to perform primitive validation called from      */
/*                      HPPManualRollbackController                                */ 
/* ------------------------------------------------------------------------------- */                             

public without sharing class HPPRewindValidation
{
    public Opportunity theOpp {get;set;}
    public HPP_Extended_Opportunity__c theExtOpp {get;set;}
    public ReturnArgs retArgs {get;set;}
    public List<RewindValidation__c> rewinds = RewindValidation__c.getall().values();  
    
    public HPPRewindValidation (Opportunity opp, HPP_Extended_Opportunity__c extOpp)
    {
        system.debug ('In HPPRewindValidation' + rewinds);
        theOpp = opp;
        theExtOpp = extOpp;
        retArgs = ProcessRewindValidation ();
    }
    
    public ReturnArgs ProcessRewindValidation ()
    {
        system.debug ('In ProcessRewindValidation' + rewinds);
        
        ReturnArgs rtv = new ReturnArgs();
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        Schema.SObjectType oppObject = objectMap.get('Opportunity');
        Schema.SObjectType extoppObject = objectMap.get('HPP_Extended_Opportunity__c');
        Schema.Describesobjectresult oppResult = oppObject.getDescribe();
        Schema.Describesobjectresult extOppResult = extOppObject.getDescribe();
        Map<String, Schema.SObjectField> oppObjectFieldMap = oppResult.fields.getMap();
        Map<String, Schema.SObjectField> extOppObjectFieldMap = extOppResult.fields.getMap();
        SObject opp = theOpp;
        SObject extOpp = theExtOpp;
        
        rtv.ReturnValue = 'SUCCESS';
        
        try
        {
            for (RewindValidation__c rewind : rewinds)
            {
                system.debug ('In for rewinds ' + rewind);
                string sourceValue;
                
                string message = '';
                system.debug ('In for rewinds 2 ' + rewind);
                if (rewind.Object__c == 'Opportunity')
                {
                    system.debug ('In for rewinds 3 ' + rewind);
                    system.debug('Field1:' + rewind.field__c);
                    system.debug('Field: ' + oppObjectFieldMap.get(rewind.Field__c));
                    system.debug('FieldMap:' + oppObjectFieldMap);
                    system.debug('ObjectValue:' + oppObjectFieldMap.get(rewind.Field__c));
                    
                    
                    sourceValue = String.valueof (opp.get(oppObjectFieldMap.get(rewind.Field__c))); 
                }
                else if ('HPP_Extended_Opportunity__c'.equalsIgnoreCase(rewind.Object__c))
                {
                    system.debug ('In for rewinds 4 ' + rewind);
                    system.debug ('The rewind value ' + rewind.Field__c);
                    system.debug ( 'Map get one ' + extOppObjectFieldMap.get(rewind.Field__c));
                    sourceValue = String.valueof (extOpp.get(extOppObjectFieldMap.get(rewind.Field__c))); 
                    
                     
                    system.debug ( 'Map get 2 ' + String.valueof (extOpp.get(extOppObjectFieldMap.get(rewind.Field__c))));
                    system.debug ('In for rewinds 5 ' + rewind);
                }
                else
                {
                }
                
                system.debug ('In for rewinds 6 ' + sourceValue + ' rewind ' + rewind);
                message = PerformComparison (sourceValue, rewind);
                
                if ( !String.IsEmpty (message))
                {
                    rtv.ReturnValue = 'FAILURE';
                    rtv.ReturnMessages.Add (message);
                }                
            }
        }
        
        catch (Exception e)
        {
            system.debug ( 'This is the validation exception ' + e.GetMessage());
            rtv.ReturnValue = 'FAILURE';
            rtv.ReturnMessages.Add ('General validation failure ' + e.GetMessage());
        }
        
        system.debug ( 'This is the result ' + rtv );
        //integer i = 1 / 0;
        return rtv;
    }
    
    public string PerformComparison (string sourceValue, RewindValidation__c rewind)
    {
        string rtv = '';
        Date sourceDate;
        DateTime sourceDateTime;
        Decimal sourceDecimal;
        Integer sourceInteger;
        string targetValue;
        Date targetDate;
        DateTime targetDateTime;
        Decimal targetDecimal;
        Integer targetInteger;
        boolean emptyValue = false;
        system.debug ( 'In performComparison' );
        
        if (String.IsEmpty(sourceValue)) 
        {
            sourceValue = '-BLANK-';
            emptyValue = true;
        }
        if (rewind.Value__c == '-BLANK-')
        {
            emptyValue = true;
        }
        
        
        system.debug ( 'What is emptyValue ' + emptyValue);
        
        if ('STRING'.equalsIgnoreCase(rewind.DataType__c) || emptyValue == true)
        {
            system.debug ( 'What is the source Value ' + sourceValue + ' rewind Value ' + rewind.Value__c);
            if (rewind.Operator__c == '=')
            {
                if (sourceValue == rewind.Value__c)
                {
                    rtv = rewind.ErrorMessage__c ;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<>')
            {
                if (sourceValue != rewind.Value__c)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<')
            {
                if (sourceValue < rewind.Value__c)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<=')
            {
                if (sourceValue <= rewind.Value__c)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '>')
            {
                if (sourceValue > rewind.Value__c)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '>=')
            {
                if (sourceValue >= rewind.Value__c)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else
            {
                if (sourceValue == rewind.Value__c)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
        }
        else if ('DATE'.equalsIgnoreCase(rewind.DataType__c))
        {
            sourceDate = Date.ValueOf(sourceValue);
            targetDate = Date.ValueOf(rewind.Value__c);
            if (rewind.Operator__c == '=')
            {
                if (sourceDate == targetDate)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<>')
            {
                if (sourceDate != targetDate)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<')
            {
                if (sourceDate < targetDate)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<=')
            {
                if (sourceDate <= targetDate)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '>')
            {
                if (sourceDate > targetDate)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '>=')
            {
                if (sourceDate >= targetDate)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else
            {
                if (sourceDate == targetDate)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
        }
        else if ('DATETIME'.equalsIgnoreCase(rewind.DataType__c))
        {
            sourceDateTime = DateTime.ValueOf(sourceValue);
            targetDateTime = DateTime.ValueOf(rewind.Value__c);
            if (rewind.Operator__c == '=')
            {
                if (sourceDateTime == targetDateTime)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<>')
            {
                if (sourceDateTime != targetDateTime)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<')
            {
                if (sourceDateTime < targetDateTime)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<=')
            {
                if (sourceDateTime <= targetDateTime)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '>')
            {
                if (sourceDateTime > targetDateTime)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '>=')
            {
                if (sourceDateTime >= targetDateTime)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else
            {
                if (sourceDateTime == targetDateTime)
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
        }
        else if ('DOUBLE'.equalsIgnoreCase(rewind.DataType__c))
        {
            sourceDecimal = Decimal.ValueOf(sourceValue);
            targetDecimal = Decimal.ValueOf(rewind.Value__c);
            if (rewind.Operator__c == '=')
            {
                if (sourceDecimal == targetDecimal )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<>')
            {
                if (sourceDecimal != targetDecimal )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<')
            {
                if (sourceDecimal < targetDecimal )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<=')
            {
                if (sourceDecimal <= targetDecimal )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '>')
            {
                if (sourceDecimal > targetDecimal )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '>=')
            {
                if (sourceDecimal >= targetDecimal )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
        }
        else if ('INTEGER'.equalsIgnoreCase(rewind.DataType__c))
        {
            sourceInteger = Integer.ValueOf(sourceValue);
            targetInteger = Integer.ValueOf(rewind.Value__c);
            if (rewind.Operator__c == '=')
            {
                if (sourceInteger == targetInteger )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<>')
            {
                if (sourceInteger != targetInteger )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<')
            {
                if (sourceInteger < targetInteger )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '<=')
            {
                if (sourceInteger <= targetInteger )
                {
                    rtv = rewind.ErrorMessage__c ;
                                            /* + 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c; */
                }
            }
            else if (rewind.Operator__c == '>')
            {
                if (sourceInteger > targetInteger )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
            else if (rewind.Operator__c == '>=')
            {
                if (sourceInteger >= targetInteger )
                {
                    rtv = rewind.ErrorMessage__c;
                                            /*+ 
                                            ' - ' + 
                                            sourceValue + 
                                            ' ' + 
                                            TranslateOperator (rewind.Operator__c) + 
                                            ' ' + 
                                            rewind.Value__c;*/
                }
            }
        }      
        
        
        
        return rtv;
       
        
        
    }
    
/*
    public string TranslateOperator (string operator)
    {
        string rtv = '';
        if ( operator == '=' )
        {
            rtv = 'EQUALS';
        }
        else if ( operator == '<>' )
        {
            rtv = 'NOT EQUALS';
        }
        else if ( operator == '>=' )
        {
            rtv = 'GREATER OR EQUALS';
        }
        else if ( operator == '<=' )
        {
            rtv = 'LESS OR EQUALS';
        }
        else if ( operator == '>' )
        {
            rtv = 'GREATER';
        }
        else if ( operator == '<' )
        {
            rtv = 'LESS';
        }
        return rtv;
    }
   */

    public class ReturnArgs
    {
        public string ReturnValue {get;set;}
        public List<string> ReturnMessages {get;set;}
        public ReturnArgs ()
        {
            ReturnMessages = new List<string>();
        }
    }
}