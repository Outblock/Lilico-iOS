import browser from "webextension-polyfill";
import { ExtMessageType, Message } from "./define";
import { FCLServiceType } from "./fcl_scripts";
import { fetchSharedData } from "./storage";
import { postPreAuthzResponse, postReadyResponse } from "./sender";

fetchSharedData().then((model) => {
  console.log("fetch shared data from app", model);
});

let processingMessage: any = null;

browser.runtime.onMessage.addListener((message: Message) => {
  console.log(
    "background.ts received content.js message",
    JSON.stringify(message)
  );

  if (!message.payload) {
    console.warn("message.payload is nil");
    return;
  }

  switch (message.type) {
    case ExtMessageType.ReceiveMessage:
      handleReceiveMessage(message.payload);
      break;

    default:
      break;
  }
});

async function handleReceiveMessage(payload: any) {
  if (processingMessage === payload) {
    console.warn("same message is processing");
    return;
  }

  let sharedData = await fetchSharedData();
  if (!sharedData) {
    // TODO: - data is not prepared action
    console.warn("shared data is not prepared");
    // debug code on chrome, don't forget delete this.
    // sharedData = { address: "0xf026a227d3723067", payer: "0xcb1cf3196916f9e2" };
    return;
  }

  try {
    if (messageIsService(payload)) {
      handleService(payload);
    } else if (payload.type === "FCL:VIEW:READY:RESPONSE") {
      handleViewReady(payload);
    } else {
      console.warn("unknown message", payload);
    }
  } catch (error) {
    console.error("handleReceiveMessage failed", error);
    processingMessage = null;
  }
}

function handleViewReady(payload: any) {
  console.log("will handle view ready", payload);
}

function handleService(payload: any) {
  console.log("will handle service");

  if (payload.service.type === FCLServiceType.PreAuthz) {
    postPreAuthzResponse();
  } else {
    postReadyResponse();
  }
}

function messageIsService(payload: any): boolean {
  if (payload.type) {
    return false;
  }

  const service = payload.service as { [key: string]: any };
  if (!service) {
    return false;
  }

  if (service.type || (service.f_type as string) === "Service") {
    return true;
  }

  return false;
}
