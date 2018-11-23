//
//  Player.swift
//  perahuKertas
//
//  Created by Anisa Budiarthati on 23/11/18.
//  Copyright © 2018 Rayo Roderik. All rights reserved.
//

import Foundation
import AVFoundation

class GSAudio: NSObject, AVAudioPlayerDelegate {
    
    static let sharedInstance = GSAudio()
    
    private override init() {}
    
    var players = [URL:AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer]()
    
    func playSound(soundFileName: String){
        
        guard let soundFileNameURL = Bundle.main.url(forResource: soundFileName, withExtension: "mp3") else {
            print("url not found")
            return
        }

        if let player = players[soundFileNameURL] { //player for sound has been found
            
            if player.isPlaying == false { //player is not in use, so use that one
                player.prepareToPlay()
                player.play()
                
            } else { // player is in use, create a new, duplicate, player and use that instead
                
                let duplicatePlayer = try! AVAudioPlayer(contentsOf: soundFileNameURL as URL)
                //use 'try!' because we know the URL worked before.
                
                duplicatePlayer.delegate = self
                //assign delegate for duplicatePlayer so delegate can remove the duplicate once it's stopped playing
                
                duplicatePlayers.append(duplicatePlayer)
                //add duplicate to array so it doesn't get removed from memory before finishing
                
                duplicatePlayer.prepareToPlay()
                duplicatePlayer.play()
                
            }
        } else { //player has not been found, create a new player with the URL if possible
            do{
                let player = try AVAudioPlayer(contentsOf: soundFileNameURL as URL)
                players[soundFileNameURL] = player
                player.prepareToPlay()
                player.play()
            } catch {
                print("Could not play sound file!")
            }
        }
    }
    
    
    func playSounds(soundFileNames: [String]){
        
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }
    
    func playSounds(soundFileNames: String...){
        for soundFileName in soundFileNames {
            playSound(soundFileName: soundFileName)
        }
    }
    
//    func playSounds(soundFileNames: [String], withDelay: Double) { //withDelay is in seconds
//        for (index, soundFileName) in soundFileNames.enumerated() {
//            let delay = withDelay*Double(index)
//            let _ = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(playSoundNotification(notification: <#T##NSNotification#>), userInfo: ["fileName":soundFileName], repeats: false)
//        }
//    }
    
    func playSoundNotification(notification: NSNotification) {
        if let soundFileName = notification.userInfo?["fileName"] as? String {
            playSound(soundFileName: soundFileName)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        duplicatePlayers.remove(at: duplicatePlayers.firstIndex(of: player)!)
        //Remove the duplicate player once it is done
    }
    
}
