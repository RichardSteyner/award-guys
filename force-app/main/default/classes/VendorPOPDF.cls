public class VendorPOPDF {
    public Map<Id,Opportunity> mapOpportunity {get;set;}
    public Opportunity vendorOpp{get;set;}
    public Map<String, List<OpportunityLineItem>> mapOppLineItem{get;set;}
    public Map<String, List<ContentVersion>> mapContentVersion{get;set;}
    public Id RecordTypeID {get;set;}
    
    //public String actualKeyValue {get;set;}
    public String actualKeyValueProduct {get;set;}
    public String actualKeyValueFile {get;set;}
    
    /*public List<OpportunityLineItem> lstOppForVendor {get;set;}
    public List<ContentVersion> lstCVForVendor {get;set;}*/
    
    public VendorPOPDF(){
        /*lstOppForVendor = new List<OpportunityLineItem>();
        lstCVForVendor = new List<ContentVersion>();*/
    }
    public VendorPOPDF(ApexPages.StandardController initVFP){
    	vendorOpp = (Opportunity) initVFP.getRecord();
        vendorOpp = [Select id, name, PO__c, CAG_New_Order__c From Opportunity where id=:vendorOpp.id];
        RecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Customer Order').getRecordTypeId();
        
        /* TEST MAPS FOR ITERATION */
        // OPPORTUNITY LINE ITEM
        mapOpportunity = new Map<Id,Opportunity>([Select Id, name, PO__c, CAG_New_Order__c, Include_in_PDF__c From Opportunity 
                                                                      where PO__c=:vendorOpp.PO__c and RecordTypeId = :RecordTypeID]);//'0124W0000006uAKQAY'
        
        mapOppLineItem = new Map<String, List<OpportunityLineItem>>();
        List<OpportunityLineItem> lstOppLineItem;
        
        List<OpportunityLineItem> lstOLIAux = [Select id,OpportunityId, Product2.name, For_PDF__c From OpportunityLineItem where OpportunityId IN :mapOpportunity.keyset()];
        if(lstOLIAux.size()>0){
            for(OpportunityLineItem item: lstOLIAux){
                if(!mapOppLineItem.containsKey(item.OpportunityId)){
                    lstOppLineItem =  new List<OpportunityLineItem>();
                    lstOppLineItem.add(item);
                    mapOppLineItem.put(item.OpportunityId,lstOppLineItem);
                }else{
                    lstOppLineItem = mapOppLineItem.get(item.OpportunityId);
                    lstOppLineItem.add(item);
                    mapOppLineItem.put(item.OpportunityId,lstOppLineItem);
                }
            }
        }
        
        for(String key: mapOpportunity.keyset()){
            if(!mapOppLineItem.keySet().contains(key)){
                List<OpportunityLineItem> lstAux =  new List<OpportunityLineItem>();
                mapOppLineItem.put(key, lstAux);
            }
        }
       
		
        // ContentDocumentLink
		Set<id> lstContentID = new Set<id>();
        Map<String, List<String>> mapContentDocumentLink = new Map<String, List<String>>();
        List<String> lstContentDocumentLink;
        
        
		
        List<ContentDocumentLink> lstCDLAux = [SELECT Id, ContentDocumentId, LinkedEntityId
                                         FROM ContentDocumentLink WHERE LinkedEntityId IN :mapOpportunity.keyset()];
        
        
        system.debug('lstCDLAux: '+lstCDLAux);
        if(lstCDLAux.size()>0){
            for(ContentDocumentLink auxCDL: lstCDLAux){
                lstContentId.add(auxCDL.ContentDocumentId);
                
                if(!mapContentDocumentLink.containsKey(auxCDL.LinkedEntityId)){
                    lstContentDocumentLink =  new List<String>();
                    lstContentDocumentLink.add(auxCDL.ContentDocumentId);
                    mapContentDocumentLink.put(auxCDL.LinkedEntityId,lstContentDocumentLink);
                }else{
                    lstContentDocumentLink = mapContentDocumentLink.get(auxCDL.LinkedEntityId);
                    lstContentDocumentLink.add(auxCDL.ContentDocumentId);
                    mapContentDocumentLink.put(auxCDL.LinkedEntityId,lstContentDocumentLink);
                }
            }
        }        
        
        // ContentVersion
        mapContentVersion = new Map<String, List<ContentVersion>>();
        List<ContentVersion> lstContentVersion;
        
        List<ContentVersion> lstCVAux = [select id, Title,FileExtension, FileType, Proof__c ,ContentDocumentId
                                   from ContentVersion where ContentDocumentId IN :lstContentID ];
        if(lstCVAux.size()>0){
            for(ContentVersion item : lstCVAux){
                
                for(String key:mapContentDocumentLink.keySet() ){
                    lstContentDocumentLink = mapContentDocumentLink.get(key);
                    if(lstContentDocumentLink.contains(item.ContentDocumentId) ){
                        if(!mapContentVersion.containsKey(key)){
                            lstContentVersion =  new List<ContentVersion> ();
                            lstContentVersion.add(item);
                            mapContentVersion.put(key,lstContentVersion);
                        }else{
                            lstContentVersion = mapContentVersion.get(key);
                            lstContentVersion.add(item);
                            mapContentVersion.put(key,lstContentVersion);
                        }
                    }
                }
            }            
        }
        
        for(String key: mapOpportunity.keyset()){
            if(!mapContentVersion.keySet().contains(key)){
                List<ContentVersion> lstAux =  new List<ContentVersion>();
                mapContentVersion.put(key, lstAux);
            }
        }
        
        
        /* FIN TEST MAPS FOR ITERATION */
    }
    
    /*public void checkClickController(){
        system.debug('actualKeyValue: '+actualKeyValue);
        Opportunity opp = [Select id, Include_in_PDF__c From Opportunity where Id = :actualKeyValue];
        Opp.Include_in_PDF__c = !Opp.Include_in_PDF__c;
        system.debug('Opp: '+Opp);
        update Opp;  
    }*/
    
    public void checkClickProductController(){
        system.debug('actualKeyValueProduct: '+actualKeyValueProduct);
        OpportunityLineItem obj = [Select id, For_PDF__c From OpportunityLineItem where Id = :actualKeyValueProduct];
        obj.For_PDF__c = !obj.For_PDF__c;
        system.debug('obj: '+obj);
        update obj;
        
        
    }
    
    public void checkClickFileController(){
        system.debug('actualKeyValueFile: '+actualKeyValueFile);
        ContentVersion obj = [Select id, Proof__c From ContentVersion where Id = :actualKeyValueFile];
        obj.Proof__c = !obj.Proof__c;
        system.debug('obj: '+obj);
        update obj;
    }
    
    public PageReference saveRecords(){
      	system.debug('SAVE RECORDS');
        //CLEAR RECORDS FROM OpportunityLineItem IN VENDOR
        delete [Select Id From OpportunityLineItem where OpportunityId = :vendorOpp.Id];

        
        //CREATE ITEMS IN VENDOR
        List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();
        
        List<OpportunityLineItem> lstOppLineItemFor = [Select id,A_C__c,A_O__c,By__c,OpportunityId,PricebookEntryId,ServiceDate,Discount,For_PDF__c,Graphics__c,
                                                    H__c,Description,Product2Id,Quantity,Rpt__c,S_P__c,UnitPrice,Ship_To__c,Shipping_City__c,Shipping_Postal_Code__c,
                                                    Shipping_State__c,Shipping_Street__c,Size__c,Style__c,V__c,Vendor__c,Vendor_description__c
                                                    From OpportunityLineItem where OpportunityId IN :mapOpportunity.keyset() AND For_PDF__c = True];
        System.debug('lstOppLineItemFor: '+lstOppLineItemFor);
        System.debug('lstOppLineItemFor: '+lstOppLineItemFor.size());
        if(lstOppLineItemFor.size()>0){
            for(OpportunityLineItem item : lstOppLineItemFor){
                OpportunityLineItem newItem = new OpportunityLineItem();
                newItem.OpportunityId = vendorOpp.id;
                newItem.PricebookEntryId = item.PricebookEntryId;
                newItem.A_C__c = item.A_C__c;
                newItem.A_O__c = item.A_O__c;
                newItem.By__c = item.By__c;
                newItem.ServiceDate = item.ServiceDate;
                newItem.Discount = item.Discount;
                newItem.For_PDF__c = item.For_PDF__c;
                newItem.Graphics__c = item.Graphics__c;
                newItem.H__c = newItem.H__c;
                newItem.Description = item.Description;
                newItem.Product2Id = item.Product2Id;
                newItem.Quantity = item.Quantity;
                newItem.Rpt__c = item.Rpt__c;
                newItem.S_P__c = item.S_P__c;
                newItem.UnitPrice = item.UnitPrice;
                newItem.Ship_To__c = item.Ship_To__c;
                newItem.Shipping_City__c = item.Shipping_City__c;
                newItem.Shipping_Postal_Code__c = item.Shipping_Postal_Code__c;
                newItem.Shipping_State__c = item.Shipping_State__c;
                newItem.Shipping_Street__c = item.Shipping_Street__c;
                newItem.Size__c = item.Size__c;
                newItem.Style__c = item.Style__c;
                newItem.V__c = item.V__c;
                newItem.Vendor__c = item.Vendor__c;
                newItem.Vendor_description__c = item.Vendor_description__c;                
                
                lstOppLineItem.add(newItem);      
            }
            system.debug('lstOppLineItem: '+lstOppLineItem);
            system.debug('lstOppLineItem: '+lstOppLineItem.size());
            insert lstOppLineItem;
        }
        
        
        
        //CLEAR RECROS FROM ContentDocumentLink
        delete [Select id From ContentDocumentLink Where LinkedEntityId=:vendorOpp.Id];

        //RELACIONAR LOS FILES EN VENDOR
        List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
        List<Id> lstIdCV = new List<Id>();
        List<ContentVersion> lstCvToShare = new List<ContentVersion>();
           
        List<ContentVersion> lstCVAux = new List<ContentVersion>();
        
        if(mapContentVersion.size()>0){
            for (List<ContentVersion> collection : mapContentVersion.values()){
                lstCVAux.addAll(collection);
            }  

            for(ContentVersion item:lstCVAux){
                lstIdCV.add(item.Id);
            }
            lstCvToShare = [Select id, Proof__c,ContentDocumentId From ContentVersion where Id IN :lstIdCV AND Proof__c= true];
            
            if(lstCvToShare.size()>0){
                for(ContentVersion item : lstCvToShare){
                    ContentDocumentLink obj = new ContentDocumentLink();
                	obj.ContentDocumentId =item.ContentDocumentId;
                    obj.LinkedEntityId =vendorOpp.id;
                    obj.ShareType ='V';
                    obj.Visibility  ='AllUsers';
                    lstCDL.add(obj);
                }
                system.debug('lstCDL: '+lstCDL);
                system.debug('lstCDL: '+lstCDL.size());
                insert lstCDL;
            }
            
        }
        
        PageReference pr = new PageReference('/'+vendorOpp.Id);//Schema.SObjectType.Opportunity.getKeyPrefix()
        return pr;
    }
}