public class doController {

  private final Account account;

      public doController() {
            account = [select id, name, site from Account limit 1];
      }

      public Account getAccount() {
            return account;
      }
  
}