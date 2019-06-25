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
    
    // 以下四個是純粹的姓名、性別、信箱、電話的Label，原先設立為 isHidden，按下按鈕才顯示出來
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var genderL: UILabel!
    @IBOutlet weak var emailL: UILabel!
    @IBOutlet weak var phoneL: UILabel!
    
    // 編輯個人資料Button(會前往另一個頁面)，原先也是 isHidden，按下按鈕才顯示出來
    @IBOutlet weak var changePersonalInfo: UIButton!
    // 登出Button，原先也是 isHidden，按下按鈕才顯示出來
    @IBOutlet weak var logOut: UIButton!
    
    // LogInViewController 有詳細說明 uid ，這邊就不再重複了
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 這裡即是 uid 所解釋的，將Firebase使用者uid儲存愛變數uid裡面，在viewDidLoad中取用一次，便可在這個viewController隨意使用
		if let user = Auth.auth().currentUser {
            uid = user.uid
        }

    }
    
    
    @IBAction func viewDetail(_ sender: Any) {
        
        // 指 ref 是 firebase中的特定路徑，導引到特定位置，像是「FIRDatabase.database().reference(withPath: "ID/\(self.uid)/Profile/Name")」
		var ref: DatabaseReference!
        
        // 這只是將原先隱藏起來的label顯示出來
        nameL.isHidden = false
        genderL.isHidden = false
        emailL.isHidden = false
        phoneL.isHidden = false
        
        //從database抓取url，再從storage下載圖片
        //先在database找到存放url的路徑
		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
        //observe 到 .value
        ref.observe(.value) { (snapshot) in
            //存放在這個 url
			if let url = snapshot.value as? String {
            	let maxSize : Int64 = 2 * 1024 * 1024 //大小：2MB，可視情況改變
            	//從Storage抓這個圖片
//				Storage.storage().reference(forURL: url).getData(maxSize: maxSize) { (data, error) in
				Storage.storage().reference().child(url).getData(maxSize: maxSize) { (data, error) in
                	if error != nil {
                    	print(error)
                    	return
                	}
				
                	guard let imageData = UIImage(data: data!) else {
						return
					}
				
                	//非同步的方式，load出來
                	DispatchQueue.main.async {
                    	self.loadImage.image = imageData
                	}
            	}
			}
        }
        
        
        // 接下來也是很重要的一步，從Firebase拿取資料，並顯示為label(name, gender, email, phone)

        // 前面有個var ref，把這一串路徑除存在變數中
		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name")
        
        // .observe 顧名思義就是「察看」的意思，也就是說ref.observe(.value)->查看「這串導引到特定位置的路徑」的value
        // snapshot只是一個代稱(習慣為snapshot)，通常搭配.value，是指「這串路徑下的值」
        ref.observe(.value) { (snapshot) in
			if let name = snapshot.value as? String { // 假設 name 是這串路徑下的值，
            	// as! String 是因為下一行程式碼self.name_check.text為label，因此必須為String
            	self.name_check.text = name // self.name_check.text這個label為上一行程式碼所假設的 name
            	self.name_check.isHidden = false // 再把原本隱藏的顯示出來
			}
        }
        
        
        // 下面就都一樣的意思，只是換成Gender、Email、Phone
		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Gender")
        ref.observe(.value) { (snapshot) in
			if let gender = snapshot.value as? String {
            	self.gender_check.text = gender
            	self.gender_check.isHidden = false
			}
        }
        
		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Email")
        ref.observe(.value) { (snapshot) in
			if let email = snapshot.value as? String {
            	self.email_check.text = email
            	self.email_check.isHidden = false
			}
        }
        
		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Phone")
        ref.observe(.value) { (snapshot) in
			if let phone = snapshot.value as? String {
            	self.phone_check.text = phone
            	self.phone_check.isHidden = false
			}
        }
        
        logOut.isHidden = false// 登出Button顯示
        changePersonalInfo.isHidden = false// 修改個人資料Button顯示
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 前往 ChangeDataViewController，一樣使用程式碼前往以避免Firebase延遲問題
    @IBAction func changePersonInfo(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "ChangeDataViewControllerID")as! ChangeDataViewController
        self.present(nextVC,animated:true,completion:nil)

    }
    
    // 前往 LogInViewController，先在Firebase中登出，並返回到最一開始的頁面
    @IBAction func logOut(_ sender: Any) {
        
		let ref = Database.database().reference(withPath: "Online-Status/\(uid)")
        // Database 的 Online-Status: "OFF"
        ref.setValue("OFF")
        // Authentication 也 SignOut
		try!Auth.auth().signOut()
        
        // 前往LogIn頁面，回到初始頁面
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "LogInViewControllerID")as! LogInViewController
        self.present(nextVC,animated:true,completion:nil)
        
        

    }
    
    
}
