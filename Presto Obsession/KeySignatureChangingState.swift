//
//  KeySignatureChangingState.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 1/11/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation

class KeySignatureChangingState:GameCountState{
    var stateMachine:GameCountStateMachine?
    
    var cyclesSinceStart = 0
    
    func isWaiting() -> Bool{
        if(cyclesSinceStart == 0){
            return true
        }
        if(cyclesSinceStart == 1){
            return false
        }
        if(cyclesSinceStart == 2){
            return true
        }
        if(cyclesSinceStart == 3){
            return true
        }
        cyclesSinceStart = 0
        self.stateMachine?.changeState(CountState.noteAndClefState)
        return false
    }
    func pickNewElement() -> GameElement{
        return GameElement.keySignature
    }
    func updateCycle(){
        cyclesSinceStart += 1
    }
}
