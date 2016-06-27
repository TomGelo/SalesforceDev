public class eventRegistrationController {
    
    public final Contact c {get;set;}
    public Map<Id, Session__c[]> eventSessions {get;set;}
    public String eventId {get;set;}
    public String[] sessionId {get;set;}
    
    
    public eventRegistrationController(ApexPages.StandardController controller){
        
        this.c = (Contact)controller.getRecord();  
        this.eventSessions = new Map<Id, Session__c[]>{};    
        this.sessionId = new String[]{};
    }
    
    public PageReference submit(){   
        
        Session_Attendee__c[] saToInsert = new Session_Attendee__c[]{};   
        Session_Attendee__c[] regSessions = new Session_Attendee__c[]{};
        
        if(sessionId.size()==0){
           ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one Session to register for this event.');
           ApexPages.addMessage(msg);
            return null;
        }
        
        regSessions = [select Id, Contact__r.Email
                       from Session_Attendee__c
                       where Session__r.Id in :sessionId];
        
        for(Session_Attendee__c thisContact : regSessions){
            
            if(thisContact.Contact__r.Email == c.Email){
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This Email address is already registerd for this Event.');
                 ApexPages.addMessage(msg);
                 return null;
            }
            
        }
        
        Contact[] thisContact = new Contact[]{};
        
        thisContact = [select Id, Email from Contact where Email = :c.Email limit 1];
        
        if(thisContact.size()==0){
            Contact newContact = c;
            insert newContact;
            
            thisContact.add(newContact);
        }
    
        for(String thisId : sessionId){
            
            Session_Attendee__c thisSA = new Session_Attendee__c();
            thisSA.Session__c = thisId;
            thisSA.Contact__c = thisContact[0].Id;
            
            saToInsert.add(thisSA);
        }
        
        if(saToInsert.size()>0){
            
            try{
                insert saToInsert;
                
                String eventName = [Select Name from Event__c where Id = :eventId].Name;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(thisContact[0].Id);
                mail.setSubject('Thank you for registering for ' + eventName);
                mail.setPlainTextBody('We hope you enjoy!');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                
            }catch (Exception ex){
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
                 ApexPages.addMessage(msg);
                 return null;
            }
                
        }
        
        return null;
    }
    
    public List<SelectOption> getEventDates() {
        
        Date isToday = date.today();
        SelectOption[] events = new SelectOption[]{};
        events.add(new SelectOption('', 'Select an Event...'));
        
        for(Event__c thisEvent : [select Id, Name, Event_Date__c, Venue__r.Name, Capacity__c, Attendees__c,
                                    (select Id, Start__c, End__c, Seats_Available__c, Attendees__c, Name from Sessions__r)
                                  from Event__c
                                  where Status__c = 'Active'
                                  and Registration_Deadline__c >= :isToday
                                  ]){
            
            if(thisEvent.Attendees__c < thisEvent.Capacity__c){
                
                Date eventDate = thisEvent.Event_Date__c;
                String thisDate =  eventDate.month() + '/' + eventDate.day() + '/' + eventDate.year();
                String label = thisDate + ' - ' + thisEvent.Name + ' - ' + thisEvent.Venue__r.Name; 
                
                events.add(new SelectOption(thisEvent.Id, label));
                
                if(thisEvent.Sessions__r.size()>0)
                    eventSessions.put(thisEvent.Id, thisEvent.Sessions__r);
                
            }
                                    
        }
        
        if(events.size()>0)
            return events;
        else return null;
        
    }
    
    public List<SelectOption> getSessionOptions() {
        
            System.debug(eventId);
            SelectOption[] sessions = new SelectOption[]{};
            
            if(eventId==null)
                return null;
                
            if(eventSessions.get(eventId).size() == 0){
                sessions.add(new SelectOption('', 'There are no Sessions available for this Event.'));
                return sessions;
            }
            
            for(Session__c thisSession : eventSessions.get(eventId)){
                
                if(thisSession.Attendees__c < thisSession.Seats_Available__c){
                
                    Datetime startDate = thisSession.Start__c;
                    Datetime endDate = thisSession.End__c;
                    
                    String startMinutes = ':' + startDate.minute();
                    String endMinutes = ':' + endDate.minute();
                    
                    if(startMinutes == ':0')
                        startMinutes = ':00';
                    
                    if(endMinutes == ':0')
                        endMinutes = ':00';
                    
                    String startTime = startDate.hour() + startMinutes;
                    String endTime = endDate.hour() + endMinutes;
                    String timeSpan = startTime + ' - ' + endTime;
                    
                    sessions.add(new SelectOption(thisSession.Id, timeSpan + ': ' + thisSession.Name));
                }
                
            }
            
            if(sessions.size()==0)
                sessions.add(new SelectOption('', 'All Sessions have been filled.'));
            
            
            return sessions;
                    
        
    }
    
    @isTest
    public static void eventRegistrationControllerTest() {
        
        Account a = new Account(Name = 'Test Account 1');
        insert a;
        
        Contact c = new Contact(
        FirstName = 'Tom',
        LastName = 'Gelo',
        Email = 'tom.gelo@gmail.com',
        AccountId = a.Id);
        insert c;
        
        Venue__c v = new Venue__c(
        Name = 'Test Venue 1',
        Capacity__c = 30,
        Address__c = 'Test Address');
        insert v;
        
        Event__c e = new Event__c(
        Name = 'Test Event 1',
        Event_Date__c = date.today()+ 14,
        Capacity__c = 30,
        Registration_Deadline__c = date.today()+7);
        insert e;
        
        Session__c s = new Session__c(
        Name = 'Test Session 1',
        Event__c = e.Id,
        Start__c = datetime.now(),
        End__c = datetime.now().addHours(1),
        Seats_Available__c = 30);
        insert s;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(c);        
        eventRegistrationController eventController = new eventRegistrationController(standardController); 
        eventController.getEventDates();
        eventController.getSessionOptions();
        
        eventController.eventId = e.Id;         
        
        eventController.sessionId.add(s.Id);
        eventController.submit();
        
        Contact contact = new Contact();
        contact.LastName = 'Gelo';
        contact.Email = 'testEmail@test.com';
        
        ApexPages.StandardController standardController2 = new ApexPages.StandardController(contact);        
        eventRegistrationController eventController2 = new eventRegistrationController(standardController2); 
        
        eventController2.eventId = e.Id; 
        eventController2.sessionId.add(s.Id);
        eventController2.submit();  

    }

}