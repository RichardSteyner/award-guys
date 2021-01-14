public with sharing class VendorPOController {
    public ApexPages.StandardController sc;
    public Opportunity Opp {get;set;}
    public List<OpportunityLineItem> oliList {get ;set;}
    public List<ContentDocumentLink> images {get ;set;}
    public Contact contact {get;set;}

    //----------------------------------------------
    public List<Opportunity> oppsRelated {get; set;}
    public Map<Id, List<OpportunityLineItem>> olisRelated {get; set;}
    public List<OpportunityLineItem> olisRelatedTotal {get; set;}
    public Set<Id> oppRelatedIds {get; set;}
    
    public VendorPOController(ApexPages.StandardController sc) { 
        this.Opp = (Opportunity)sc.getRecord();
        Opportunity auxOpp = [Select Contact__c From Opportunity where Id=:Opp.Id];
        oliList = [Select Name, ID, Quantity, UnitPrice, TotalPrice, Style__c, OpportunityId, A_C__c,V__c,H__c,Rpt__c,A_O__c,Vendor__c,
                    S_P__c,Size__c,Description,By__c,Vendor_description__c
                    FROM OpportunityLineItem WHERE OpportunityId =:Opp.Id];
        
        /*images = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId,
ContentDocument.LatestPublishedVersion.Title
FROM ContentDocumentLink WHERE LinkedEntityId = :Opp.Id];*/

        contact = new Contact();
        if(auxOpp.Contact__c != null){
            contact = [Select Name, Phone, Email, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry From Contact where id=:auxOpp.Contact__c];
        }


        //--------------------------------------------------------------------------------------------
        /*String recordTypeOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Customer Order') != null ? Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Customer Order').getRecordTypeId() : null;
        
        oppsRelated = [select Id, Name,
                            Contact__r.Name, Contact__r.Phone, Contact__r.Email, Contact__r.MailingStreet,
                            Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode 
                        from Opportunity 
                        where PO__c =: Opp.PO__c and RecordTypeId =: recordTypeOpp and Include_in_PDF__c=true 
                        order by Name];

        oppRelatedIds = new Set<Id>();
        for(Opportunity opp : oppsRelated) oppRelatedIds.add(opp.Id);

        olisRelated = new Map<Id, List<OpportunityLineItem>>();
        List<OpportunityLineItem> auxOlis;
        olisRelatedTotal = new List<OpportunityLineItem>();
        for(OpportunityLineItem oli : [select Name, ID, Quantity, UnitPrice, TotalPrice, Style__c, 
                                            OpportunityId, A_C__c, V__c, H__c, Rpt__c, A_O__c, Vendor__c,
                                            S_P__c, Size__c, Description, By__c, Vendor_description__c
                                        FROM OpportunityLineItem 
                                        WHERE OpportunityId in: oppRelatedIds and For_PDF__c=true]){
                                            if(olisRelated.get(oli.OpportunityId)!=null){
                                                auxOlis = olisRelated.get(oli.OpportunityId);
                                                auxOlis.add(oli);
                                            }else{
                                                auxOlis = new List<OpportunityLineItem>();
                                                auxOlis.add(oli);
                                            }
                                            olisRelated.put(oli.OpportunityId, auxOlis);
                                            olisRelatedTotal.add(oli);
                                        }*/

        List<ContentDocumentLink> lstAux = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId,
                                            ContentDocument.LatestPublishedVersion.Title
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId =: Opp.Id];
        images = new List<ContentDocumentLink>();
        for(ContentDocumentLink aux : lstAux){
            /*ContentVersion cvAux = [select Proof__c from ContentVersion where ContentDocumentId= :aux.ContentDocumentId];
            if(cvAux.Proof__c){
                images.add(aux);
            }*/
            images.add(aux);
        }
        
    }
}