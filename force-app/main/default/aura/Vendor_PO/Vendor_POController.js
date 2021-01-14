({
    doInit : function(component, event, helper) {
        var action = component.get("c.getOportunityVendor");
        action.setParams({
            "oppId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var opp = response.getReturnValue();
            component.set("v.lstOrders", opp);
        });
        
        var actionDocuments = component.get("c.lstDocuments");
        actionDocuments.setParams({
            "oppId" : component.get("v.recordId")
        });
        actionDocuments.setCallback(this,function(response){
            var lstDocImg = response.getReturnValue();
            component.set("v.lstContentVersion",lstDocImg);
        });
        
        $A.enqueueAction(action);
        $A.enqueueAction(actionDocuments);
    }
    
    /*myAction : function(component, event, helper) {
		
	}*/
})