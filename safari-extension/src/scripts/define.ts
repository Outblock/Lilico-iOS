import browser from "webextension-polyfill";

const applicationName = "LilicoExt";

export interface Message {
  type: string;
  payload?: any;
}

export enum ExtMessageType {
  ReceiveMessage = "message",
  ReceiveTransactionMessage = "transaction",
  PostMessage = "post_message",
}

export enum NativeMessageType {
  Fetch = "fetch",
}

export function sendNativeMessage(
  event: NativeMessageType,
  payload?: any
): Promise<any> {
  const e: Message = {
    type: event,
    payload: payload ?? null,
  };

  return browser.runtime.sendNativeMessage(applicationName, e);
}
