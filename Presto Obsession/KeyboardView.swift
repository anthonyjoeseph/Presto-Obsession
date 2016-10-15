//
//  KeyboardView.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 8/26/15.
//  Copyright (c) 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import UIKit

class KeyboardView: UIView{
    
    fileprivate let ivoryToEbonyWidth:CGFloat = 0.7
    fileprivate let ivoryToEbonyHeight:CGFloat = 0.5
    
    var keyRange:KeyRange
    fileprivate var keys:Array<KeyBase> = []
    
    //defined in "layoutSubviews"
    fileprivate var ivoryWidth:CGFloat = 0
    fileprivate var ivoryHeight:CGFloat = 0
    fileprivate var ebonyWidth:CGFloat = 0
    fileprivate var ebonyHeight:CGFloat = 0
    
    var pressedPitchesFunc: (Set<Pitch>) -> Void
    var releasedFunc: (Void) -> Void
    var keysHaveLetters:Bool = false

    required init?(coder aDecoder: NSCoder) {
        self.keyRange = KeyRange(lowPitch: Pitch(absolutePitch: 0), highPitch: Pitch(absolutePitch: 0))
        //empty, client can override
        self.pressedPitchesFunc =  {( n:Set<Pitch> ) -> Void in }
        self.releasedFunc = {(Void) -> Void in }
        super.init(coder: aDecoder)
    }
    
    func addKey(_ pitch:Pitch){
        let newKey:KeyBase
        if(self.keysHaveLetters){
            newKey = KeyBase(isIvory: Keyboard.isIvory(pitch), pitchLetterOp: Keyboard.letterIfIvory(pitch))
        }else{
            newKey = KeyBase(isIvory: Keyboard.isIvory(pitch), pitchLetterOp: nil)
        }
        keys.append(newKey)
        
        var keyFrame:CGRect = CGRect.zero
        if Keyboard.isIvory(pitch) {
            keyFrame.size.width = ivoryWidth
            keyFrame.size.height = ivoryHeight
            keyFrame.origin.x = ivoryWidth * CGFloat(self.keyRange.ivoryIndex(pitch)!)
        }else{
            keyFrame.size.width = ebonyWidth
            keyFrame.size.height = ebonyHeight
            keyFrame.origin.x = ( ivoryWidth * CGFloat(self.keyRange.ivoryIndex(pitch)!) ) - (ebonyWidth/2)
        }
        newKey.frame = keyFrame
        
        newKey.isHighlighted = false
        newKey.isUserInteractionEnabled = false
        
        self.addSubview(newKey)
        if Keyboard.isIvory(pitch) {
            self.sendSubview(toBack: newKey)
        }
    }
    
    func removeAllKeysFromView(){
        for view:UIView in self.subviews {
            view.removeFromSuperview()
        }
        self.keys.removeAll(keepingCapacity: true)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        ivoryWidth = self.frame.size.width / CGFloat(self.keyRange.numIvoryKeys)
        ivoryHeight = self.frame.size.height
        ebonyWidth = ivoryWidth * ivoryToEbonyWidth
        ebonyHeight = ivoryHeight * ivoryToEbonyHeight
        
        self.removeAllKeysFromView()
        for pitch in self.keyRange.pitches {
            self.addKey(pitch)
        }
    }
    
    fileprivate func pitchForKeyIndex(_ keyIndex:Int) -> Pitch{
        let lowestKeyPitch:Pitch = self.keyRange.lowPitch()
        let keyAtIndexAbsolutePitch:Int = lowestKeyPitch.absolutePitch + keyIndex
        return Pitch(absolutePitch:keyAtIndexAbsolutePitch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var pressedPitches:Set<Pitch> = Set<Pitch>()
        for keyIndex in 0 ... self.keys.count-1 {
            let key:KeyBase = self.keys[keyIndex]
            let pressedKeyPitch:Pitch = self.pitchForKeyIndex(keyIndex)
            var keyIsPressed:Bool = false
            for touch:UITouch in touches {
                let location:CGPoint = touch.location(in: self)
                if key.frame.contains(location) {
                    var ignore:Bool = false
                    if Keyboard.isIvory(pressedKeyPitch) {
                        if keyIndex > 0 {
                            let previousKey:KeyBase = self.keys[keyIndex-1]
                            let previousPitch:Pitch = self.pitchForKeyIndex(keyIndex-1)
                            if (!Keyboard.isIvory(previousPitch) &&
                                previousKey.frame.contains(location)){
                                    ignore = true
                            }
                        }
                        if keyIndex < self.keys.count-1 {
                            let nextKey:KeyBase = self.keys[keyIndex+1]
                            let nextPitch:Pitch = self.pitchForKeyIndex(keyIndex+1)
                            if(!Keyboard.isIvory(nextPitch) &&
                                nextKey.frame.contains(location)){
                                    ignore = true
                            }
                        }
                    }
                    
                    if ignore == false {
                        keyIsPressed = true
                        if !key.isHighlighted {
                            key.isHighlighted = true
                            pressedPitches.insert(pressedKeyPitch)
                        }
                    }
                }
            }
            if keyIsPressed == false && key.isHighlighted{
                key.isHighlighted = false
            }
        }
        
        self.pressedPitchesFunc(pressedPitches)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesMoved(touches, with: event)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for keyImage:UIImageView in keys {
            for touch:UITouch in touches {
                let location:CGPoint = touch.location(in: self)
                if keyImage.frame.contains(location) {
                    if (touch.phase == UITouchPhase.ended ||
                        touch.phase == UITouchPhase.cancelled){
                            keyImage.isHighlighted = false
                    }
                }
            }
        }
        self.releasedFunc()
    }
}
