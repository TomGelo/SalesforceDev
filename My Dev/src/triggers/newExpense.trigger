trigger newExpense on Expense__c (before insert, before update) {
	
	Id[] accounts = new Id[]{};
	Id[] moreaccounts = new Id[]{};
	Map<Id, Budget__c> budgetAccounts = new Map<Id, Budget__c>();
	
	for(Expense__c expense : trigger.new){
		
		accounts.add(expense.Account__c);
		
	}
	
	if(accounts.size()>0){
		
		for(Budget__c budget : [select Id, Account__c, Year__c from Budget__c where Account__c in :accounts and Active__c = 1]){
			
			budgetAccounts.put(budget.Account__c, budget);
			
		}
		
	}
	
	for(Expense__c expense : trigger.new){
		
		Budget__c thisBudget = new Budget__c();
		String year = String.valueOf(expense.Date__c.year());
		
		if(budgetAccounts.containsKey(expense.Account__c)){
			
			thisBudget = budgetAccounts.get(expense.Account__c);
			
			if(thisBudget.Year__c == year){
				
				if(expense.Budget__c == null)
					expense.Budget__c = thisBudget.Id;
				
			}
			else expense.Budget__c.addError('Only Expenses for the current year can be entered at this time.');
		}
		
	}
}