public with sharing class OLIController {
    
    public ApexPages.StandardController sc;
    public Opportunity Opp {get;set;}
    public List<OpportunityLineItem> OLIlist2 {get ;set;}
    public String OLIlist2Size {get ;set;}
    public Account relatedAccount {get;set;}
    public String DateNow {get;set;}
    
    public OLIController(ApexPages.StandardController sc) { 
        DateNow =  System.now().format();
        this.Opp = (Opportunity)sc.getRecord();
        OLIlist2 = [Select Name, ID, Quantity, UnitPrice, TotalPrice, Style__c, OpportunityId, A_C__c,V__c,H__c,Rpt__c,A_O__c,Vendor__c,
                    S_P__c,Size__c,Description,By__c,Vendor_description__c, On_Back_Order__c, Projected_Delivery_Date__c
                    FROM OpportunityLineItem WHERE OpportunityId =:Opp.Id];
        OLIlist2Size = String.valueOf(OLIlist2.size()+1);
        relatedAccount = [Select ID, Comments__c  From Account where Id=:Opp.AccountId ];
        
        
    }
    
    
    /*public List<OpportunityLineItem> getOLIs() {
        
        List<OpportunityLineItem> OLIlist2 = [Select Name, Quantity,UnitPrice, TotalPrice,Check__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId =:Opp.Id];
        
        return OLIlist2;
        
    }*/
    /*public PageReference saveIt() {
        // List<OpportunityLineItem> listOLI = getOLIs();
        
        update OLIlist2;
        
        return null;
        
    }*/
}