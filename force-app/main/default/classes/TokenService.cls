/**
 * @description Service class for Token__c lifecycle operations. All DML is
 *              executed in user context (with sharing) to respect sharing rules.
 */
public with sharing class TokenService {
  /**
   * @description Issues a new token for the given account.
   * @param accountId The Account Id that will own the token.
   * @param expiryDate The date the token expires. Must be after today.
   * @param scope A short description of the token's intended scope.
   * @return The newly created Token__c record.
   */
  @AuraEnabled
  public static Token__c issueToken(
    Id accountId,
    Date expiryDate,
    String scope
  ) {
    Date issuedDate = Date.today();
    if (expiryDate <= issuedDate) {
      throw new AuraHandledException(
        'Expiry date must be after the issued date.'
      );
    }

    Token__c token = new Token__c(
      Owner_Account__c = accountId,
      Status__c = 'Active',
      Issued_Date__c = issuedDate,
      Expiry_Date__c = expiryDate,
      Scope__c = scope
    );

    // Enforce FLS before insert
    SObjectAccessDecision decision = Security.stripInaccessible(
      AccessType.CREATABLE,
      new List<Token__c>{ token }
    );
    insert decision.getRecords();
    return [
      SELECT Id, Name, Status__c, Issued_Date__c, Expiry_Date__c, Scope__c
      FROM Token__c
      WHERE Id = :decision.getRecords()[0].Id
      WITH USER_MODE
    ];
  }

  /**
   * @description Revokes an existing token. Throws if already Revoked.
   * @param tokenId The Id of the token to revoke.
   */
  @AuraEnabled
  public static void revokeToken(Id tokenId) {
    List<Token__c> tokens = [
      SELECT Id, Status__c
      FROM Token__c
      WHERE Id = :tokenId
      WITH USER_MODE
      LIMIT 1
    ];

    if (tokens.isEmpty()) {
      throw new AuraHandledException('Token not found.');
    }

    Token__c token = tokens[0];
    if (token.Status__c == 'Revoked') {
      throw new AuraHandledException('Token is already Revoked.');
    }

    token.Status__c = 'Revoked';
    SObjectAccessDecision decision = Security.stripInaccessible(
      AccessType.UPDATABLE,
      new List<Token__c>{ token }
    );
    update decision.getRecords();
  }

  /**
   * @description Expires a token by setting its status to Expired.
   * @param tokenId The Id of the token to expire.
   */
  @AuraEnabled
  public static void expireToken(Id tokenId) {
    List<Token__c> tokens = [
      SELECT Id, Status__c
      FROM Token__c
      WHERE Id = :tokenId
      WITH USER_MODE
      LIMIT 1
    ];

    if (tokens.isEmpty()) {
      throw new AuraHandledException('Token not found.');
    }

    Token__c token = tokens[0];
    token.Status__c = 'Expired';
    SObjectAccessDecision decision = Security.stripInaccessible(
      AccessType.UPDATABLE,
      new List<Token__c>{ token }
    );
    update decision.getRecords();
  }
}
