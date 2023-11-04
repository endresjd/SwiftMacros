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
/// - Parameters:
///   - string: String representation of the URL
///   - method: A value to assign to the request's httpMethod property.  Defaults to "GET"
///   - headers: Dictionary of string key/value pairs that are set (not added!) in the request using URLRequest's setValue(_:forHTTPHeaderField:) method.  The default is an empty dictionary
/// - Returns: A fully construct URLRequest or nil if the URL could not be created
/// - Important: Using this multiple times at the top level, like in a command-line tool, will expand them all properly, but only the first expansion seems used.
@freestanding(expression)
public macro buildURLRequest(_ string: String, method: String = "GET", headers: [String:String] = [:]) -> URLRequest? = #externalMacro(module: "MacpluginsMacrosCore", type: "BuildURLRequestMacro")
