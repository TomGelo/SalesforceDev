public global with sharing class CalendarController {

	public static Contact[] contacts { get; set; }
	public static Shift__c[] shifts { get; set; }
	
	public CalendarController() {}
	
	@RemoteAction
	global static Contact[] getContacts(){
		
		contacts =  [select Name, Id from Contact limit 10];
		return contacts;
		
		
	}
	
	@RemoteAction
	global static Shift__c[] getShifts(String visStart, String visEnd){
		
		Datetime startTime = datetime.valueOf(visStart.replace('T',' '));
		Datetime endTime = datetime.valueOf(visEnd.replace('T',' '));
		shifts =  [select Id, Start__c, End__c, Employee__r.Name 
				   from Shift__c
				   where Start__c >= :startTime
				   and End__c <= :endTime];
		return shifts;
		
		
	}
	
	@RemoteAction 
	global static String insertEvent(String eventStart, string eventEnd,  string employee){
		
		Shift__c shift = new Shift__c();
		shift.Start__c = datetime.valueOf(eventStart.replace('T',' '));
		shift.End__c = datetime.valueOf(eventEnd.replace('T',' '));
		shift.Employee__c = employee;
		
		insert shift;
		
        return shift.Id;
					
	}
	
	@RemoteAction 
	global static Boolean updateEvent(String eventStart, string eventEnd,  string event){
	
		Shift__c shift = new Shift__c(Id = event);
		shift.Start__c = datetime.valueOf(eventStart.replace('T',' '));
		shift.End__c = datetime.valueOf(eventEnd.replace('T',' '));
		
		update shift;
		
        return true;
	}
	
	@RemoteAction 
	global static Boolean deleteEvent(string event){
	
		Shift__c shift = new Shift__c(Id = event);
		
		delete shift;
		
        return true;
	}
}