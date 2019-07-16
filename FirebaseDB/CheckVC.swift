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

class CheckVC: UIViewController {

	//在這裡從Firebase load image
	var loadImage: UIImageView!
	
	// 這是從Firebase拿取資訊，顯示實際註冊資料的Label
	var name_check: UILabel!
	var gender_check: UILabel!
	var email_check: UILabel!
	var phone_check: UILabel!

	var m_stackLbls: UIStackView!
	var m_stackBtns: UIStackView!
	// 編輯個人資料Button(會前往另一個頁面)，原先也是 isHidden，按下按鈕才顯示出來
	var changePersonalInfo: UIButton!
	// 登出Button，原先也是 isHidden，按下按鈕才顯示出來
//	var logOut: UIButton!
	
	// LogInViewController 有詳細說明 uid ，這邊就不再重複了
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
		btnLeft.setTitle("Modify", for: .normal)
		btnLeft.setTitleColor(.blue, for: .normal)
		btnLeft.addTarget(self, action: #selector(changePersonInfo), for: .touchUpInside)
		
		let btnRight = UIButton(frame: .zero)
		btnRight.setTitle("Logout", for: .normal)
		btnRight.setTitleColor(.red, for: .normal)
		btnRight.addTarget(self, action: #selector(logOut), for: .touchUpInside)
		
		self.m_stackBtns = UIStackView(arrangedSubviews: [btnLeft, btnRight])
		self.m_stackBtns.axis = .horizontal
		self.m_stackBtns.alignment = .fill
		self.m_stackBtns.distribution = .fillEqually
		
		self.view.addSubview(self.m_stackBtns)
		self.m_stackBtns.translatesAutoresizingMaskIntoConstraints = false
		//		self.m_stackBtns.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor).isActive = true
		self.m_stackBtns.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
		self.m_stackBtns.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_stackBtns.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor).isActive = true
		self.m_stackBtns.heightAnchor.constraint(equalToConstant: 50).isActive = true
	}
	
	fileprivate func setupLblStack() {
		
	
		self.name_check = UILabel(frame: .zero)
		self.gender_check = UILabel(frame: .zero)
		self.email_check = UILabel(frame: .zero)
		self.phone_check = UILabel(frame: .zero)
		let checkArray: [UILabel] = [self.name_check, self.gender_check, self.email_check, self.phone_check]
		for lbl in checkArray {
			lbl.textColor = .white
		}
		
		let titles = ["Name", "Sex", "Mail", "Phone"]
		var lblArray = [UILabel]()
		for title in titles {
			let lbl = UILabel(frame: .zero)
			lbl.text = title + " : "
			lbl.font = .boldSystemFont(ofSize: 16)
			lblArray.append(lbl)
		}
		
		let stackLeft = UIStackView(arrangedSubviews: lblArray)
		stackLeft.axis = .vertical
		stackLeft.distribution = .fillEqually
		let stackRight = UIStackView(arrangedSubviews: checkArray)
		stackRight.axis = .vertical
		stackRight.distribution = .fillEqually
		stackRight.widthAnchor.constraint(equalToConstant: 250).isActive = true
		self.m_stackLbls = UIStackView(arrangedSubviews: [stackLeft, stackRight])
		self.m_stackLbls.axis = .horizontal
		self.m_stackLbls.alignment = .fill
		self.m_stackLbls.distribution = .fill
		self.m_stackLbls.spacing = 5
		
		self.view.addSubview(self.m_stackLbls)
		self.m_stackLbls.translatesAutoresizingMaskIntoConstraints = false
		self.m_stackLbls.topAnchor.constraint(equalTo: self.loadImage.bottomAnchor).isActive = true
//		self.m_stackLbls.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
//		self.m_stackLbls.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_stackLbls.bottomAnchor.constraint(equalTo: self.m_stackBtns.readableContentGuide.topAnchor).isActive = true
		self.m_stackLbls.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		self.m_stackLbls.widthAnchor.constraint(equalToConstant: 320).isActive = true
	}
	
	fileprivate func setupImgView() {
		self.loadImage = UIImageView(image: UIImage(named: "smile"))
		self.view.addSubview(self.loadImage)
		self.loadImage.contentMode = .scaleAspectFit
		self.loadImage.translatesAutoresizingMaskIntoConstraints = false
		self.loadImage.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor).isActive = true
		self.loadImage.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
		self.loadImage.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.loadImage.heightAnchor.constraint(equalTo: self.view.readableContentGuide.heightAnchor, multiplier: 1/3).isActive = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 這裡即是 uid 所解釋的，將Firebase使用者uid儲存愛變數uid裡面，在viewDidLoad中取用一次，便可在這個viewController隨意使用
		if let user = Auth.auth().currentUser {
			viewDetail(user.uid)
		}
		
		setupTestUI()
	
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
								//								vc.joinRoom()
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
		
		// 指 ref 是 firebase中的特定路徑，導引到特定位置，像是「FIRDatabase.database().reference(withPath: "ID/\(self.uid)/Profile/Name")」
		//		var ref: DatabaseReference!
		let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(uid)")
		//從database抓取url，再從storage下載圖片
		//先在database找到存放url的路徑
		//observe 到 .value
		refUser.child(DEF_USER_PHOTO).observe(.value) { (snapshot) in
			//存放在這個 url
			if let url = snapshot.value as? String {
				let maxSize : Int64 = 2 * 1024 * 1024 //大小：2MB，可視情況改變
				//從Storage抓這個圖片
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
					
					//非同步的方式，load出來
					DispatchQueue.main.async {
						self.loadImage.image = imageData
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
					self.name_check.text = user.name
					
					let gender = user.sex
					switch gender {
					case 1:
						self.gender_check.text = "man"
					case 2:
						self.gender_check.text = "woman"
					default:
						self.gender_check.text = "?"
					}
					
					self.email_check.text = user.mail
					
					self.phone_check.text = user.phone
				}
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// 前往 ChangeDataViewController，一樣使用程式碼前往以避免Firebase延遲問題
	@objc func changePersonInfo(_ sender: Any) {
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "ChangeDataViewControllerID") as? ChangeVC {
			if let img = self.loadImage.image {
				print(img.size)
				vc.m_image = img
			}
			self.present(vc, animated: true)
		}
	}
	
	// 前往 LogInViewController，先在Firebase中登出，並返回到最一開始的頁面
	@objc func logOut(_ sender: Any) {
		guard let myId = self.m_user?.uid else {
			return
		}
		let ref = Database.database().reference(withPath: "Online-Status/\(myId)")
		// Database 的 Online-Status: "OFF"
		ref.setValue("OFF")
		// Authentication 也 SignOut
		try! Auth.auth().signOut()
		
		// 前往LogIn頁面，回到初始頁面
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "LogInViewControllerID") as? LoginVC {
			self.present(vc, animated:true)
		}
	}
}

