//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct MacpluginsPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BuildURLRequestMacro.self,
        OSLoggerMacro.self,
        EquatableMacro.self
    ]
}
