//
//  ViewController.swift
//  node
//
//  Created by Hans Kyndesgaard on 05/08/16.
//  Copyright © 2016 Hans Kyndesgaard. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    
    
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var amplitudeLabel: UILabel!
    //@IBOutlet var noteNameWithSharpsLabel: UILabel!
    //@IBOutlet var noteNameWithFlatsLabel: UILabel!
    //@IBOutlet var audioInputPlot: EZAudioPlot!
    
    var mic : AKMicrophone!
    var tracker : AKFrequencyTracker!
    var silence: AKBooster!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)
        AudioKit.output = silence
        AudioKit.start()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateUI), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        if tracker.amplitude > 0.1 {
            frequencyLabel.text = String(format: "%0.1f", tracker.frequency)
            amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
        }
    }
    
}

