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

// This is either a bug or my blatant misunderstanding on how they are used in this case.  All #buildURLRequest
// defined at the top level of code (not in a function) result in unique expansions, but they all end up
// using only the values from the first one (this one)
if let thisIsUsedEverywhereAtTopLevel = #buildURLRequest("https://www.macplugins.com", method: "DELETE", headers: ["one":"two", "three":"four"]) {
    print("result: \(thisIsUsedEverywhereAtTopLevel)")
    print("result.httpMethod: \(thisIsUsedEverywhereAtTopLevel.httpMethod ?? "GET")")
    print("result headers: \(thisIsUsedEverywhereAtTopLevel.allHTTPHeaderFields ?? [:])")
}

if let request = #buildURLRequest("https://www.apple.com") {
    print("requestOne: \(request)")
    print("requestOne.httpMethod: \(request.httpMethod ?? "GET")")
}

if let request = #buildURLRequest("https://www.apple.com", method: "PUT") {
    print("request: \(request)")
    print("request.httpMethod: \(request.httpMethod ?? "GET")")
}

if let request = #buildURLRequest("a b c", method: "DELETE") {
    print("request: \(request)")
    print("request.httpMethod: \(request.httpMethod ?? "GET")")
}

func buildRequestExample() {
    if let request = #buildURLRequest("https://www.macplugins.com", method: "POST", headers: ["one":"two", "three":"four"]) {
        print("request: \(request)")
        print("request.httpMethod: \(request.httpMethod ?? "GET")")
        print("request headers: \(request.allHTTPHeaderFields ?? [:])")
    }

    print()
    
    if let request = #buildURLRequest("https://www.apple.com", method: "PUT") {
        print("request: \(request)")
        print("request.httpMethod: \(request.httpMethod ?? "GET")")
        print("request headers: \(request.allHTTPHeaderFields ?? [:])")
    }

    print()
    
    if let request = #buildURLRequest("https://www.google.com") {
        print("request: \(request)")
        print("request.httpMethod: \(request.httpMethod ?? "GET")")
        print("request headers: \(request.allHTTPHeaderFields ?? [:])")
    }
}

print()
buildRequestExample()
print()

// Good overview: https://www.avanderlee.com/debugging/oslog-unified-logging/
// And here: https://developer.apple.com/documentation/xcode/formatting-your-documentation
@OSLogger(subsystem: "Client")
@OSLogger("categoryLogger", subsystem: "Client", category: "Other")
@OSLogger("subsystemLogger", subsystem: "subsystem")
@OSLogger("fullLogger", subsystem: "Example sub-system", category: "example category")
struct ExampleStruct {
    func example(_ message: String) {
        logger.debug("a debug message")
        categoryLogger.debug("categoryLogger debug message")
        subsystemLogger.info("a subsystem message: \(message, privacy: .private)")
        fullLogger.notice("Notice from fullLogger")
    }
}

let example = ExampleStruct()

example.example("subsystem message")
