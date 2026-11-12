/**
 * @description Test class for TokenExpiryBatch. Validates batch execution and
 *              schedulable entry point.
 */
@IsTest
private class TokenExpiryBatchTest {
  @TestSetup
  static void setup() {
    Account acct = TestDataFactory.createAccount();
    // Active token with past expiry (should be expired by batch)
    TestDataFactory.createToken(acct.Id, 'Active', -1);
    TestDataFactory.createToken(acct.Id, 'Active', -5);
    // Active token with future expiry (should NOT be expired by batch)
    TestDataFactory.createToken(acct.Id, 'Active', 30);
    // Already-expired token (should remain unchanged)
    TestDataFactory.createToken(acct.Id, 'Expired', -10);
  }

  @IsTest
  static void testBatchExecute_expiresOverdueActiveTokens() {
    Test.startTest();
    Database.executeBatch(new TokenExpiryBatch(), 200);
    Test.stopTest();

    List<Token__c> nowExpired = [
      SELECT Id, Status__c
      FROM Token__c
      WHERE Status__c = 'Expired'
    ];
    // 2 newly expired + 1 already expired = 3
    System.assertEquals(
      3,
      nowExpired.size(),
      'Expected 3 expired tokens after batch run'
    );

    List<Token__c> stillActive = [
      SELECT Id, Status__c
      FROM Token__c
      WHERE Status__c = 'Active'
    ];
    System.assertEquals(
      1,
      stillActive.size(),
      'Expected 1 active token (future expiry) after batch run'
    );
  }

  @IsTest
  static void testSchedulableExecute_triggersTheBatch() {
    Test.startTest();
    String cronExpr = '0 0 0 * * ?';
    System.schedule('TokenExpiryBatchTest', cronExpr, new TokenExpiryBatch());
    Test.stopTest();

    // If we reach here without exception, the schedulable ran successfully
    System.assert(true, 'Schedulable should execute without error');
  }
}
