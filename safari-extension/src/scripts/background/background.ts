import browser from "webextension-polyfill";
import { ExtMessageType, Message, PortName } from "../utils/define";
import { FCLServiceType } from "../utils/fcl_scripts";
import { fetchSharedData } from "./storage";
import { postPreAuthzResponse, postReadyResponse } from "./sender";

fetchSharedData().then((model) => {
  console.log("fetch shared data from app", model);
});

let processingMessage: any | undefined;
let processingServiceType: FCLServiceType | undefined;
let processingFCLResponse: any | undefined;

// receive event from port
browser.runtime.onConnect.addListener((port) => {
  switch (port.name) {
    case PortName.Authn:
      handleAuthnConnection(port);
      break;

    default:
      console.warn("unknown port name", port);
      break;
  }
});

let authnPort: browser.Runtime.Port | undefined;
function handleAuthnConnection(port: browser.Runtime.Port) {
  authnPort = port;
  port.onMessage.addListener((message) => {
    console.log("background receive message via authn connection", message);
    authnPort?.postMessage("response from background");
  });
}

// receive event from content
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
    return;
  }

  try {
    if (messageIsService(payload)) {
      processingMessage = payload;
      handleService(payload);
    } else if (payload.type === "FCL:VIEW:READY:RESPONSE") {
      processingMessage = payload;
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

  const type = payload.service.type;
  if (processingServiceType !== type) {
    console.error(
      "service type is not same, old: " +
        processingServiceType +
        ". new: " +
        type
    );

    return;
  }

  switch (type) {
    case FCLServiceType.Authn:
      handleAuthn(payload);
      break;

    default:
      break;
  }
}

function handleAuthn(payload: any) {
  console.log("will handle authn");

  if (
    payload.service.type === processingFCLResponse?.service?.type &&
    payload.type === processingFCLResponse?.type
  ) {
    console.error(
      "handle authn is processing: " + payload.service.type + "-" + payload.type
    );
    return;
  }

  processingFCLResponse = payload;
  // TODO: //
}

function handleService(payload: any) {
  console.log("will handle service");

  processingServiceType = payload.service.type;

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
