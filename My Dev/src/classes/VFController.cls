public class VFController {
 
    // Constructor - this only really matters if the autoRun function doesn't work right
	
	public VFController(ApexPages.StandardController controller) {  
    	this.controller = controller;  
    }
    
public PageReference getRedir() {   
   
         Lead l = [select id, Status from Lead where Id = :ApexPages.currentPage().getParameters().get('id')];  
   
         PageReference newPage;  
         
         if (l.id == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
         }  
   		 else{
   		 	
   		 	l.Status = 'Open - Not Contacted';
            update l;
         }  
   
         newPage = new PageReference('/' + l.id);  
         newPage.getParameters().put('nooverride', '1');   
         newPage.getParameters().put('id', l.id);  
         return newPage.setRedirect(true);          
   
     }
 private final ApexPages.StandardController controller;     
}