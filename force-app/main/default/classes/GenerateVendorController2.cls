public class GenerateVendorController2 {

    public List<OpportunityLineItem> oliList {get ;set;}
    public List<OrderVendor> myList {get ;set;}

    public String actualKeyValue {get;set;}

    public GenerateVendorController2() {
        oliList = [Select Name, ID, Quantity, UnitPrice, TotalPrice, Style__c, OpportunityId, A_C__c,V__c,H__c,Rpt__c,A_O__c,Vendor__c,
                    S_P__c,Size__c,Description,By__c,Vendor_description__c
                    FROM OpportunityLineItem];

        myList = new List<OrderVendor>();
    }

    public void searchQuantity(){
        System.debug('Hola');
        System.debug(actualKeyValue);
        Integer pos = Integer.valueOf(actualKeyValue);
        List<Product2> auxProducts = [select Name 
                                        from Product2 
                                        where ProductCode =: myList[pos].style.CAG_SKU__c limit 1];
        AggregateResult resultados = [select sum(Quantity) suma
                                        from OpportunityLineItem
                                        where Product2.ProductCode =: myList[pos].style.CAG_SKU__c
                                            and Opportunity.IsClosed = false and Product2.ProductCode<>''];
        System.debug(resultados.get('suma'));
        myList[pos].style.Quantity__c = (Decimal)resultados.get('suma');
        if(auxProducts.size()>0) myList[pos].style.Name = auxProducts[0].Name;
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
                                                Aux_Purchase__c=ov.po.Vendor__c));
            }
        }

        insert poInsert.values();

        for(Style__c sty : stylesInsert){
            sty.Purchase_Order__c = poInsert.get(sty.Aux_Purchase__c).Id;
        }

        insert stylesInsert;
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
}