//  Copyright (c) 2023, John Endres
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//
//  Created by John Endres on 10/31/23.
//

//
//  LabeledExprListSyntaxExtension.swift
//  
//
//  Created by John Endres on 11/8/23.
//

import Foundation
import SwiftSyntax

extension LabeledExprListSyntax {
    /// Retrieve the first variable without a label
    var firstUnlabeled:  Element? {
        return first { element in
            return element.label == nil
        }
    }
    
    /// Retrieve the first element with the given label.
    func first(labeled name: String) -> Element? {
        return first { element in
            if let label = element.label, label.text == name {
                return true
            }
            
            return false
        }
    }
}
