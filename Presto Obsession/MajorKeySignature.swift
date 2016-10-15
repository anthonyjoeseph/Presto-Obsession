//
//  MajorKeySignature.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/20/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

enum Accidental:String {
    case None = "", Natural = "nat", Sharp = "#", Flat = "b";
}

enum KeyType:String {
    case None = "", Sharp = "sharp", Flat = "flat";
}

class MajorKeySignature{
    let keyTitleLetter:PitchLetter
    let keyTitleType:KeyType
    let keyType:KeyType
    fileprivate var accidentalPitchLetters:[PitchLetter]
    fileprivate var nonSolfegAccidentals:Dictionary<Int, Accidental>
    
    init?(keyTitleLetter:PitchLetter, keyTitleType:KeyType){
        self.keyTitleLetter = keyTitleLetter
        self.keyTitleType = keyTitleType
        self.accidentalPitchLetters = []
        self.nonSolfegAccidentals = Dictionary<Int, Accidental>()
        
        if(keyTitleLetter == PitchLetter.C && keyTitleType == KeyType.None){
            self.keyType = KeyType.None
        }else if((keyTitleType == KeyType.None && keyTitleLetter != PitchLetter.F) || keyTitleType == KeyType.Sharp){
            self.keyType = KeyType.Sharp
        }else{
            self.keyType = KeyType.Flat
        }
        
        if (keyTitleLetter == PitchLetter.F && keyTitleType == KeyType.Flat) ||
            (keyTitleLetter == PitchLetter.E && keyTitleType == KeyType.Sharp) ||
            (keyTitleLetter == PitchLetter.G && keyTitleType == KeyType.Sharp) ||
            (keyTitleLetter == PitchLetter.B && keyTitleType == KeyType.Sharp) ||
            (keyTitleLetter == PitchLetter.A && keyTitleType == KeyType.Sharp) ||
            (keyTitleLetter == PitchLetter.D && keyTitleType == KeyType.Sharp){
            return nil
        }
        
        populateAccidentalPitchLetters()
        
        populateAccidentals()
    }
    
    fileprivate func populateAccidentalPitchLetters(){
        if(keyTitleLetter == PitchLetter.C && self.keyTitleType == KeyType.None){
            self.accidentalPitchLetters = []
        }else{
            let accidentalsInOrder:[PitchLetter]
            var absolutePitchFromKeyLetter = lowestPitchForLetter(self.keyTitleLetter).absolutePitch + 36 //three octaves up
            if(self.keyTitleType == KeyType.Flat){
                absolutePitchFromKeyLetter -= 1
            }else if(self.keyTitleType == KeyType.Sharp){
                absolutePitchFromKeyLetter += 1
            }
            let pitchFromKeyLetter = Pitch(absolutePitch: absolutePitchFromKeyLetter)
            let numFourthsFromC:Int
            let intervalDirection:IntervalDirection
            if(self.keyType == KeyType.Sharp){
                accidentalsInOrder = [PitchLetter.F, PitchLetter.C, PitchLetter.G, PitchLetter.D,
                    PitchLetter.A, PitchLetter.E, PitchLetter.B]
                intervalDirection = IntervalDirection.down
            }else{
                accidentalsInOrder = [PitchLetter.B, PitchLetter.E, PitchLetter.A, PitchLetter.D,
                    PitchLetter.G, PitchLetter.C, PitchLetter.F]
                intervalDirection = IntervalDirection.up
            }
            numFourthsFromC = fourthsFromC(pitchFromKeyLetter, intervalDirection: intervalDirection)
            self.accidentalPitchLetters = Array(accidentalsInOrder[0...numFourthsFromC-1])
        }
    }
    
    fileprivate func fourthsFromC(_ relativePitch:Pitch, intervalDirection:IntervalDirection) -> Int{
        var currentPitch = Pitch.middleC
        var fourthCounter = 0
        while (currentPitch.basePitch()) != (relativePitch.basePitch()){
            currentPitch = currentPitch.interval(Interval(distance:IntervalDistance.perfectFourth, direction: intervalDirection))
            fourthCounter += 1
        }
        return fourthCounter
    }
    
    fileprivate func populateAccidentals(){
        var tonicPitch:Pitch = lowestPitchForLetter(self.keyTitleLetter).interval(Interval(distance:IntervalDistance.perfectOctave, direction: IntervalDirection.up))
        let nextPitchAccidental:Accidental
        
        switch(self.keyTitleType){
        case KeyType.Flat:
            tonicPitch = tonicPitch.interval(Interval(distance:IntervalDistance.halfStep, direction: IntervalDirection.down))
            nextPitchAccidental = Accidental.Natural
            break
        case KeyType.Sharp:
            tonicPitch = tonicPitch.interval(Interval(distance: IntervalDistance.halfStep, direction: IntervalDirection.up))
            nextPitchAccidental = Accidental.Natural
            break
        default:
            let halfStepUp:Pitch = tonicPitch.interval(Interval(distance: IntervalDistance.halfStep, direction: IntervalDirection.up))
            if Keyboard.isIvory(halfStepUp) {
                nextPitchAccidental = Accidental.Natural
            }else{
                nextPitchAccidental = Accidental.Flat
            }
            break
        }
        self.nonSolfegAccidentals[tonicPitch.basePitch()] = Accidental.None
        self.nonSolfegAccidentals[tonicPitch.interval(Interval(distance: IntervalDistance.halfStep, direction: IntervalDirection.up)).basePitch()]
            = nextPitchAccidental
        
        let majorScaleSteps:[IntervalDistance] =
            [IntervalDistance.wholeStep,
             IntervalDistance.halfStep,
             IntervalDistance.wholeStep,
             IntervalDistance.wholeStep,
             IntervalDistance.wholeStep,
             IntervalDistance.wholeStep]
        let possibleAccidentals = [Accidental.Flat, Accidental.None, Accidental.Sharp, Accidental.Flat, Accidental.Flat]
        var currentPitch:Pitch = tonicPitch.interval(Interval(distance: IntervalDistance.wholeStep, direction: IntervalDirection.up))
        for index:Int in 0...4{
            self.nonSolfegAccidentals[currentPitch.basePitch()] = Accidental.None
            let halfStepUp:Pitch = currentPitch.interval(Interval(distance: IntervalDistance.halfStep, direction: IntervalDirection.up))
            if Keyboard.isIvory(halfStepUp) {
                self.nonSolfegAccidentals[halfStepUp.basePitch()] = Accidental.Natural
            }else{
                self.nonSolfegAccidentals[halfStepUp.basePitch()] = possibleAccidentals[index]
            }
            currentPitch = currentPitch.interval(Interval(distance: majorScaleSteps[index], direction: IntervalDirection.up))
        }
        self.nonSolfegAccidentals[currentPitch.basePitch()] = Accidental.None
    }
    
    func isInKey(_ pitch:Pitch) -> Bool{
        return self.nonSolfegAccidentals[pitch.basePitch()]! == Accidental.None;
    }
    
    func nameForPitch(_ pitch:Pitch) -> String{
        let relativeIvory = relativeIvoryPitch(pitch)
        let accidentalRaw = self.nonSolfegAccidentals[pitch.basePitch()]!.rawValue
        let letter = Keyboard.letterIfIvory(relativeIvory)!
        return letter.rawValue + accidentalRaw;
    }
    
    func relativeIvoryPitch(_ pitch:Pitch) -> Pitch{
        var absoluteIvoryPitch:Int = 0
        
        switch(self.nonSolfegAccidentals[pitch.basePitch()]!){
        case Accidental.None:
            if(Keyboard.isIvory(pitch)){
                if(self.keyType == KeyType.Sharp){
                    let halfStepDown = pitch.interval(Interval(distance: IntervalDistance.halfStep, direction: IntervalDirection.down))
                    if(Keyboard.isIvory(halfStepDown) &&
                        self.accidentalPitchLetters.contains(Keyboard.letterIfIvory(halfStepDown)!)){
                        absoluteIvoryPitch = pitch.absolutePitch - 1
                    }else{
                        absoluteIvoryPitch = pitch.absolutePitch
                    }
                }else{
                    let halfStepUp = pitch.interval(Interval(distance: IntervalDistance.halfStep, direction: IntervalDirection.up))
                    if(Keyboard.isIvory(halfStepUp) &&
                        self.accidentalPitchLetters.contains(Keyboard.letterIfIvory(halfStepUp)!)){
                            absoluteIvoryPitch = pitch.absolutePitch + 1
                    }else{
                        absoluteIvoryPitch = pitch.absolutePitch
                    }
                }
            }else{
                if(self.keyType == KeyType.Sharp){
                    absoluteIvoryPitch = pitch.absolutePitch - 1
                }else{
                    absoluteIvoryPitch = pitch.absolutePitch + 1
                }
            }
            break
        case Accidental.Natural:
            absoluteIvoryPitch = pitch.absolutePitch
            break
        case Accidental.Flat:
            absoluteIvoryPitch = pitch.absolutePitch + 1
            break
        case Accidental.Sharp:
            absoluteIvoryPitch = pitch.absolutePitch - 1
            break
        }
        return Pitch(absolutePitch: absoluteIvoryPitch);
    }
    
    func nonSolfegAccidental(_ pitch:Pitch) -> Accidental{
        /*let nonSolfegAccidental = self.nonSolfegAccidentals[pitch.basePitch()]!
        if let defPreviousPitch = previousPitch{
            if ((self.nonSolfegAccidentals[defPreviousPitch.basePitch()]! != Accidental.None)
                && self.relativeIvoryPitch(defPreviousPitch) == self.relativeIvoryPitch(pitch)){
                if(pitch == previousPitch){
                    return Accidental.None
                }else if(nonSolfegAccidental == Accidental.None){
                    return Accidental.Natural
                }
            }
        }
        return nonSolfegAccidental;*/
        return self.nonSolfegAccidentals[pitch.basePitch()]!
    }
    
    func toString() -> String{
        return self.keyTitleLetter.rawValue + self.keyTitleType.rawValue
    }
    
    func getAccidentalPitchLetters() -> [PitchLetter]{
        return accidentalPitchLetters
    }
}
