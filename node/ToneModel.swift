//
//  ToneModel.swift
//  node
//
//  Created by Hans Kyndesgaard on 12/02/2017.
//  Copyright © 2017 Hans Kyndesgaard. All rights reserved.
//

import Foundation
import UIKit

enum Clef {
    case Treble
    case Bass
}

class ToneModel {
    var Target: Int
    var TargetClef : Clef
    var Score: Int
    var Played: Bool
    
    let pitchReference : Double
    let semitone = pow(2.0, 1.0 / 12.0)
    
    var Bass : Bool
    var Treble : Bool
    
    init(pitchReference : Double) {
        self.pitchReference = pitchReference
        Bass = true
        Treble = true
        Target = 49
        TargetClef = Clef.Treble
        Score = 0
        Played = false
    }
    
    
    func play(freq : Double) -> Bool{
        let played = note(freq: freq)
        if (played == Target){
            Score += 1
            
            return true
        }
        return false
    }
    
    func next(){
        Played = false
        if (Treble && Bass){
            if (coinFlip()){
                nextTreble()
            } else {
                nextBass()
            }
        }
        if (Bass){
            nextBass()
        } else {
            nextTreble()
        }
    }
    
    func coinFlip() -> Bool{
        return arc4random_uniform(1) == 0
    }
    
    func nextTreble() {
        TargetClef = Clef.Treble
        Target = Int(arc4random_uniform(27) + 37)
        
    }
    
    func nextBass(){
        TargetClef = Clef.Bass
        Target = Int(arc4random_uniform(27) + 16)
    }
    
    func note(freq : Double) -> Int {
        let semitonesFromReference = lround((log(freq) - log(pitchReference)) / log(semitone))
        return semitonesFromReference + 49
    }
    
    func ScoreImage() -> UIImage {
        let clefName = (TargetClef == Clef.Treble ? "T" : "B")
        let name = clefName + String(Target) + ".png"
        return UIImage(named: name)!
    }
    
}
