//
//  ClefSprite.swift
//  Sight Read Pro
//
//  Created by Anthony Gabriele on 7/8/16.
//  Copyright © 2016 Anthony Gabriele Company. All rights reserved.
//

import Foundation
import SpriteKit

class ClefSprite: SKSpriteNode, StaffElementNode{
    
    fileprivate static let trebleClefImageName = "TrebleClef"
    fileprivate static let bassClefImageName = "BassClef"
    
    fileprivate static let clefXPosLedgerLines:CGFloat = 3
    
    fileprivate var clefTexture:SKTexture?
    fileprivate let isTrebleClef:Bool
    
    init(isTrebleClef:Bool){
        self.isTrebleClef = isTrebleClef
        if(isTrebleClef){
            self.clefTexture = SKTexture(imageNamed:ClefSprite.trebleClefImageName)
        }else{
            self.clefTexture = SKTexture(imageNamed:ClefSprite.bassClefImageName)
        }
        super.init(texture: self.clefTexture!, color: SKColor.clear, size: self.clefTexture!.size())
    }
    
    required init?(coder aDecoder: NSCoder){
        self.isTrebleClef = true
        self.clefTexture = SKTexture(imageNamed:ClefSprite.trebleClefImageName)
        super.init(coder: aDecoder)
    }
    
    func positionOnStaff(_ staffSize: CGSize, ledgerLineSpace: CGFloat) -> CGPoint{
        
        let clefYOffset:CGFloat
        if self.isTrebleClef {
            clefYOffset = -27
        }else{
            self.anchorPoint = CGPoint(x: 0.5, y: 0.4)
            clefYOffset = 8
        }
        
        let middlePosition = staffSize.height/2
        return CGPoint(x: ClefSprite.clefXPosLedgerLines*ledgerLineSpace, y: middlePosition + clefYOffset)
    }
    
    func acceptStaffDimensions(_ staffSize:CGSize, ledgerLineSpace:CGFloat){
        //set height
        let staffHeight = staffSize.height
        let desiredClefHeight:CGFloat
        if self.isTrebleClef {
            desiredClefHeight = staffHeight * 1.8
        }else{
            self.anchorPoint = CGPoint(x: 0.5, y: 0.4)
            desiredClefHeight = staffHeight * 0.8
        }
        let currentClefHeight = self.size.height
        let heightScale = desiredClefHeight/currentClefHeight
        self.xScale = heightScale
        self.yScale = heightScale
    }
    
    func onePerStaff() -> Bool{
        return true
    }
    
    func staffElementType() -> StaffElementType{
        return StaffElementType.clef
    }
    
    func hasMidPointWhenAnimating() -> Bool{
        return true
    }
}
