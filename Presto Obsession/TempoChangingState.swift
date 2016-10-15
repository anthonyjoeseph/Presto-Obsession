//
//  TempoChangingState.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 1/11/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation

class TempoChangingState:GameCountState{
    var stateMachine:GameCountStateMachine?
    
    func isWaiting() -> Bool{
        return !self.stateMachine!.areNotesCleared!()
    }
    func pickNewElement() -> GameElement{
        self.stateMachine?.changeState(CountState.noteAndClefState)
        return GameElement.tempo
    }
    func updateCycle(){
        //nothing
    }
}
