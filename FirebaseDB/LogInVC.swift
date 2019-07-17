//
//  LogInViewController.swift
//  FirebaseDB
//
//  Created by Derek on 2019/2/3.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn


class LoginVC: UIViewController {
    
	@IBOutlet weak var signBtn: GIDSignInButton!	
	@IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
	
	var m_uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		GIDSignIn.sharedInstance().uiDelegate = self
		GIDSignIn.sharedInstance().delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    @IBAction func SignUp_Button_Tapped(_ sender: Any) {
		
        if self.Email.text != "" || self.Password.text != ""{

			Auth.auth().createUser(withEmail: self.Email.text!, password: self.Password.text!, completion: { (user, error) in
                if error == nil{
					if let user = Auth.auth().currentUser{
						
                        self.m_uid = user.uid
						
						let storyboard = UIStoryboard(name: "Main", bundle: nil)
						if let vc =  storyboard.instantiateViewController(withIdentifier: "SignUpViewControllerID") as? SignUpVC {
							self.present(vc, animated: true, completion: nil)
						}
                    }
                }
				
            })
        }
    }
	
    //for Test
	fileprivate func createRoomAndMembers(_ roomNum: Int) {
		
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomNum)")
		refRoom.child(DEF_ROOM_HOST).setValue(self.m_uid)
		refRoom.child(DEF_ROOM_GROUP).setValue(1)
		refRoom.child(DEF_ROOM_TITLE).setValue("Welcome")
		refRoom.child(DEF_ROOM_MESSAGE).setValue("Hello World!")
	
		refRoom.child(DEF_ROOM_MEMBERS).observeSingleEvent(of: .value) { (snapshot) in
			if !snapshot.hasChildren() {
				let names = ["Andy", "Bob", "Candy", "Dexter", "Edwin", "Frank", "Gina"]
				for name in names {
					let tmpId = names.index(of: name) ?? 0
//					let refRoomMember = refRoom.child("Members").child("\(tmpId)")
					let values: [String : Any] = [
							DEF_ROOM_MEMBERS_NICKNAME : name,
							DEF_ROOM_MEMBERS_INDEX : 0,
							DEF_ROOM_MEMBERS_CANDIDATE : false,
							DEF_ROOM_MEMBERS_TEAM : 0,
							DEF_ROOM_MEMBERS_VOTED : false,
							DEF_ROOM_MEMBERS_POLL: 0
						]
					refRoom.child(DEF_ROOM_MEMBERS).updateChildValues(["\(tmpId)" : values])
				}
			}
		}
	}
	
	@IBAction func LogIn_Button_Tapped(_ sender: Any) {

        if self.Email.text != "" || self.Password.text != ""{
			
			Auth.auth().signIn(withEmail: self.Email.text!, password: self.Password.text!, completion: { (user, error) in
                
                if error == nil {
					if let user = Auth.auth().currentUser{
                        self.m_uid = user.uid
                    }
                    
                    // Online-Status when login success ,Online-Status->On
					Database.database().reference(withPath: "Online-Status/\(self.m_uid)").setValue("ON")
                    
                    //go CheckVC
					let vc = CheckVC()
					self.present(vc, animated: true)
					
				} else {
					print(error.debugDescription)
				}
                
            })
        }
    }
}

extension LoginVC: GIDSignInUIDelegate {
	// MARK: - GIDSignInUIDelegate Delegates
	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		//myActivityIndicator.stopAnimating()
	}
	
	func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		self.present(viewController, animated: true, completion: nil)
	}
	
	func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension LoginVC: GIDSignInDelegate {
	@available(iOS 9.0, *)
	func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
		-> Bool {
			return GIDSignIn.sharedInstance().handle(url,
													 sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
													 annotation: [:])
	}
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
		if let error = error {
			// ...
			print(error)
			return
		}
		
		guard let authentication = user.authentication else {
			print("authentication")
			return
		}
		let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
													   accessToken: authentication.accessToken)

		Auth.auth().signIn(with: credential) { (authResult, error) in
			if let error = error {
				print(error)
				return
			}
			// User is signed in
//			print(authResult?.user)
			if let uid = authResult?.user.uid {
				self.m_uid = uid
				let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(self.m_uid)")
				refUser.observeSingleEvent(of: .value) { (snapshot) in
					if !snapshot.hasChildren() {
						refUser.child(DEF_USER_NAME).setValue(authResult?.user.displayName ?? nil)
						refUser.child(DEF_USER_MAIL).setValue(authResult?.user.email ?? nil)
					}
					Database.database().reference(withPath: "Online-Status/\(self.m_uid)").setValue("ON")
					if let dict = snapshot.value as? [String : Any] {
						let user = ST_USER_INFO(uid: snapshot.key,
											mail: dict[DEF_USER_MAIL] as? String,
											phone: dict[DEF_USER_PHONE] as? String,
											name: dict[DEF_USER_NAME] as? String,
											photo: dict[DEF_USER_PHOTO] as? String,
											sex: dict[DEF_USER_SEX] as? Int)
						let tabbarCtl = UITabBarController()
						let vc1 = CheckVC()
						vc1.view.backgroundColor = .gray
						let vc2 = CollectionVC()
						vc2.view.backgroundColor = .gray
						vc2.m_user = user
						vc1.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
						vc2.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
						tabbarCtl.viewControllers = [vc1, vc2]
						self.present(tabbarCtl, animated: true)
					}
				}
			}
		}
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		print ("didDisconnectWith")
	}
	
	
}
