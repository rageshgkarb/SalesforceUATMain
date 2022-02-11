@IsTest
public class z_ProductHelper 
{
    public IBB_Product_Set__c ProductSet{get;set;}
    public IBB_Product__c Product{get;set;}
    
    // C00233
    public IBB_Product_Set__c theProdSet {get;set;}
    public IBB_Product__c theProd{get;set;}
    
    public z_ProductHelper()
    {
        
    
        ProductSet = new IBB_Product_Set__c();
        ProductSet.Name = 'Test'; 
        ProductSet.Max_No_of_Applicants__c = 4;
        ProductSet.ProductSetType__c = 'btl';
        insert ProductSet;
        
        Product = new IBB_Product__c();
        Product.Name = 'Test';
        Product.IBb_product_set__c =ProductSet.id;
        Product.Max_finance_to_value_FTV__c = 80;
        Product.ShowOnAIP__c = true;
        Product.Benchmark_rate__c = 4;
        
        insert Product;
        
        
        
        
        /*
        List<IBB_Product_Set__c> lst = new List<IBB_Product_Set__c>();
        IBB_Product_Set__c a = new IBB_Product_Set__c();
        a.name='HPP';
        a.Max_No_of_Applicants__c = 2;
        insert a;
        */
        
    }
    
    public void Director(String id)
    {
        ProductSet.EventDirector__c = id;
        //theProdSet.EventDirector__c = id;    // C00233
    }
    
    public IBB_Product_Set__c Build()
    {
        update ProductSet;
        return ProductSet;
        
        
        
        
    }
    // C00233
    public IBB_Product_Set__c Build2()
    {
        theProdSet = new IBB_Product_Set__c();
        theProdSet.Name = 'Business Current Accounts'; 
        theProdSet.Max_No_of_Applicants__c = 4;
        theProdSet.ProductSetType__c = 'btl';
        insert theProdSet;
        
        theProd = new IBB_Product__c();
        theProd.Name = 'Test';
        theProd.IBb_product_set__c =theProdSet.id;
        theProd.Max_finance_to_value_FTV__c = 80;
        theProd.ShowOnAIP__c = true;
        theProd.Benchmark_rate__c = 4;
        
        insert theProd;
        update theProdSet;
        return theProdSet;
    }
}