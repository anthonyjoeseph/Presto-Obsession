//
//  KeySignatureSprite.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/27/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import Foundation
import SpriteKit

class KeySignatureSprite: SKSpriteNode, StaffElementNode{
    
    fileprivate static let keySigXPosLedgerLines:CGFloat = 5
    
    fileprivate let xSpaceBetweenAccidentals:CGFloat = CGFloat(30)
    
    fileprivate var accidentalIncrements:[Int]
    fileprivate var accidental:Accidental
    fileprivate var overheadLetter:SKLabelNode? = nil
    
    fileprivate var courtesyKeySig:KeySignatureSprite?
    fileprivate var courtesyKeySigPadding:CGFloat?
    
    init(accidentalIncrements:[Int], accidental:Accidental){
        self.accidentalIncrements = accidentalIncrements
        self.accidental = accidental
        super.init(texture: nil, color: UIColor.clear, size: CGSize(width: 1, height: 1))
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.accidentalIncrements = []
        self.accidental = Accidental.None
        super.init(coder: aDecoder)
    }
    
    func addAccidentals(_ ledgerLineSpace:CGFloat){
        var currentXPosition:CGFloat = CGFloat(0)
        for incrementsFromMiddle:Int in accidentalIncrements{
            let accidentalSprite:SKSpriteNode
            let noteHeight = ledgerLineSpace
            let desiredAccidentalHeight:CGFloat
            
            switch(accidental){
            case Accidental.Sharp:
                accidentalSprite = SKSpriteNode(imageNamed: "Sharp")
                desiredAccidentalHeight = noteHeight * 1.7
                break
            case Accidental.Flat:
                accidentalSprite = SKSpriteNode(imageNamed: "Flat")
                desiredAccidentalHeight = noteHeight * 2
                accidentalSprite.anchorPoint = CGPoint(x: 0.5, y: 0.25)
                break
            case Accidental.Natural:
                accidentalSprite = SKSpriteNode(imageNamed: "Natural")
                desiredAccidentalHeight = noteHeight * 1.7
                break
            default:
                accidentalSprite = SKSpriteNode(imageNamed: "Natural")
                desiredAccidentalHeight = noteHeight * 1.7
                break
            }
            
            let currentAccidentalHeight = accidentalSprite.size.height
            let heightScale = desiredAccidentalHeight/currentAccidentalHeight
            accidentalSprite.xScale = heightScale
            accidentalSprite.yScale = heightScale
            
            let positionOnStaff = CGPoint(x: currentXPosition, y: CGFloat(incrementsFromMiddle)*(ledgerLineSpace/2))
            accidentalSprite.position = positionOnStaff
            currentXPosition += xSpaceBetweenAccidentals
            self.addChild(accidentalSprite)
        }
        
        if let unwrapCourtesyKeySig = self.courtesyKeySig{
            self.courtesyKeySig?.addAccidentals(ledgerLineSpace)
            
            unwrapCourtesyKeySig.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            let keySignaturePadding = unwrapCourtesyKeySig.calculateAccumulatedFrame().width + 30
            unwrapCourtesyKeySig.position = CGPoint(x: -keySignaturePadding, y: 0)
            self.addChild(unwrapCourtesyKeySig)
            
            self.courtesyKeySigPadding = keySignaturePadding
        }
    }
    
    func addCourtesyKeySig(_ courtesyKeySig:KeySignatureSprite){
        
        self.courtesyKeySig = courtesyKeySig
    }
    
    func removeCourtesyKeySig(){
        if let unwrapCourtesyKeySig = self.courtesyKeySig{
            unwrapCourtesyKeySig.removeFromParent()
        }
    }
    
    func getCourtesyKeySigPadding() -> CGFloat?{
        return self.courtesyKeySigPadding
    }
    
    func positionOnStaff(_ staffSize: CGSize, ledgerLineSpace: CGFloat) -> CGPoint{
        self.anchorPoint = CGPoint(x: 0, y: 0.5)
        let middlePosition = staffSize.height/2
        return CGPoint(x: KeySignatureSprite.keySigXPosLedgerLines*ledgerLineSpace, y: middlePosition)
    }
    
    func acceptStaffDimensions(_ staffSize:CGSize, ledgerLineSpace:CGFloat){
        self.addAccidentals(ledgerLineSpace)
    }
    
    func onePerStaff() -> Bool{
        return true
    }
    
    func staffElementType() -> StaffElementType{
        return StaffElementType.keySignature
    }
    
    func hasMidPointWhenAnimating() -> Bool{
        return true
    }
}
