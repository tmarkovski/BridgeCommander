# BridgeCommander
[![Build Status](https://travis-ci.org/tmarkovski/BridgeCommander.svg?branch=master)](https://travis-ci.org/tmarkovski/BridgeCommander)

A wrapper library for iOS apps that provides easy to use functions for briding the communication between the native runtime and javascript runtime hosted in a WKWebView. The library wraps the functionality provided by `WKUserContentController` and embeds a javascript library that exposes promise style functions.

## Usage
In Swift, create a `BridgeCommander` instance and start adding commands. Use `send` function to provide result back or `error` to pass back an error result.
```swift
    let commander = BridgeCommander(webView)
    commander.add("echo") { command in
        command.send(args: "You said: \(command.args)")
    }
```
In JavaScript, invoke this command as
```javascript
    BridgeCommander.call("echo", "Hello!")
        .then(function(result) { console.log(result); })
        .catch(function(error) { console.log(error); });
```

That's it!

## Installation
### Plain old copy/paste
The simplest way would be to add `BridgeCommander.swift` and `BridgeCommander.js` to your xcode project. Make sure to update the javascript file reference inside the code if you rename the files or place them in separate folders. Do not reference the js file in your web app, it will be automatically available everywhere.
### Using Carthage
This is a clean and fast way to use this as a library in your project. If you're unfamiliar with Carthage, [read Ray's article](https://www.raywenderlich.com/109330/carthage-tutorial-getting-started) on using it 
