jest.mock(
  "@salesforce/apex/TokenService.revokeToken",
  () => ({ __esModule: true, default: jest.fn() }),
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/TokenService.issueToken",
  () => ({ __esModule: true, default: jest.fn() }),
  { virtual: true }
);

import { createElement } from "lwc";
import TokenActions from "c/tokenActions";
import revokeToken from "@salesforce/apex/TokenService.revokeToken";
import issueToken from "@salesforce/apex/TokenService.issueToken";

function getIssueButton(element) {
  return Array.from(
    element.shadowRoot.querySelectorAll("lightning-button")
  ).find((btn) => btn.label === "Issue Token");
}

function getRevokeButton(element) {
  return Array.from(
    element.shadowRoot.querySelectorAll("lightning-button")
  ).find((btn) => btn.label === "Revoke Token");
}

describe("c-token-actions", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  // ─── Issue Token ─────────────────────────────────────────────────────────

  it("dispatches success toast and refresh event on successful issue", () => {
    issueToken.mockResolvedValue({});
    const element = createElement("c-token-actions", { is: TokenActions });
    element.accountId = "a001000000001AAA";
    element.expiryDate = "2027-01-01";
    element.scope = "read:all";
    document.body.appendChild(element);

    const refreshHandler = jest.fn();
    element.addEventListener("refresh", refreshHandler);

    const issueButton = getIssueButton(element);
    expect(issueButton).toBeDefined();
    issueButton.click();

    return Promise.resolve()
      .then(() => {
        expect(issueToken).toHaveBeenCalledWith({
          accountId: "a001000000001AAA",
          expiryDate: "2027-01-01",
          scope: "read:all"
        });
        return Promise.resolve();
      })
      .then(() => {
        expect(refreshHandler).toHaveBeenCalledTimes(1);
      });
  });

  it("dispatches error toast on failed issue", () => {
    issueToken.mockRejectedValue({ body: { message: "Issue failed" } });
    const element = createElement("c-token-actions", { is: TokenActions });
    element.accountId = "a001000000001AAA";
    element.expiryDate = "2027-01-01";
    element.scope = "read:all";
    document.body.appendChild(element);

    const refreshHandler = jest.fn();
    element.addEventListener("refresh", refreshHandler);

    const issueButton = getIssueButton(element);
    issueButton.click();

    return Promise.resolve()
      .then(() => Promise.resolve())
      .then(() => {
        expect(issueToken).toHaveBeenCalled();
        expect(refreshHandler).not.toHaveBeenCalled();
      });
  });

  // ─── Revoke Token ─────────────────────────────────────────────────────────

  it("dispatches success toast and refresh event on successful revoke", () => {
    revokeToken.mockResolvedValue({});
    const element = createElement("c-token-actions", { is: TokenActions });
    element.tokenId = "a001000000001AAA";
    document.body.appendChild(element);

    const refreshHandler = jest.fn();
    element.addEventListener("refresh", refreshHandler);

    const revokeButton = getRevokeButton(element);
    expect(revokeButton).toBeDefined();
    revokeButton.click();

    return Promise.resolve()
      .then(() => {
        expect(revokeToken).toHaveBeenCalledWith({
          tokenId: "a001000000001AAA"
        });
        return Promise.resolve();
      })
      .then(() => {
        expect(refreshHandler).toHaveBeenCalledTimes(1);
      });
  });

  it("dispatches error toast on failed revoke", () => {
    revokeToken.mockRejectedValue({ body: { message: "Revoke failed" } });
    const element = createElement("c-token-actions", { is: TokenActions });
    element.tokenId = "a001000000001AAA";
    document.body.appendChild(element);

    const refreshHandler = jest.fn();
    element.addEventListener("refresh", refreshHandler);

    const revokeButton = getRevokeButton(element);
    revokeButton.click();

    return Promise.resolve()
      .then(() => Promise.resolve())
      .then(() => {
        expect(revokeToken).toHaveBeenCalled();
        expect(refreshHandler).not.toHaveBeenCalled();
      });
  });

  it("disables revoke button when tokenId is not set", () => {
    const element = createElement("c-token-actions", { is: TokenActions });
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const revokeButton = getRevokeButton(element);
      expect(revokeButton).toBeDefined();
      expect(revokeButton.disabled).toBe(true);
    });
  });

  it("enables revoke button when tokenId is set", () => {
    const element = createElement("c-token-actions", { is: TokenActions });
    element.tokenId = "a001000000001AAA";
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      const revokeButton = getRevokeButton(element);
      expect(revokeButton).toBeDefined();
      expect(revokeButton.disabled).toBe(false);
    });
  });
});
