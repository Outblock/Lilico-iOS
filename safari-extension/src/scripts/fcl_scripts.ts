export enum FCLServiceType {
  PreAuthz = "pre-authz",
  Authn = "authn",
  Authz = "authz",
  UserSignature = "user-signature",
}

export enum FCLScriptsReplacement {
  Address = "$ADDRESS_REPLACEMENT",
  PayerAddress = "$PAYER_ADDRESS_REPLACEMENT",
}

export interface Replacement {
  key: FCLScriptsReplacement;
  value: string;
}

export function generateMessage(
  originStr: string,
  replacements: Replacement[]
): string {
  let finalStr = originStr;
  replacements.forEach((element) => {
    finalStr = finalStr.replace(element.key, element.value);
  });

  return finalStr;
}

export const preAuthzResponse = `
  {
    "status": "APPROVED",
    "data": {
        "f_type": "PreAuthzResponse",
        "f_vsn": "1.0.0",
        "proposer": {
            "f_type": "Service",
            "f_vsn": "1.0.0",
            "type": "authz",
            "uid": "lilico#authz",
            "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
            "method": "EXT/RPC",
            "identity": {
                "address": "$ADDRESS_REPLACEMENT",
                "keyId": 0
            }
        },
        "payer": [
            {
                "f_type": "Service",
                "f_vsn": "1.0.0",
                "type": "authz",
                "uid": "lilico#authz",
                "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
                "method": "EXT/RPC",
                "identity": {
                    "address": "$PAYER_ADDRESS_REPLACEMENT",
                    "keyId": 0
                }
            }
        ],
        "authorization": [
            {
                "f_type": "Service",
                "f_vsn": "1.0.0",
                "type": "authz",
                "uid": "lilico#authz",
                "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
                "method": "EXT/RPC",
                "identity": {
                    "address": "$ADDRESS_REPLACEMENT",
                    "keyId": 0
                }
            }
        ]
    },
    "type": "FCL:VIEW:RESPONSE"
  }
`;
