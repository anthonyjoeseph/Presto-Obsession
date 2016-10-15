//
//  GameCountState.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 1/10/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation

protocol GameCountState{
    var stateMachine:GameCountStateMachine? { get set }
    func isWaiting() -> Bool
    func pickNewElement() -> GameElement
    func updateCycle()
}

enum CountState{
    case noteAndClefState, tempoChangeState, keySignatureChangeState
}

class GameCountStateMachine{
    let difficultyLevel:DifficultyLevel
    
    fileprivate var currentState:GameCountState
    fileprivate var noteAndClefState:NoteAndClefState = NoteAndClefState()
    fileprivate var keySignatureChangingState:KeySignatureChangingState = KeySignatureChangingState()
    fileprivate var tempoChangingState:TempoChangingState = TempoChangingState()
    var areNotesCleared: ((Void) -> Bool)?
    
    init(difficultyLevel:DifficultyLevel){
        self.difficultyLevel = difficultyLevel
        self.currentState = self.noteAndClefState
        self.noteAndClefState.stateMachine = self
        self.keySignatureChangingState.stateMachine = self
        self.tempoChangingState.stateMachine = self
    }
    
    func changeState(_ newState:CountState){
        switch(newState){
        case CountState.noteAndClefState:
            self.currentState = self.noteAndClefState
            break
        case CountState.tempoChangeState:
            self.currentState = self.tempoChangingState
            break
        case CountState.keySignatureChangeState:
            self.currentState = self.keySignatureChangingState
            break
        }
    }
    
    func isWaiting() -> Bool{
        return self.currentState.isWaiting()
    }
    
    func pickNewElement() -> GameElement{
        return self.currentState.pickNewElement()
    }
    
    func updateCycle(){
        return self.currentState.updateCycle()
    }
}

