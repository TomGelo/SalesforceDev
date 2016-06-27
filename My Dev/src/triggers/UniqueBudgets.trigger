trigger UniqueBudgets on Budget__c (after insert, after update) {
	
	Budget__c[] otherBudgets = new Budget__c[]{};
	Account[] accountUpdate = new Account[]{};
	
	for(Budget__c thisBudget : trigger.new){
			
		if(thisBudget.Account__c != null && thisBudget.Year__c != null){
				
			otherBudgets = [select Id
							from Budget__c
							where Account__c = :thisBudget.Account__c
							and Year__c = :thisBudget.Year__c];

			if(otherBudgets.size()>0){
					
				if((trigger.isInsert && otherBudgets[0].Id != thisBudget.Id) ||
				   (trigger.isUpdate && trigger.oldMap.get(thisBudget.Id).Year__c != thisBudget.Year__c))
						thisBudget.Year__c.addError('A budget record for this year currently exists.');
				else if(thisBudget.Active__c == 1) {
					Account acct = new Account(Id = thisBudget.Account__c);
					acct.Total_Budget__c = thisBudget.Total_Budget__c;
					acct.Total_Expense__c = thisBudget.Total_Expenses__c;
				
					accountUpdate.add(acct);
				}				
			}
		} 
	}
	
	if(accountUpdate.size()>0){
		try{
			update accountUpdate;
		}
		catch (System.DmlException e) {
    		for (Integer i = 0; i < e.getNumDml(); i++) {
      			 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
	    	}
		}
	}
}