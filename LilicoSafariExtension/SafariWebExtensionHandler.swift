//
//  SafariWebExtensionHandler.swift
//  LilicoSafariExtension
//
//  Created by Selina on 7/7/2023.
//

import SafariServices
import os.log
import SwiftyBeaver

let log = SwiftyBeaver.self

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    
    override init() {
        super.init()
        setup()
        log.debug("SafariWebExtensionHandler init")
    }
    
    private func setup() {
#if DEBUG
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M - $X"
        log.addDestination(console)
#endif
    }

    func beginRequest(with context: NSExtensionContext) {
        log.debug("SafariWebExtensionHandler init")
        
        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey]
        if message is [String: AnyObject] {
            log.debug("msg is dict")
        } else if message is String {
            log.debug("msg is string")
        }
        log.debug("receive message from web extension: \(message)")
//        os_log(.default, "Received message from browser.runtime.sendNativeMessage: %@", message as! CVarArg)

        let response = NSExtensionItem()
        response.userInfo = [ SFExtensionMessageKey: [ "Response to": message ] ]

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }

}
