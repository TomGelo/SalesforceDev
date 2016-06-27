public class addSessionsController {
    
    public final Event__c e {get;set;}    
    public String[] listValues {get;set;}    
    public sessionRow[] newSessions {get;set;}
    public sessionRow session {get;set;}
    public Integer totalSeats {get;set;}
    public Session__c[] sessionsToInsert {get;set;}
 
    public addSessionsController(ApexPages.StandardController controller){        
        this.e = (Event__c)controller.getRecord();               
        this.newSessions = new sessionRow[]{};
        this.totalSeats = 0;
        this.sessionsToInsert = new Session__c[]{};
 
    } 
    
    public void addSession(){
        
        String startTime = ApexPages.currentPage().getParameters().get('startTime');
        String endTime = ApexPages.currentPage().getParameters().get('endTime');
        
        String[] returnStart = extractTime(startTime);
        String[] returnEnd = extractTime(endTime);
        
        sessionRow thisSession = new sessionRow();
        thisSession.startTime = returnStart[2];
        thisSession.endTime = returnEnd[2];
        thisSession.name = '';
        thisSession.capacity = 0;
       
        thisSession.startHours = Integer.valueOf(returnStart[0]);
        thisSession.startMinutes = Integer.valueOf(returnStart[1]);
        
        thisSession.endHours = Integer.valueOf(returnEnd[0]);
        thisSession.endMinutes = Integer.valueOf(returnEnd[1]);
        
        newSessions.add(thisSession);
    }
    
    public String[] extractTime(String stringTime){
        
        Integer hour = 8;
        Integer minute = 0;
        
        Integer intTime = integer.valueOf(stringTime);
        intTime = intTime * 15;
        while(intTime >= 60){
            intTime = intTime - 60;
            hour++;
        }
        minute=intTime;
        
        if(hour > 12)
            hour = hour - 12;
            
        String stringHour = String.valueOf(hour);
        String stringMinute;
        if(minute==0)
            stringMinute = '00';
        else stringMinute = String.valueOf(minute);
        
        String[] returnTime = new String[]{stringHour, stringMinute, stringHour + ':' + stringMinute};
        
        return returnTime;
        
    }
    
    public PageReference updateTotalSeats(){
        
        totalSeats = 0;
        
        for(sessionRow thisSession : newSessions){
            
            totalSeats = totalSeats + thisSession.capacity;
        }
        
        if(totalSeats > e.Capacity__c){
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, 'The total seats for your sessions are greater than the capacity of the event.  Please reduce the number of seats. '));
        }
                        
        return null;
    }
    
    public PageReference sessionSave(){
        
        String[] errors = new String[]{};
        Boolean noSeats = false;
        Boolean noName = false;
        
        if(newSessions.size()==0){
            errors.add('There must be at least one Session created for this Event');
        }
        
        if(totalSeats == 0)
            errors.add('There are no seats allocated for this Event.');
        
        for(sessionRow thisSession : newSessions){
            
            Date eventDate = e.Event_Date__c;
            
            Integer year = eventDate.year();
            Integer month = eventDate.month();
            Integer day = eventDate.day();
            
            if(thisSession.name == '')
                noName = true;
                
            if(thisSession.capacity == 0)           
                noSeats = true;
                
            Session__c newSession = new Session__c();
            newSession.Seats_Available__c = thisSession.capacity;
            newSession.Name = thisSession.name;
            newSession.Event__c = e.Id;
            newSession.Start__c = datetime.newInstance(
                year, month, day, thisSession.startHours, thisSession.startMinutes,0);
            newSession.End__c = datetime.newInstance(
                year, month, day, thisSession.endHours, thisSession.endMinutes,0);
            
            sessionsToInsert.add(newSession);           
        }
        
        if(noName)
            errors.add('All Sessions must have a Name.');
        
        if(noSeats)
            errors.add('All Sessions must have seats allocated.');
        
        if(errors.size()>0){
            
            for(String error : errors){
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
            return null;
        }
        else if(sessionsToInsert.size()>0){
            try{
                insert sessionsToInsert;
            }catch (Exception ex){
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
        }
        
        return goBack();
    }
    
    public PageReference goBack(){
        
        PageReference eventPage = new ApexPages.StandardController(e).view();
        eventPage.setRedirect(true);
        return eventPage;
    }
    
    public class sessionRow {
        
        public String startTime {get;set;}
        public String endTime {get;set;}
        public String name {get;set;}
        public Integer capacity {get; set;}
        public Integer startHours {get; set;}
        public Integer endMinutes {get; set;} 
        public Integer endHours {get; set;}
        public Integer startMinutes {get; set;}     
        
    }       
    
    @isTest
    public static void addSessionsControllerTest() {
        
        Account a = new Account(Name = 'Test Account 1');
        insert a;
        
        Contact c = new Contact(
        FirstName = 'Tom',
        LastName = 'Gelo',
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
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(e);        
        addSessionsController eventController = new addSessionsController(standardController); 
        
        //add values to mimic selection bar
        ApexPages.currentPage().getParameters().put('startTime', '0');
        ApexPages.currentPage().getParameters().put('endTime', '25');
        
        //attempt save expect failure - no Sessions created
        eventController.sessionSave();
        System.assertequals(true,ApexPages.hasMessages());
       
        //create Session
        eventController.addSession();
        
        //exceed capacity
        eventController.newSessions[0].capacity = 31;
        eventController.updateTotalSeats();
        System.assertequals(true,ApexPages.hasMessages());
        
        //correct capacity - supply name
        eventController.newSessions[0].capacity = 15;
        eventController.newSessions[0].name = 'Test Session 1';
        eventController.updateTotalSeats();

        eventController.sessionSave();
        
        //confirm insert
        System.assertEquals(1, [select count() from Session__c where Event__c = :e.id]);
        
        
    }
 
}