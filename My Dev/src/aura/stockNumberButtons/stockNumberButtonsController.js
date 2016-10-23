({
    searchKeyChange: function(component, event, helper) {
        var myEvent = $A.get("e.c:stockNumberSearchKeyChange");
        myEvent.fire();
    },
    
    handleSearchKeyChange: function(component, event, helper){
        component.set("v._label", 'Continue');
    }
})