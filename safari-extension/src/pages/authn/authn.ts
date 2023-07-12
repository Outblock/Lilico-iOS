import { createApp } from "vue";
import "../../style.css";
import App from "./Authn.vue";
import browser from "webextension-polyfill";
import { PortName } from "../../scripts/utils/define";

createApp(App).mount("#app");

const port = browser.runtime.connect({ name: PortName.Authn });
port.onMessage.addListener((message) => {
  console.log("authn.ts receive message via authn connection", message);
  // handleMessage(message);
});

port.postMessage("hello from authn");

// function handleMessage(message: Message) {
//   console.log("msg", message);
// }
