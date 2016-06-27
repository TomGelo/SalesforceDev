trigger sessionTrigger on Session__c (after delete, after update) {

	Set<Id> events = new Set<Id>{};
	Map<Id, Id[]> eventLists = new Map<Id, Id[]>{};
	Event__c[] eventsToUpdate = new Event__c[]{};
	Session_Attendee__c[] saToDelete = new Session_Attendee__c[]{};
	Id[] emptyList = new Id[]{};

	if(trigger.isUpdate){
		for(Session__c session : trigger.new){
			events.add(session.Event__c);
			eventLists.put(session.Event__c, emptyList);
		}
	}
	
	if(trigger.isDelete){
		for(Session__c session : trigger.old){
			events.add(session.Event__c);
			eventLists.put(session.Event__c, emptyList);
		}
	}
	
	System.debug(events.size());
	
	for(Session__c thisSession : [select Id, eventid__c, Event__c,
								 	(select Id, Contact__c, Canceled__c from Session_Attendees__r)
								  from Session__c
								  where Event__c IN :events]){
								  	
		Id[] uniqueContacts = new Id[]{};
		Id[] thisEventList = new Id[]{};
		Session_Attendee__c[] thisSessionAttendees = new Session_Attendee__c[]{};
		
		thisSessionAttendees = thisSession.Session_Attendees__r; 			
		
		System.debug('Session Attendees: ' + thisSession.Session_Attendees__r.size());
		
		if(thisSessionAttendees.size()==0){
			
			Event__c thisEvent = new Event__c(Id = thisSession.Event__c);
			thisEvent.Attendees__c = 0;		
			
		}
		else {
			for(Session_Attendee__c thisSa: thisSessionAttendees){
				
				if(thisSa.Canceled__c == false)
					uniqueContacts.add(thisSa.Contact__c);
				else saToDelete.add(thisSa);
				
			}
			
			thisEventList = eventLists.get(thisSession.Event__c);
			thisEventList.addAll(uniqueContacts);
				
			eventLists.put(thisSession.Event__c, thisEventList);	
		}
	}
	
	for(Id eventId : eventLists.keySet()){
		
		Set<Id> deDupe = new Set<Id>{};
		Event__c thisEvent = new Event__c(Id = eventId);
		
		if(eventLists.get(eventId).size()==0)
			thisEvent.Attendees__c = 0;
		else{
			deDupe.addAll(eventLists.get(eventId));
			thisEvent.Attendees__c = deDupe.size();
			System.debug('Event Attendees: ' + deDupe.size());
		}
		
		eventsToUpdate.add(thisEvent);
		
	}
	
	if(eventsToUpdate.size()>0){
		update eventsToUpdate;
	}
	
	if(saToDelete.size()>0)
		delete saToDelete;
	
}