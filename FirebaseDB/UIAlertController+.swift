//
//  UIAlertController+.swift
//  FirebaseDB
//
//  Created by DerekYang on 2019/7/15.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
	class func textAlert(title: String, msg: String, callback: @escaping (String) -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		
		alert.addTextField {
			(textField: UITextField!) -> Void in
			//			textField.placeholder = "Name"
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancelAction)
		
		let okAction = UIAlertAction(title: "OK", style: .default) {
			_ in
			if let name = alert.textFields?.first?.text {
				callback(name)
			}
		}
		alert.addAction(okAction)
		
		return alert
	}
	
	class func checkAlert(title: String, msg: String, callback: @escaping () -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(
			title: "Cancel",
			style: .cancel)
		alert.addAction(cancelAction)
		
		let okAction = UIAlertAction(title: "OK", style: .default) {
			_ in
			callback()
		}
		alert.addAction(okAction)
		
		return alert
	}
	
	class func selectAlert(title: String, msg: String, callback: @escaping (Bool) -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancelAction)
		
		let okAction = UIAlertAction(title: "OK", style: .default) {
			_ in
			callback(true)
		}
		alert.addAction(okAction)
		
		let nakAction = UIAlertAction(title: "NO", style: .default) {
			_ in
			callback(false)
		}
		alert.addAction(nakAction)
		
		return alert
	}
	
	class func tripleTextAlert(title: String, msg: String, callback: @escaping (String?, String?, Int) -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		
		alert.addTextField {
			(textField: UITextField!) -> Void in
			textField.placeholder = "Title"
		}
		
		alert.addTextField {
			(textField: UITextField!) -> Void in
			textField.placeholder = "Message"
		}
		
		alert.addTextField {
			(textField: UITextField!) -> Void in
			textField.placeholder = "Number"
			textField.keyboardType = .numberPad
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancelAction)
		
		let okAction = UIAlertAction(title: "OK", style: .default) {
			_ in
			if let numStr = alert.textFields?[2].text,
				let num = Int(numStr) {
				let title = alert.textFields?[0].text
				let msg = alert.textFields?[1].text
				callback(title, msg, num)
			}
		}
		alert.addAction(okAction)
		
		return alert
	}
}
