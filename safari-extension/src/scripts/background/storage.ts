import { NativeMessageType, sendNativeMessage } from "../utils/define";

export interface SharedModel {
  address: string;
  payer: string;
}

export let sharedModel: SharedModel | undefined;

export async function fetchSharedData(): Promise<SharedModel | undefined> {
  try {
    const data = await sendNativeMessage(NativeMessageType.Fetch);
    sharedModel = data;
    return sharedModel;
  } catch (error) {
    console.error("fetch shared data failed", error);
    sharedModel = undefined;
    return sharedModel;
  }
}
