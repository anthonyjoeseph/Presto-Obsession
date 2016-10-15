//
//  NoteAndClefState.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 1/11/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation

class NoteAndClefState:GameCountState{
    var stateMachine:GameCountStateMachine?
    var noteCountSinceNewKeySignature:Int = 0
    var noteCountSinceNewClef:Int = 0
    var noteCountSinceTempoChange:Int = 0
    
    fileprivate func oddsOfNewClef() -> Float{
        if(noteCountSinceNewClef > 6){
            switch(self.stateMachine!.difficultyLevel){
            case DifficultyLevel.beginner:
                return 0
            case DifficultyLevel.intermediate:
                return 0.3
            case DifficultyLevel.expert:
                return 0.3
            }
        }else{
            return 0
        }
    }
    
    fileprivate func oddsOfNewKeySignature() -> Float{
        if(noteCountSinceNewKeySignature > 6){
            switch(self.stateMachine!.difficultyLevel){
            case DifficultyLevel.beginner:
                return 0
            case DifficultyLevel.intermediate:
                return 0
            case DifficultyLevel.expert:
                return 0.3
            }
        }else{
            return 0
        }
    }
    
    fileprivate func randomFromZeroToOne() -> Float{
        return Float(arc4random()) / Float(UINT32_MAX)
    }
    
    fileprivate func randomElement() -> GameElement{
        var random:Float = randomFromZeroToOne()
        if(random < oddsOfNewKeySignature()){
            return GameElement.keySignature
        }
        random -= oddsOfNewKeySignature()
        if(random < oddsOfNewClef()){
            return GameElement.clef
        }
        return GameElement.note
    }
    
    func isWaiting() -> Bool{
        if(noteCountSinceTempoChange >= 20){
            noteCountSinceTempoChange = 0
            self.stateMachine!.changeState(CountState.tempoChangeState)
            return true
        }
        return false
    }
    func pickNewElement() -> GameElement{
        var newElement = randomElement()
        if(newElement == GameElement.keySignature){
            newElement = GameElement.note
        }
        switch(newElement){
        case GameElement.note:
            noteCountSinceTempoChange += 1
            noteCountSinceNewClef += 1
            noteCountSinceNewKeySignature += 1
            break
        case GameElement.clef:
            noteCountSinceNewClef = 0
            break
        default:
            break
        }
        return newElement
    }
    func updateCycle(){
        let randElement = randomElement()
        if(randElement == GameElement.keySignature){
            noteCountSinceNewKeySignature = 0
            self.stateMachine!.changeState(CountState.keySignatureChangeState)
        }
    }
}
