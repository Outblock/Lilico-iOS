import browser from "webextension-polyfill";
import {
  generateMessage,
  preAuthzResponse,
  FCLScriptsReplacement,
} from "../utils/fcl_scripts";
import { fetchSharedData } from "./storage";
import { ExtMessageType } from "../utils/define";

export async function postPreAuthzResponse() {
  const sharedModel = await fetchSharedData();
  if (!sharedModel) {
    console.error("shared model is invalid");
    return;
  }

  let replacements = [
    { key: FCLScriptsReplacement.Address, value: sharedModel.address },
    { key: FCLScriptsReplacement.PayerAddress, value: sharedModel.payer },
  ];

  const message = generateMessage(preAuthzResponse, replacements);
  postToContent(message);
  console.log("postPreAuthzResponse sent");
}

export function postReadyResponse() {
  const message = { type: "FCL:VIEW:READY" };

  postToContent(message);
  console.log("postReadyResponse sent");
}

async function postToContent(message: any) {
  const tabs = await browser.tabs.query({ active: true, currentWindow: true });
  const tabId = tabs[0].id;
  if (!tabId) {
    console.error("tabId is nil");
    return;
  }

  browser.tabs.sendMessage(tabId, {
    type: ExtMessageType.PostMessage,
    payload: message,
  });
}
