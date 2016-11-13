//
//  GameViewController.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/29/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import UIKit
import SpriteKit
import AudioToolbox
import GoogleMobileAds

class GameViewController: UIViewController {
    
    
    @IBOutlet var skViewOp:SKView?
    @IBOutlet var keyboardView:KeyboardView?
    @IBOutlet var countdownView:CountdownView?
    @IBOutlet weak var bannerView: GADBannerView!
    
    static let distanceBetweenBeats:Double = 60
    
    var difficultyLevel:DifficultyLevel = DifficultyLevel.beginner
    var gameModel:GameModel
    var gameScene:GameScene
    var isPlayingGame:Bool
    var previousNote:Note = Note(pitch:Pitch(absolutePitch:0), rhythm:Rhythm.quarter)
    
    var currentLetterIndex:Int = 0
    
    var audioSounds:Dictionary<Int, SystemSoundID>
    
    required init?(coder aDecoder: NSCoder) {
        self.audioSounds = Dictionary<Int, SystemSoundID>()
        self.gameModel = GameModel()
        self.gameScene = GameScene(size: CGSize(width: 0,height: 0))
        self.isPlayingGame = true
        super.init(coder: aDecoder)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if(self.isPlayingGame){
            let scoreUpdatedFunc = {
                self.gameScene.setScoreText(String(self.gameModel.getScore()))
            }
            let highScoreUpdatedFunc = {
                self.gameScene.setHighScoreText(String(self.gameModel.getHighScore()))
            }
            self.gameModel = GameModel(difficultyLevel: self.difficultyLevel, updateStaffWithGameElement: self.updateStaffWithGameElement, areNotesCleared: self.areNotesCleared, scoreUpdated: scoreUpdatedFunc, highScoreUpdated: highScoreUpdatedFunc)
            
            let skView = skViewOp!
            self.gameScene = GameScene(size: skView.bounds.size)
            skView.showsFPS = false
            skView.showsNodeCount = false
            skView.ignoresSiblingOrder = true
            gameScene.scaleMode = .resizeFill
            skView.presentScene(gameScene)
            
            self.gameModel.initializeScores()
            
            
            self.countdownView?.timerOverFunc = {self.gameModel.resetTimer()}
            self.keyboardView?.pressedPitchesFunc = self.pitchesPressed
            self.keyboardView?.releasedFunc = {self.gameScene.releaseNoteZone()}
            self.keyboardView?.keyRange = self.gameModel.musicElements.currentKeyRange
            if(self.difficultyLevel == DifficultyLevel.beginner){
                self.keyboardView?.keysHaveLetters = true
            }else{
                self.keyboardView?.keysHaveLetters = false
            }
            let keySignature = self.createKeySignatureSprite(self.gameModel.musicElements.currentKeySignature, clef: self.gameModel.musicElements.currentClef, isNaturals: false)
            let clefSprite = self.createClefSprite(self.gameModel.musicElements.currentClef)
            let tempoMarkingSprite = TempoMarkingSprite(tempoMarking: self.gameModel.musicElements.currentBPM)
            self.gameScene.staffNode.placeStaffElementNode(keySignature)
            self.gameScene.staffNode.placeStaffElementNode(clefSprite)
            self.gameScene.staffNode.placeStaffElementNode(tempoMarkingSprite)
        }
    }
    
    override func viewDidLoad() {
        self.bannerView.adUnitID = "ca-app-pub-5722576367260583/7404747359"
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        
        loadSounds()
        
        var soundID:SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "silent" as CFString!, "mp3" as CFString!, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        AudioServicesPlaySystemSound(soundID)
    }
    
    func loadSounds(){
        for index:Int in 0...87 {
            var soundID:SystemSoundID = 0
            let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), String(index) as CFString!, "aif" as CFString!, nil)
            AudioServicesCreateSystemSoundID(soundURL!, &soundID)
            self.audioSounds[index] = soundID
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //handle GameModel
    
    func updateStaffWithGameElement(_ newGameElement:GameElement){
        switch(newGameElement){
        case GameElement.note:
            let newNote = self.gameModel.musicElements.newNote()
            let newNoteSprite = self.createNoteSprite(newNote)
            let endFunc = {
                self.gameScene.staffNode.removeNoteSprite(newNoteSprite)
                self.gameOver()
            }
            self.gameScene.staffNode.animateStaffElementNode(newNoteSprite,
                                                              pixelsPerSecond: pixelsPerSecondFromTempo(),
                                                              midFunc: nil,
                                                              endFunc: endFunc)
            break
        case GameElement.keySignature:
            let newKeySignatureSprite = self.createKeySignatureSprite(self.gameModel.musicElements.currentKeySignature, clef: self.gameModel.musicElements.currentClef, isNaturals: false)
            let oldKeySignatureSprite = self.createKeySignatureSprite(self.gameModel.musicElements.previousKeySignature, clef: self.gameModel.musicElements.currentClef, isNaturals: true)
            newKeySignatureSprite.addCourtesyKeySig(oldKeySignatureSprite)
            self.gameScene.staffNode.animateStaffElementNode(newKeySignatureSprite,
                                                            pixelsPerSecond: pixelsPerSecondFromTempo(),
                                                            midFunc: nil, endFunc: nil)
            break
        case GameElement.clef:
            let newClefSprite = self.createClefSprite(self.gameModel.musicElements.currentClef)
            let keySigAtThisTime = self.gameModel.musicElements.currentKeySignature
            let clefAtThisTime = self.gameModel.musicElements.currentClef
            let clefsKeyRangeAtThisTime = self.gameModel.musicElements.currentKeyRange
            let midFunc = {() -> Void in
                self.keyboardView!.keyRange = clefsKeyRangeAtThisTime
            }
            let endFunc = {
                let newKeySigSprite = self.createKeySignatureSprite(keySigAtThisTime, clef: clefAtThisTime, isNaturals: false)
                self.gameScene.staffNode.placeStaffElementNode(newKeySigSprite)
            }
            self.gameScene.staffNode.animateStaffElementNode(newClefSprite,
                                                              pixelsPerSecond: pixelsPerSecondFromTempo(),
                                                              midFunc: midFunc,
                                                              endFunc: endFunc)
            break
        case GameElement.tempo:
            self.gameScene.staffNode.setTempo(self.gameModel.musicElements.currentBPM)
            break
        }
    }
    
    fileprivate func pixelsPerSecondFromTempo() -> Double{
        let pixelsPerBeat:Double = Double(self.gameScene.size.width)/Double(8)
        let beatsPerSecond:Double = Double(self.gameModel.musicElements.currentBPM)/Double(GameModel.secondsInMinute)
        let pixelsPerSecond = pixelsPerBeat * beatsPerSecond
        return pixelsPerSecond
    }
    
    //game model delegate
    
    func areNotesCleared() -> Bool{
        return self.gameScene.staffNode.currentNoteSprites().count == 0
    }
    
    //handle creating sprites
    
    fileprivate func createNoteSprite(_ note:Note) -> NoteSprite{
        let clef = self.gameModel.musicElements.currentClef
        let keySignature = self.gameModel.musicElements.currentKeySignature
        let incrementsFromMiddle:Int = clef.incrementsFromMiddle(note.pitch, keySignature: keySignature)
        
        let ledgerLines:LedgerLines? = clef.ledgerLines(note.pitch, keySignature: keySignature)
        let roughNoteWidth = CGFloat(30)
        let endXPosition:CGFloat = self.gameScene.noteZoneFrame().minX - roughNoteWidth
        let noteSprite = NoteSprite(note: note, incrementsFromMiddle: incrementsFromMiddle, ledgerLines:ledgerLines, endXPosition: endXPosition)
        let isStemUp = clef.isStemUp(note.pitch, keySignature: keySignature)
        noteSprite.addStem(isStemUp)
        if(addCourtesyNatural(currentNote: note)){
            noteSprite.addAccidental(Accidental.Natural)
        }else{
            noteSprite.addAccidental(keySignature.nonSolfegAccidental(note.pitch))
        }
        if(self.difficultyLevel == DifficultyLevel.beginner){
            noteSprite.addLetter(Keyboard.letterIfIvory(keySignature.relativeIvoryPitch(note.pitch))!, isStemInTheWay: !isStemUp)
        }
        
        return noteSprite
    }
    
    private func addCourtesyNatural(currentNote: Note) -> Bool{
        let keySignature = self.gameModel.musicElements.currentKeySignature
        let currentPitch = currentNote.pitch
        let currentAccidental:Accidental = keySignature.nonSolfegAccidental(currentPitch)
        let previousPitch = self.previousNote.pitch
        let previousAccidental:Accidental = keySignature.nonSolfegAccidental(previousPitch)
        
        let currentRelWhite = keySignature.relativeIvoryPitch(currentPitch)
        let previousRelWhite = keySignature.relativeIvoryPitch(previousPitch)
        
        self.previousNote = currentNote
        
        return currentRelWhite == previousRelWhite && currentAccidental == Accidental.None && (previousAccidental == Accidental.Flat || previousAccidental == Accidental.Sharp)
    }
    
    fileprivate func createKeySignatureSprite(_ keySignature:MajorKeySignature, clef:Clef, isNaturals:Bool) -> KeySignatureSprite{
        let accidental:Accidental
        if(isNaturals){
            accidental = Accidental.Natural
        }else{
            if (keySignature.keyType == KeyType.Sharp){
                accidental = Accidental.Sharp
            }else{
                accidental = Accidental.Flat
            }
        }
        let accidentalPitchLetters:[PitchLetter] = keySignature.getAccidentalPitchLetters()
        let incrementsFromMiddle:[Int] =
            clef.keySignatureAccidentalIncrementsFromMiddle(accidentalPitchLetters, keyType: keySignature.keyType)
        let keySigSprite = KeySignatureSprite(accidentalIncrements: incrementsFromMiddle, accidental: accidental)
        
        return keySigSprite
    }
    
    fileprivate func createClefSprite(_ clef:Clef) -> ClefSprite{
        let clefSprite:ClefSprite = ClefSprite(isTrebleClef: clef.isTrebleClef)
        
        return clefSprite
    }
    
    //handle keyboard event
    
    func pitchesPressed(_ pitches:Set<Pitch>){
        for pitch:Pitch in pitches{
            playSound(pitch)
        }
        for noteSprite:NoteSprite in self.gameScene.staffNode.currentNoteSprites(){
            let relativeSpritePosition = self.gameScene.convert(noteSprite.position, from: self.gameScene.staffNode)
            if(self.gameScene.noteZoneContainsPoint(relativeSpritePosition)){
                if(pitches.contains(noteSprite.note.pitch)){
                    self.gameModel.updateScoreWithCorrectNote()
                    self.gameScene.staffNode.removeNoteSprite(noteSprite)
                }else{
                    self.gameModel.updateScoreWithIncorrectNote()
                }
            }
        }
        self.gameScene.pressNoteZone()
    }
    
    fileprivate func playSound(_ pitch:Pitch){
        let systemSound:SystemSoundID = self.audioSounds[pitch.absolutePitch]!
        AudioServicesPlaySystemSound(systemSound)
    }
    
    fileprivate func transitionToHighScoreViewController(){
        let gameData = GamePersistence()
        gameData.storeNewScore(self.gameModel.getScore(), name: "nil")
        self.performSegue(withIdentifier: "GameOver", sender: self)
    }
    
    //handle game over
    
    func gameOver(){
        self.isPlayingGame = false
        self.gameModel.stopTimer()
    
        transitionToHighScoreViewController()
    }
}
