//
//  CheckVC.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/16.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class CheckVC: BackgroundVC {

	//Firebase load image
	var m_imgView: UIImageView!
	
	var m_nameLbl: UILabel!
	var m_sexLbl: UILabel!
	var m_mailLbl: UILabel!
	var m_phoneLbl: UILabel!

	var m_stackLbls: UIStackView!
	var m_stackBtns: UIStackView!

	var changePersonalInfo: UIButton!

	var m_user: ST_USER_INFO? = nil
		
	fileprivate func setupTestUI() {
		let btn = UIButton(frame: CGRect(x: 30, y: 30, width: 50, height: 50))
		btn.setTitle("Enter", for: .normal)
		btn.setTitleColor(.red, for: .normal)
		view.addSubview(btn)
		btn.addTarget(self, action: #selector(clickEnter), for: .touchUpInside)
		
		let btn2 = UIButton(frame: CGRect(x: 130, y: 30, width: 50, height: 50))
		btn2.setTitle("test", for: .normal)
		btn2.setTitleColor(.blue, for: .normal)
		view.addSubview(btn2)
		btn2.addTarget(self, action: #selector(clickTest), for: .touchUpInside)
		
		let btn3 = UIButton(frame: CGRect(x: 230, y: 30, width: 50, height: 50))
		btn3.setTitle("Rooms", for: .normal)
		btn3.setTitleColor(.green, for: .normal)
		view.addSubview(btn3)
		btn3.addTarget(self, action: #selector(clickRooms), for: .touchUpInside)
	}
	
	@objc func clickTest() {
		
	}
	
	fileprivate func setupBtnStack() {
		let btnLeft = UIButton(frame: .zero)
//		btnLeft.setTitle("Edit", for: .normal)
		btnLeft.setBackgroundImage(UIImage(named: "edit"), for: .normal)
		btnLeft.setTitleColor(.blue, for: .normal)
		btnLeft.addTarget(self, action: #selector(changePersonInfo), for: .touchUpInside)
		btnLeft.widthAnchor.constraint(equalTo: btnLeft.heightAnchor).isActive = true
		
		let btnRight = UIButton(frame: .zero)
//		btnRight.setTitle("Logout", for: .normal)
		btnRight.setBackgroundImage(UIImage(named: "logout"), for: .normal)
		btnRight.setTitleColor(.red, for: .normal)
		btnRight.addTarget(self, action: #selector(logOut), for: .touchUpInside)
		btnRight.widthAnchor.constraint(equalTo: btnRight.heightAnchor).isActive = true
		
		self.m_stackBtns = UIStackView(arrangedSubviews: [btnLeft, btnRight])
		self.m_stackBtns.axis = .horizontal
		self.m_stackBtns.alignment = .center
		self.m_stackBtns.distribution = .equalSpacing
		self.m_stackBtns.spacing = 50
		
		self.view.addSubview(self.m_stackBtns)
		self.m_stackBtns.translatesAutoresizingMaskIntoConstraints = false
		//		self.m_stackBtns.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor).isActive = true
//		self.m_stackBtns.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
//		self.m_stackBtns.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_stackBtns.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor, constant: -20).isActive = true
		self.m_stackBtns.centerXAnchor.constraint(equalTo: self.view.readableContentGuide.centerXAnchor).isActive = true
		self.m_stackBtns.heightAnchor.constraint(equalToConstant: 60).isActive = true
		self.m_stackBtns.widthAnchor.constraint(equalToConstant: 200).isActive = true
	}
	
	fileprivate func setupLblStack() {
		
		self.m_nameLbl = UILabel(frame: .zero)
		self.m_sexLbl = UILabel(frame: .zero)
		self.m_mailLbl = UILabel(frame: .zero)
		self.m_phoneLbl = UILabel(frame: .zero)
		let checkArray: [UILabel] = [self.m_nameLbl, self.m_sexLbl, self.m_mailLbl, self.m_phoneLbl]
		for lbl in checkArray {
			lbl.textColor = .white
		}
		
		let titles = ["Name", "Sex", "Mail", "Phone"]
		var lblArray = [UILabel]()
		for title in titles {
			let lbl = UILabel(frame: .zero)
			lbl.text = title + " : "
			lbl.textColor = .yellow
			lbl.font = .boldSystemFont(ofSize: 16)
			lblArray.append(lbl)
		}
		
		let stackLeft = UIStackView(arrangedSubviews: lblArray)
		stackLeft.axis = .vertical
		stackLeft.distribution = .fillEqually
		let stackRight = UIStackView(arrangedSubviews: checkArray)
		stackRight.axis = .vertical
		stackRight.distribution = .fillEqually
		stackRight.widthAnchor.constraint(equalToConstant: 230).isActive = true
		self.m_stackLbls = UIStackView(arrangedSubviews: [stackLeft, stackRight])
		self.m_stackLbls.axis = .horizontal
		self.m_stackLbls.alignment = .fill
		self.m_stackLbls.distribution = .fill
		self.m_stackLbls.spacing = 5
		
		self.view.addSubview(self.m_stackLbls)
		self.m_stackLbls.translatesAutoresizingMaskIntoConstraints = false
		self.m_stackLbls.topAnchor.constraint(equalTo: self.m_imgView.bottomAnchor).isActive = true
//		self.m_stackLbls.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
//		self.m_stackLbls.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_stackLbls.bottomAnchor.constraint(equalTo: self.m_stackBtns.readableContentGuide.topAnchor).isActive = true
		self.m_stackLbls.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		self.m_stackLbls.widthAnchor.constraint(equalToConstant: 300).isActive = true
	}
	
	fileprivate func setupImgView() {
		self.m_imgView = UIImageView(image: UIImage(named: "smile"))
		
		self.view.addSubview(self.m_imgView)
		self.m_imgView.contentMode = .scaleAspectFill
		self.m_imgView.translatesAutoresizingMaskIntoConstraints = false
		self.m_imgView.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor).isActive = true
//		self.loadImage.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
//		self.loadImage.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_imgView.centerXAnchor.constraint(equalTo: self.view.readableContentGuide.centerXAnchor).isActive = true
		self.m_imgView.heightAnchor.constraint(equalTo: self.view.readableContentGuide.heightAnchor, multiplier: 1/3).isActive = true
		self.m_imgView.widthAnchor.constraint(equalTo: self.m_imgView.heightAnchor, multiplier: 1).isActive = true
		
		self.m_imgView.clipsToBounds = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let user = Auth.auth().currentUser {
			viewDetail(user.uid)
		}
		
//		setupTestUI()
	
		setupBtnStack()
				
		setupImgView()
		
		setupLblStack()

	}
		
	@objc func clickRooms() {
		let vc = CollectionVC()
		vc.view.backgroundColor = .lightGray
		vc.m_user = self.m_user
		self.present(vc, animated: true)
	}
	
	@objc func clickEnter() {
		enterRoom(11111)
	}
	
	func enterRoom(_ number: Int) {
		let refRooms = Database.database().reference(withPath: "\(DEF_ROOM)")
		refRooms.observeSingleEvent(of: .value) { (snapshot) in
			if snapshot.hasChildren() {
				for item in snapshot.children {
					if let room = item as? DataSnapshot {
						if(room.key == String(number)) {
							if let user = self.m_user {
								let vc = RoomVC()
								vc.m_room = ST_ROOM_INFO(number: number, members: nil, groups: nil, title: nil, message: nil, background: nil)
								vc.m_user = user
								vc.view.backgroundColor = .lightGray
								self.present(vc, animated: true)
							}
						}
					}
				}
			}
		}
	}
	
	
	func viewDetail(_ uid: String) {
		
		let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(uid)")
		refUser.child(DEF_USER_PHOTO).observe(.value) { (snapshot) in
			if let url = snapshot.value as? String {
				let maxSize : Int64 = 2 * 1024 * 1024 //2MB
				//get image from Storage
				Storage.storage().reference().child(url).getData(maxSize: maxSize) { (data, error) in
					if error != nil {
						print(error.debugDescription)
						return
					}
					
					guard let _data = data else {
						return
					}
					
					guard let imageData = UIImage(data: _data) else {
						return
					}
					
					DispatchQueue.main.async {
						self.m_imgView.image = imageData
					}
				}
			}
		}
		
		refUser.observe(.value) { (snapshot) in
			if let dict = snapshot.value as? [String : Any] {
				self.m_user = ST_USER_INFO(uid: snapshot.key,
										mail: dict[DEF_USER_MAIL] as? String,
										phone: dict[DEF_USER_PHONE] as? String,
										name: dict[DEF_USER_NAME] as? String,
										photo: dict[DEF_USER_PHOTO] as? String,
										sex: dict[DEF_USER_SEX] as? Int)
				if let user = self.m_user {
					self.m_nameLbl.text = user.name
					
					let gender = user.sex
					switch gender {
					case 1:
						self.m_sexLbl.text = "man"
					case 2:
						self.m_sexLbl.text = "woman"
					default:
						self.m_sexLbl.text = "?"
					}
					
					self.m_mailLbl.text = user.mail
					
					self.m_phoneLbl.text = user.phone
				}
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// go ChangeVC
	@objc func changePersonInfo(_ sender: Any) {
		
//		let storyboard = UIStoryboard(name: "Main", bundle: nil)
//		if let vc = storyboard.instantiateViewController(withIdentifier: "ChangeDataViewControllerID") as? ChangeVC {
		let vc = ModifyVC()
			if let img = self.m_imgView.image {
//				print(img.size)
				vc.m_selfie = img
			}
			self.present(vc, animated: true)
//		}
	}
	

	@objc func logOut(_ sender: Any) {
		guard let myId = self.m_user?.uid else {
			return
		}
		let ref = Database.database().reference(withPath: "Online-Status/\(myId)")
		// Database 的 Online-Status: "OFF"
		ref.setValue("OFF")
		// Authentication 也 SignOut
		try! Auth.auth().signOut()
		
		// go LogInVC
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "LogInViewControllerID") as? LoginVC {
			self.present(vc, animated:true)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.m_imgView.layer.cornerRadius = self.m_imgView.frame.width/2
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			// your code here
			self.m_imgView.layer.cornerRadius = self.m_imgView.frame.width/2
		}

	}
}

