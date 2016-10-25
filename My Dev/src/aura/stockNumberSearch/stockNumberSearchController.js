({
    searchKeyChange: function(component, event, helper) {
        var myEvent = $A.get("e.c:stockNumberSearchKeyChange"); 
        var spinner = component.find('spinner');
        
         if (event.getParams().keyCode === 13){
        	 $A.util.toggleClass(spinner, 'slds-hide');
        	 setTimeout(function(){
        	 
        		  var spinnerShow = component.find('spinner');
        		  $A.util.toggleClass(spinnerShow, 'slds-hide');
        		  myEvent.setParams({"searchKey": component.find("search").get("v.value")});
        		  myEvent.fire();
        		 
         	 }, 2000);
         }
    },
    
    handleSearchKeyChange: function(component, event, helper){
        var icon = component.find('icon');
        $A.util.toggleClass(icon, 'slds-hide');
    }
})