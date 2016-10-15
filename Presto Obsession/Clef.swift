//
//  Clef.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/27/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

struct LedgerLines{
    let NumLines:Int
    let IsOnLine:Bool
    let IsAboveStaff:Bool
}

class Clef{
    let B4MiddleTrebleClef = Pitch(absolutePitch: 50)
    let D2MiddleBassClef = Pitch(absolutePitch: 29)
    let A4TrebleBaseA = Pitch(absolutePitch: 48)
    let A2BassBaseA = Pitch(absolutePitch: 24)
    let G4HighestTrebleSharp = Pitch(absolutePitch: 58)
    let E4HighestTrebleFlat = Pitch(absolutePitch: 55)
    let G2HighestBassSharp = Pitch(absolutePitch: 34)
    let E2HighestBassFlat = Pitch(absolutePitch: 31)
    
    static let numStepsInsideStaff:Int = 11
    let isTrebleClef:Bool
    let middlePitch:Pitch
    
    init(isTrebleClef:Bool){
        self.isTrebleClef = isTrebleClef
        if(isTrebleClef){
            self.middlePitch = B4MiddleTrebleClef
        }else{
            self.middlePitch = D2MiddleBassClef
        }
    }
    
    func incrementsFromMiddle(_ pitch:Pitch, keySignature:MajorKeySignature) -> Int{
        let relativeIvory = keySignature.relativeIvoryPitch(pitch)
        return Keyboard.staffDistanceIfIvories(self.middlePitch, comparisonPitch: relativeIvory)!
    }
    
    func isStemUp(_ pitch:Pitch, keySignature:MajorKeySignature) -> Bool{
        return incrementsFromMiddle(pitch, keySignature: keySignature) < 0
    }
    
    func ledgerLines(_ pitch:Pitch, keySignature:MajorKeySignature) -> LedgerLines?{
        let numIncrementsFromMiddleInStaff:Int = 5
        let incrementsFromMiddleForPitch:Int = incrementsFromMiddle(pitch, keySignature: keySignature)
        let numIncrementsAbove:Int
        if(incrementsFromMiddleForPitch > numIncrementsFromMiddleInStaff){
            numIncrementsAbove = incrementsFromMiddleForPitch - numIncrementsFromMiddleInStaff
        }else if (incrementsFromMiddleForPitch < -numIncrementsFromMiddleInStaff){
            numIncrementsAbove = incrementsFromMiddleForPitch + numIncrementsFromMiddleInStaff
        }else{
            return nil
        }
        return LedgerLines(NumLines: (abs(numIncrementsAbove)+1)/2, IsOnLine: abs(numIncrementsAbove)%2==1, IsAboveStaff: numIncrementsAbove > 0)
    }
    func keySignatureAccidentalIncrementsFromMiddle(_ accidentalLetters:[PitchLetter], keyType:KeyType) -> [Int]{
        var allIncrements:[Int] = []
        for accidentalLetter in accidentalLetters{
            let baseAPitch:Pitch
            let highestPitch:Pitch
            if isTrebleClef {
                baseAPitch = A4TrebleBaseA
                if(keyType == KeyType.Sharp){
                    highestPitch = G4HighestTrebleSharp
                }else{
                    highestPitch = E4HighestTrebleFlat
                }
            }else{
                baseAPitch = A2BassBaseA
                if(keyType == KeyType.Sharp){
                    highestPitch = G2HighestBassSharp
                }else{
                    highestPitch = E2HighestBassFlat
                }
            }
            let basePitchForAccidental = lowestPitchForLetter(accidentalLetter)
            var accidentalPitch = Pitch(absolutePitch: basePitchForAccidental.absolutePitch + baseAPitch.absolutePitch)
            if(highestPitch.absolutePitch < accidentalPitch.absolutePitch){
                accidentalPitch = accidentalPitch.interval(Interval(distance: IntervalDistance.perfectOctave, direction: IntervalDirection.down))
            }
            allIncrements.append(Keyboard.staffDistanceIfIvories(self.middlePitch, comparisonPitch: accidentalPitch)!)
        }
        return allIncrements
    }
}
