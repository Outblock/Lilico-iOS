import browser from "webextension-polyfill";
import { ExtMessageType, Message } from "./define";

console.log("content.js will start");

window.addEventListener("message", function (event) {
  console.log("content.ts received webpage message", JSON.stringify(event))

  const msgObj: Message = {type: ExtMessageType.ReceiveMessage, payload: event}
  browser.runtime.sendMessage(msgObj)
});

window.addEventListener("FLOW::TX", function (event) {
  console.log("received FLOW::TX event " + JSON.stringify(event));
});

const service = {
  f_type: "Service",
  f_vsn: "1.0.0",
  type: "authn",
  uid: "Lilico",
  endpoint: "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
  method: "EXT/RPC",
  id: "hpclkefagolihohboafpheddmmgdffjm",
  identity: {
    address: "0x33f75ff0b830dcec",
  },
  provider: {
    address: "0x33f75ff0b830dcec",
    name: "Lilico",
    icon: "https://lilico.app/logo.png",
    description:
      "Lilico is bringing an out of the world experience to your crypto assets on Flow",
  },
};

function injectExtService(service: any) {
  if (service.type === "authn" && service.endpoint != null) {
    if (!Array.isArray(window.fcl_extensions)) {
      console.log("window.fcl_extensions is not an array");
      window.fcl_extensions = [];
    }
    window.fcl_extensions.push(service);
    console.log("js inject success");
  } else {
    console.warn("Authn service is required");
  }
}

injectExtService(service);

console.log("content.js did end");

// const jsCode = `
//   console.log("content.js will start11");

//   document.title = "haha";

//   window.addEventListener("message", function (event) {
//     console.log("received message event " + event)
//   });

//   window.addEventListener("FLOW::TX", function (event) {
//     console.log("received FLOW::TX event " + event)
//   });

//   const service = {
//     f_type: "Service",
//     f_vsn: "1.0.0",
//     type: "authn",
//     uid: "Lilico",
//     endpoint: "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
//     method: "EXT/RPC",
//     id: "hpclkefagolihohboafpheddmmgdffjm",
//     identity: {
//       address: "0x33f75ff0b830dcec",
//     },
//     provider: {
//       address: "0x33f75ff0b830dcec",
//       name: "Lilico",
//       icon: "https://lilico.app/logo.png",
//       description:
//         "Lilico is bringing an out of the world experience to your crypto assets on Flow",
//     },
//   };

//   function injectExtService(service) {
//     if (service.type === "authn" && service.endpoint != null) {
//       if (!Array.isArray(window.fcl_extensions)) {
//         console.log("window.fcl_extensions is not an array")
//         window.fcl_extensions = [];
//       }
//       window.fcl_extensions.push(service);
//       console.log("js inject success")
//     } else {
//       console.warn("Authn service is required");
//     }
//   }

//   injectExtService(service);

//   console.log("content.js did end");
// `;
// var script = document.createElement("script");
// script.textContent = jsCode;
// document.body.appendChild(script);
