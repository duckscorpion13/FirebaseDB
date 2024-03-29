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


class CollectionVC: BackgroundVC {
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
		
		let field = UITextField(frame: .zero)
		field.addTarget(self, action: #selector(fieldChange), for: .editingChanged)
		field.addTarget(self, action: #selector(fieldEnter), for: .touchDown)
//		field.delegate = self
		field.backgroundColor = .white
		self.view.addSubview(field)
		field.translatesAutoresizingMaskIntoConstraints = false
		field.heightAnchor.constraint(equalToConstant: 35).isActive = true
//		field.widthAnchor.constraint(equalToConstant: 180).isActive = true
		field.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor, constant: 15).isActive = true
//		field.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		field.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor).isActive = true
//		field.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		
		let search = UIImageView(image: UIImage(named: "search"))
		search.backgroundColor = .white
		self.view.addSubview(search)
		search.translatesAutoresizingMaskIntoConstraints = false
		search.heightAnchor.constraint(equalToConstant: 35).isActive = true
		search.widthAnchor.constraint(equalTo: search.heightAnchor).isActive = true
		search.leadingAnchor.constraint(equalTo: field.trailingAnchor).isActive = true
		search.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor, constant: -15).isActive = true
		search.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor).isActive = true
		
		let layout = UICollectionViewFlowLayout()
		layout.headerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)
		self.m_collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		
		// Register cell classes
		self.m_collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		self.m_collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
		self.m_collectionView.delegate = self
		self.m_collectionView.dataSource = self
		
	
		let blurEffect = UIBlurEffect(style: .light)
		let blurView = UIVisualEffectView(effect: blurEffect)
		blurView.alpha = 0.8
		self.m_collectionView.backgroundView = blurView
		self.m_collectionView.backgroundColor = .clear
		
		self.view.addSubview(self.m_collectionView)
		self.m_collectionView.translatesAutoresizingMaskIntoConstraints = false
		self.m_collectionView.topAnchor.constraint(equalTo: field.bottomAnchor).isActive = true
//		self.m_collectionView.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor).isActive = true
		self.m_collectionView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
		self.m_collectionView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_collectionView.heightAnchor.constraint(equalTo: self.view.readableContentGuide.heightAnchor, multiplier: 4/5).isActive = true
	}
	@objc func fieldEnter() {
		self.m_isMove = false
	}
	@objc func fieldChange(_ sender: Any) {
		if let field = sender as? UITextField,
		let text = field.text,
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.m_collectionView.reloadData()
		}
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
	
		let btn = GradientButton(frame: CGRect(x: 0, y: 0, width: 160, height: 50), startColor: .orange, endColor: .blue, type: .GRADIENT_UP_TO_DOWN)
		btn.setTitle("Create Room", for: .normal)
		btn.setTitleColor(.white, for: .normal)
		btn.addTarget(self, action: #selector(clickCreate), for: .touchUpInside)

		self.view.addSubview(btn)
		btn.translatesAutoresizingMaskIntoConstraints = false
		btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
		btn.widthAnchor.constraint(equalToConstant: 160).isActive = true
		btn.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor, constant: -20).isActive = true
		btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

    }
	
	@objc func clickCreate() {
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
								vc.m_background = self.m_imgMap[room.key]
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
		}
	}
	
	func getPhoto(_ roomNum: String) {
		
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
		refRoom.child(DEF_ROOM_BACKGROUND).observe(.value) { (snapshot) in
			if let url = snapshot.value as? String {
				let maxSize : Int64 =  2 * 1024 * 1024 //大小：2MB，可視情況改變
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
		// 當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
		self.checkPresent(alert, animated: true)
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
					let numStr = para[2]
					if let num = Int(numStr) {
						self.createRoom(num, title: para[0], message: para[1]) {
							if let img = self.m_image {
								self.m_imgMap[numStr] = img
								self.uploadImage(img, roomNum: num)
								self.enterRoom(num)
							}
						}
					}
				}
			}
			self.checkPresent(alert, animated: true)
		}
	}
}
