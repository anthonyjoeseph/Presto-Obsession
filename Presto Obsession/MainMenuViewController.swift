//
//  MainMenuViewController.swift
//  Presto Concentration
//
//  Created by Anthony Gabriele on 12/29/15.
//  Copyright © 2015 Anthony Gabriele. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenuViewController: UIViewController{
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let newViewController = segue.destination as? GameViewController {
            if segue.identifier == "Beginner"{
                newViewController.difficultyLevel = DifficultyLevel.beginner
            }else if segue.identifier == "Intermediate" {
                newViewController.difficultyLevel = DifficultyLevel.intermediate
            }else if segue.identifier == "Expert"{
                newViewController.difficultyLevel = DifficultyLevel.expert
            }
        }
    }
}
