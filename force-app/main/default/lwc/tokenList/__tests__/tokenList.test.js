jest.mock(
  "@salesforce/apex/TokenSelector.getTokensByAccount",
  () => {
    const {
      createApexTestWireAdapter
    } = require("@salesforce/wire-service-jest-util");
    return {
      __esModule: true,
      default: createApexTestWireAdapter(function getTokensByAccount() {
        return Promise.resolve();
      })
    };
  },
  { virtual: true }
);

import { createElement } from "lwc";
import TokenList from "c/tokenList";
import getTokensByAccount from "@salesforce/apex/TokenSelector.getTokensByAccount";

const MOCK_TOKENS = [
  {
    Id: "a001000000000001",
    Name: "TKN-0001",
    Status__c: "Active",
    Issued_Date__c: "2026-01-01",
    Expiry_Date__c: "2027-01-01",
    Scope__c: "read:all"
  },
  {
    Id: "a001000000000002",
    Name: "TKN-0002",
    Status__c: "Expired",
    Issued_Date__c: "2025-01-01",
    Expiry_Date__c: "2025-06-01",
    Scope__c: "write:data"
  },
  {
    Id: "a001000000000003",
    Name: "TKN-0003",
    Status__c: "Revoked",
    Issued_Date__c: "2025-06-01",
    Expiry_Date__c: "2026-06-01",
    Scope__c: "admin"
  }
];

describe("c-token-list", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("renders datatable when wire returns data", () => {
    const element = createElement("c-token-list", { is: TokenList });
    element.accountId = "a001000000001AAA";
    document.body.appendChild(element);

    getTokensByAccount.emit(MOCK_TOKENS);

    return Promise.resolve().then(() => {
      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable).not.toBeNull();
      expect(datatable.data.length).toBe(3);
    });
  });

  it("renders error message when wire returns error", () => {
    const element = createElement("c-token-list", { is: TokenList });
    element.accountId = "a001000000001AAA";
    document.body.appendChild(element);

    getTokensByAccount.emitError({ message: "Network error" });

    return Promise.resolve().then(() => {
      const errorEl = element.shadowRoot.querySelector(
        ".slds-text-color_error"
      );
      expect(errorEl).not.toBeNull();
      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable).toBeNull();
    });
  });

  it("does not render datatable or error on initial render", () => {
    const element = createElement("c-token-list", { is: TokenList });
    element.accountId = "a001000000001AAA";
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      const errorEl = element.shadowRoot.querySelector(
        ".slds-text-color_error"
      );
      expect(datatable).toBeNull();
      expect(errorEl).toBeNull();
    });
  });

  it("passes correct columns to datatable", () => {
    const element = createElement("c-token-list", { is: TokenList });
    element.accountId = "a001000000001AAA";
    document.body.appendChild(element);

    getTokensByAccount.emit(MOCK_TOKENS);

    return Promise.resolve().then(() => {
      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable.columns).toBeDefined();
      expect(datatable.columns.length).toBeGreaterThan(0);
    });
  });

  it("maps badgeClass for Active status", () => {
    const element = createElement("c-token-list", { is: TokenList });
    element.accountId = "a001000000001AAA";
    document.body.appendChild(element);

    const singleActiveToken = [MOCK_TOKENS[0]];
    getTokensByAccount.emit(singleActiveToken);

    return Promise.resolve().then(() => {
      const datatable = element.shadowRoot.querySelector("lightning-datatable");
      expect(datatable.data[0].badgeClass).toContain("slds-badge_success");
    });
  });
});
