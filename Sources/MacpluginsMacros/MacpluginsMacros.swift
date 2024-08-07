//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

import Foundation

/// Used to build an URLRequest from a string.  The macro results in code that creates the URL, and if that succeeds
/// creates the URLRequest filled in with the given optional data and returns that.  Any errors result in a nil result, and those errors
/// are all related to creating the URL instance inline.
/// 
/// - Parameters:
///   - string: String representation of the URL
///   - method: A value to assign to the request's httpMethod property.  Defaults to "GET"
///   - headers: Dictionary of string key/value pairs that are set (not added!) in the request using URLRequest's setValue(_:forHTTPHeaderField:) method.  The default is an empty dictionary
///   - Returns: A fully construct URLRequest or nil if the URL could not be created
///
/// - Important: Using this multiple times at the top level, like in a command-line tool, will expand them all properly, but only the first expansion seems used.
///
/// ## Examples
/// Here are 3 examples on how to create some URLRequests with code to print out the values
///
/// ### GET request with no headers
///
/// ```swift
/// if let request = #buildURLRequest("https://www.apple.com") {
///     print("requestOne: \(request)")
///     print("requestOne.httpMethod: \(request.httpMethod ?? "GET")")
/// }
/// ```
///
/// ### PUT request with no headers
///
/// ```swift
/// if let request = #buildURLRequest("https://www.apple.com", method: "PUT") {
///     print("request: \(request)")
///     print("request.httpMethod: \(request.httpMethod ?? "GET")")
/// }
/// ```
///
/// ### POST request with headers
///
/// ```swift
/// if let request = #buildURLRequest("https://www.macplugins.com", method: "POST", headers: ["one":"two", "three":"four"]) {
///     print("request: \(request)")
///     print("request.httpMethod: \(request.httpMethod ?? "GET")")
///     print("request headers: \(request.allHTTPHeaderFields ?? [:])")
/// }
/// ```
///
/// ### Using variable inputs
///
/// ```swift
/// let url = "https://www.johndoe.com"
/// let method = "GET"
/// let headers = ["first":"John", "last":"Doe"]
///
/// if let request = #buildURLRequest(url, method: method, headers: headers) {
/// }
/// ```
@freestanding(expression)
public macro buildURLRequest(_ string: String, method: String = "GET", headers: [String:String] = [:]) -> URLRequest? = #externalMacro(module: "MacpluginsMacrosCore", type: "BuildURLRequestMacro")

/// Adds a logger instance to the class or struct this is attached to with it's subsytem set to the given value or the current bundle identifier,
/// and the category as the type name it is attached to.
///
/// - Parameters:
///   - loggerName: The name for this logger instance which must be a double-quoted string.  The default is "logger".
///   - subsystem: The logger's subsystem.  Defaults to the bundle identifier or "Unknown" if that can't be resolved.  Command-line tools will likely be "Unknown"
///   - category: The logger's category.  Defaults to the name of the class or struct it is attached to.
///
/// - Important: You must `import os` in your swift file for this to compile properly.
///
/// ## Examples
///
/// This shows a struct that has 4 loggers attached.  It has a method showing how they are called.  The messages will show
/// up in Xcode's console or the System's console depending on how the code is being run.
///
/// ```swift
/// import os
///
/// let subsystem = "ClientSubsystem"
/// let category = "ClientCategory"
///
/// @OSLogger
/// @OSLogger("clientLogger", subsystem: subsystem, category: category)
/// @OSLogger("categoryLogger", subsystem: "Client", category: "Other")
/// @OSLogger("subsystemLogger", subsystem: "subsystem")
/// @OSLogger("fullLogger", subsystem: "Example sub-system", category: "example category")
/// struct ExampleStruct {
///     func example(_ message: String) {
///         logger.debug("a debug message")
///         clientLogger.error("CLIENT LOGGER!")
///         categoryLogger.debug("categoryLogger debug message")
///         subsystemLogger.info("a subsystem message: \(message, privacy: .private)")
///         fullLogger.notice("Notice from fullLogger")
///     }
/// }
///
/// let example = ExampleStruct()
///
/// example.example("subsystem message")
/// ```
@attached(member, names: arbitrary)
public macro OSLogger(_ loggerName: String = "logger", subsystem: String? = nil, category: String? = nil) = #externalMacro(
    module: "MacpluginsMacrosCore",
    type: "OSLoggerMacro"
)

/// Adds an extension to a type so that that type conforms to Equatable
///
/// A shortcut for Equatable protocol conformance
///
///     @Equatable
///     struct SomeStruct {
///         var property: Int
///     }
///
/// Produces
///
///     struct SomeStruct {
///         var property: Int
///     }
///     extension SomeStruct: Equatable {
///     }
@attached(extension, conformances: Equatable)
public macro Equatable() = #externalMacro(
    module: "MacpluginsMacrosCore",
    type: "EquatableMacro"
)
 
