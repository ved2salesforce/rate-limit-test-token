/**
 * @description Test class for TokenService. Validates happy paths and error
 *              branches for issueToken, revokeToken, and expireToken.
 */
@IsTest
private class TokenServiceTest {
  @TestSetup
  static void setup() {
    Account acct = TestDataFactory.createAccount();
    TestDataFactory.createToken(acct.Id, 'Active', 30);
    TestDataFactory.createToken(acct.Id, 'Revoked', 30);
    TestDataFactory.createToken(acct.Id, 'Active', 60);
  }

  // ─── issueToken ──────────────────────────────────────────────────────────

  @IsTest
  static void testIssueToken_success() {
    Account acct = [SELECT Id FROM Account LIMIT 1];
    Date futureDate = Date.today().addDays(10);

    Test.startTest();
    Token__c result = TokenService.issueToken(acct.Id, futureDate, 'read:data');
    Test.stopTest();

    System.assertNotEquals(null, result.Id, 'Token should have been inserted');
    Token__c saved = [
      SELECT Status__c, Issued_Date__c, Expiry_Date__c, Scope__c
      FROM Token__c
      WHERE Id = :result.Id
    ];
    System.assertEquals(
      'Active',
      saved.Status__c,
      'New token should be Active'
    );
    System.assertEquals(
      Date.today(),
      saved.Issued_Date__c,
      'Issued date should be today'
    );
    System.assertEquals(
      futureDate,
      saved.Expiry_Date__c,
      'Expiry date should match input'
    );
    System.assertEquals(
      'read:data',
      saved.Scope__c,
      'Scope should match input'
    );
  }

  @IsTest
  static void testIssueToken_expiryDateToday_throwsException() {
    Account acct = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    try {
      TokenService.issueToken(acct.Id, Date.today(), 'read:data');
      System.assert(false, 'Expected AuraHandledException was not thrown');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage() != null,
        'Exception message should not be null'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void testIssueToken_expiryDateInPast_throwsException() {
    Account acct = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    try {
      TokenService.issueToken(acct.Id, Date.today().addDays(-1), 'read:data');
      System.assert(false, 'Expected AuraHandledException was not thrown');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage() != null,
        'Exception message should not be null'
      );
    }
    Test.stopTest();
  }

  // ─── revokeToken ─────────────────────────────────────────────────────────

  @IsTest
  static void testRevokeToken_activeToken_success() {
    Token__c activeToken = [
      SELECT Id
      FROM Token__c
      WHERE Status__c = 'Active'
      LIMIT 1
    ];

    Test.startTest();
    TokenService.revokeToken(activeToken.Id);
    Test.stopTest();

    Token__c updated = [
      SELECT Status__c
      FROM Token__c
      WHERE Id = :activeToken.Id
    ];
    System.assertEquals(
      'Revoked',
      updated.Status__c,
      'Token should now be Revoked'
    );
  }

  @IsTest
  static void testRevokeToken_alreadyRevoked_throwsException() {
    Token__c revokedToken = [
      SELECT Id
      FROM Token__c
      WHERE Status__c = 'Revoked'
      LIMIT 1
    ];

    Test.startTest();
    try {
      TokenService.revokeToken(revokedToken.Id);
      System.assert(false, 'Expected AuraHandledException was not thrown');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage() != null,
        'Exception message should not be null'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void testRevokeToken_notFound_throwsException() {
    Test.startTest();
    try {
      TokenService.revokeToken('a00000000000001AAA');
      System.assert(false, 'Expected AuraHandledException was not thrown');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage() != null,
        'Exception message should not be null'
      );
    }
    Test.stopTest();
  }

  // ─── expireToken ─────────────────────────────────────────────────────────

  @IsTest
  static void testExpireToken_activeToken_success() {
    // Get the second active token
    List<Token__c> activeTokens = [
      SELECT Id
      FROM Token__c
      WHERE Status__c = 'Active'
      LIMIT 2
    ];
    Token__c activeToken = activeTokens[activeTokens.size() - 1];

    Test.startTest();
    TokenService.expireToken(activeToken.Id);
    Test.stopTest();

    Token__c updated = [
      SELECT Status__c
      FROM Token__c
      WHERE Id = :activeToken.Id
    ];
    System.assertEquals(
      'Expired',
      updated.Status__c,
      'Token should now be Expired'
    );
  }

  @IsTest
  static void testExpireToken_notFound_throwsException() {
    Test.startTest();
    try {
      TokenService.expireToken('a00000000000001AAA');
      System.assert(false, 'Expected AuraHandledException was not thrown');
    } catch (AuraHandledException e) {
      System.assert(
        e.getMessage() != null,
        'Exception message should not be null'
      );
    }
    Test.stopTest();
  }
}
