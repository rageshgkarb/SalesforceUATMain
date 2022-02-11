public class KendoUIHelper
{
    
    
    public class KendoUIGridOption
    {
        public integer page{get;set;}
        public integer pageSize{get;set;}
        public integer skip{get;set;}
        public string sortField{get;set;}
        public integer take{get;set;}
        
        public KendoUIGridOption()
        {
        
        }
        
        public KendoUIGridOption(String options)
        {
            system.debug(options);
        
            if(options != null)
            {
                try
                {
                    KendoUIGridOption temp = new KendoUIGridOption();
                    temp = (KendoUIGridOption) JSON.deserialize(options, KendoUIGridOption.class);
                    
                    page = temp.page;
                    pageSize = temp.pageSize;
                    skip = temp.skip;
                    sortField = temp.sortField;
                    take = temp.take;
                    
                }
                catch(Exception ex)
                {
                    system.debug('Error ' + ex.getMessage());
                }
            }
        }
    }

}