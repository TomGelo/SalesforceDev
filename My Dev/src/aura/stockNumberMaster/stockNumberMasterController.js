({
	searchKeyChange : function(component, event, helper) {
		var searchKey = event.getParam("searchKey");
       	var shTarget = component.find('stockDisplay');
        $A.util.removeClass(shTarget, 'slds-hide');
        $A.util.addClass(shTarget, 'slds-show');
        
        var searchButton = component.find('stockSearchSubmit');
        console.log(searchButton);
	}
})