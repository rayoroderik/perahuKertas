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
    
    func updateBoatLayerOpen(_ level: Float) {
        if level < 2 {
            boat.image = UIImage(named: "Boat1")
        } else if level < 4 {
            boat.image = UIImage(named: "Boat2")
        } else if level < 6 {
            boat.image = UIImage(named: "Boat3")
        } else {
            boat.image = UIImage(named: "Boat4")
        }
    }
    
    func animateBoatGoAway() {
        UIView.animate(withDuration: 4) {
            self.boat.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        UIView.animate(withDuration: 8) {
            self.boat.frame.origin.y += 450
            self.boat.alpha = 0
        }
    }
    
    func boatViewInit() {
        boat.transform = .identity
        boat.frame.origin = CGPoint(x: 102, y: 424)
        boat.alpha = 1
    }
}
