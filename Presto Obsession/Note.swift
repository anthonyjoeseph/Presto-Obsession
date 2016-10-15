//
//  Note.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

enum Rhythm:Int{
    case thirtySecond = 1
    case sixteenth = 2
    case eighth = 4
    case quarter = 8
    case half = 16
    case whole = 32
}

struct Note {
    let pitch:Pitch
    let rhythm:Rhythm
}
