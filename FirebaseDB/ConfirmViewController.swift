//
//  ConfirmViewController.swift
//  FirebaseDB
//
//  Created by Derek on 2019/2/3.
//  Copyright © 2019年 Derek. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ConfirmViewController: UIViewController {
    
    //在這裡從Firebase load image
    @IBOutlet weak var loadImage: UIImageView!
    
    // 這是從Firebase拿取資訊，顯示實際註冊資料的Label
    @IBOutlet weak var name_check: UILabel!
    @IBOutlet weak var gender_check: UILabel!
    @IBOutlet weak var email_check: UILabel!
    @IBOutlet weak var phone_check: UILabel!
    
    // 編輯個人資料Button(會前往另一個頁面)，原先也是 isHidden，按下按鈕才顯示出來
    @IBOutlet weak var changePersonalInfo: UIButton!
    // 登出Button，原先也是 isHidden，按下按鈕才顯示出來
    @IBOutlet weak var logOut: UIButton!
    
    // LogInViewController 有詳細說明 uid ，這邊就不再重複了
	var m_user: ST_USER_INFO!
    var m_userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 這裡即是 uid 所解釋的，將Firebase使用者uid儲存愛變數uid裡面，在viewDidLoad中取用一次，便可在這個viewController隨意使用
		if let user = Auth.auth().currentUser {
            m_userId = user.uid
			viewDetail()
        }

		let btn = UIButton(frame: CGRect(x: 30, y: 30, width: 50, height: 50))
		btn.setTitle("Room", for: .normal)
		btn.setTitleColor(.red, for: .normal)
		view.addSubview(btn)
		btn.addTarget(self, action: #selector(enterRoom), for: .touchUpInside)
    }
	
	@objc func enterRoom() {
		let vc = RoomVC()
		vc.view.backgroundColor = .lightGray
		self.present(vc, animated: true)
	}
    
	func viewDetail() {
        
        // 指 ref 是 firebase中的特定路徑，導引到特定位置，像是「FIRDatabase.database().reference(withPath: "ID/\(self.uid)/Profile/Name")」
//		var ref: DatabaseReference!
        let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(self.m_userId)")
        //從database抓取url，再從storage下載圖片
        //先在database找到存放url的路徑
//		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
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
				self.name_check.text = dict[DEF_USER_NAME] as? String
				
				let gender = dict[DEF_USER_SEX] as? Int
				switch gender {
				case 1:
					self.gender_check.text = "man"
				case 2:
					self.gender_check.text = "woman"
				default:
					self.gender_check.text = "?"
				}
				
				self.email_check.text = dict[DEF_USER_MAIL] as? String
				
				self.phone_check.text = dict[DEF_USER_PHONE] as? String
			
			}
		}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 前往 ChangeDataViewController，一樣使用程式碼前往以避免Firebase延遲問題
    @IBAction func changePersonInfo(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "ChangeDataViewControllerID") as? ChangeDataViewController {
			if let img = self.loadImage.image {
				print(img.size)
				vc.m_image = img
			}
			self.present(vc, animated: true)
		}
    }
    
    // 前往 LogInViewController，先在Firebase中登出，並返回到最一開始的頁面
    @IBAction func logOut(_ sender: Any) {
        
		let ref = Database.database().reference(withPath: "Online-Status/\(m_userId)")
        // Database 的 Online-Status: "OFF"
        ref.setValue("OFF")
        // Authentication 也 SignOut
		try!Auth.auth().signOut()
        
        // 前往LogIn頁面，回到初始頁面
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "LogInViewControllerID")as! LoginVC
        self.present(nextVC,animated:true,completion:nil)
        
        

    }
    
    
}
