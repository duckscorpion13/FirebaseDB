//
//  RoomVC.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/9.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

enum EN_TABLE_MODE: Int {
	case TABLE_BY_DEFAULT = 0
	case TABLE_BY_SORT
	case TABLE_BY_GROUP
}

class RoomVC: UIViewController {

	var m_stackBtns: UIStackView? = nil
	
	var m_tableType: EN_TABLE_MODE = .TABLE_BY_DEFAULT
	
//	var m_isSort = false
//	var m_isGroup = false
	var m_user: ST_USER_INFO? = nil
	var m_room: ST_ROOM_INFO? = nil
//	var m_roomNum = 0
//	var m_teamCount = 3
	var m_isHost = false
	var m_tableView = UITableView(frame: .zero, style: .grouped)
	var m_members = [ST_MEMBER_INFO]()
	var m_sortMembers = [ST_MEMBER_INFO]()
	var m_groupMembers = [[ST_MEMBER_INFO]]()
	var m_imgMap = [String : UIImage]()
	
	var m_sortArray = [Int]()
	var m_groupArray = [Int]()
	
	fileprivate func setupTableView() {
		
		self.m_tableView.register(MyTableViewCell.self, forCellReuseIdentifier: "Cell")
		
		self.m_tableView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.m_tableView)
		self.m_tableView.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor, constant: 20).isActive = true
		self.m_tableView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
		self.m_tableView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_tableView.heightAnchor.constraint(equalTo: self.view.readableContentGuide.heightAnchor, multiplier: 0.65).isActive = true
		
		self.m_tableView.dataSource = self
		self.m_tableView.delegate = self
		
//		print(randomIndex(10))
	}
	
	func updateRand(_ total: Int) {
		guard let roomNum = self.m_room?.number else {
			return
		}
		
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
		refRoom.child(DEF_ROOM_RAND).setValue(self.randomIndex(total))
	}
	
	func addMember(_ name: String) {
		guard let roomNum = self.m_room?.number else {
			return
		}
		
		let uid = UUID().uuidString
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
		let values: [String : Any] =
			[
				DEF_ROOM_MEMBERS_NICKNAME : name,
				DEF_ROOM_MEMBERS_INDEX : 0,
				DEF_ROOM_MEMBERS_CANDIDATE : false,
				DEF_ROOM_MEMBERS_TEAM : 0,
				DEF_ROOM_MEMBERS_VOTED : false,
				DEF_ROOM_MEMBERS_POLL: 0
		]
		refRoom.child(DEF_ROOM_MEMBERS).updateChildValues([uid : values])
	}
	
	func joinRoom() {
		guard let roomNum = self.m_room?.number else {
			return
		}
		
		if let user = self.m_user,
		let name = user.name,
		let uid = user.uid {
			let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
			let values: NSMutableDictionary =
				[
					DEF_ROOM_MEMBERS_NICKNAME : name,
					DEF_ROOM_MEMBERS_INDEX : 0,
					DEF_ROOM_MEMBERS_CANDIDATE : false,
					DEF_ROOM_MEMBERS_TEAM : 0,
					DEF_ROOM_MEMBERS_VOTED : false,
					DEF_ROOM_MEMBERS_POLL : 0,
				]
			refRoom.child(DEF_ROOM_MEMBERS).updateChildValues([uid : values])
		}
	}
	
	@objc func leaveRoom() {
		guard let roomNum = self.m_room?.number else {
			return
		}
		
		if let user = self.m_user,
		let uid = user.uid {
			let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
			refRoom.child(DEF_ROOM_MEMBERS).child(uid).removeValue()
			self.dismiss(animated: true)
		}
	}
	
	func getRoomInfo() {
		guard let roomNum = self.m_room?.number else {
			return
		}
		
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
		
		refRoom.observe( .value) { (snapshot) in
			if let dict = snapshot.value as? [String : Any] {
				self.m_room?.groups = dict[DEF_ROOM_GROUP] as? Int
				self.m_room?.title = dict[DEF_ROOM_TITLE] as? String
				self.m_room?.message = dict[DEF_ROOM_MESSAGE] as? String
			}
		}
		
		refRoom.child(DEF_ROOM_HOST).observeSingleEvent(of: .value) { (snapshot) in
			if let host = snapshot.value as? String,
			let uid = self.m_user?.uid {
				self.m_isHost = (host == uid)
			}
		}
		
		refRoom.child(DEF_ROOM_MEMBERS).observe(.value) { (snapshot) in
			if snapshot.hasChildren() {
				self.m_room?.members = Int(snapshot.childrenCount)
				self.m_members.removeAll()
				var randArray = [Int]()
				for member in snapshot.children {
					if let item = member as? DataSnapshot,
					let dict = item.value as? [String : Any],
					let name = dict[DEF_ROOM_MEMBERS_NICKNAME] as? String {
						self.getPhoto(item.key)
						let info = ST_MEMBER_INFO(uid: item.key,
												candidate: dict[DEF_ROOM_MEMBERS_CANDIDATE] as? Bool,
												  team: dict[DEF_ROOM_MEMBERS_TEAM] as? Int,
												  index: dict[DEF_ROOM_MEMBERS_INDEX] as? Int,
												  nickname: name,
												  voted: dict[DEF_ROOM_MEMBERS_VOTED] as? Bool,
												  poll: dict[DEF_ROOM_MEMBERS_POLL] as? Int)
						randArray.append(dict[DEF_ROOM_MEMBERS_INDEX] as? Int ?? 0)
						self.m_members.append(info)
					}
				}
				
				self.buildGroupArray(Int(snapshot.childrenCount))
				self.buildSortArray(randArray)
//				print(self.m_members)
				DispatchQueue.main.async {
					self.m_tableView.reloadData()
				}
			}
		}
	}
	
	func getPhoto(_ userId: String) {
		
		let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(userId)")
		//從database抓取url，再從storage下載圖片
		//先在database找到存放url的路徑
		//		ref = Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo")
		//observe 到 .value
		refUser.child(DEF_USER_PHOTO).observe(.value) { (snapshot) in
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
					
					self.m_imgMap[userId] = imageData
				}
			}
		}
	}
	
	@objc func clickGroup() {
		randamGroup(5)
	}
	
	fileprivate func buildGroupArray(_ max: Int) {
		self.m_groupMembers.removeAll()
		for i in 0 ..< max {
			
			let array = self.m_members.filter {
				$0.team == i
			}
			self.m_groupMembers.append(array)
		}
	}
	
	func randamGroup(_ max: Int) {
		guard let roomNum = self.m_room?.number else {
			return
		}

		self.m_tableType = .TABLE_BY_GROUP
		if(self.m_isHost) {
			let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
			refRoom.updateChildValues([DEF_ROOM_GROUP : max])
			refRoom.child(DEF_ROOM_MEMBERS).observeSingleEvent(of: .value) { (snapshot) in
				if snapshot.hasChildren() {
					var i = 0
					let groupArray = self.randomIndex(Int(snapshot.childrenCount)).map {
						$0 % max
					}
	//				print(randArray)
					for member in snapshot.children {
						if let item = member as? DataSnapshot {
							let team = groupArray[i]
							self.m_members[i].team = team
							refRoom.child(DEF_ROOM_MEMBERS).child(item.key).updateChildValues([DEF_ROOM_MEMBERS_TEAM : team])
							i += 1
						}
					}
					self.m_groupArray = groupArray
//					self.buildGroupArray(max)
				}
			}
		}
	}
	@objc func clickSort() {
		randamSort()
	}
	
	fileprivate func buildSortArray(_ randArray: [Int]) {
		self.m_sortMembers.removeAll()
		for i in 0 ..< randArray.count {
			if let index = randArray.index(of: i) {
				let member = self.m_members[index]
				self.m_sortMembers.append(member)
			}
		}
	}
	
	func randamSort() {
		guard let roomNum = self.m_room?.number else {
			return
		}
		
		self.m_tableType = .TABLE_BY_SORT
		if(self.m_isHost) {
			let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
			refRoom.child(DEF_ROOM_MEMBERS).observeSingleEvent(of: .value) { (snapshot) in
				if snapshot.hasChildren() {
					var i = 0
					let randArray = self.randomIndex(Int(snapshot.childrenCount))
	//				print(randArray)
					for member in snapshot.children {
						if let item = member as? DataSnapshot {
							let order = randArray[i]
							self.m_members[i].index = order
							refRoom.child(DEF_ROOM_MEMBERS).child(item.key).updateChildValues([DEF_ROOM_MEMBERS_INDEX : order])
							i += 1
						}
					}
					
//					self.buildSortArray(randArray)
				}
			}
		}
	}
	
	fileprivate func randomIndex(_ total: Int) -> [Int] {
		var randomArray = [Int]()
		while randomArray.count < total {
			let number = Int.random(in: 0 ..< total)
			if let _ = randomArray.firstIndex(of: number) {
			} else {
				randomArray.append(number)
			}
		}
		return randomArray
	}
	
	fileprivate func setupBtns() {
		let btn1 = UIButton(frame: CGRect(x: 30, y: 30, width: 50, height: 50))
		btn1.setTitle("Group", for: .normal)
		btn1.setTitleColor(.red, for: .normal)
		view.addSubview(btn1)
		btn1.addTarget(self, action: #selector(clickGroup), for: .touchUpInside)
		
		let btn2 = UIButton(frame: CGRect(x: 130, y: 30, width: 50, height: 50))
		btn2.setTitle("Add", for: .normal)
		btn2.setTitleColor(.blue, for: .normal)
		view.addSubview(btn2)
		btn2.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
		
		let btn3 = UIButton(frame: CGRect(x: 230, y: 30, width: 50, height: 50))
		btn3.setTitle("Leave", for: .normal)
		btn3.setTitleColor(.green, for: .normal)
		view.addSubview(btn3)
		btn3.addTarget(self, action: #selector(leaveRoom), for: .touchUpInside)
		
		let btn4 = UIButton(frame: CGRect(x: 330, y: 30, width: 50, height: 50))
		btn4.setTitle("Sort", for: .normal)
		btn4.setTitleColor(.red, for: .normal)
		view.addSubview(btn4)
		btn4.addTarget(self, action: #selector(clickSort), for: .touchUpInside)
		
		self.m_stackBtns = UIStackView(arrangedSubviews: [btn1, btn2, btn3, btn4])
		if let stack = self.m_stackBtns {
			stack.alignment = .fill
			stack.distribution = .fillEqually
			stack.frame = CGRect(x: 30, y: 30, width: 250, height: 50)
			view.addSubview(stack)
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		setupTableView()
		
		setupBtns()
		
		let segment = UISegmentedControl(frame: CGRect(x: 30, y: 130, width: 250, height: 50))
		segment.insertSegment(withTitle: "normal", at: 0, animated: true)
		segment.insertSegment(withTitle: "sort", at: 1, animated: true)
		segment.insertSegment(withTitle: "group", at: 2, animated: true)
		segment.selectedSegmentIndex = 0
		view.addSubview(segment)
		segment.addTarget(self, action: #selector(clickSegment), for: .valueChanged)
		
		getRoomInfo()
        // Do any additional setup after loading the view.
    }
	@objc func clickSegment(_ sender: Any) {
		if let segment = sender as? UISegmentedControl {
			self.m_tableType = EN_TABLE_MODE(rawValue: segment.selectedSegmentIndex) ?? .TABLE_BY_DEFAULT
			DispatchQueue.main.async {
				self.m_tableView.reloadData()
			}
		}
	}
	@objc func showAlert() {
		let alert = UIAlertController(title: "New Member",
								message: "Enter Name",
								preferredStyle: .alert)
		alert.addTextField {
			(textField: UITextField!) -> Void in
			textField.placeholder = "Name"
		}
		
		let cancelAction = UIAlertAction(
			title: "Cancel",
			style: .cancel)
		alert.addAction(cancelAction)
		
		let okAction = UIAlertAction(
			title: "OK",
			style: .default) {
				(action: UIAlertAction!) -> Void in
				if let name = alert.textFields?.first?.text {
					self.addMember(name)
				}
		}
		alert.addAction(okAction)
		
		self.present(alert, animated: true)
				

	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RoomVC: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.m_tableType {
		case .TABLE_BY_GROUP:
			return self.m_groupMembers[section].count
		case .TABLE_BY_SORT:
			return self.m_sortMembers.count
		default:
			return self.m_members.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyTableViewCell
		var member: ST_MEMBER_INFO? = nil
		switch self.m_tableType {
		case .TABLE_BY_GROUP:
			if(indexPath.row < self.m_groupMembers[indexPath.section].count) {
				member = self.m_groupMembers[indexPath.section][indexPath.row]
			}
		case .TABLE_BY_SORT:
			if(indexPath.row < self.m_sortMembers.count) {
				member = self.m_sortMembers[indexPath.row]
			}
		default:
			if(indexPath.row < self.m_members.count) {
				member = self.m_members[indexPath.row]
			}
		}
		cell.nameLabel.text = member?.nickname
		cell.detailLabel.text = "\(member?.poll ?? 0)"
		let uid = member?.uid ?? ""
		if let _ = self.m_imgMap.index(forKey: uid) {
			cell.imgView.image = self.m_imgMap[uid]
		} else {
			cell.imgView.image = UIImage(named: "smile")
		}
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		let groups = self.m_room?.groups ?? 1
		return self.m_tableType == .TABLE_BY_GROUP ? groups : 1
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return  self.m_tableType == .TABLE_BY_GROUP ? "TEAM \(section + 1)" : nil
	}

}
