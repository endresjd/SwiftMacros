// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MacpluginsSwiftMacros",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MacpluginsMacros",
            targets: ["MacpluginsMacros"]
        ),
        .executable(
            name: "MacpluginsMacrosClient",
            targets: ["MacpluginsMacrosClient"]
        ),
    ],
    dependencies: [
        // Depend on the latest Swift 5.9 prerelease of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "MacpluginsMacrosCore",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "MacpluginsMacros", dependencies: ["MacpluginsMacrosCore"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "MacpluginsMacrosClient",
            dependencies: [
                "MacpluginsMacros",
            ]
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "MacpluginsTests",
            dependencies: [
                "MacpluginsMacrosCore",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
