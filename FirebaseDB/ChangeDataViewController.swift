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

class ChangeDataViewController: UIViewController {
    
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
	@IBOutlet weak var gender: UISegmentedControl!
	var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

		if let user = Auth.auth().currentUser {
            uid = user.uid
        }
    
		var ref: DatabaseReference!
        
		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name")
        ref.observe(.value, with: { (snapshot) in
			if let name = snapshot.value as? String {
            	self.name.text = name
			}
        })
        
		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Gender")
        ref.observe(.value, with: { (snapshot) in
			if let gender = snapshot.value as? Int {
            	self.gender.selectedSegmentIndex = gender
			}
        })
        
		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Phone")
        ref.observe(.value, with: { (snapshot) in
			if let phone = snapshot.value as? String {
            	self.phone.text = phone
			}
        })
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func uploadImage(_ sender: Any) {
        
        // 建立一個 UIImagePickerController 的實體
        let imagePickerController = UIImagePickerController()
        
        // 委任代理
        imagePickerController.delegate = self
        
        // 建立一個 UIAlertController 的實體
        // 設定 UIAlertController 的標題與樣式為 動作清單 (actionSheet)
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        
        // 建立三個 UIAlertAction 的實體
        // 新增 UIAlertAction 在 UIAlertController actionSheet 的 動作 (action) 與標題
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in
            
            // 判斷是否可以從照片圖庫取得照片來源
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.photoLibrary)，並 present UIImagePickerController
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
            
            // 判斷是否可以從相機取得照片來源
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.camera)，並 present UIImagePickerController
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        
        // 新增一個取消動作，讓使用者可以跳出 UIAlertController
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in
            
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        // 將上面三個 UIAlertAction 動作加入 UIAlertController
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        // 當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
        present(imagePickerAlertController, animated: true, completion: nil)
        

    }
    
    @IBAction func save(_ sender: Any) {
        
        
        if name.text != "" && phone.text != "" {
			Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name").setValue(name.text)
			Database.database().reference(withPath: "ID/\(self.uid)/Profile/Gender").setValue(gender.selectedSegmentIndex)
			Database.database().reference(withPath: "ID/\(self.uid)/Profile/Phone").setValue(phone.text)
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "ConfirmViewControllerID")as! ConfirmViewController
            self.present(nextVC,animated:true,completion:nil)
        }
        

    }
    
}

extension ChangeDataViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
        var selectedImageFromPicker: UIImage?
        
        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = pickedImage
        }
        
        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = UUID().uuidString
        
        
		guard let user = Auth.auth().currentUser else {
			return
		}
		uid = user.uid

		let storageRef = Storage.storage().reference().child("\(uniqueString).jpg")
		// 當判斷有 selectedImage 時，我們會在 if 判斷式裡將圖片上傳
		guard let selectedImage = selectedImageFromPicker else {
			return
		}
			
		if let uploadData = selectedImage.jpegData(compressionQuality: 0.5) {
			// 這行就是 FirebaseStorage 關鍵的存取方法。
			storageRef.putData(uploadData, metadata: nil) { (data, error) in
				if error != nil {
				// 若有接收到錯誤，我們就直接印在 Console 就好，在這邊就不另外做處理。
					print("Error: \(error!.localizedDescription)")
					return
				}
                        
				// 連結取得方式就是：data?.downloadURL()?.absoluteString。
//				storageRef.downloadURL { (url, error) in
					// 我們可以 print 出來看看這個連結事不是我們剛剛所上傳的照片。
					if let uploadImageUrl = data?.path {
						print("Photo Url: \(uploadImageUrl)")
						// 存放在database
						let databaseRef = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
						
						databaseRef.setValue(uploadImageUrl) { (error, dataRef) in
							
							if error != nil {
								print("Database Error: \(error!.localizedDescription)")
							} else {
								print("圖片已儲存")
							}
						}
					}
//				}
			}
		}
		dismiss(animated: true, completion: nil)
	}//uid
}

