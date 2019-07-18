//
//  MyCollectionViewCell.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/16.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
	var imageView: UIImageView!
	var titleLabel: UILabel!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		let titleHeight: CGFloat = 40.0
		// 建立一個 UIImageView
		imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height - titleHeight))
		imageView.contentMode = .scaleAspectFit
		self.addSubview(imageView)
		
		// 建立一個 UILabel
		titleLabel = UILabel(frame:CGRect(x: 0, y: frame.height - titleHeight, width: frame.width, height: titleHeight))
		titleLabel.textAlignment = .center
		titleLabel.textColor = .white
		self.addSubview(titleLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
