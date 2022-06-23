//
//  ViewController.swift
//  Banger
//
//  Created by Dorel Saig on 28/05/2022.
//

import UIKit
import FirebaseAuthUI
import FirebasePhoneAuthUI
import FirebaseDatabase

class ViewController: UIViewController, FUIAuthDelegate {
    
    
    var logStatus = true
    let authUI = FUIAuth.defaultAuthUI()
    var dataManager:DataManager!
    var ref: DatabaseReference!
    @IBOutlet weak var login_VIEW_loading: UIView!
    @IBOutlet weak var login_IND_loadingIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataManager = appDelegate.data
        
        checkLoggedIn()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login_IND_loadingIndicator.startAnimating()
        self.login_VIEW_loading.isHidden = false
        
    }
    
    func checkLoggedIn(){
        
        Auth.auth().addStateDidChangeListener { [self] (auth, user) in
            if let user = user {
                print("Logged in with : \(user.uid)")
                self.login_VIEW_loading.isHidden = false
                dataManager.setCurrentUserUID(uid: user.uid)
                checkUserExistInDB(user.uid)
                
                self.logStatus = true
            } else {
                self.login_VIEW_loading.isHidden = true
                self.logStatus = false
                let providers: [FUIAuthProvider] = [FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)]
                self.authUI?.providers = providers
                self.authUI?.delegate = self
            }
        }
    }
    
    
    func checkUserExistInDB(_ uid:String){
        ref = Database.database().reference()
        var user = User(uuid: dataManager.currentUserUID!, name: "Dorel", instaUrl: "adsdad")
        
        ref.child("users").observe(DataEventType.value, with: { (snapshot) in
            if snapshot.hasChild(uid){
                self.dataManager?.setCurrentUserUID(uid: uid)
                
                guard let userSnap = snapshot.childSnapshot(forPath: uid).value as? Dictionary<String, AnyObject> else {return}
                
                user = self.dataManager.userSnapToUser(uuid: uid, userSnap: userSnap)
                
                self.dataManager?.setCurrentUser(user: user)
                
                let nav = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! TabViewController
                nav.dataManager = self.dataManager
                self.present(nav, animated: true)
                
                print("true User exist ")
                
            }else{
                self.dataManager?.setCurrentUser(user: user)
                self.performSegue(withIdentifier: "signup", sender: self)
                self.login_VIEW_loading.isHidden = true
                
                print("false User doesn't exist")
                
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? SignUpController {
            nextVC.dataManager = dataManager
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {

        let phoneProvider = FUIAuth.defaultAuthUI()!.providers.first as! FUIPhoneAuth
        phoneProvider.signIn(withPresenting: self, phoneNumber: nil)
        
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        print("Succesess - ֿ")
    }
}

