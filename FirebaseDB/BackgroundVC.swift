//
//  BackgroundVC.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/18.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class BackgroundVC: UIViewController {

	var m_background: UIImage? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		if let img = self.m_background {
			setupBackground(img)
		}
    }
    
	fileprivate func setupBackground(_ image: UIImage) {
		let imgView = UIImageView(image: image)
		self.view.addSubview(imgView)
		imgView.translatesAutoresizingMaskIntoConstraints = false
		imgView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		imgView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		imgView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		imgView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true		
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
