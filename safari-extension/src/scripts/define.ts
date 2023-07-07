import browser from "webextension-polyfill";

const applicationName = "LilicoExt";

export interface Message {
  type: string;
  payload?: any;
}

export enum ExtMessageType {
  ReceiveMessage = "message",
  ReceiveTransactionMessage = "transaction",
}

export enum NativeMessageType {
  Init = "init",
}

export function sendNativeMessage(event: NativeMessageType, payload?: any) {
  const e: Message = {
    type: event,
    payload: payload ?? null,
  };

  browser.runtime.sendNativeMessage(applicationName, e).then((response) => {
    console.log("receive message from native", response);
  });
}

export enum FCLServiceType {
  PreAuthz = "pre-authz",
  Authn = "authn",
  Authz = "authz",
  UserSignature = "user-signature"
}