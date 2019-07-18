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

class RoomVC: BackgroundVC {

	private let reuseIdentifier = "TableCell"
	
	var m_stackBtns: UIStackView? = nil
	
	var m_tableType: EN_TABLE_MODE = .TABLE_BY_DEFAULT
	
	var m_user: ST_USER_INFO? = nil
	var m_room: ST_ROOM_INFO? = nil

	var m_isHost = false
	
	var m_isVoted = false
	var m_segment = UISegmentedControl(frame: .zero)
	var m_tableView = UITableView(frame: .zero, style: .grouped)
	var m_members = [ST_MEMBER_INFO]()
	var m_sortMembers = [ST_MEMBER_INFO]()
	var m_groupMembers = [[ST_MEMBER_INFO]]()
	var m_imgMap = [String : UIImage]()
	
	var m_sortArray = [Int]()
	var m_groupArray = [Int]()
	
	fileprivate func setupTableView() {
		
		self.m_tableView.register(MyTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
		
		let refresh = UIRefreshControl()
		refresh.addTarget(self, action: #selector(refetch), for: .valueChanged)
		refresh.backgroundColor = .white
		if #available(iOS 10.0, *) {
			self.m_tableView.refreshControl = refresh
		} else {
			// Fallback on earlier versions
			self.m_tableView.addSubview(refresh)
		}
		
		let blurEffect = UIBlurEffect(style: .light)
		let blurView = UIVisualEffectView(effect: blurEffect)
		blurView.alpha = 0.8
		self.m_tableView.backgroundView = blurView
		self.m_tableView.backgroundColor = .clear
		
		self.m_tableView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.m_tableView)
		self.m_tableView.topAnchor.constraint(equalTo: self.m_segment.bottomAnchor, constant: 15).isActive = true
		self.m_tableView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
		self.m_tableView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_tableView.heightAnchor.constraint(equalTo: self.view.readableContentGuide.heightAnchor, multiplier: 0.85).isActive = true
		
		self.m_tableView.dataSource = self
		self.m_tableView.delegate = self
		
//		print(randomIndex(10))
	}
	
	@objc func refetch(_ sender: Any) {
		if let refresh = sender as? UIRefreshControl {
			print("aaaaaa")
			if(m_isHost) {
				switch self.m_tableType {
				case .TABLE_BY_GROUP:
					self.randomGroup(self.m_room?.groups ?? 1)
				case .TABLE_BY_SORT:
					self.randomSort()
				default: break
					
				}
			}
			refresh.endRefreshing()
		}
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
		
		if let name = self.m_user?.name,
		let myId = self.m_user?.uid {
			let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
			refRoom.child(DEF_ROOM_MEMBERS).child(myId).observeSingleEvent(of: .value) {  (snapshot) in
				if (!snapshot.hasChildren()) {
					let values: NSMutableDictionary =
						[
							DEF_ROOM_MEMBERS_NICKNAME : name,
							DEF_ROOM_MEMBERS_INDEX : 0,
							DEF_ROOM_MEMBERS_CANDIDATE : false,
							DEF_ROOM_MEMBERS_TEAM : 0,
							DEF_ROOM_MEMBERS_VOTED : false,
							DEF_ROOM_MEMBERS_POLL : 0,
						]
					refRoom.child(DEF_ROOM_MEMBERS).updateChildValues([myId : values])
				}
			}
		}
	}
	
	@objc func leaveRoom() {
		guard let roomNum = self.m_room?.number else {
			return
		}
		
		if(self.m_isHost) {
			let alert = UIAlertController.boolAction(title: "Close", message: "delete room, Sure?") {
				isDelete in
				if(isDelete) {
					let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
					refRoom.removeValue() {_,_ in
						self.dismiss(animated: true)
					}
				} else {
					self.dismiss(animated: true)
				}
			}
			self.present(alert, animated: true)
		} else {
			self.dismiss(animated: true)
		}
		
	}
	
	func getMemberInfo(_ uid: String) -> ST_MEMBER_INFO? {
		for member in self.m_members {
			if(uid == member.uid) {
				return member
			}
		}
		return nil
	}
	
	func expel(_ uid: String, success: @escaping () -> Void = {} ) {
		guard let roomNum = self.m_room?.number else {
			return
		}
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
		refRoom.child(DEF_ROOM_MEMBERS).child(uid).removeValue() { _,_ in
			success()
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
		
		refRoom.child(DEF_ROOM_HOST).observe( .value) { (snapshot) in
			if let host = snapshot.value as? String,
			let myId = self.m_user?.uid {
				self.m_isHost = (host == myId)
				self.m_stackBtns?.isHidden = !self.m_isHost
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
						
						if let myId = self.m_user?.uid,
						info.uid == myId {
							self.m_isVoted = dict[DEF_ROOM_MEMBERS_VOTED] as? Bool ?? true
						}
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
		refUser.child(DEF_USER_PHOTO).observe(.value) { (snapshot) in
			if let url = snapshot.value as? String {
				let maxSize : Int64 =  2 * 1024 * 1024 //2MB
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
					
					DispatchQueue.main.async {
						self.m_tableView.reloadData()
					}
				}
			}
		}
	}
	
	@objc func clickGroup() {
		let alert = UIAlertController.textsAlert(title: "Group", message: "How many teams?", placeholders: ["Group"]) { array in
			if(1 == array.count) {
				if let count = Int(array[0]) {
					self.randomGroup(count) {
						self.m_segment.selectedSegmentIndex = self.m_tableType.rawValue
					}
				}
			}
		}
		self.present(alert, animated: true)
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
	
	func randomGroup(_ max: Int, callback: @escaping () -> () = {}) {
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

					callback()
				}
			}
		}
	}
	
	@objc func clickSort() {
		let alert = UIAlertController.checkAction(title: "Sort", message: "Sure?") {
			self.randomSort {
				self.m_segment.selectedSegmentIndex = self.m_tableType.rawValue
			}
		}
		self.present(alert, animated: true)
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
	
	func vote(_ uid: String) {
		guard let roomNum = self.m_room?.number else {
			return
		}
		
		let refMembers = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)").child(DEF_ROOM_MEMBERS)
		refMembers.child(uid).child(DEF_ROOM_MEMBERS_POLL).observeSingleEvent(of: .value) { (snapshot) in
			
			guard let myId = self.m_user?.uid else {
				return
			}
			if let poll = snapshot.value as? Int {
				refMembers.child(uid).updateChildValues([DEF_ROOM_MEMBERS_POLL : poll+1])
				refMembers.child(myId).updateChildValues([DEF_ROOM_MEMBERS_VOTED : true])
			}
		}
	}
	
	@objc func resetVoted() {
		guard let roomNum = self.m_room?.number else {
			return
		}
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
		refRoom.child(DEF_ROOM_MEMBERS).observeSingleEvent(of: .value) { (snapshot) in
			if snapshot.hasChildren() {
				for member in snapshot.children {
					if let item = member as? DataSnapshot {
						refRoom.child(DEF_ROOM_MEMBERS).child(item.key).updateChildValues([DEF_ROOM_MEMBERS_POLL : 0, DEF_ROOM_MEMBERS_VOTED : false])
					}
				}
			}
		}
	}
	
	func randomSort(callback: @escaping () -> () = {}) {
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
					callback()
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
		let btnExit = UIButton(frame: .zero)
//		btnExit.setTitle("Leave", for: .normal)
		btnExit.setBackgroundImage(UIImage(named: "exit"), for: .normal)
		view.addSubview(btnExit)
		btnExit.translatesAutoresizingMaskIntoConstraints = false
		btnExit.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35).isActive = true
		btnExit.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15).isActive = true
		btnExit.widthAnchor.constraint(equalToConstant: 35).isActive = true
		btnExit.heightAnchor.constraint(equalToConstant: 35).isActive = true
		btnExit.addTarget(self, action: #selector(leaveRoom), for: .touchUpInside)
		
	
		let btnAdd = UIButton(frame: CGRect.zero)
//		btnAdd.setTitle("Add", for: .normal)
		btnAdd.setBackgroundImage(UIImage(named: "add"), for: .normal)
		view.addSubview(btnAdd)
		btnAdd.translatesAutoresizingMaskIntoConstraints = false
		btnAdd.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 35).isActive = true
		btnAdd.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15).isActive = true
		btnAdd.widthAnchor.constraint(equalToConstant: 35).isActive = true
		btnAdd.heightAnchor.constraint(equalToConstant: 35).isActive = true
		btnAdd.addTarget(self, action: #selector(clickAdd), for: .touchUpInside)
		
		
		let btn1 = UIButton(frame: CGRect.zero)
		btn1.setBackgroundImage(UIImage(named: "team"), for: .normal)
//		btn1.backgroundColor = .white
//		btn1.setTitle("Team", for: .normal)
//		btn1.setTitleColor(.red, for: .normal)
		btn1.addTarget(self, action: #selector(clickGroup), for: .touchUpInside)
		btn1.widthAnchor.constraint(equalTo: btn1.heightAnchor).isActive = true
		
		let btn2 = UIButton(frame: CGRect.zero)
		btn2.setBackgroundImage(UIImage(named: "reset"), for: .normal)
//		btn2.backgroundColor = .white
//		btn2.setTitle("Reset", for: .normal)
//		btn2.setTitleColor(.green, for: .normal)
		btn2.addTarget(self, action: #selector(resetVoted), for: .touchUpInside)
		btn2.widthAnchor.constraint(equalTo: btn2.heightAnchor).isActive = true
		
		let btn3 = UIButton(frame: CGRect.zero)
		btn3.setBackgroundImage(UIImage(named: "sort"), for: .normal)
//		btn3.backgroundColor = .white
//		btn3.setTitle("Sort", for: .normal)
//		btn3.setTitleColor(.blue, for: .normal)
		btn3.addTarget(self, action: #selector(clickSort), for: .touchUpInside)
		btn3.widthAnchor.constraint(equalTo: btn3.heightAnchor).isActive = true
		
	
		
		self.m_stackBtns = UIStackView(arrangedSubviews: [btn1, btn2, btn3])
		if let stack = self.m_stackBtns {
			
			stack.alignment = .center
			stack.distribution = .equalSpacing
			view.addSubview(stack)
			
			stack.translatesAutoresizingMaskIntoConstraints = false
			stack.bottomAnchor.constraint(equalTo: self.view.readableContentGuide.bottomAnchor).isActive = true
			stack.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
			stack.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
			stack.heightAnchor.constraint(equalToConstant: 50).isActive = true
		}
	}
	
	fileprivate func setupSegment() {
		
		self.m_segment.tintColor = .red
	
		self.m_segment.insertSegment(withTitle: "normal", at: 0, animated: true)
		self.m_segment.insertSegment(withTitle: "sort", at: 1, animated: true)
		self.m_segment.insertSegment(withTitle: "group", at: 2, animated: true)
		self.m_segment.selectedSegmentIndex = 0
		self.m_segment.addTarget(self, action: #selector(clickSegment), for: .valueChanged)
		view.addSubview(self.m_segment)
		
		self.m_segment.translatesAutoresizingMaskIntoConstraints = false
		self.m_segment.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor, constant: 15).isActive = true
		self.m_segment.centerXAnchor.constraint(equalTo: self.view.readableContentGuide.centerXAnchor).isActive = true
		self.m_segment.widthAnchor.constraint(equalToConstant: 250).isActive = true
		self.m_segment.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		setupSegment()
		
		setupTableView()
		
		setupBtns()
		
		joinRoom()
		
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
	
	@objc func clickAdd() {
		let alert = UIAlertController.textsAlert(title: "New Member", message: "What's new member's nickname", placeholders: ["Name"]) { array in
			if(1 == array.count) {
				let name = array[0]
				self.addMember(name)
			}
		}
		self.present(alert, animated: true)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
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
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MyTableViewCell
		cell.delegate = self
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
		cell.uid = uid
		if let _ = self.m_imgMap.index(forKey: uid) {
			cell.imgView.image = self.m_imgMap[uid]
		} else {
			cell.imgView.image = UIImage(named: "smile")
		}
		
		cell.voteBtn.isHidden = (self.m_user?.uid == uid)
		cell.voteBtn.isEnabled = !self.m_isVoted
		
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		let groups = self.m_room?.groups ?? 1
		return self.m_tableType == .TABLE_BY_GROUP ? groups : 1
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return  self.m_tableType == .TABLE_BY_GROUP ? "TEAM \(section + 1)" : nil
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return self.m_isHost
	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
	{
		if editingStyle == .delete {
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
			if let uid = member?.uid {
				let name = self.getMemberInfo(uid)?.nickname ?? ""
				let alert = UIAlertController.checkAction(title: "Expel", message: "ban \(name), sure?") {
					self.expel(uid)
				}
				self.present(alert, animated: true)
			}
				
		}
	}
}

extension RoomVC: MyTableViewCellDelegate {
	func handleVote(_ uid: String) {
//		print(uid)\
		if(!m_isVoted) {
			let name = self.getMemberInfo(uid)?.nickname ?? ""
			let alert = UIAlertController.checkAction(title: "Vote", message: "vote \(name) sure?") {
				self.vote(uid)
			}
			self.present(alert, animated: true)
		}
	}
}
