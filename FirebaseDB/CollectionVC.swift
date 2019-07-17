//
//  CollectionVC.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/15.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage


class CollectionVC: UIViewController {
	private let reuseIdentifier = "CollectionCell"

	var m_isFilter = false
	
	var m_user: ST_USER_INFO? = nil
	var fullScreenSize :CGSize! = UIScreen.main.bounds.size
	
	var m_collectionView: UICollectionView!
	
	var m_rooms = [ST_ROOM_INFO]()
	var m_filterRooms = [ST_ROOM_INFO]()
	var m_imgMap = [String : UIImage]()
	var m_image: UIImage? = nil
	
	fileprivate func setupCollectionView() {
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		let layout = UICollectionViewFlowLayout()
		layout.headerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)
		self.m_collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		
		// Register cell classes
		self.m_collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		self.m_collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
		self.m_collectionView.delegate = self
		self.m_collectionView.dataSource = self
		
	
		
		self.view.addSubview(self.m_collectionView)
		self.m_collectionView.translatesAutoresizingMaskIntoConstraints = false
		self.m_collectionView.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor).isActive = true
//		self.m_collectionView.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor).isActive = true
		self.m_collectionView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
		self.m_collectionView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_collectionView.heightAnchor.constraint(equalTo: self.view.readableContentGuide.heightAnchor, multiplier: 4/5).isActive = true
		
		
		let field = UITextField(frame: .zero)
		field.delegate = self
		field.backgroundColor = .white
		self.view.addSubview(field)
		field.translatesAutoresizingMaskIntoConstraints = false
		field.heightAnchor.constraint(equalToConstant: 35).isActive = true
		field.widthAnchor.constraint(equalToConstant: 180).isActive = true
		field.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor).isActive = true
		field.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
	}
	
	fileprivate func getRoomsInfo() {
		// Do any additional setup after loading the view.
		
		let refRooms = Database.database().reference(withPath: "\(DEF_ROOM)")
		
		refRooms.observe( .value) { (snapshot) in
			if snapshot.hasChildren() {
				
				self.m_rooms.removeAll()
				
				for room in snapshot.children {
					if let item = room as? DataSnapshot,
						let dict = item.value as? [String : Any] {
						let roomInfo = ST_ROOM_INFO(number: Int(item.key),
													members: 0,
													groups: dict[DEF_ROOM_GROUP] as? Int,
													title: dict[DEF_ROOM_TITLE] as? String,
													message: dict[DEF_ROOM_MESSAGE] as? String,
													background: dict[DEF_ROOM_BACKGROUND] as? String)
						self.m_rooms.append(roomInfo)
						
						self.getPhoto(item.key)
					}
				}
				DispatchQueue.main.async {
					self.m_collectionView.reloadData()
				}
			}
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		setupCollectionView()
		
		getRoomsInfo()
		
		
		
		let btn = UIButton(frame: .zero)
		btn.setTitle("Create Room", for: .normal)
		btn.setTitleColor(.blue, for: .normal)
		btn.addTarget(self, action: #selector(clickTest), for: .touchUpInside)
		self.view.addSubview(btn)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
		btn.widthAnchor.constraint(equalToConstant: 150).isActive = true
		btn.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor, constant: -20).isActive = true
		btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
	
	@objc func clickTest() {
		openImgPicker()
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
//								vc.view.backgroundColor = .lightGray
								self.present(vc, animated: true)
							}
						}
					}
				}
			}
		}
		
	}
	
	func createRoom(_ number: Int, title: String, message: String, callback: @escaping () -> () = {}) {
		
		if let myId = self.m_user?.uid {
			let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)")
			let values: [String : Any] =
				[
					DEF_ROOM_HOST : myId,
					DEF_ROOM_GROUP : 1,
					DEF_ROOM_TITLE : title,
					DEF_ROOM_MESSAGE : message,
				]
			refRoom.updateChildValues(["\(number)" : values]) {_,_ in
				callback()
			}
//			refRoom.child(DEF_ROOM_HOST).setValue(myId)
//			refRoom.child(DEF_ROOM_GROUP).setValue(1)
//			refRoom.child(DEF_ROOM_TITLE).setValue(title)
//			refRoom.child(DEF_ROOM_MESSAGE).setValue(message)

			enterRoom(number)
		}
	}
	
	func getPhoto(_ roomNum: String) {
		
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
		//從database抓取url，再從storage下載圖片
		//先在database找到存放url的路徑
		//		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
		//observe 到 .value
		refRoom.child(DEF_ROOM_BACKGROUND).observe(.value) { (snapshot) in
			//存放在這個 url
			if let url = snapshot.value as? String {
				let maxSize : Int64 =  2 * 1024 * 1024 //大小：2MB，可視情況改變
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
					
					self.m_imgMap[roomNum] = imageData
					DispatchQueue.main.async {
						self.m_collectionView.reloadData()
					}
				}
			}
		}
	}
	
	fileprivate func uploadImage(_ image: UIImage, roomNum: Int) {
		
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
					
					let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
					refRoom.child(DEF_ROOM_BACKGROUND).setValue(uploadImageUrl) { (error, dataRef) in
						
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
	
	func openImgPicker() {
		
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
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
extension CollectionVC: UICollectionViewDelegate, UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
		if(m_isFilter) {
			return self.m_filterRooms.count
		} else {
        	return self.m_rooms.count
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		// 依據前面註冊設置的識別名稱 "Cell" 取得目前使用的 cell
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
		
		let roomNum = m_isFilter ? String(self.m_filterRooms[indexPath.row].number ?? 0) : String(self.m_rooms[indexPath.row].number ?? 0)
		// 設置 cell 內容 (即自定義元件裡 增加的圖片與文字元件)
		if let _ = self.m_imgMap.index(forKey: roomNum) {
			cell.imageView.image = self.m_imgMap[roomNum]
		} else {
			cell.imageView.image = UIImage(named: "smile")
		}
		cell.titleLabel.text = m_isFilter ? self.m_filterRooms[indexPath.row].title : self.m_rooms[indexPath.row].title
		
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let roomNum = self.m_rooms[indexPath.row].number {
			self.enterRoom(roomNum)
		}
	}
	
//	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//
//	}
	
	
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension CollectionVC: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let edge = min(self.view.frame.width, self.view.frame.height) / 3
		return CGSize(width: edge, height: edge)
	}
	
	// 设置cell和视图边的间距
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
	}
	
	// 设置每一个cell最小行间距
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
	
	// 设置每一个cell的列间距
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
}


extension CollectionVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {


		// 取得從 UIImagePickerController 選擇的檔案
		guard let pickedImage = info[.originalImage] as? UIImage else {
			return
		}

		self.m_image = pickedImage
		picker.dismiss(animated: true) {
			let alert = UIAlertController.textsAlert(title: "New", message: "Create Room", placeholders: ["Title", "Message", "Number"]) {
				para in
				if (3 == para.count) {
					if let num = Int(para[2]) {
						self.createRoom(num, title: para[0], message: para[1]) {
							if let img = self.m_image {
								self.uploadImage(img, roomNum: num)
							}
						}
					}
				}
			}
			self.present(alert, animated: true)
		}
	}
}

extension CollectionVC: UITextFieldDelegate {
//	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool // return NO to disallow editing.
//
//	@available(iOS 2.0, *)
//	optional func textFieldDidBeginEditing(_ textField: UITextField) // became first responder
//
//	@available(iOS 2.0, *)
//	optional
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		if let text = textField.text,
		text != "" {
			self.m_filterRooms = self.m_rooms.filter({info in
				if let title = info.title?.lowercased(),
					let _ = title.range(of: text.lowercased()) {
					return true
				} else {
					return false
				}
			})
			self.m_isFilter = true
		} else {
			self.m_isFilter = false
		}
		self.m_collectionView.reloadData()
		
		return true
	}// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
//
//	@available(iOS 2.0, *)
//	optional func textFieldDidEndEditing(_ textField: UITextField) // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//
//	@available(iOS 10.0, *)
//	optional func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) // if implemented, called in place of textFieldDidEndEditing:
//
//
//	@available(iOS 2.0, *)
//	optional
//	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//		print("BBBBBBBBBBBBB")
//
//		return true
//	}// return NO to not change text
//
//
//	@available(iOS 2.0, *)
//	optional
//	func textFieldShouldClear(_ textField: UITextField) -> Bool {// called when clear button pressed. return NO to ignore (no notifications)
//		return true
//	}
//	@available(iOS 2.0, *)
//	optional func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
}
