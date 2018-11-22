//
//  UIAnimations.swift
//  perahuKertas
//
//  Created by Bisma Satria Wasesasegara on 16/11/18.
//  Copyright © 2018 Rayo Roderik. All rights reserved.
//

import UIKit

extension ViewController {
    
    func startWaterMoveTimer() {
        topWaterMove()
        topWaterTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (_) in
            self.topWaterMove()
        })
        bottomWaterMove()
        bottomWaterTimer = Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true, block: { (_) in
            self.bottomWaterMove()
        })
    }
    
    func startBoatTimer() {
        boatSwing()
        boatSwingTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: true, block: { (_) in
            self.boatSwing()
        })
    }
    
    func stopBoatTimer() {
        if boatSwingTimer != nil || boatSwingTimer != Timer() {
            self.boatSwingTimer?.invalidate()
            self.boatSwingTimer = nil
        }
    }
    
    func topWaterMove() {
        if topWaterMoveRight {
            UIView.animate(withDuration: 2) {
                self.topWater.transform = CGAffineTransform(translationX: 50, y: 0)
                self.topWaterMoveRight = !self.topWaterMoveRight
            }
        } else {
            UIView.animate(withDuration: 2) {
                self.topWater.transform = CGAffineTransform(translationX: -50, y: 0)
                self.topWaterMoveRight = !self.topWaterMoveRight
            }
        }
    }
    
    func bottomWaterMove() {
        if bottomWaterMoveRight {
            UIView.animate(withDuration: 1.8) {
                self.bottomWater.transform = CGAffineTransform(translationX: 75, y: 0)
                self.bottomWaterMoveRight = !self.bottomWaterMoveRight
            }
        } else {
            UIView.animate(withDuration: 1.8) {
                self.bottomWater.transform = CGAffineTransform(translationX: -75, y: 0)
                self.bottomWaterMoveRight = !self.bottomWaterMoveRight
            }
        }
    }
    
    func boatSwing() {
        if boatSwingRight {
            UIView.animate(withDuration: 3, animations: {
                self.boat.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/40))
            }) { (_) in
                UIView.animate(withDuration: 3, animations: {
                    self.boat.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/40))
                    self.boatSwingRight = !self.boatSwingRight
                })
            }
        } else {
            UIView.animate(withDuration: 3, animations: {
                self.boat.transform = CGAffineTransform(rotationAngle: -CGFloat(Double.pi/40))
            }) { (_) in
                UIView.animate(withDuration: 3, animations: {
                    self.boat.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/40))
                    self.boatSwingRight = !self.boatSwingRight
                })
            }
        }
    }
    
    func blowedBoat(_ level: Float) {
        if !gameEnded {
            UIView.animate(withDuration: 2) {
                if level == 0 {
                    self.boat.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.boat.frame.origin.y = 424
                } else if level < 2 {
                    self.boat.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    self.boat.frame.origin.y = 424 + 40
                } else if level < 4 {
                    self.boat.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    self.boat.frame.origin.y = 424 + 60
                } else if level < 6 {
                    self.boat.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                    self.boat.frame.origin.y = 424 + 80
                } else {
                    self.boat.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.boat.frame.origin.y = 424 + 100
                }
            }
        }
    }
    
    func updateBoatLayerOpen(_ level: Float) {
        blowedBoat(level)
        if level < 2 {
            boat.image = UIImage(named: "Boat1")
            topWater.image = UIImage(named: "TopWaterSteady")
            bottomWater.image = UIImage(named: "BottomWaterSteady")
        } else if level < 4 {
            boat.image = UIImage(named: "Boat2")
            topWater.image = UIImage(named: "TopWaterSteady")
            bottomWater.image = UIImage(named: "BottomWaterSteady")
        } else if level < 6 {
            boat.image = UIImage(named: "Boat3")
            topWater.image = UIImage(named: "TopWater")
            bottomWater.image = UIImage(named: "BottomWater")
        } else {
            boat.image = UIImage(named: "Boat4")
            topWater.image = UIImage(named: "TopWater")
            bottomWater.image = UIImage(named: "BottomWater")
        }
    }
    
    func animateBoatGoAway() {
        topWater.image = UIImage(named: "TopWaterSteady")
        bottomWater.image = UIImage(named: "BottomWaterSteady")
        UIView.animate(withDuration: 4) {
            self.boat.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.boat.alpha = 0
        }
        UIView.animate(withDuration: 8) {
            self.boat.frame.origin.y += 450
        }
    }
    
    func boatViewInit() {
        boat.transform = .identity
        boat.frame.origin = CGPoint(x: 102, y: 424)
        boat.alpha = 1
        distanceIndicator.frame.origin = CGPoint(x: 19, y: 724)
    }
    
    func boatAnimateReset() {
        UIView.animate(withDuration: 1) {
            self.boat.frame.origin = CGPoint(x: 102, y: 424)
            self.boat.alpha = 1
            self.distanceIndicator.frame.origin = CGPoint(x: 19, y: 724)
        }
    }
    
    func createResetButton() {
        let resetButton: UILabel = {
            let resetLabel: UILabel = UILabel()
            resetLabel.translatesAutoresizingMaskIntoConstraints = false
            resetLabel.text = "Restart"
            resetLabel.font = UIFont.init(name: "Helvetica", size: 40)
            resetLabel.sizeToFit()
            resetLabel.textAlignment = .center
            resetLabel.textColor = .darkText
            resetLabel.isUserInteractionEnabled = true
            resetLabel.alpha = 0
            resetLabel.tag = 111
            return resetLabel
        }()
        let tap = UITapGestureRecognizer(target: self, action: #selector(resetState))
        resetButton.addGestureRecognizer(tap)
        view.addSubview(resetButton)
        resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        UIView.animate(withDuration: 1) {
            resetButton.alpha = 1
        }
    }
    
    @objc func resetState() {
        for view in self.view.subviews {
            if view.tag == 111 {
                view.removeFromSuperview()
            }
        }
        boat.image = UIImage(named: "Boat1")
        timerLabel.text = "Blow the ship to start sailing"
        timerLabel.font = UIFont.init(name: "Helvetica", size: 24)
        boatAnimateReset()
        elapsedTime = 0
        distance = 0
        gameEnded = false
        isWritingScore = false
        havePassedHalfway = false
        levelTimerCallback()
        startBoatTimer()
    }
}
