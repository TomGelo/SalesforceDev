({
    searchKeyChange: function(component, event, helper) {
        var myEvent = $A.get("e.c:stockNumberSearchKeyChange"); 
        
        if (event.getParams().keyCode === 13){
        	myEvent.setParams({"searchKey": component.find("search").get("v.value")});
        	myEvent.fire();
    	}
        
    },
    
    handleSearchKeyChange: function(component, event, helper){
        var icon = component.find('icon');
        $A.util.removeClass(icon, 'slds-hide');
        $A.util.addClass(icon, 'slds-show');
    }
})