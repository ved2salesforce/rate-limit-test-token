import { LightningElement, api, wire } from "lwc";
import getTokensByAccount from "@salesforce/apex/TokenSelector.getTokensByAccount";

const STATUS_BADGE_STYLES = {
  Active: "slds-badge slds-badge_success",
  Expired: "slds-badge",
  Revoked: "slds-badge slds-badge_error"
};

export default class TokenList extends LightningElement {
  @api accountId;

  tokens;
  error;

  columns = [
    { label: "Token Name", fieldName: "Name" },
    { label: "Status", fieldName: "Status__c" },
    { label: "Issued Date", fieldName: "Issued_Date__c", type: "date" },
    { label: "Expiry Date", fieldName: "Expiry_Date__c", type: "date" },
    { label: "Scope", fieldName: "Scope__c" }
  ];

  @wire(getTokensByAccount, { accountId: "$accountId" })
  wiredTokens({ data, error }) {
    if (data) {
      this.tokens = data.map((token) => ({
        ...token,
        badgeClass: STATUS_BADGE_STYLES[token.Status__c] || "slds-badge"
      }));
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.tokens = undefined;
    }
  }
}
