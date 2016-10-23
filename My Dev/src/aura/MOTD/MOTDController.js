({
	myAction : function(component, event, helper) {
		var dateFormat = "EEEE";
var userLocaleLang = $A.get("$Locale.langLocale");
component.set("v.DayOfTheWeek",$A.localizationService.formatDate(new Date(), dateFormat, userLocaleLang));
        
	}
})