/**
 * @description Batch and Schedulable job that auto-expires active tokens whose
 *              Expiry_Date__c is on or before today.
 */
public with sharing class TokenExpiryBatch implements Database.Batchable<SObject>, Schedulable {
  /**
   * @description Returns a QueryLocator for active tokens that have expired.
   * @param bc Batch context provided by the platform.
   * @return QueryLocator selecting expired-but-still-Active tokens.
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Status__c FROM Token__c WHERE Expiry_Date__c <= TODAY AND Status__c = \'Active\''
    );
  }

  /**
   * @description Bulk-updates the token status to Expired.
   * @param bc Batch context provided by the platform.
   * @param scope List of Token__c records to process.
   */
  public void execute(Database.BatchableContext bc, List<Token__c> scope) {
    for (Token__c token : scope) {
      token.Status__c = 'Expired';
    }
    SObjectAccessDecision decision = Security.stripInaccessible(
      AccessType.UPDATABLE,
      scope
    );
    update decision.getRecords();
  }

  /**
   * @description Required finish method for the Batchable interface. No
   *              post-processing is needed.
   * @param bc Batch context provided by the platform.
   */
  public void finish(Database.BatchableContext bc) {
    // No post-processing required.
  }

  /**
   * @description Schedulable entry point. Executes the batch job.
   * @param sc Schedulable context provided by the platform.
   */
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new TokenExpiryBatch());
  }
}
