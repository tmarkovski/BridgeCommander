//
//  SwiftBridgeCommander.swift
//  SwiftBridgeCommander
//
//  Created by Markovski, Tomislav on 12/1/16.
//  Copyright © 2016 Blue Metal. All rights reserved.
//

import Foundation
import WebKit

class SwiftBridgeCommander : NSObject, WKScriptMessageHandler {
    let commandPrefix = "__SWIFT_BRIDGE_COMMANDER"
    let bridgeScriptObject = "__SWIFT_BRIDGE_COMMANDER_JS_OBJECT"
    
    let webView: WKWebView
    var commands = [String: CommandHandler]()
    
    init(webView: WKWebView) {
        
        self.webView = webView
        
        super.init()
        if let filepath = Bundle.main.path(forResource: "SwiftBridgeCommander", ofType: "js") {
            do {
                let contents = try String(contentsOfFile: filepath)
                self.webView.configuration.userContentController.addUserScript(WKUserScript(source: contents, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
                self.webView.configuration.userContentController.add(self, name: commandPrefix)
            } catch {
               print("Error occured")
            }
        } else {
            print("Error script not found")
        }
    }
    
    func add(_ name: String, handler: @escaping CommandHandler){
        commands[name] = handler
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Message rceived: \(message.name) Body: \(message.body)")
        guard let msg = parse(message.body) else {
            print("Cannot parse message"); return
        }
        guard let handler = commands[msg.command!] else {
            print("Command not registered: \(msg.command)"); return
        }
        handler(BridgeCommand(msg, commander: self))
    }
    
    func parse(_ body: Any) -> BridgeMessage? {
        do {
            var message = BridgeMessage()
            
            let data = (body as! String).data(using: .utf8)
            let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
            
            message.id = parsedData["id"] as? String
            message.command = parsedData["command"] as? String
            message.args = parsedData["args"] as? String
            
            return message
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    func send(args: String, id: String) {
        webView.evaluateJavaScript("window['\(bridgeScriptObject)'].response({'id':'\(id)', 'payload':'\(args)'})", completionHandler: nil)
    }
    
    func error(args: String, id: String) {
        webView.evaluateJavaScript("window['\(bridgeScriptObject)'].error({'id':'\(id)', 'payload':'\(args)'})", completionHandler: nil)
    }
}

struct BridgeMessage {
    var id, command, args: String?
}

typealias CommandHandler = (_ command: BridgeCommand) -> Void

class BridgeCommand {
    private let message: BridgeMessage
    private let commander: SwiftBridgeCommander
    let args: String
    
    init(_ message: BridgeMessage, commander: SwiftBridgeCommander) {
        self.message = message
        self.commander = commander
        self.args = message.args!
    }
    
    func send(args: String) {
        commander.send(args: args, id: self.message.id!)
    }
    
    func error(args: String) {
        commander.error(args: args, id: self.message.id!)
    }
}
