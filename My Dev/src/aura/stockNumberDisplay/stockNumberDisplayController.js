({	
	doInit: function(cmp) {
        var hideTag = cmp.get("v.hideTag");
        var tagDiv = cmp.find("buyerTag");
       
        if(hideTag == "true"){
        	$A.util.addClass(tagDiv, 'slds-hide');
        }
    },
    
	searchKeyChange : function(component, event, helper) {
		 var searchKey = event.getParam("searchKey");
	}
})