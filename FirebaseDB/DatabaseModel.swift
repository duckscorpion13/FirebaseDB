//
//  DatabaseModel.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/10.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
//////////////////////////////////////////////////////////
let DEF_USER = "User"

let DEF_USER_MAIL = "Mail"
let DEF_USER_SEX = "Sex"
let DEF_USER_NAME = "Name"
let DEF_USER_PHONE = "Phone"
let DEF_USER_PHOTO = "Photo"

//////////////////////////////////////////////////////////

let DEF_ROOM = "Room"

let DEF_ROOM_HOST = "Host"
let DEF_ROOM_MEMBERS = "Members"
let DEF_ROOM_MESSAGE = "Message"
let DEF_ROOM_TITLE = "Title"
let DEF_ROOM_GROUP = "Group"

let DEF_ROOM_MEMBERS_CANDIDATE = "Candidate"
let DEF_ROOM_MEMBERS_TEAM = "Team"
let DEF_ROOM_MEMBERS_INDEX = "Index"
let DEF_ROOM_MEMBERS_NICKNAME = "Nickname"
let DEF_ROOM_MEMBERS_VOTED = "Voted"
let DEF_ROOM_MEMBERS_POLL = "Poll"

//////////////////////////////////////////////////////////
struct ST_USER_INFO: Codable {
	var uid: String?
	
	var mail: String?
	var phone: String?
	var name: String?
	var photo: String?
	var sex: Int?
}

struct ST_MEMBER_INFO: Codable {
	var uid: String?
	
	var candidate: Bool?
	var team: Int?
	var index: Int?
	var nickname: String?
	var voted: Bool?
	var poll: Int?
}
