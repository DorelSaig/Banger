//
//  ProfileController.swift
//  Banger
//
//  Created by Dorel Saig on 06/06/2022.
//

import UIKit
import YPImagePicker
import FirebaseStorage
import FirebaseAuthUI
import Kingfisher
import SwiftUI

class ProfileController: UIViewController {
    
    var dataManager:DataManager!
    let storage = Storage.storage()
    var storageRef: StorageReference!
    var editState:Bool!
    var imagePicker: ImagePicker!
    var myDownloadURL:String!
    var name:String!
    var instaUrl:String!
    
    @IBOutlet weak var profile_IMG_profilepic: UIImageView!
    @IBOutlet weak var profile_PRG_indicator: UIActivityIndicatorView!
    @IBOutlet weak var profile_TXT_name: UITextField!
    @IBOutlet weak var profile_TXT_insta: UITextField!
    @IBOutlet weak var profile_BTN_edit: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let dm = appDelegate.data {
            dataManager = dm
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileController.imageTapped(gesture:)))
        profile_IMG_profilepic.addGestureRecognizer(tapGesture)
        profile_IMG_profilepic.isUserInteractionEnabled = false
        
        myDownloadURL = dataManager?.currentUser?.imgUrl
        
        editState = true
        
        loadData()
        
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        
        profile_BTN_edit.isEnabled = false
        if (gesture.view as? UIImageView) != nil {
            
            var config = YPImagePickerConfiguration()
            config.showsCrop = .circle
            config.shouldSaveNewPicturesToAlbum = false
            let picker = YPImagePicker(configuration: config)
            picker.didFinishPicking { [unowned picker] items, _ in
                if let photo = items.singlePhoto {
                    self.profile_PRG_indicator.startAnimating()
                    //self.uploadImagePic(img1: photo.image)
                    self.dataManager.uploadImagePic(img1: photo.image, uuid: (self.dataManager.currentUserUID)!, file: "users", delegate: self)
                    
                }
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
        
    }
    
    func loadData(){
        if let user = dataManager?.currentUser{
            profile_TXT_name.text = user.name
            let stringArr = user.instaUrl.components(separatedBy: "/")
            profile_TXT_insta.text = stringArr.last
            
            print("imaaaggeeeeee : \(user.imgUrl)")
            
            KF.url(URL(string: user.imgUrl))
                .fade(duration: 0.25)
                .cacheMemoryOnly()
            //.setProcessor(RoundCornerImageProcessor(cornerRadius: 1000))
                .set(to: profile_IMG_profilepic)
            
            profile_IMG_profilepic.layer.cornerRadius = 150
        }
    }
    
    func editMode(state:Bool){
        
        var color = UIColor(named: "tFcolor")
        
        if(state) {
            color = UIColor.gray
        } else {
            color = UIColor(named: "tFcolor")
        }
        
        profile_IMG_profilepic.isUserInteractionEnabled = state
        profile_TXT_name.isEnabled = state
        profile_TXT_name.backgroundColor = color
        profile_TXT_insta.isEnabled = state
        profile_TXT_insta.backgroundColor = color
    }
    
    @IBAction func editClicked(_ sender: Any) {
        if editState {
            
            profile_BTN_edit.setTitle("Save", for: .normal)
            self.title = "Edit Profile"
            editMode(state: editState)
            editState = !editState
            
        } else {
            
            profile_BTN_edit.setTitle("Edit", for: .normal)
            self.title = "Profile"
            editMode(state: editState)
            editState = !editState
            
            if let user =  dataManager.currentUser {
                
                if !profile_TXT_name.text!.isEmpty{
                    user.name = profile_TXT_name.text ?? "Unknown"
                }
                if !profile_TXT_insta.text!.isEmpty{
                    user.instaUrl = "https://www.instagram.com/\(profile_TXT_insta.text ?? "")"
                }
                user.imgUrl = myDownloadURL
                dataManager.updateUserDetails(user: user)
                
            }
            
        }
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let login = self.storyboard?.instantiateViewController(withIdentifier: "login") as! ViewController
            login.dataManager = self.dataManager
            self.present(login, animated: true)
        } catch let error as NSError {
            print  (error.localizedDescription)
        }
    }
    
}


// MARK: - Extentions 📚

extension ProfileController: Delegate_Image_Uploaded{
    func imageUploaded(imageUrl: String?) {
        
        self.myDownloadURL = imageUrl
        self.profile_BTN_edit.isEnabled = true
        
        KF.url(URL(string: imageUrl!))
            .fade(duration: 0.25)
            .setProcessor(RoundCornerImageProcessor(cornerRadius: 1000))
            .onSuccess{ resault in
                self.profile_PRG_indicator.stopAnimating()}
            .set(to: self.profile_IMG_profilepic)
        
    }
    
}
