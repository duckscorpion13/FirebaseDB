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

	var m_tableView = UITableView()
	var m_members = [String]()
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
	
	func getRoomInfo(_ roomId: Int) {
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomId)")
		refRoom.child(DEF_ROOM_MEMBERS).observe(.value) { (snapshot) in
			if snapshot.hasChildren() {
				self.m_members.removeAll()
				for member in snapshot.children {
					if let item = member as? DataSnapshot,
						let dict = item.value as? [String : Any],
						let name = dict[DEF_ROOM_MEMBERS_NICKNAME] as? String {
						self.m_members.append(name)
					}
				}
				print(self.m_members)
				self.m_tableView.reloadData()
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
		
		getRoomInfo(12345)
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
		return self.m_members.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		cell.textLabel?.text = self.m_members[indexPath.row]
		
//		let timeStamp = m_logs[indexPath.row].time ?? ""
//		let timeInterval = TimeInterval(timeStamp)
//		let date = Date(timeIntervalSince1970: timeInterval!)
//
//
//		let formatter = DateFormatter()
//		formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//		cell.nameLabel.text = "\(formatter.string(from: date))"
//
//		cell.detailLabel.text = m_logs[indexPath.row].award ?? ""
		
		// Configure the cell...
		return cell
	}
	
	
}
