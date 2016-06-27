@isTest
public class Test_Session_trigger {

	static testMethod void sessionTest(){
		
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
		Capacity__c = 30,
		Event_Date__c = date.today()+ 14,
		Registration_Deadline__c = date.today()+7);
		insert e;
		
		Session__c s = new Session__c(
		Name = 'Test Session 1',
		Event__c = e.Id,
		Start__c = datetime.now(),
		End__c = datetime.now().addHours(1),
		Seats_Available__c = 30);
		insert s;
		
		Session_Attendee__c sa = new Session_Attendee__c(
		Session__c = s.Id,
		Contact__c = c.Id);
		insert sa;
		
		Session_Attendee__c sa2 = new Session_Attendee__c(
		Session__c = s.Id,
		Contact__c = c.Id);
		insert sa2;
		
		System.assertEquals(1, [select Attendees__c from Event__c where Id = :e.Id].Attendees__c);
		
		sa2.Canceled__c = true;
		update sa2;
		
		delete s;
		
		System.assertEquals(0, [select Attendees__c from Event__c where Id = :e.Id].Attendees__c);

	}
}