//
//  ChangeDataViewController.swift
//  FirebaseDB
//
//  Created by Derek on 2019/2/3.
//  Copyright © 2019年 Derek. All rights reserved.


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ChangeVC: UIViewController {
    
    
	@IBOutlet weak var photo: UIButton!
	@IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
	@IBOutlet weak var gender: UISegmentedControl!
	var m_userId = ""
	var m_image: UIImage? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.photo.setBackgroundImage(m_image, for: .normal)
		self.m_image = nil
		
		if let user = Auth.auth().currentUser {
            m_userId = user.uid
        }
    
		let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(self.m_userId)")
        
//		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name")
        refUser.child(DEF_USER_NAME).observeSingleEvent(of: .value, with: { (snapshot) in
			if let name = snapshot.value as? String {
            	self.name.text = name
			}
        })
        
//		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Gender")
		refUser.child(DEF_USER_SEX).observeSingleEvent(of: .value, with: { (snapshot) in
			if let gender = snapshot.value as? Int {
            	self.gender.selectedSegmentIndex = gender
			}
        })
        
//		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Phone")
		refUser.child(DEF_USER_PHONE).observeSingleEvent(of: .value, with: { (snapshot) in
			if let phone = snapshot.value as? String {
            	self.phone.text = phone
			}
        })
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    
    @IBAction func openImgPC(_ sender: Any) {
        
        // 建立一個 UIImagePickerController 的實體
        let picker = UIImagePickerController()
        
        // 委任代理
        picker.delegate = self
        
		let alert = UIAlertController.selectAction(title: "Upload Picture", message: "Select Image", actions: ["Album", "Camera"]) { select in
			if(0 == select) {
				if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
					picker.sourceType = .photoLibrary
					self.present(picker, animated: true)
				}
			} else {
				if UIImagePickerController.isSourceTypeAvailable(.camera) {
					picker.sourceType = .camera
					self.present(picker, animated: true)
				}
			}
		}
        // 當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
        present(alert, animated: true)
        

    }
	
	fileprivate func uploadImage(_ image: UIImage) {
		
		let uniqueString = UUID().uuidString
		let storageRef = Storage.storage().reference().child("\(uniqueString).jpg")
		if let uploadData = image.jpegData(compressionQuality: 0.1) {
			// 這行就是 FirebaseStorage 關鍵的存取方法。
			storageRef.putData(uploadData, metadata: nil) { (data, error) in
				if error != nil {
					//					print("Error: \(error!.localizedDescription)")
					return
				}
				
				if let uploadImageUrl = data?.path {
					//					print("Photo Url: \(uploadImageUrl)")
					
					let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(self.m_userId)")
					refUser.child(DEF_USER_PHOTO).setValue(uploadImageUrl) { (error, dataRef) in
						
						if error != nil {
							print("Database Error: \(error!.localizedDescription)")
						} else {
							print("Success")
						}
					}
				}
			}
		}
	}
	
    @IBAction func save(_ sender: Any) {
        
        
        if name.text != "" && phone.text != "" {
			let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(self.m_userId)")
			
			refUser.child(DEF_USER_NAME).setValue(name.text)
			refUser.child(DEF_USER_SEX).setValue(gender.selectedSegmentIndex)
			refUser.child(DEF_USER_PHONE).setValue(phone.text)
		
			if let img = self.m_image {
				uploadImage(img)
			}
			
			self.dismiss(animated: true)
        }
        

    }
    
}

extension ChangeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		
        // 取得從 UIImagePickerController 選擇的檔案
        guard let pickedImage = info[.originalImage] as? UIImage else {
			return
		}
		
		self.photo.setBackgroundImage(pickedImage, for: .normal)
		self.m_image = pickedImage
		picker.dismiss(animated: true)
	}
}

