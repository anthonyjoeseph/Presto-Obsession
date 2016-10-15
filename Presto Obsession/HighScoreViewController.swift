//
//  HighScoreViewController.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 1/11/16.
//  Copyright © 2016 Anthony Gabriele. All rights reserved.
//

import Foundation
import UIKit

class HighScoreViewController: UIViewController{
    
    @IBOutlet fileprivate var nameLabels:[UILabel]!
    @IBOutlet fileprivate var scoreLabels:[UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postScores()
    }
    
    fileprivate func postScores(){
        self.nameLabels.sort(
            by: {
                (label1:UILabel, label2:UILabel) -> Bool in
                return label1.tag < label2.tag
        })
        self.scoreLabels.sort(
            by: {
                (label1:UILabel, label2:UILabel) -> Bool in
                return label1.tag < label2.tag
        })
        
        let gameData = GamePersistence()
        if let scores = gameData.highScores() {
            let names = gameData.scoreNames()!
            for index in 0...scores.count-1{
                let currentScoreLabel = scoreLabels[index]
                let currentNameLabel = nameLabels[index]
                
                let currentScore = scores[index]
                let currentName = names[currentScore]
                
                currentScoreLabel.text = String(currentScore)
                currentNameLabel.text = currentName
            }
        }
    }
    
    @IBAction func resetScores(){
        let gameData = GamePersistence()
        gameData.resetScores()
        postScores()
    }
}
