import browser from "webextension-polyfill";
import { ExtMessageType, FCLServiceType, Message } from "./define";

let processingMessage: any = null

browser.runtime.onMessage.addListener((message: Message) => {
  console.log(
    "background.ts received content.js message",
    JSON.stringify(message)
  );

  if (!message.payload) {
    console.warn('message.payload is nil')
    return;
  }

  switch (message.type) {
    case ExtMessageType.ReceiveMessage:
      handleReceiveMessage(message.payload)
      break;
  
    default:
      break;
  }
});

function handleReceiveMessage(payload: any) {
  if (processingMessage === payload) {
    console.warn('same message is processing')
    return
  }

  // TODO: - check required info

  try {
    if (messageIsService(payload)) {
      handleService(payload)
    }
  } catch (error) {
    console.error('handleReceiveMessage failed', error)
    processingMessage = null
  }
}

function handleService(payload: any) {
  console.log('will handle service')

  if (payload.service.type === FCLServiceType.PreAuthz) {
    // post preAuthz response
  } else {
    // post ready response
  }
}

function messageIsService(payload: any): boolean {
  if (!payload.type) {
    return false
  }

  const service = payload.service as {[key: string]: any};
  if (!service) {
    return false
  }

  if (service.type || (service.f_type as string) === 'Service') {
    return true
  }

  return false
}