public class clsRemakeOrder {
	
    //agregar una Instancia para el Standard Controller 
    private ApexPages.StandardController controller {get; set;}
    //Agrega la instancia para las variables que son pasadas por id en la url
    Opportunity opp {get; set;}
    //Se usa para asignar/mantener el nuevo id creado en Opp  
    public ID newRecordId {get; set;}
    

    public clsRemakeOrder(ApexPages.StandardController controller){
    	
        this.controller=controller;
        opp=(Opportunity)controller.getRecord();        
    }
    
    //Metodo llamado desde la VF action
    public PageReference cloneOpportunityRemake(){
   
        //Configurar el punto de guardado para la reversion
        Savepoint sp=Database.setSavepoint();
        Opportunity newOpp;
        
        try{
            //Copiar la Opportunidad-Incluir los campos que deseas clonar
         	opp=[Select id,Name,AccountId,Type,Loss_Reason__c,Remade__c, Contact__c,Date_Logged__c,Invoice__c,
                 PO__c,Reference__c,Hand_Delivery__c, Special_price__c, Send_Artwork_for_Approval__c,	
                 CAG_New_Order__c, Order_Date__c, OwnerId, Designer__c, CloseDate, StageName,Probability,
                 Amount, Sales_Rep__c, Nally_Order__c, Paid__c, Bill__c, No_Cost__c	,Ship__c,Ship_To__c,Pickup__c,
                 Is_shipping_the_same_for_all_products__c,
                 NextStep,PO_to_Follow__c,
                 Description, Layout__c,Graphic__c,Budget_Confirmed__c,ContractId,
                 Discovery_Completed__c, ExpectedRevenue, ForecastCategoryName, H_D__c,LeadSource,
                 IqScore, P_U__c,Pricebook2Id,CampaignId,IsPrivate,TotalOpportunityQuantity, ROI_Analysis_Completed__c,
                 SHIP_WT_PRICE__c,SyncedQuoteId from Opportunity where Id=:opp.Id];
           
            //NuevaOpportunidad
            newOpp=opp.clone(false);
            newOpp.Order_Type__c='Remake';
            newOpp.Origin_Order__c=opp.Id;
            newOpp.Date_Logged__c=date.today();
            newOpp.CloseDate=date.today()+15;
           	newOpp.Remake__c=true;
            newOpp.RecordTypeId='0124W0000006uAKQAY';
            insert newOpp;
            
            //Setear el nuevo Id de la Opp a la variable newRecordId
            newRecordId=newOpp.Id;
            
            //Relacion con Products
            List<OpportunityLineItem> items=new List<OpportunityLineItem>();
  
            for(OpportunityLineItem pdd :[Select p.OpportunityId,p.Product2Id,p.UnitPrice, p.Quantity,p.By__c, p.S_P__c, 
                                          p.A_C__c,p.Description,p.Graphics__c, p.ServiceDate,p.ProductCode, p.ListPrice,
                                          p.Ship_To__c, p.Style__c, p.Size__c, p.Shipping_Street__c, p.Shipping_City__c, p.Shipping_State__c, 
                                          p.Shipping_Postal_Code__c, p.PricebookEntryId from OpportunityLineItem p where OpportunityId =:opp.Id ]){  
                
                OpportunityLineItem newOli = pdd.clone(false);
                newOli.Opportunityid=newOpp.id;
                
                items.add(newOli);
            }
            if(items.size()>0){
                insert items;
            }
           
            
            //Relacion con ContactRoles
             List<OpportunityContactRole> itemsCR=new List<OpportunityContactRole>();
  
            for(OpportunityContactRole ocr :[Select ContactId,OpportunityId, IsPrimary,Role from OpportunityContactRole where OpportunityId =:opp.Id ]){
            	  
                OpportunityContactRole newOct = ocr.clone(false);
                newOct.OpportunityId=newOpp.id;
                itemsCR.add(newOct);
            }
           
             if(itemsCR.size()>0){
                insert itemsCR;
            }
            
            

    
            for(ContentDocumentLink file: [SELECT id,ContentDocumentID,ShareType, Visibility from ContentDocumentLink WHERE LinkedEntityId=:opp.Id]){
                
                 ContentVersion VersionListold = [select Title,Description,VersionData,PathOnClient,ContentBodyId,Proof__c from ContentVersion where ContentDocumentId= :file.ContentDocumentID ];
                
                 ContentVersion VersionListnew=new ContentVersion();
                
                VersionListnew.Title=VersionListold.Title;
                VersionListnew.Description=VersionListold.Description;
                VersionListnew.Proof__c=VersionListold.Proof__c;
                VersionListnew.PathOnClient=VersionListold.PathOnClient;
                VersionListnew.VersionData=VersionListold.VersionData;
                VersionListnew.FirstPublishLocationId=newOpp.Id;
                
                if(VersionListnew.Title !=null){
                 	insert VersionListnew;
                }
            }
            
                           
        }catch(Exception e){
            System.debug('Error'+e);
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/'+newOpp.Id);
   }
}