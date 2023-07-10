import {
  generateMessage,
  preAuthzResponse,
  FCLScriptsReplacement,
} from "./fcl_scripts";
import { fetchSharedData } from "./storage";

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
  postMessage(message);
  console.log("postPreAuthzResponse sent");
}

export function postReadyResponse() {
  const message = `
    { type: 'FCL:VIEW:READY' }
  `;

  postMessage(message);
  console.log("postReadyResponse sent");
}

function postMessage(message: string) {
  window && window.postMessage(JSON.parse(JSON.stringify(message || {})), "*");
}
