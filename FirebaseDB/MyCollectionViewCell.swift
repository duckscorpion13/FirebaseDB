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
		
		
		// 建立一個 UIImageView
		imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
		self.addSubview(imageView)
		
		// 建立一個 UILabel
		titleLabel = UILabel(frame:CGRect(x: 0, y: 0, width: frame.width, height: 40))
		titleLabel.textAlignment = .center
		titleLabel.textColor = UIColor.orange
		self.addSubview(titleLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
