/**
 * @description Utility class for creating test data. Must not be deployed to
 *              production; annotated with @IsTest for safety.
 */
@IsTest
public class TestDataFactory {
  /**
   * @description Creates and inserts a test Account record.
   * @return Inserted Account record.
   */
  public static Account createAccount() {
    Account acct = new Account(Name = 'Test Account');
    insert acct;
    return acct;
  }

  /**
   * @description Creates and inserts a Token__c record.
   * @param accountId Id of the owning Account.
   * @param status    Status__c picklist value (Active, Expired, Revoked).
   * @param daysUntilExpiry Positive days in the future, negative for past dates.
   * @return Inserted Token__c record.
   */
  public static Token__c createToken(
    Id accountId,
    String status,
    Integer daysUntilExpiry
  ) {
    Token__c token = new Token__c(
      Owner_Account__c = accountId,
      Status__c = status,
      Issued_Date__c = Date.today().addDays(-1),
      Expiry_Date__c = Date.today().addDays(daysUntilExpiry),
      Scope__c = 'read:all'
    );
    insert token;
    return token;
  }
}
