//
//  SignUpViewController.swift
//  FirebaseDB
//
//  Created by Derek on 2019/2/2.
//  Copyright © 2019年 Derek. All rights reserved.



import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpVC: UIViewController {
    
    
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var Gender: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Phone: UITextField!
    
    // LogInViewController 有詳細說明 uid ，這邊就不再重複了
    var uid = ""
    
    // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
    let uniqueString = UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 這裡即是 uid 所解釋的，將Firebase使用者uid儲存愛變數uid裡面，在viewDidLoad中取用一次，便可在這個viewController隨意使用
		if let user = Auth.auth().currentUser{
            uid = user.uid
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //上傳照片按鈕
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
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        
        // 將上面三個 UIAlertAction 動作加入 UIAlertController
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        // 當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
        present(imagePickerAlertController, animated: true, completion: nil)
    }

    // 這是前往LogInViewController的按鈕，但在到下一個ViewController之前，先「確認註冊資料填寫完畢」
    @IBAction func Confirm_Button_Tapped(_ sender: Any) {
        
        // 在四個 Text Field 中都要輸入東西，接著把所有在手機上輸入的資訊，在Firebase中setvalue，就即時更新到 Firebase 了！
        if Name.text != "" && Gender.text != "" && Email.text != "" && Phone.text != ""{
			Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name").setValue(Name.text)
			Database.database().reference(withPath: "ID/\(self.uid)/Profile/Gender").setValue(Gender.text)
            Database.database().reference(withPath: "ID/\(self.uid)/Profile/Email").setValue(Email.text)
            Database.database().reference(withPath: "ID/\(self.uid)/Profile/Phone").setValue(Phone.text)

            //跳回登入頁
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "LogInViewControllerID") as! LoginVC
            self.present(nextVC, animated: true, completion: nil)
        
        }
        
    }

}


//添加照片的Extention
extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
        // 取得從 UIImagePickerController 選擇的檔案
        guard let pickedImage = info[.editedImage] as? UIImage else {
			return
		}
	
		guard let user = Auth.auth().currentUser else {
			return
		}
        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = NSUUID().uuidString
		
		self.uid = user.uid
	
		let storageRef = Storage.storage().reference().child("\(uniqueString).png")
		let databaseRef = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
				
		if let uploadData = pickedImage.pngData() {
			// 這行就是 FirebaseStorage 關鍵的存取方法。
			storageRef.putData(uploadData, metadata: nil) { (data, error) in
				
				if error != nil {
					// 若有接收到錯誤，我們就直接印在 Console 就好，在這邊就不另外做處理。
					print("Error: \(error!.localizedDescription)")
					return
				}
                        
				// 連結取得方式就是：data?.downloadURL()?.absoluteString。
				if let uploadImageUrl = data?.path {
					
					// 我們可以 print 出來看看這個連結事不是我們剛剛所上傳的照片。
					print("Photo Url: \(uploadImageUrl)")
					
					// 存放在database
					databaseRef.setValue(uploadImageUrl) { (error, dataRef) in
						if error != nil {
							print("Database Error: \(error!.localizedDescription)")
						}
						else {
							print("圖片已儲存")
						}
					}
				}
			}
		}
		dismiss(animated: true, completion: nil)
    }
}

