//
//  GradientButton.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/18.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

enum EN_GRADIENT_TYPE: Int {
	case GRADIENT_LEFTUP_TO_RIGHTDOWN
	case GRADIENT_UP_TO_DOWN
	case GRADIENT_LEFT_TO_RIGHT
}

class GradientButton: UIButton {

	override init(frame: CGRect) {
		super.init(frame: frame)
		
	}
	
	convenience init(frame: CGRect, startColor: UIColor, endColor: UIColor, type: EN_GRADIENT_TYPE, isRoundCorner: Bool = true) {
		self.init(frame: frame)
		
		if(isRoundCorner) {
			self.clipsToBounds = true
			self.layer.cornerRadius = frame.height / 2
		}
		
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = frame
		switch type {
			case .GRADIENT_UP_TO_DOWN:
				gradientLayer.startPoint = CGPoint(x: 0, y: 0)
				gradientLayer.endPoint = CGPoint(x: 0, y: 1)
			case .GRADIENT_LEFT_TO_RIGHT:
				gradientLayer.startPoint = CGPoint(x: 0, y: 0)
				gradientLayer.endPoint = CGPoint(x: 1, y: 0)
			default:
				gradientLayer.startPoint = CGPoint(x: 0, y: 0)
				gradientLayer.endPoint = CGPoint(x: 1, y: 1)
		}
		
		gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
		self.layer.addSublayer(gradientLayer)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
