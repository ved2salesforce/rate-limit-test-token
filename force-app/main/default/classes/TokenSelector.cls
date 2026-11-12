/**
 * @description Selector class for Token__c records. All queries execute with
 *              WITH USER_MODE to enforce object- and field-level security.
 */
public with sharing class TokenSelector {
  /**
   * @description Returns all tokens associated with a given Account.
   * @param accountId The Id of the Account whose tokens are requested.
   * @return List of Token__c records owned by the account.
   */
  @AuraEnabled(cacheable=true)
  public static List<Token__c> getTokensByAccount(Id accountId) {
    return [
      SELECT
        Id,
        Name,
        Status__c,
        Issued_Date__c,
        Expiry_Date__c,
        Owner_Account__c,
        Scope__c
      FROM Token__c
      WHERE Owner_Account__c = :accountId
      WITH USER_MODE
      ORDER BY CreatedDate DESC
    ];
  }

  /**
   * @description Returns all tokens that match the given status value.
   * @param status The Status__c picklist value to filter on.
   * @return List of matching Token__c records.
   */
  @AuraEnabled(cacheable=true)
  public static List<Token__c> getTokensByStatus(String status) {
    return [
      SELECT
        Id,
        Name,
        Status__c,
        Issued_Date__c,
        Expiry_Date__c,
        Owner_Account__c,
        Scope__c
      FROM Token__c
      WHERE Status__c = :status
      WITH USER_MODE
      ORDER BY CreatedDate DESC
    ];
  }

  /**
   * @description Returns active tokens whose Expiry_Date__c falls within the
   *              given number of days from today.
   * @param days Number of days from today to look ahead.
   * @return List of Token__c records expiring within that window.
   */
  @AuraEnabled(cacheable=true)
  public static List<Token__c> getTokensExpiringWithinDays(Integer days) {
    Date cutoff = Date.today().addDays(days);
    return [
      SELECT
        Id,
        Name,
        Status__c,
        Issued_Date__c,
        Expiry_Date__c,
        Owner_Account__c,
        Scope__c
      FROM Token__c
      WHERE
        Status__c = 'Active'
        AND Expiry_Date__c <= :cutoff
        AND Expiry_Date__c >= TODAY
      WITH USER_MODE
      ORDER BY Expiry_Date__c ASC
    ];
  }
}
