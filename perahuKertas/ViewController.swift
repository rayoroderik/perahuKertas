//
//  ViewController.swift
//  perahuKertas
//
//  Created by Rayo Roderik on 16/11/18.
//  Copyright © 2018 Rayo Roderik. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreAudio

class ViewController: UIViewController {
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    var distance = 0
    
    let LEVEL_THRESHOLD: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            44100.0,
            AVNumberOfChannelsKey:      2,
            AVEncoderBitRateKey:        12800,
            AVLinearPCMBitDepthKey:     16,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)
            
        } catch {
            return
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
        
        levelTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
        
    }
    
    @objc func levelTimerCallback() {
        recorder.updateMeters()
        
        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > LEVEL_THRESHOLD
        
        // do whatever you want with isLoud
        if isLoud {
            distance = distance + Int(level)
            print(distance)
            
            let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
            
            
        }
        
        while distance >= 5000{
            // finish line
            
        }
    }
    
    @objc func fireTimer(){
        print("timer start")
        var elapsedTime = 0
        elapsedTime += 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
