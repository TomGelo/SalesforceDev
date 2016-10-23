({
    getCase: function(cmp){
        var action = cmp.get("c.getCaseFromId");
        action.setParams({
            "caseId":null
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.record", response.getReturnValue());
            }
        });
	 $A.enqueueAction(action);
    }
})