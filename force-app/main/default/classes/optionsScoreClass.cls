public  class optionsScoreClass {
    @AuraEnabled
       public string option{get;set;}
    @AuraEnabled
        public decimal score{get;set;}
    @AuraEnabled
        public string optionId{get;set;}
    @AuraEnabled
        public boolean isCriticalValue{get;set;}
    
}