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
import CloudKit
import AudioToolbox

class ViewController: UIViewController {
    
    @IBOutlet weak var viewContainer: UIView!
    var topWaterTimer: Timer?
    var bottomWaterTimer: Timer?
    var boatSwingTimer: Timer?
    var topWaterMoveRight: Bool = true
    var bottomWaterMoveRight: Bool = false
    var boatSwingRight: Bool = true
    var level: Float = 0.0
    var movingDistance : Float = 0.0
    
    let synth = AVSpeechSynthesizer()
    let instruct = "Blow into the microphone to start sailing. Do your best to reach the island in the shortest time!"
    let halfway = "Hey, you are halfway there!"
    let finishsound = "Congratulations! You've reached the finish line!"
    
    let container = CKContainer.default()
    var score = CKRecord(recordType: "Highscores")
    var isWritingScore = false
    var wr = 1.33
    
    var player: AVAudioPlayer?
    
    let boat: UIImageView = {
        let boat: UIImage = UIImage(named: "Boat1")!
        let size: CGSize = CGSize(width: boat.size.width, height: boat.size.height)
        let boatView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        boatView.image = boat
        boatView.contentMode = .scaleAspectFill
        return boatView
    }()
    
    let topWater: UIImageView = {
        let topWater: UIImage = UIImage(named: "TopWaterSteady")!
        let size: CGSize = CGSize(width: topWater.size.width, height: topWater.size.height)
        let topWaterView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        topWaterView.image = topWater
        topWaterView.contentMode = .scaleAspectFill
        return topWaterView
    }()
    
    let bottomWater: UIImageView = {
        let bottomWater: UIImage = UIImage(named: "BottomWaterSteady")!
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
    
    let land: UIImageView = {
        let landImage: UIImage = UIImage(named: "Land")!
        let size: CGSize = CGSize(width: landImage.size.width, height: landImage.size.height)
        let landView: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        landView.image = landImage
        landView.contentMode = .scaleAspectFill
        return landView
    }()
    
    let timerLabel: UILabel = {
        let timerLabel: UILabel = UILabel()
        timerLabel.frame = CGRect(x: 10, y: 50, width: 230, height: 60)
        timerLabel.text = "Blow the ship to start sailing"
        timerLabel.textColor = UIColor.black
        timerLabel.font = UIFont.init(name: "Helvetica", size: 24)
        timerLabel.textAlignment = .center
        timerLabel.numberOfLines = 0
        timerLabel.lineBreakMode = .byWordWrapping
        return timerLabel
    }()
    
    let inputNameAlertController: UIAlertController = {
        let inputNameAlertController: UIAlertController =  UIAlertController(title: "", message: "", preferredStyle: .alert)
        return inputNameAlertController
    }()
    
    var recorder: AVAudioRecorder!
    var levelTimer: Timer?
    var scoreTimer: Timer?
    var distance = 0
    let finish = 3440
    var elapsedTime = 0.01
    var gameEnded = false
    var gameIsSet = false
    var havePassedHalfway = false
    
    let LEVEL_THRESHOLD: Float = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !gameIsSet { // First setup ingame avoiding minimize app re-setup
            // Instruction speaking
            speakUtterance(instruct)
            
            // Record blow
            recordBlow()
            
            // Set levelTimer
            levelTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
            showNameTextField()
            
            // Setup animations
            initiationPosition()
            addSubviewsInit()
            startWaterMoveTimer()
            startBoatTimer()
            
            // Make game setup indicator true
            gameIsSet = true
        }
    }
    
    @objc func levelTimerCallback() {
        if !gameEnded {
            if distance >= finish {
                gameEnded = true
            }
            recorder.updateMeters()
            level = recorder.averagePower(forChannel: 0)
            let isLoud = level > LEVEL_THRESHOLD
            if isLoud && distance == 0 {
                startTimer()
                moveShip()
                playWaveSound()
//                DispatchQueue.main.async {
//                    self.playWaveSound()
//                }
            } else if isLoud && distance >= finish/2 && havePassedHalfway == false {
                speakUtterance(halfway)
                havePassedHalfway = true
                moveShip()
            } else if isLoud && distance < finish{
                moveShip()
            }
        } else {
            if !isWritingScore {
                isWritingScore = true
                stopTimer()
                stopBoatTimer()
                animateBoatGoAway()
                
                // Finish speaking
                speakUtterance(finishsound)
                
                //munculin textField untuk input nama, lalu push ke publicDatabase di CloudKit dengan score-nya. kalo nama-nya uda ada, suggest nama lain.
                showNameTextField()
                print("time: \(elapsedTime)")
            }
        }
    }
    
    func showNameTextField(){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Highscores", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "SecondsPassed", ascending: true)]
        container.publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            if let records = records{
                if let record = records.first{
                    //kalo namanya uda ada
                    self.wr = self.score["SecondsPassed"]!
                    print("halo \(self.wr)")
                }
                else{
//
//                    self.score["SecondsPassed"] = Double(String(format: "%.2f", self.elapsedTime))
//                    self.container.publicCloudDatabase.save(self.score) { (record, error) in
//                        if let error = error{
//                            print(error.localizedDescription)
//                        }
//                    }
                }
            }
        }
        
        inputNameAlertController.title = "You spent \(String(format: "%.2f", elapsedTime)) seconds. The World Record is \(String(format: "%.2f", wr)) seconds."
        
        if inputNameAlertController.textFields?.count == 0{
            inputNameAlertController.addTextField { (nameTextField) in
                nameTextField.placeholder = "Enter name here"
            }
            
            inputNameAlertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
                self.createResetButton()
            }))
            inputNameAlertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (alertAction) in
                if let name = self.inputNameAlertController.textFields![0].text{
                    self.insertNew(with: name)
                }
                self.createResetButton()
            }))
        }
        
        self.present(inputNameAlertController, animated: true, completion: nil)
    }
    
    func insertNew(with name: String){
        let nameEqualTo = NSPredicate(format: "Name = %@", name)
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Highscores", predicate: predicate)
//        query.sortDescriptors = [NSSortDescriptor(key: "SecondsPassed", ascending: true)]
        
        container.publicCloudDatabase.perform(query, inZoneWith: CKRecordZone.default().zoneID) { (records, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            if let records = records{
                if let record = records.first{
                    //kalo namanya uda ada
                    
                }
                else{
                    self.score["Name"] = name
                    self.score["SecondsPassed"] = Double(String(format: "%.2f", self.elapsedTime))
                    self.container.publicCloudDatabase.save(self.score) { (record, error) in
                        if let error = error{
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    func moveShip(){
        vibrateShip()
        distance = distance + Int(level)
        print(distance) // Print distance
        updateBoatLayerOpen(level)
        movingDistance = Float(distance) / 5
        animateMoveShipUpdate()
    }
    
    func vibrateShip() {
        if level > 6 {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            playWindSound()
        }
        
    }
    
    func startTimer(){
        scoreTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer(){
        if scoreTimer != nil || scoreTimer != Timer() {
            scoreTimer?.invalidate()
            scoreTimer = nil
        }
    }
    
    @objc func fireTimer(){
        elapsedTime += 0.01
        let currentTime = String(format: "%.2f", elapsedTime)
        timerLabel.font = UIFont.init(name: "Helvetica", size: 60)
        timerLabel.text = "\(currentTime) s"
    }
    
    func playWaveSound() {
//        guard let url = Bundle.main.url(forResource: "WaveSound", withExtension: "mp3") else {
//            print("url not found")
//            return
//        }
//
//        do {
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//
//            player!.play()
//            player?.numberOfLoops = -1
//        } catch let error as NSError {
//            print("error: \(error.localizedDescription)")
//        }
        
        GSAudio.sharedInstance.playSound(soundFileName: "WaveSound")
    }
    
    func playWindSound() {
//        guard let url = Bundle.main.url(forResource: "wind", withExtension: "m4a") else {
//            print("url not found")
//            return
//        }
//
//        do {
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
//
//            player!.play()
//        } catch let error as NSError {
//            print("error: \(error.localizedDescription)")
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
        GSAudio.sharedInstance.playSound(soundFileName: "WindSound")
    }
    
    func addSubviewsInit() {
        viewContainer.addSubview(land)
        viewContainer.addSubview(boat)
        viewContainer.addSubview(topWater)
        viewContainer.addSubview(bottomWater)
        viewContainer.addSubview(lengthBar)
        viewContainer.addSubview(distanceIndicator)
        viewContainer.addSubview(timerLabel)
    }
    
    func initiationPosition() {
        // Water
        imageDesireSize(view: topWater, desiredWidth: 500)
        imageDesireSize(view: bottomWater, desiredWidth: 500)
        topWater.image = UIImage(named: "TopWaterSteady")
        bottomWater.image = UIImage(named: "BottomWaterSteady")
        topWater.frame.origin = CGPoint(
            x: (UIScreen.main.bounds.width - topWater.frame.width) / 2,
            y: 734)
        bottomWater.frame.origin = CGPoint(
            x: (UIScreen.main.bounds.width - bottomWater.frame.width) / 2,
            y: 770)
        
        // Boat
        boatViewInit()
        
        // Land
        landViewInit()
        
        // Indicators
        lengthBar.frame.origin = CGPoint(x: 19, y: 51)
        distanceIndicator.frame.origin = CGPoint(x: 19, y: 724)
        
        timerLabel.frame.origin = CGPoint(x: (UIScreen.main.bounds.width - timerLabel.frame.width)/2, y: 250)
        //        self.timerLabel.frame.origin = CGPoint(x: 50, y: 50)
        
    }
    
}
