//
//  ModifyVC.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/18.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ModifyVC: BackgroundVC {
	
		var m_photoBtn: UIButton!
	
		var m_nameField = UITextField()
		var m_phoneField = UITextField()
		var m_sexSegment = UISegmentedControl()
		
		var m_userId = ""
		var m_selfie: UIImage? = nil
		
	fileprivate func getUserInfo() {
		if let user = Auth.auth().currentUser {
			m_userId = user.uid
		}
		
		let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(self.m_userId)")
		
		refUser.child(DEF_USER_NAME).observeSingleEvent(of: .value, with: { (snapshot) in
			if let name = snapshot.value as? String {
				self.m_nameField.text = name
			}
		})
		
		refUser.child(DEF_USER_SEX).observeSingleEvent(of: .value, with: { (snapshot) in
			if let gender = snapshot.value as? Int {
				self.m_sexSegment.selectedSegmentIndex = gender
			}
		})
		
		refUser.child(DEF_USER_PHONE).observeSingleEvent(of: .value, with: { (snapshot) in
			if let phone = snapshot.value as? String {
				self.m_phoneField.text = phone
			}
		})
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	
		self.m_photoBtn = UIButton(frame: .zero)
		self.m_photoBtn.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
		self.m_photoBtn.setTitle("Change", for: .normal)
		
		self.view.addSubview(self.m_photoBtn)
		self.m_photoBtn.translatesAutoresizingMaskIntoConstraints = false
		self.m_photoBtn.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor, constant: 30).isActive = true
		self.m_photoBtn.heightAnchor.constraint(equalTo: self.view.readableContentGuide.heightAnchor, multiplier: 0.25).isActive = true
		self.m_photoBtn.widthAnchor.constraint(equalTo: self.m_photoBtn.heightAnchor).isActive = true
		self.m_photoBtn.centerXAnchor.constraint(equalTo: self.view.readableContentGuide.centerXAnchor).isActive = true
		self.m_photoBtn.setBackgroundImage(m_selfie, for: .normal)
		self.m_selfie = nil
	
		let saveBtn = GradientButton(frame: CGRect(x: 0, y: 0, width: 150, height: 45), startColor: .orange, endColor: .green, type: .GRADIENT_LEFTUP_TO_RIGHTDOWN)
		saveBtn.addTarget(self, action: #selector(clickSave), for: .touchUpInside)
		saveBtn.setTitle("Save", for: .normal)
		
		self.view.addSubview(saveBtn)
		saveBtn.translatesAutoresizingMaskIntoConstraints = false
		saveBtn.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor, constant: -20).isActive = true
		saveBtn.centerXAnchor.constraint(equalTo: self.view.readableContentGuide.centerXAnchor).isActive = true
		saveBtn.widthAnchor.constraint(equalToConstant: 150).isActive = true
		saveBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
	
		self.m_nameField.backgroundColor = .white
		self.m_nameField.textColor = .blue
		self.m_nameField.textAlignment = .center
		self.m_nameField.placeholder = "Name"
		
		self.m_sexSegment.insertSegment(withTitle: "?", at: 0, animated: true)
		self.m_sexSegment.insertSegment(withTitle: "♂︎", at: 1, animated: true)
		self.m_sexSegment.insertSegment(withTitle: "♀︎", at: 2, animated: true)
		
		self.m_phoneField.backgroundColor = .white
		self.m_phoneField.textColor = .blue
		self.m_phoneField.textAlignment = .center
		self.m_phoneField.placeholder = "Phone"
		
		let stack = UIStackView(arrangedSubviews: [self.m_nameField, self.m_sexSegment, self.m_phoneField])
		stack.alignment = .fill
		stack.axis = .vertical
		stack.distribution = .fill
		stack.spacing = 25
		
		self.view.addSubview(stack)
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.topAnchor.constraint(equalTo: self.m_photoBtn.bottomAnchor, constant: 30).isActive = true
		stack.centerXAnchor.constraint(equalTo: self.view.readableContentGuide.centerXAnchor).isActive = true
		stack.widthAnchor.constraint(equalToConstant: 260).isActive = true
		stack.heightAnchor.constraint(equalToConstant: 160).isActive = true
		
		self.getUserInfo()
	}
	
		
	@objc func openImagePicker() {
		
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
		
		@objc func clickSave() {
			
			if m_nameField.text != "" && m_phoneField.text != "" {
				let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(self.m_userId)")
				
				refUser.child(DEF_USER_NAME).setValue(m_nameField.text)
				refUser.child(DEF_USER_SEX).setValue(m_sexSegment.selectedSegmentIndex)
				refUser.child(DEF_USER_PHONE).setValue(m_phoneField.text)
				
				if let img = self.m_selfie {
					uploadImage(img)
				}
				
				self.dismiss(animated: true)
			}
		}
		
	}
	
extension ModifyVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		// get picked image
		guard let pickedImage = info[.originalImage] as? UIImage else {
			return
		}
		
		self.m_photoBtn.setBackgroundImage(pickedImage, for: .normal)
		self.m_selfie = pickedImage
		picker.dismiss(animated: true)
	}
}
	

    

