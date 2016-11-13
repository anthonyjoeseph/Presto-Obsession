//
//  MusicElements.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/19/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation

class MusicElements:NSObject{
    
    let difficultyLevel:DifficultyLevel
    var currentBPM:Int = GameModel.defaultBPM
    var currentClef:Clef = Clef(isTrebleClef: true)
    var previousKeySignature:MajorKeySignature = MajorKeySignature(keyTitleLetter: PitchLetter.C, keyTitleType: KeyType.None)!
    var currentKeySignature:MajorKeySignature = MajorKeySignature(keyTitleLetter: PitchLetter.C, keyTitleType: KeyType.None)!
    var currentKeyRange:KeyRange = GameModel.trebleKeyRange
    
    init(difficultyLevel:DifficultyLevel){
        self.difficultyLevel = difficultyLevel
        switch(self.difficultyLevel){
        case DifficultyLevel.beginner:
            self.currentBPM = 40
            break
        case DifficultyLevel.intermediate:
            self.currentBPM = 50
            break
        case DifficultyLevel.expert:
            self.currentBPM = 60
            break
        }
    }
    
    func newNote() -> Note{
        let randomPitch:Pitch
        if(self.difficultyLevel == DifficultyLevel.beginner){
            randomPitch = randomPitchInKey()
        }else{
            randomPitch = anyRandomPitch()
        }
        return Note(pitch: randomPitch, rhythm: Rhythm.quarter)
    }
    
    fileprivate func anyRandomPitch() -> Pitch{
        let rangeSize:UInt32 = UInt32(self.currentKeyRange.highPitch().absolutePitch - self.currentKeyRange.lowPitch().absolutePitch)
        let randomIndex:Int = Int(arc4random_uniform(rangeSize))
        return self.currentKeyRange.pitches[randomIndex]
    }
    
    fileprivate func randomPitchInKey() -> Pitch{
        let randomPitch = anyRandomPitch()
        if(self.currentKeySignature.isInKey(randomPitch)){
            return randomPitch
        }
        return randomPitchInKey()
    }
    
    func changeClef(){
        let createdClef = Clef(isTrebleClef: !self.currentClef.isTrebleClef)
        if(self.currentClef.isTrebleClef){
            self.currentKeyRange = GameModel.trebleKeyRange
        }else{
            self.currentKeyRange = GameModel.bassKeyRange
        }
        self.currentClef = createdClef
        
        if(self.currentClef.isTrebleClef){
            self.currentKeyRange = GameModel.trebleKeyRange
        }else{
            self.currentKeyRange = GameModel.bassKeyRange
        }
    }
    
    func changeKeySignature(){
        let newKeyLetter:PitchLetter
        let randomLetterIndex = arc4random_uniform(7)
        switch(randomLetterIndex){
        case 0:
            newKeyLetter = PitchLetter.A
            break
        case 1:
            newKeyLetter = PitchLetter.B
            break
        case 2:
            newKeyLetter = PitchLetter.C
            break
        case 3:
            newKeyLetter = PitchLetter.D
            break
        case 4:
            newKeyLetter = PitchLetter.E
            break
        case 5:
            newKeyLetter = PitchLetter.F
            break
        case 6:
            newKeyLetter = PitchLetter.G
            break
        default:
            newKeyLetter = PitchLetter.A
            break
        }
        
        var newKeyType:KeyType
        let randomAccidentalIndex = arc4random_uniform(3)
        switch(randomAccidentalIndex){
        case 0:
            newKeyType = KeyType.None
            break
        case 1:
            newKeyType = KeyType.Flat
            break
        case 2:
            newKeyType = KeyType.Sharp
            break
        default:
            newKeyType = KeyType.None
            break
        }
        if(newKeyLetter == PitchLetter.B && newKeyType == KeyType.Sharp){
            newKeyType = KeyType.None
        }else if(newKeyLetter == PitchLetter.E && newKeyType == KeyType.Sharp){
            newKeyType = KeyType.None
        }else if(newKeyLetter == PitchLetter.F && newKeyType == KeyType.Flat){
            newKeyType = KeyType.None
        }else if(newKeyLetter == PitchLetter.G && newKeyType == KeyType.Sharp){
            newKeyType = KeyType.None
        }else if(newKeyLetter == PitchLetter.A && newKeyType == KeyType.Sharp){
            newKeyType = KeyType.None
        }else if(newKeyLetter == PitchLetter.D && newKeyType == KeyType.Sharp){
            newKeyType = KeyType.None
        }
        self.previousKeySignature = self.currentKeySignature
        self.currentKeySignature = MajorKeySignature(keyTitleLetter: newKeyLetter, keyTitleType: newKeyType)!
    }
    
    func increaseBPM(){
        if(self.difficultyLevel == DifficultyLevel.beginner){
            self.currentBPM += 5
        }else{
            self.currentBPM += 10
        }
    }
}
