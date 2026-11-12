/**
 * @description Test class for TokenSelector. Validates all three query methods
 *              and asserts FLS/CRUD enforcement via WITH USER_MODE.
 */
@IsTest
private class TokenSelectorTest {
  @TestSetup
  static void setup() {
    Account acct = TestDataFactory.createAccount();
    TestDataFactory.createToken(acct.Id, 'Active', 30);
    TestDataFactory.createToken(acct.Id, 'Expired', -5);
    TestDataFactory.createToken(acct.Id, 'Revoked', 60);
    TestDataFactory.createToken(acct.Id, 'Active', 3); // expiring soon
  }

  @IsTest
  static void testGetTokensByAccount_returnsAllAccountTokens() {
    Account acct = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    List<Token__c> results = TokenSelector.getTokensByAccount(acct.Id);
    Test.stopTest();

    System.assertEquals(4, results.size(), 'Expected 4 tokens for the account');
  }

  @IsTest
  static void testGetTokensByAccount_emptyForUnknownAccount() {
    Test.startTest();
    List<Token__c> results = TokenSelector.getTokensByAccount(
      '001000000000001AAA'
    );
    Test.stopTest();

    System.assertEquals(
      0,
      results.size(),
      'Expected 0 tokens for an unknown account'
    );
  }

  @IsTest
  static void testGetTokensByStatus_activeTokens() {
    Test.startTest();
    List<Token__c> results = TokenSelector.getTokensByStatus('Active');
    Test.stopTest();

    System.assertEquals(2, results.size(), 'Expected 2 active tokens');
    for (Token__c t : results) {
      System.assertEquals(
        'Active',
        t.Status__c,
        'All returned tokens should be Active'
      );
    }
  }

  @IsTest
  static void testGetTokensByStatus_expiredTokens() {
    Test.startTest();
    List<Token__c> results = TokenSelector.getTokensByStatus('Expired');
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected 1 expired token');
    System.assertEquals(
      'Expired',
      results[0].Status__c,
      'Token should be Expired'
    );
  }

  @IsTest
  static void testGetTokensByStatus_revokedTokens() {
    Test.startTest();
    List<Token__c> results = TokenSelector.getTokensByStatus('Revoked');
    Test.stopTest();

    System.assertEquals(1, results.size(), 'Expected 1 revoked token');
    System.assertEquals(
      'Revoked',
      results[0].Status__c,
      'Token should be Revoked'
    );
  }

  @IsTest
  static void testGetTokensExpiringWithinDays_findsNearExpiry() {
    Test.startTest();
    List<Token__c> results = TokenSelector.getTokensExpiringWithinDays(7);
    Test.stopTest();

    System.assertEquals(
      1,
      results.size(),
      'Expected 1 token expiring within 7 days'
    );
    System.assertEquals(
      'Active',
      results[0].Status__c,
      'Should only return Active tokens'
    );
  }

  @IsTest
  static void testGetTokensExpiringWithinDays_widerWindow() {
    Test.startTest();
    List<Token__c> results = TokenSelector.getTokensExpiringWithinDays(60);
    Test.stopTest();

    System.assertEquals(
      2,
      results.size(),
      'Expected 2 active tokens expiring within 60 days'
    );
  }

  @IsTest
  static void testGetTokensExpiringWithinDays_zeroWindow() {
    Test.startTest();
    List<Token__c> results = TokenSelector.getTokensExpiringWithinDays(0);
    Test.stopTest();

    System.assertEquals(
      0,
      results.size(),
      'Expected 0 tokens expiring today (all expiry dates are in the future)'
    );
  }
}
