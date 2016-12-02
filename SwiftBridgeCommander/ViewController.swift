//
//  ViewController.swift
//  SwiftBridgeCommander
//
//  Created by Markovski, Tomislav on 12/1/16.
//  Copyright © 2016 Blue Metal. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var webView: WKWebView?
    var commander: SwiftBridgeCommander?
    
    override func loadView() {
        super.loadView()
        
        webView = WKWebView(frame: view.frame)
        view.addSubview(webView!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("User content controller: \(webView!.configuration.userContentController)")
        
        commander = SwiftBridgeCommander(webView: webView!)
        
        //webView!.load(URLRequest(url: URL(string: "https://www.xamarin.com")!))
        
        commander?.add("command1") {
            command in
            print("Argument: \(command.args)")
            
            command.send(args: "Success! You sent: \(command.args)")
        }
        commander?.add("command2", handler: test)
        
       let url = Bundle.main.url(forResource: "index", withExtension: "html")
       self.webView!.loadFileURL(url!, allowingReadAccessTo: Bundle.main.resourceURL!)
    }
    
    func test(command: BridgeCommand) {
        print("Argument: \(command.args)")
        command.error(args: "Oh Noez!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

