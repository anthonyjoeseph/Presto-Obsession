//
//  Pitch.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/21/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

struct Interval{
    let distance:IntervalDistance
    let direction:IntervalDirection
}

enum IntervalDistance:Int{
    case halfStep = 1
    case wholeStep = 2
    case minorThird = 3
    case majorThird = 4
    case perfectFourth = 5
    case tritone = 6
    case perfectFifth = 7
    case minorSixth = 8
    case majorSixth = 9
    case minorSeventh = 10
    case majorSeventh = 11
    case perfectOctave = 12
}

enum IntervalDirection:Int{
    case down = 0
    case up = 1
}

class Pitch:Equatable, Hashable{
    let absolutePitch:Int
    let octave:Int
    
    var hashValue: Int {
        return absolutePitch
    }
    
    static let middleC:Pitch = Pitch(absolutePitch:39)
    
    init(absolutePitch:Int){
        self.absolutePitch = absolutePitch
        self.octave = absolutePitch / 12
    }
    func interval(_ interval:Interval) -> Pitch{
        var newAbsolutePitch:Int
        if(interval.direction == IntervalDirection.down){
            newAbsolutePitch = self.absolutePitch - interval.distance.rawValue
            if(newAbsolutePitch < 0){
                newAbsolutePitch += 84
            }
        }else{
            newAbsolutePitch = self.absolutePitch + interval.distance.rawValue
            if(newAbsolutePitch >= 88){
                newAbsolutePitch -= 84
            }
        }
        return Pitch(absolutePitch: newAbsolutePitch)
    }
    func basePitch() -> Int{
        return absolutePitch % 12
    }
}

func ==(lhs: Pitch, rhs: Pitch) -> Bool {
    return lhs.absolutePitch == rhs.absolutePitch
}
