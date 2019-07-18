//
//  ChangeDataViewController.swift
//  FirebaseDB
//
//  Created by Derek on 2019/2/3.
//  Copyright © 2019 Derek. All rights reserved.


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ChangeVC: BackgroundVC {
    
    
	@IBOutlet weak var m_saveBtn: UIButton!
	@IBOutlet weak var photo: UIButton!
	@IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
	@IBOutlet weak var gender: UISegmentedControl!
	
	var m_userId = ""
	var m_selfie: UIImage? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.photo.setBackgroundImage(m_selfie, for: .normal)
		self.m_selfie = nil
		
		m_saveBtn.clipsToBounds = true
		m_saveBtn.layer.cornerRadius = 25
		
		if let user = Auth.auth().currentUser {
            m_userId = user.uid
        }
    
		let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(self.m_userId)")
		
        refUser.child(DEF_USER_NAME).observeSingleEvent(of: .value, with: { (snapshot) in
			if let name = snapshot.value as? String {
            	self.name.text = name
			}
        })
		
		refUser.child(DEF_USER_SEX).observeSingleEvent(of: .value, with: { (snapshot) in
			if let gender = snapshot.value as? Int {
            	self.gender.selectedSegmentIndex = gender
			}
        })
		
		refUser.child(DEF_USER_PHONE).observeSingleEvent(of: .value, with: { (snapshot) in
			if let phone = snapshot.value as? String {
            	self.phone.text = phone
			}
        })
    
    }
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    
    @IBAction func openImgPC(_ sender: Any) {
		
        let picker = UIImagePickerController()
		
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
        present(alert, animated: true)
		
    }
	
	fileprivate func uploadImage(_ image: UIImage) {
		
		let uniqueString = UUID().uuidString
		let storageRef = Storage.storage().reference().child("\(uniqueString).jpg")
		if let uploadData = image.jpegData(compressionQuality: 0.1) {
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
		
			if let img = self.m_selfie {
				uploadImage(img)
			}
			
			self.dismiss(animated: true)
        }
    }
    
}

extension ChangeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
        // get picked image
        guard let pickedImage = info[.originalImage] as? UIImage else {
			return
		}
		
		self.photo.setBackgroundImage(pickedImage, for: .normal)
		self.m_selfie = pickedImage
		picker.dismiss(animated: true)
	}
}

