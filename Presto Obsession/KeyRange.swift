//
//  KeyRange.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation

class KeyRange:NSObject {
    var pitches:Array<Pitch>
    let numIvoryKeys:Int
    
    init(lowPitch:Pitch, highPitch:Pitch){
        pitches = Array<Pitch>()
        var numIvoryKeysMutable:Int = 0
        for currentAbsPitch in lowPitch.absolutePitch ... highPitch.absolutePitch {
            let newPitch = Pitch(absolutePitch:currentAbsPitch)
            pitches.append(newPitch)
            if(Keyboard.isIvory(newPitch)){
                numIvoryKeysMutable += 1
            }
        }
        numIvoryKeys = numIvoryKeysMutable
    }
    
    func lowPitch() -> Pitch{
        return pitches.first!
    }
    
    func highPitch() -> Pitch{
        return pitches.last!
    }
    
    func ivoryIndex(_ midPitch:Pitch) -> Int?{
        let lowPitch = self.lowPitch()
        let highPitch = self.highPitch()
        if(lowPitch.absolutePitch <= midPitch.absolutePitch
            && midPitch.absolutePitch <= highPitch.absolutePitch){
                var ivoryPitchCount:Int = 0
                if lowPitch.absolutePitch < midPitch.absolutePitch {
                    for currentPitchAbs in lowPitch.absolutePitch ... midPitch.absolutePitch - 1 {
                        let currentPitchIndex = currentPitchAbs - lowPitch.absolutePitch
                        let currentPitch:Pitch = self.pitches[currentPitchIndex]
                        if Keyboard.isIvory(currentPitch){
                            ivoryPitchCount += 1
                        }
                    }
                }
                return ivoryPitchCount
        }
        return nil
    }
}
