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

	var m_user: ST_USER_INFO? = nil
	var fullScreenSize :CGSize! = UIScreen.main.bounds.size
	
	var m_collectionView: UICollectionView!
	
	var m_rooms = [ST_ROOM_INFO]()
	var m_imgMap = [String : UIImage]()
	
	fileprivate func setupCollectionView() {
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		self.m_collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		
		// Register cell classes
		self.m_collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		self.m_collectionView.delegate = self
		self.m_collectionView.dataSource = self
		
		
		self.view.addSubview(self.m_collectionView)
		self.m_collectionView.translatesAutoresizingMaskIntoConstraints = false
		self.m_collectionView.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor).isActive = true
//		self.m_collectionView.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor).isActive = true
		self.m_collectionView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
		self.m_collectionView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_collectionView.heightAnchor.constraint(equalTo: self.view.readableContentGuide.heightAnchor, multiplier: 2/3).isActive = true
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
        return self.m_rooms.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		// 依據前面註冊設置的識別名稱 "Cell" 取得目前使用的 cell
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
		
		let roomNum = String(self.m_rooms[indexPath.row].number ?? 0)
		// 設置 cell 內容 (即自定義元件裡 增加的圖片與文字元件)
		if let _ = self.m_imgMap.index(forKey: roomNum) {
			cell.imageView.image = self.m_imgMap[roomNum]
		} else {
			cell.imageView.image = UIImage(named: "smile")
		}
		cell.titleLabel.text = self.m_rooms[indexPath.row].title
		
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if let roomNum = self.m_rooms[indexPath.row].number {
			self.enterRoom(roomNum)
		}
	}
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
		return CGSize(width: 100, height: 100)
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
