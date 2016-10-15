//
//  StaffElementNode.swift
//  Sight Read Pro
//
//  Created by Anthony Gabriele on 7/8/16.
//  Copyright © 2016 Anthony Gabriele Company. All rights reserved.
//

import Foundation
import UIKit

enum StaffElementType{
    case note
    case keySignature
    case clef
    case tempoMarking
}

protocol StaffElementNode{
    func positionOnStaff(_ staffSize:CGSize, ledgerLineSpace:CGFloat) -> CGPoint
    func acceptStaffDimensions(_ staffSize:CGSize, ledgerLineSpace:CGFloat)
    func onePerStaff() -> Bool
    func staffElementType() -> StaffElementType
    func hasMidPointWhenAnimating() -> Bool
}
