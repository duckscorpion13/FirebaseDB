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
	
	class func checkAction(title: String, message: String, callback: @escaping () -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancelAction)
		
		let okAction = UIAlertAction(title: "OK", style: .default) {
			_ in
			callback()
		}
		alert.addAction(okAction)
		
		return alert
	}
	
	class func boolAction(title: String, message: String, callback: @escaping (Bool) -> ()) -> UIAlertController {
		return selectAction(title: title, message: message, actions: ["YES", "NO"]) {
			value in callback(value == 0)
		}
	}
	
	class func selectAction(title: String, message: String, actions: [String], callback: @escaping (Int) -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancelAction)
		
		for action in actions {
			let act = UIAlertAction(title: action, style: .default) {
				_ in
				callback(actions.index(of: action) ?? -1)
			}
			alert.addAction(act)
		}
		
		return alert
	}
	
	class func textsAlert(title: String, message: String, placeholders: [String], callback: @escaping ([String]) -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		for placeholder in placeholders {
			alert.addTextField {
				textField in
				textField.placeholder = placeholder
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancelAction)
		
		let okAction = UIAlertAction(title: "OK", style: .default) {
			_ in
			var paras = [String]()
			if let fields = alert.textFields {
				for field in fields{
					let para = field.text ?? ""
					paras.append(para)
				}
			}
			callback(paras)
		}
		alert.addAction(okAction)
		
		return alert
	}
}
