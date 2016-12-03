# BridgeCommander
[![Build Status](https://travis-ci.org/tmarkovski/BridgeCommander.svg?branch=master)](https://travis-ci.org/tmarkovski/BridgeCommander)

A wrapper library for iOS apps that provides easy to use functions for briding the communication between the native runtime and javascript runtime hosted in a WKWebView. The library wraps the functionality provided by `WKUserContentController` and embeds a javascript library that exposes promise style functions.

## Usage
In Swift, create a `BridgeCommander` instance and start adding commands
