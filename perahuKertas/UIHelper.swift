//
//  UIHelper.swift
//  ByeByeBoat
//
//  Created by Bisma Satria Wasesasegara on 16/11/18.
//  Copyright © 2018 Bisma Satria Wasesasegara. All rights reserved.
//

import UIKit

func imageDesireSize(view myView: UIView, desiredWidth width: CGFloat) {
    let scale: CGFloat = width / myView.frame.width
    let height: CGFloat = myView.frame.height * scale
    myView.frame.size = CGSize(width: width, height: height)
}

func imageDesireSize(view myView: UIView, desiredHeight height: CGFloat) {
    let scale: CGFloat = height / myView.frame.height
    let width: CGFloat = myView.frame.width * scale
    myView.frame.size = CGSize(width: width, height: height)
}

