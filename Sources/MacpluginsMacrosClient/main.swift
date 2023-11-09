//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

import Foundation
import os
import MacpluginsMacros

let logger = Logger(subsystem: "MacPluginsMacrosClient", category: "top-level")

func dumpURLRequest(_ request: URLRequest) {
    logger.debug("result: \(request)")
    logger.debug("result.httpMethod: \(request.httpMethod ?? "GET")")
    logger.debug("result headers: \(request.allHTTPHeaderFields ?? [:])")
}

// This is either a bug or my blatant misunderstanding on how they are used in this case.  All #buildURLRequest
// defined at the top level of code (not in a function) result in unique expansions, but they all end up
// using only the values from the first one (this one)
if let thisIsUsedEverywhereAtTopLevel = #buildURLRequest("https://www.macplugins.com", method: "DELETE", headers: ["one":"two", "three":"four"]) {
    dumpURLRequest(thisIsUsedEverywhereAtTopLevel)
}

if let request = #buildURLRequest("https://www.apple.com") {
    dumpURLRequest(request)
}

if let request = #buildURLRequest("https://www.apple.com", method: "PUT") {
    dumpURLRequest(request)
}

if let request = #buildURLRequest("a b c", method: "DELETE") {
    dumpURLRequest(request)
}

func buildRequestExample() {
    if let request = #buildURLRequest("https://www.macplugins.com", method: "POST", headers: ["one":"two", "three":"four"]) {
        dumpURLRequest(request)
    }

    if let request = #buildURLRequest("https://www.apple.com", method: "PUT") {
        dumpURLRequest(request)
    }

    if let request = #buildURLRequest("https://www.google.com") {
        dumpURLRequest(request)
    }
    
    let url = "https://www.johndoe.com"
    let method = "GET"
    let headers = ["first":"John", "last":"Doe"]

    if let request = #buildURLRequest(url, method: method, headers: headers) {
        dumpURLRequest(request)
    }
}

buildRequestExample()

@OSLogger(subsystem: "MacpluginsMacrosClient")
struct RequestExample {
    let postRequest = #buildURLRequest("https://www.macplugins.com", method: "POST", headers: ["one":"two", "three":"four"])
    let putRequest = #buildURLRequest("https://www.apple.com", method: "PUT")
    let getRequest = #buildURLRequest("https://www.google.com")
    
    func run() {
        log(postRequest)
        log(putRequest)
        log(getRequest)
    }
    
    func log(_ request: URLRequest?) {
        if let request {
            logger.info("request: \(request)")
            logger.info("request.httpMethod: \(request.httpMethod ?? "GET")")
            logger.info("request headers: \(request.allHTTPHeaderFields ?? [:])")
        }
    }
}

let requestExample = RequestExample()

requestExample.run()

// Good overview: https://www.avanderlee.com/debugging/oslog-unified-logging/
// And here: https://developer.apple.com/documentation/xcode/formatting-your-documentation
let subsystem = "ClientSubsystem"
let category = "ClientCategory"

@OSLogger
@OSLogger("clientLogger", subsystem: subsystem, category: category)
@OSLogger("categoryLogger", subsystem: "Client", category: "Other")
@OSLogger("subsystemLogger", subsystem: "subsystem")
@OSLogger("fullLogger", subsystem: "Example sub-system", category: "example category")
struct ExampleStruct {
    func example(_ message: String) {
        logger.debug("a debug message")
        clientLogger.error("CLIENT LOGGER!")
        categoryLogger.debug("categoryLogger debug message")
        subsystemLogger.info("a subsystem message: \(message, privacy: .private)")
        fullLogger.notice("Notice from fullLogger")
    }
}

let example = ExampleStruct()

example.example("subsystem message")
