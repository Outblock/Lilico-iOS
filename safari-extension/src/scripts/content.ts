import browser from "webextension-polyfill";
import { ExtMessageType, Message } from "./define";

console.log("content.ts will start");

// inject js
const script = document.createElement("script");
script.setAttribute("type", "text/javascript");
script.setAttribute("src", browser.runtime.getURL("./content_script.js"));
document.body.appendChild(script);

// receive event from page
window.addEventListener("message", function (event) {
  if (event.data.internalSendFlag) {
    // ignore event from self
    console.info("ignore event from self");
    return;
  }

  console.log("content.ts received webpage message", event.data);

  const msgObj: Message = {
    type: ExtMessageType.ReceiveMessage,
    payload: event.data,
  };
  browser.runtime.sendMessage(msgObj);
});

// receive event from page
window.addEventListener("FLOW::TX", function (event) {
  console.log("received FLOW::TX event");
  console.log("received FLOW::TX event", event);
});

// receive event from background
browser.runtime.onMessage.addListener((message: Message) => {
  console.log("content.ts received background.ts message", message);

  switch (message.type) {
    case ExtMessageType.PostMessage:
      postMessage(message.payload);
      break;
    default:
      console.warn("unknown message type");
      break;
  }
});

function postMessage(message: any) {
  message.internalSendFlag = true;
  console.log("will post message to page", message);
  window && window.postMessage(JSON.parse(JSON.stringify(message || {})), "*");
}
