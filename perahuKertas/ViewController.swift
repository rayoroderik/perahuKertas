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
    
    @IBOutlet weak var viewContainer: UIView!
    var topWaterTimer: Timer?
    var bottomWaterTimer: Timer?
    var boatSwingTimer: Timer?
    var topWaterMoveRight: Bool = true
    var bottomWaterMoveRight: Bool = false
    var boatSwingRight: Bool = true
    
    let boat: UIImageView = {
        let boat: UIImage = UIImage(named: "Boat1")!
        let size: CGSize = CGSize(width: boat.size.width, height: boat.size.height)
        let boatView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        boatView.image = boat
        boatView.contentMode = .scaleAspectFill
        return boatView
    }()
    
    
    let topWater: UIImageView = {
        let topWater: UIImage = UIImage(named: "TopWater")!
        let size: CGSize = CGSize(width: topWater.size.width, height: topWater.size.height)
        let topWaterView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        topWaterView.image = topWater
        topWaterView.contentMode = .scaleAspectFill
        return topWaterView
    }()
    
    
    let bottomWater: UIImageView = {
        let bottomWater: UIImage = UIImage(named: "BottomWater")!
        let size: CGSize = CGSize(width: bottomWater.size.width, height: bottomWater.size.height)
        let bottomWaterView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        bottomWaterView.image = bottomWater
        bottomWaterView.contentMode = .scaleAspectFill
        return bottomWaterView
    }()
    
    let lengthBar: UIImageView = {
        let lengthBar: UIImage = UIImage(named: "LengthBar")!
        let size: CGSize = CGSize(width: lengthBar.size.width, height: lengthBar.size.height)
        let lengthBarView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        lengthBarView.image = lengthBar
        lengthBarView.contentMode = .scaleAspectFill
        return lengthBarView
    }()
    
    let distanceIndicator: UIImageView = {
        let distanceIndicator: UIImage = UIImage(named: "DistanceIndicator")!
        let size: CGSize = CGSize(width: distanceIndicator.size.width, height: distanceIndicator.size.height)
        let distanceIndicatorView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        distanceIndicatorView.image = distanceIndicator
        distanceIndicatorView.contentMode = .scaleAspectFill
        return distanceIndicatorView
    }()
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    var x = 0
    
    let LEVEL_THRESHOLD: Float = -10.0
    
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
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)
            
        } catch {
            return
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
        
        levelTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
        
        self.initiationPosition()
        self.startWaterMoveTimer()
    }
    
    @objc func levelTimerCallback() {
        recorder.updateMeters()
        
        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > LEVEL_THRESHOLD
        
        // do whatever you want with isLoud
        if isLoud {
            updateBoatLayerOpen(level)
            print(level)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initiationPosition() {
        imageDesireSize(view: topWater, desiredWidth: 500)
        imageDesireSize(view: bottomWater, desiredWidth: 500)
        
        self.boat.frame.origin = CGPoint(x: 102, y: 424)
        self.topWater.frame.origin = CGPoint(x: (UIScreen.main.bounds.width - self.topWater.frame.width) / 2, y: 734)
        self.bottomWater.frame.origin = CGPoint(x: (UIScreen.main.bounds.width - self.bottomWater.frame.width) / 2, y: 770)
        self.lengthBar.frame.origin = CGPoint(x: 19, y: 51)
        self.distanceIndicator.frame.origin = CGPoint(x: 19, y: 724)
        
        viewContainer.addSubview(boat)
        viewContainer.addSubview(topWater)
        viewContainer.addSubview(bottomWater)
        viewContainer.addSubview(lengthBar)
        viewContainer.addSubview(distanceIndicator)
    }
    
}
