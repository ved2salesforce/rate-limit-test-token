import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import revokeToken from "@salesforce/apex/TokenService.revokeToken";
import issueToken from "@salesforce/apex/TokenService.issueToken";

export default class TokenActions extends LightningElement {
  @api accountId;
  @api tokenId;
  @api expiryDate;
  @api scope;

  get isRevokeDisabled() {
    return !this.tokenId;
  }

  handleIssue() {
    issueToken({
      accountId: this.accountId,
      expiryDate: this.expiryDate,
      scope: this.scope
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Token issued successfully.",
            variant: "success"
          })
        );
        this.dispatchRefresh();
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error.body
              ? error.body.message
              : "An error occurred while issuing the token.",
            variant: "error"
          })
        );
      });
  }

  handleRevoke() {
    revokeToken({ tokenId: this.tokenId })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Token revoked successfully.",
            variant: "success"
          })
        );
        this.dispatchRefresh();
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error.body
              ? error.body.message
              : "An error occurred while revoking the token.",
            variant: "error"
          })
        );
      });
  }

  dispatchRefresh() {
    this.dispatchEvent(new CustomEvent("refresh"));
  }
}
