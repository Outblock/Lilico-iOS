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
        log.debug("init")
    }
    
    private func setup() {
#if DEBUG
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M - $X"
        log.addDestination(console)
#endif
    }

    func beginRequest(with context: NSExtensionContext) {
        log.debug("begin request")
        
        guard let item = context.inputItems.first as? NSExtensionItem,
              let msg = item.userInfo?[SFExtensionMessageKey] as? [String: AnyObject],
              let typeString = msg["type"] as? String,
              let type = NativeMessageType(rawValue: typeString) else {
            log.warning("request info is invalid", context: context.inputItems)
            return
        }
        
        log.debug("receive message from web extension: \(msg)")
        
        switch type {
        case .fetch:
            handleFetchRequest(context)
        }
        
//        os_log(.default, "Received message from browser.runtime.sendNativeMessage: %@", message as! CVarArg)
    }
}

private func handleFetchRequest(_ context: NSExtensionContext) {
    guard let sharedModel = ExtConnectivity.shared.sharedModel, sharedModel.isValid else {
        callback(context)
        return
    }
    
    do {
        let data = try JSONEncoder().encode(sharedModel)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            callback(context)
            return
        }
        
        callback(context, message: dict)
    } catch {
        callback(context)
    }
}

private func callback(_ context: NSExtensionContext, message: Any? = nil) {
    let response = NSExtensionItem()
    if let message = message {
        response.userInfo = [SFExtensionMessageKey: message]
    }
    context.completeRequest(returningItems: [response])
}
