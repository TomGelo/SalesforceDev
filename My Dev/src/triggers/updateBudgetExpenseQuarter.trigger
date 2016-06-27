trigger updateBudgetExpenseQuarter on Expense__c (after insert, after update, after delete) {
	
	Budget__c[] budgetUpdate = new Budget__c[]{};
	Set<Id> budgets = new Set<Id>{};
	
	if(trigger.isDelete){
		for(Expense__c thisExpense : trigger.old){
			budgets.add(thisExpense.Budget__c);
		}
	}
	else{
		for(Expense__c thisExpense : trigger.new){
			
			budgets.add(thisExpense.Budget__c);
			
		}
	}
	
	for(Budget__c thisBudget : [select Id, Q1_Expenses__c, Q2_Expenses__c, Q3_Expenses__c, Q4_Expenses__c,
								(select Id, Date__c, Amount__c
								 from Expenses__r)
								from Budget__c
								where Id in :budgets]){
		
		thisBudget.Q1_Expenses__c = 0;
		thisBudget.Q2_Expenses__c = 0;
		thisBudget.Q3_Expenses__c = 0;
		thisBudget.Q4_Expenses__c = 0;		
									
		for(Expense__c thisExpense : thisBudget.Expenses__r){
			
			Integer month = thisExpense.Date__c.month();	
			
			if(month == 1 || month == 2 || month == 3)
				thisBudget.Q1_Expenses__c += thisExpense.Amount__c;
			else if(month == 4 || month == 5 || month == 6)
				thisBudget.Q2_Expenses__c += thisExpense.Amount__c;
			else if(month == 7 || month == 8 || month == 9)
				thisBudget.Q3_Expenses__c += thisExpense.Amount__c;
			else if(month == 10 || month == 11 || month == 12)
				thisBudget.Q4_Expenses__c += thisExpense.Amount__c;
					
		}
		budgetUpdate.add(thisBudget);
	
	}
	
	if(budgetUpdate.size()>0){
		try{
			update budgetUpdate;
		}
		catch (System.DmlException e) {
    		for (Integer i = 0; i < e.getNumDml(); i++) {
      			 ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getDmlMessage(i)));
	    	}
		}
	}
}