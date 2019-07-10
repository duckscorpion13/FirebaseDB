//
//  RoomVC.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/9.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RoomVC: UIViewController {

	var m_isSort = false
	var m_isGroup = false
	var m_userId = ""
	var m_roomId = 12345
	var m_teamCount = 3
	var m_tableView = UITableView()
	var m_members = [ST_MEMBER_INFO]()
	var m_sortMembers = [ST_MEMBER_INFO]()
	var m_groupMembers = [[ST_MEMBER_INFO]]()
	fileprivate func setupTableView() {
		
		self.m_tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		
		self.m_tableView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.m_tableView)
		self.m_tableView.topAnchor.constraint(equalTo: self.view.readableContentGuide.topAnchor, constant: 20).isActive = true
		self.m_tableView.leadingAnchor.constraint(equalTo: self.view.readableContentGuide.leadingAnchor).isActive = true
		self.m_tableView.trailingAnchor.constraint(equalTo: self.view.readableContentGuide.trailingAnchor).isActive = true
		self.m_tableView.heightAnchor.constraint(equalTo: self.view.readableContentGuide.heightAnchor, multiplier: 0.5).isActive = true
		
		self.m_tableView.dataSource = self
		self.m_tableView.delegate = self
		
		print(randomIndex(10))
	}
	
	func joinRoom(_ name: String) {
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(m_roomId)")
		let values: NSMutableDictionary =
			[
				DEF_ROOM_MEMBERS_NICKNAME : name,
				DEF_ROOM_MEMBERS_INDEX : 0,
				DEF_ROOM_MEMBERS_CANDIDATE : false,
				DEF_ROOM_MEMBERS_TEAM : 0,
				DEF_ROOM_MEMBERS_VOTE : 0
			]
		refRoom.child(DEF_ROOM_MEMBERS).updateChildValues(["\(m_userId)":values])
	}
	
	
	func getRoomInfo() {
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(m_roomId)")
		refRoom.child(DEF_ROOM_MEMBERS).observe(.value) { (snapshot) in
			if snapshot.hasChildren() {
				self.m_members.removeAll()
				for member in snapshot.children {
					if let item = member as? DataSnapshot,
					let dict = item.value as? [String : Any],
					let name = dict[DEF_ROOM_MEMBERS_NICKNAME] as? String {
						let info = ST_MEMBER_INFO(candidate: dict[DEF_ROOM_MEMBERS_CANDIDATE] as? Bool,
												  team: dict[DEF_ROOM_MEMBERS_TEAM] as? Int,
												  index: dict[DEF_ROOM_MEMBERS_INDEX] as? Int,
												  nickname: name,
												  vote: dict[DEF_ROOM_MEMBERS_VOTE] as? Int)
						self.m_members.append(info)
					}
				}
//				print(self.m_members)
				DispatchQueue.main.async {
					self.m_tableView.reloadData()
				}
			}
		}
	}
	@objc func randamGroup() {
		self.m_isGroup = true
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(m_roomId)")
		refRoom.child(DEF_ROOM_MEMBERS).observeSingleEvent(of: .value) { (snapshot) in
			if snapshot.hasChildren() {
				var index = 0
				let randArray = self.randomIndex(Int(snapshot.childrenCount))
				print(randArray)
				for member in snapshot.children {
					if let item = member as? DataSnapshot {
						let team = randArray[index] % self.m_teamCount
						refRoom.child(DEF_ROOM_MEMBERS).child(item.key).updateChildValues([DEF_ROOM_MEMBERS_TEAM : team])
						index += 1
					}
				}
				
				self.m_groupMembers.removeAll()
				for i in 0 ..< self.m_teamCount {
					
					let array = self.m_members.filter { member in
						return member.team == i
					}
					print(array)
					self.m_groupMembers.append(array)
				}
				
				DispatchQueue.main.async {
					self.m_tableView.reloadData()
				}
				
			}
		}
	}
	@objc func randamSort() {
		self.m_isSort = true
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(m_roomId)")
		refRoom.child(DEF_ROOM_MEMBERS).observeSingleEvent(of: .value) { (snapshot) in
			if snapshot.hasChildren() {
				var index = 0
				let randArray = self.randomIndex(Int(snapshot.childrenCount))
				print(randArray)
				for member in snapshot.children {
					if let item = member as? DataSnapshot {
						refRoom.child(DEF_ROOM_MEMBERS).child(item.key).updateChildValues([DEF_ROOM_MEMBERS_INDEX:randArray[index]])
						index += 1
					}
				}
				
				self.m_sortMembers.removeAll()
				for i in 0 ..< randArray.count {
					if let index = randArray.index(of: i) {
						let member = self.m_members[index]
						self.m_sortMembers.append(member)
					}
				}
			
				DispatchQueue.main.async {
					self.m_tableView.reloadData()
				}
				
			}
		}
	}
	
	func randomIndex(_ total: Int) -> [Int] {
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
	
	override func viewDidLoad() {
        super.viewDidLoad()

	
		
		
		setupTableView()
		
		let btn = UIButton(frame: CGRect(x: 30, y: 30, width: 50, height: 50))
		btn.setTitle("Sort", for: .normal)
		btn.setTitleColor(.red, for: .normal)
		view.addSubview(btn)
		btn.addTarget(self, action: #selector(randamGroup), for: .touchUpInside)
		
		getRoomInfo()
        // Do any additional setup after loading the view.
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
		if(m_isSort) {
			return self.m_sortMembers.count
		} else {
			return m_isGroup ? self.m_groupMembers[section].count : self.m_members.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		if(m_isGroup) {
			let member = self.m_groupMembers[indexPath.section][indexPath.row]
			cell.textLabel?.text = member.nickname
		} else {
			let member = m_isSort ? self.m_sortMembers[indexPath.row] : self.m_members[indexPath.row]
			cell.textLabel?.text = member.nickname
		}
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return m_isGroup ? self.m_groupMembers.count : 1
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return  m_isGroup ? "TEAM \(section + 1)" : nil
	}

}
