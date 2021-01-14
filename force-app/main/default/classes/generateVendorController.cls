public with sharing class generateVendorController {
    
    public List<OpportunityLineItem> oliList {get ;set;}
    public List<OrderVendor> myList {get ;set;}
    public String actualKeyValue {get;set;}
    
    
    public String searchKey {get;set;}
    public Contact contact {get;set;}
    public Boolean displayContactPopUp {get;set;}
    public List<Contact> lstContactSelected{get;set;}
    public List<Contact> lstAllContact{get;set;}
    public Static Id contactId {get;set;}

    public generateVendorController() {
        oliList = [Select Name, ID, Quantity, UnitPrice, TotalPrice, Style__c, OpportunityId, A_C__c,V__c,H__c,Rpt__c,A_O__c,Vendor__c,
                    S_P__c,Size__c,Description,By__c,Vendor_description__c
                    FROM OpportunityLineItem];

        myList = new List<OrderVendor>();
    }

    public void searchQuantity(){
        System.debug('Hola');
        System.debug(actualKeyValue);
        Integer pos = Integer.valueOf(actualKeyValue);
        List<Product2> auxProducts = [select id, Name 
                                        from Product2 
                                        where ProductCode =: myList[pos].style.CAG_SKU__c limit 1];
        AggregateResult resultados = [select sum(Quantity) suma
                                        from OpportunityLineItem
                                        where Product2.ProductCode =: myList[pos].style.CAG_SKU__c
                                            and Opportunity.IsClosed = false and Product2.ProductCode<>''];
        System.debug(resultados.get('suma'));
        myList[pos].style.Quantity__c = (Decimal)resultados.get('suma');
        if(auxProducts.size()>0){
			myList[pos].style.Name = auxProducts[0].Name;
            myList[pos].style.Product__c = auxProducts[0].id;
        }
        System.debug('Chau');
    }

    public PageReference addItem() {
        OrderVendor auxOV = new OrderVendor();
        auxOV.key = String.valueOf(myList.size());
        auxOV.style = new Style__c(Name='Aquí se hará la búsqueda');
        auxOV.po = new Purchase_Order__c();
        myList.add(auxOV);
        return null;
    }

    public void saveAction(){
        Map<String, Purchase_Order__c> poInsert = new Map<String, Purchase_Order__c>();
        List<Style__c> stylesInsert = new List<Style__c>();

        for(OrderVendor ov : myList){
            if(ov.style.Quantity__c!=null && ov.style.Quantity__c>0 && ov.po.Vendor__c!=null){
                poInsert.put(ov.po.Vendor__c, ov.po);
                stylesInsert.add(new Style__c(Name=ov.style.Name,
                                                CAG_SKU__c=ov.style.CAG_SKU__c,
                                                Description__c=ov.style.Description__c,
                                                Quantity__c=ov.style.Quantity__c,
                                                Aux_Purchase__c=ov.po.Vendor__c,
                                             	Product__c = ov.style.Product__c));
            }
        }

        insert poInsert.values();

        Map<String,String> mapPOProduct = new Map<String,String>();
        List<String> lstIdProd = new List<String>();
        
        for(Style__c sty : stylesInsert){
            sty.Purchase_Order__c = poInsert.get(sty.Aux_Purchase__c).Id;
            
            //Map Product And Purchase Order
            mapPOProduct.put(sty.Product__c,sty.Purchase_Order__c);
        }

        insert stylesInsert;
        
        //Add files from Products to Purchase Order
        List<ContentVersion> lstContent = [Select id, FirstPublishLocationId, ContentDocumentId From ContentVersion Where FirstPublishLocationId IN :mapPOProduct.keySet()];
        
        List<ContentDocumentLink> lstFilesProducts = new List<ContentDocumentLink>();
        For(ContentVersion version:lstContent){
            ContentDocumentLink obj = new ContentDocumentLink();
            obj.ContentDocumentId =version.ContentDocumentId;
            obj.LinkedEntityId = mapPOProduct.get(version.FirstPublishLocationId);
            obj.ShareType ='V';
            obj.Visibility  ='AllUsers';
            lstFilesProducts.add(obj);
        }
        
        insert lstFilesProducts;
    }

    public PageReference save(){
        saveAction();
        PageReference tempPage = ApexPages.currentPage();            
        tempPage.setRedirect(true);
        return tempPage;
    }

    public class OrderVendor {
        public String key { get; set;}
        public Integer qty { get; set;}
        public Style__c style { get; set;}
        public Purchase_Order__c po { get; set;}
    }
    
    
    /*MODAL SELECCTION CONTACT CODE*/
    public PageReference closePopup() {
        displayContactPopUp = false;
        return null;
    }
    
    public PageReference showPopup() {
        //string ids=apexpages.currentpage().getparameters().get('window');
        lstAllContact =[select Name from Contact];  //where id=:ids];
        displayContactPopUp=true;
        return null;
    }
    
    public void search(){
        string searchquery='select Name,id from contact where name like \'%'+searchKey+'%\' Limit 10';
        lstAllContact= Database.query(searchquery);
    }
    public void clear(){
        lstAllContact.clear();
    }
              
    public PageReference onRowClick(){
        System.debug('DO SOME ACTION: '+ contactId);
        
        OrderVendor auxOV = new OrderVendor();
        auxOV.key = String.valueOf(myList.size());
        auxOV.style = new Style__c(Name='Aquí se hará la búsqueda');
        auxOV.po = new Purchase_Order__c();
        auxOV.po.Vendor__c = contactId;
        myList.add(auxOV);
        Return null;
    }

}