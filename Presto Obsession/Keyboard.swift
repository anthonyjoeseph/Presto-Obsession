//
//  Keyboard.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/26/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

enum PitchLetter:String{
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case E = "E"
    case F = "F"
    case G = "G"
}

func lowestPitchForLetter(_ pitchLetter:PitchLetter) -> Pitch{
    switch(pitchLetter){
    case PitchLetter.A:
        return Pitch(absolutePitch: 0)
    case PitchLetter.B:
        return Pitch(absolutePitch: 2)
    case PitchLetter.C:
        return Pitch(absolutePitch: 3)
    case PitchLetter.D:
        return Pitch(absolutePitch: 5)
    case PitchLetter.E:
        return Pitch(absolutePitch: 7)
    case PitchLetter.F:
        return Pitch(absolutePitch: 8)
    case PitchLetter.G:
        return Pitch(absolutePitch: 10)
    }
}

class Keyboard:NSObject{
    static func isIvory(_ pitch:Pitch) -> Bool{
        let isIvory:Bool
        switch(pitch.basePitch()){
        case 0:
            isIvory = true
        case 1:
            isIvory = false
        case 2:
            isIvory = true
        case 3:
            isIvory = true
        case 4:
            isIvory = false
        case 5:
            isIvory = true
        case 6:
            isIvory = false
        case 7:
            isIvory = true
        case 8:
            isIvory = true
        case 9:
            isIvory = false
        case 10:
            isIvory = true
        case 11:
            isIvory = false
        default:
            isIvory = true
        }
        
        return isIvory
    }
    static func staffDistanceIfIvories(_ pitch:Pitch, comparisonPitch:Pitch) -> Int?{
        if(!self.isIvory(pitch) || !self.isIvory(comparisonPitch)){
            return nil
        }
        if pitch.absolutePitch == comparisonPitch.absolutePitch {
            return 0
        }
        if pitch.absolutePitch > comparisonPitch.absolutePitch {
            return -1 * self.staffDistanceIfIvories(comparisonPitch, comparisonPitch: pitch)!
        }
        var ivoriesBetween = 0
        for currentAbsolutePitch in pitch.absolutePitch ... comparisonPitch.absolutePitch-1 {
            let currentPitch = Pitch(absolutePitch: currentAbsolutePitch)
            if isIvory(currentPitch){
                ivoriesBetween += 1
            }
        }
        return ivoriesBetween
    }
    
    static func letterIfIvory(_ possibleIvoryPitch:Pitch) -> PitchLetter?{
        if(Keyboard.isIvory(possibleIvoryPitch)){
            let noteLetter:PitchLetter
            switch(possibleIvoryPitch.basePitch()){
            case 0:
                noteLetter = PitchLetter.A
            case 2:
                noteLetter = PitchLetter.B
            case 3:
                noteLetter = PitchLetter.C
            case 5:
                noteLetter = PitchLetter.D
            case 7:
                noteLetter = PitchLetter.E
            case 8:
                noteLetter = PitchLetter.F
            case 10:
                noteLetter = PitchLetter.G
            default:
                noteLetter = PitchLetter.A
            }
            return noteLetter
        }
        return nil
    }
}
