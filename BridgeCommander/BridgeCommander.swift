//
//  SwiftBridgeCommander.swift
//  SwiftBridgeCommander
//
//  Created by Markovski, Tomislav on 12/1/16.
//  Copyright © 2016 Blue Metal. All rights reserved.
//

import Foundation
import WebKit

public class BridgeCommander : NSObject, WKScriptMessageHandler {
    let messageHandlerName = "__SWIFT_BRIDGE_COMMANDER"
    let bridgeScriptObject = "BridgeCommander"
    
    let webView: WKWebView
    var commands = [String: CommandHandler]()
    
    public init(_ webView: WKWebView) {
        
        self.webView = webView
        
        super.init()
        if let filepath = Bundle(for: type(of: self)).path(forResource: "BridgeCommander", ofType: "js") {
            do {
                let contents = try String(contentsOfFile: filepath)
                self.webView.configuration.userContentController.addUserScript(WKUserScript(source: contents, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
            self.webView.configuration.userContentController.add(self, name: messageHandlerName)
        } catch {
            print("Error occured")
            }
        } else {
            print("Error script not found")
        }
    }
    
    public func add(_ name: String, handler: @escaping CommandHandler){
        commands[name] = handler
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Message rceived: \(message.name) Body: \(message.body)")
        guard let msg = parse(message.body) else {
            print("Cannot parse message"); return
        }
        guard let handler = commands[msg.command!] else {
            let error = "Command not registered: \(msg.command!)"
            BridgeCommand(msg, commander: self)
                .error(args: error)
            print(error)
            return
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

public typealias CommandHandler = (_ command: BridgeCommand) -> Void

public class BridgeCommand {
    private let message: BridgeMessage
    private let commander: BridgeCommander
    public let args: String
    
    init(_ message: BridgeMessage, commander: BridgeCommander) {
        self.message = message
        self.commander = commander
        self.args = message.args!
    }
    
    public func send(args: String) {
        commander.send(args: args, id: self.message.id!)
    }
    
    public func error(args: String) {
        commander.error(args: args, id: self.message.id!)
    }
}
