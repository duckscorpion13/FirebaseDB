//
//  LogInViewController.swift
//  FirebaseDB
//
//  Created by Derek on 2019/2/3.
//  Copyright © 2019年 Derek. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth// 這邊的Auth，是指Authentication，「新增使用者UID」或是「從Auth獲取使用者UID」需要用到這個部分
import FirebaseDatabase // 需要用到Database
import GoogleSignIn


class LoginVC: UIViewController {
    
	@IBOutlet weak var signBtn: GIDSignInButton!	
	@IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    // uid 是「使用者的獨特編碼」，在這邊儲存成一個 "" ，沒有任何值的 String，這樣聽起來有點饒舌
    // 比如說：某使用者UID是 "Avdfu12ejsiod9"<隨便亂取>，在 SignUp_Button_Tapped 或 LogIn_Button_Tapped
    // 有一串程式碼是 「self.uid = user.uid」
    // 前者 uid 即是指 「var uid = ""」的 uid，而後者的 uid 是指 「Firebase - Auth 的 使用者UID」
    // 意思就是「將Firebase使用者uid儲存愛變數uid中」，因為 var 代表「變數」，最終就變成 var uid = "Avdfu12ejsiod9"
    // 這樣，在我們需要使用者UID的時候（不論「從Firebase拿取資料」或是「從手機將資料放置到Firebase」皆需要用到）就可以輕易使用了！
	
	var m_uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		GIDSignIn.sharedInstance().uiDelegate = self
		GIDSignIn.sharedInstance().delegate = self
//		GIDSignIn.sharedInstance().signIn()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 這是前往SignUpViewController的按鈕，但在到下一個ViewController之前，先「新增了一個使用者」
    @IBAction func SignUp_Button_Tapped(_ sender: Any) {
        
        // 第一個要確保 Email & Password 這兩個 Text Field 不能什麼字都沒打，不然這樣就不合理啦！
        // 當然還能用別的假設，如：Email一定要加上"@"等等，這是最簡單，卻也不是很謹慎的方式
        // 俗話說：「一個成功的App要假設使用者的所有可能」，也就是說絕對不能讓使用者產生Bug的機會啊
        // 所以還是可以好好想想要用什麼樣的假設，但基本邏輯上這樣沒問題！
        if self.Email.text != "" || self.Password.text != ""{
            
            // 接下來，FIRAuth.auth().createUser，這邊就是「新增使用者」，
            // 部落格中在步驟三的前半段，有先啟用電子郵件/密碼，所以這邊會有 withEmail, password
            // 另外提醒，順著打程式碼會出現
            // FIRAuth.auth()?.createUser(withEmail: String, password: String, completion: FIRAuthResultCallback?)，
            // 那怎麼變成 completion: { (user, error) in 這樣的呢？
            // 其實很簡單，只要在藍藍的 FIRAuthResultCallback? 按個 enter(return) 鍵，就會變成這樣囉
			Auth.auth().createUser(withEmail: self.Email.text!, password: self.Password.text!, completion: { (user, error) in
                if error == nil{
					if let user = Auth.auth().currentUser{
                        
                        //這裏即是「var uid」那邊所說明的，將Firebase使用者uid儲存愛變數uid裡面，便可隨意使用，不用重複打這幾行程式碼
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
    
    // 這是前往ConfirmViewController的按鈕，但在到下一個ViewController之前，先「在Firebase做登入的動作」
	fileprivate func createRoomAndMembers(_ roomId: Int) {
		
		let refRoom = Database.database().reference(withPath: "\(DEF_ROOM)/\(roomId)")
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
					let values: [String : Any] =
						[
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
//		createRoomAndMembers(11111)

        // 一樣要先假設 Email & Password 要輸入某些字喔！
        if self.Email.text != "" || self.Password.text != ""{
            
            // 這裡跟SignUp_Button_Tapped不一樣的地方就是，從createUser改成SignIn，其餘都一樣，就不再贅述了
			Auth.auth().signIn(withEmail: self.Email.text!, password: self.Password.text!, completion: { (user, error) in
                
                if error == nil {
					if let user = Auth.auth().currentUser{
                        self.m_uid = user.uid
                    }
                    
                    // Online-Status 是線上狀態，在點選「登入」按鈕後，將Online-Status設定為On
					Database.database().reference(withPath: "Online-Status/\(self.m_uid)").setValue("ON")
                    
                    //跳到確認頁
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
					if let vc = storyboard.instantiateViewController(withIdentifier: "ConfirmViewControllerID") as? ConfirmVC {
						self.present(vc, animated: true)
					}
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
		// ...
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
		// ...
		Auth.auth().signIn(with: credential) { (authResult, error) in
			if let error = error {
				// ...
				print(error)
				return
			}
			// User is signed in
			// ...
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
