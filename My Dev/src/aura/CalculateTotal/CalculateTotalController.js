({
	calculate : function(component, event, helper) {
		var inputOne = component.find("inputOne").get("v.value");
        var inputTwo = component.find("inputTwo").get("v.value");
        var inputThree = component.find("inputThree").get("v.value");
        var output = component.find("totalValue").get("v.value");

        
        output.set("v.value", parseInt(inputOne) + parseInt(inputTwo) + parseInt(inputThree))
	}
})