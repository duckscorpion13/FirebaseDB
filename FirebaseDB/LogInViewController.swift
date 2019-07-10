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

struct ST_ROOM_MEMBER: Codable {
//	let Name: String?
	let ID: String?
	let Group: Int = 0
	
}

class LogInViewController: UIViewController {
    
	@IBOutlet weak var signBtn: GIDSignInButton!	
	@IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    // uid 是「使用者的獨特編碼」，在這邊儲存成一個 "" ，沒有任何值的 String，這樣聽起來有點饒舌
    // 比如說：某使用者UID是 "Avdfu12ejsiod9"<隨便亂取>，在 SignUp_Button_Tapped 或 LogIn_Button_Tapped
    // 有一串程式碼是 「self.uid = user.uid」
    // 前者 uid 即是指 「var uid = ""」的 uid，而後者的 uid 是指 「Firebase - Auth 的 使用者UID」
    // 意思就是「將Firebase使用者uid儲存愛變數uid中」，因為 var 代表「變數」，最終就變成 var uid = "Avdfu12ejsiod9"
    // 這樣，在我們需要使用者UID的時候（不論「從Firebase拿取資料」或是「從手機將資料放置到Firebase」皆需要用到）就可以輕易使用了！
    var uid = ""
    
    
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
//			Auth.auth().createUser(withEmail: self.Email.text!, password: self.Password.text!, completion: { (user, error) in
			Auth.auth().createUser(withEmail: "duckscorpion13@gmail.com", password: "abc123", completion: { (user, error) in
                if error == nil{
					if let user = Auth.auth().currentUser{
                        
                        //這裏即是「var uid」那邊所說明的，將Firebase使用者uid儲存愛變數uid裡面，便可隨意使用，不用重複打這幾行程式碼
                        self.uid = user.uid
                    }
                }
                
                // 到了另一個重點啦！這是指在 database 中以 "ID/\(self.uid)/Profile/Safety-Check" 為路徑，設一個值: "ON"
                // 要在 Database 中建立資訊，一定要 setvalue 才會成功喔！
                
                //「新增使用者」、「在Database中新增一個Safety-Check:"ON"」，接著就跳到註冊頁
                // 另外提醒，這邊要在 Main.storyboard，Show Utilities，Identity inspector(左邊數來第三個)
                // storyboardID 要記得改名字，像是這裡的SignUpViewController，要在storyboardID改成SignUpViewControllerID
				Database.database().reference(withPath: "ID/\(self.uid)/Profile/Safety-Check").setValue("ON")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextVC =  storyboard.instantiateViewController(withIdentifier: "SignUpViewControllerID") as! SignUpViewController
                self.present(nextVC, animated: true, completion: nil)
                
            })
        }
    }
    
    // 這是前往ConfirmViewController的按鈕，但在到下一個ViewController之前，先「在Firebase做登入的動作」
	fileprivate func createRoom(_ roomId: Int) {
		
		let refRoom = Database.database().reference(withPath: "Room/\(roomId)")
		refRoom.child(DEF_ROOM_HOST).setValue(self.uid)
		refRoom.child(DEF_ROOM_GROUP).setValue(1)
		refRoom.child(DEF_ROOM_TITLE).setValue("Welcome")
		refRoom.child(DEF_ROOM_MESSAGE).setValue("Hello World!")
		refRoom.child(DEF_ROOM_MEMBERS).observe(.value) { (snapshot) in
			if snapshot.hasChildren() {
				var tmpArray = [String]()
				for member in snapshot.children {
					if let item = member as? DataSnapshot,
						let dict = item.value as? [String : Any],
						let name = dict[DEF_ROOM_MEMBERS_NICKNAME] as? String {
						tmpArray.append(name)
					}
				}
				print(tmpArray)
			} else {
				let names = ["Andy","Bob","Candy","Dexter","Edwin"]
				for name in names {
					let tmpId = names.index(of: name) ?? 0
					let refRoomMember = refRoom.child("Members").child("\(tmpId)")
					refRoomMember.child(DEF_ROOM_MEMBERS_NICKNAME).setValue(name)
					refRoomMember.child(DEF_ROOM_MEMBERS_INDEX).setValue(0)
					refRoomMember.child(DEF_ROOM_MEMBERS_CANDIDATE).setValue(false)
					refRoomMember.child(DEF_ROOM_MEMBERS_TEAM).setValue(0)
					refRoomMember.child(DEF_ROOM_MEMBERS_VOTE).setValue(0)
					//					refRoom.child("Members").child("\(tmpId)").child("Name").setValue(name)
					//					refRoom.child("Members").child("\(tmpId)").child("Index").setValue(0)
					//					refRoom.child("Members").child("\(tmpId)").child("Group").setValue(0)
					//					refRoom.child("Members").child("\(tmpId)").child("Vote").setValue(0)
				}
			}
		}
	}
	
	@IBAction func LogIn_Button_Tapped(_ sender: Any) {
		createRoom(12345)
	
        // 一樣要先假設 Email & Password 要輸入某些字喔！
        if self.Email.text != "" || self.Password.text != ""{
            
            // 這裡跟SignUp_Button_Tapped不一樣的地方就是，從createUser改成SignIn，其餘都一樣，就不再贅述了
			Auth.auth().signIn(withEmail: self.Email.text!, password: self.Password.text!, completion: { (user, error) in
                
                if error == nil {
					if let user = Auth.auth().currentUser{
                        self.uid = user.uid
                        
                    }
                    
                    // Online-Status 是線上狀態，在點選「登入」按鈕後，將Online-Status設定為On
					Database.database().reference(withPath: "Online-Status/\(self.uid)").setValue("ON")
                    
                    //跳到確認頁
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextVC = storyboard.instantiateViewController(withIdentifier: "ConfirmViewControllerID")as! ConfirmViewController
					
				

					
                    self.present(nextVC,animated:true,completion:nil)
                }
                
            })
        }

    }   
}

extension LogInViewController: GIDSignInUIDelegate {
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

extension LogInViewController: GIDSignInDelegate {
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
				self.uid = uid
				let refUser = Database.database().reference(withPath: "\(DEF_USER)/\(self.uid)")
				refUser.observe(.value) { (snapshot) in
					if let _ = snapshot.value as? String {
					} else {
						refUser.child(DEF_USER_NAME).setValue(authResult?.user.displayName ?? nil)
						refUser.child(DEF_USER_MAIL).setValue(authResult?.user.email ?? nil)
//						Database.database().reference(withPath: "ID/\(self.uid)/Profile/Name").setValue(authResult?.user.displayName ?? nil)
//						Database.database().reference(withPath: "ID/\(self.uid)/Profile/Email").setValue(authResult?.user.email ?? nil)
					}
				}
//				Database.database().reference(withPath: "ID/\(self.uid)/Profile/Photo").setValue(authResult?.user.photoURL ?? nil)
				
			}
			
		

			Database.database().reference(withPath: "Online-Status/\(self.uid)").setValue("ON")
//		Database.database().reference().child("ID/\(self.uid)")).setValue(authResult?.user.email ?? "abc", forKey: "email")
			//跳到確認頁
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let nextVC = storyboard.instantiateViewController(withIdentifier: "ConfirmViewControllerID")as! ConfirmViewController
			self.present(nextVC,animated:true,completion:nil)
		}
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		print ("didDisconnectWith")
	}
	
	
}
