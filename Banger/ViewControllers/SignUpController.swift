import UIKit
import FirebaseStorage
import FirebaseDatabase
import YPImagePicker
import Kingfisher

class SignUpController: UIViewController{
    
    var dataManager:DataManager!
    var imagePicker: ImagePicker!
    let storage = Storage.storage()
    var storageRef: StorageReference!
    
    @IBOutlet weak var signU_IMG_profile: UIImageView!
    @IBOutlet weak var signUp_PRG_Indicator: UIActivityIndicatorView!
    @IBOutlet weak var signUp_TF_name: UITextField!
    @IBOutlet weak var signUp_TF_InstaName: UITextField!
    @IBOutlet weak var signUp_BTN_signupButton: UIButton!
    
    var myDownloadURL = "https://firebasestorage.googleapis.com/v0/b/superme-e69d5.appspot.com/o/images%2Fimg_profile_pic.JPG?alt=media&token=5970cec0-9663-4ddd-9395-ef2791ad938d"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpController.imageTapped(gesture:)))
        signU_IMG_profile.addGestureRecognizer(tapGesture)
        signU_IMG_profile.isUserInteractionEnabled = true
    }
    
    func uploadImagePic(img1 :UIImage){
        var data = NSData()
        data = img1.jpegData(compressionQuality: 0.8)! as NSData
        // set upload path
        let filePath = "\(dataManager.currentUserUID ?? "error")" // path where you wanted to store img in storage
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        self.storageRef = storage.reference()
        let userref = self.storageRef.child("users").child(filePath)
        
        let upload = userref.putData(data as Data, metadata: metaData){(metaData,error) in
            if let error = error {
                print(error.localizedDescription)
                
                return
            }
        }
        
        upload.observe(.success) { snapshot in
            userref.downloadURL(completion: { (url: URL?, error: Error?) in
                if let url = url {
                    self.myDownloadURL = url.absoluteString
                    self.signUp_BTN_signupButton.isEnabled = true
                    
                    KF.url(URL(string: (self.myDownloadURL)))
                        .fade(duration: 0.25)
                        .cacheMemoryOnly()
                        .setProcessor(RoundCornerImageProcessor(cornerRadius: 1000))
                        .onSuccess{result in
                            self.signUp_PRG_Indicator.stopAnimating()}
                        .set(to: self.signU_IMG_profile)
                    
                }
            })
        }
        
    }
    
    // ----------------------- Clickers ------------------------------
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        
        signUp_BTN_signupButton.isEnabled = false
        signUp_PRG_Indicator.startAnimating()
        
        if (gesture.view as? UIImageView) != nil {
            var config = YPImagePickerConfiguration()
            config.showsCrop = .circle
            let picker = YPImagePicker(configuration: config)
            picker.didFinishPicking { [unowned picker] items, _ in
                if let photo = items.singlePhoto {
                    self.signU_IMG_profile.image = photo.image
                    self.uploadImagePic(img1: photo.image)
                }
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
        
    }
    
    var ref: DatabaseReference!
    @IBAction func signupClicked(_ sender: Any) {
        
        guard let username = signUp_TF_name.text, !username.isEmpty else {
            dataManager.displayMyAlertMessage(message: "Please Fill All Fields", delegate: self)
            return
        }
        
        let tempUser = User(uuid: dataManager.currentUserUID!, name: username , instaUrl: "https://www.instagram.com/\(signUp_TF_InstaName.text ?? "")"   )
        
        tempUser.imgUrl = myDownloadURL

        //-------- Store user in DB
        ref = Database.database().reference()
        let userInfoDictionary = dataManager.userToDict(user: tempUser)
        
        self.ref.child("users").child("\(dataManager.currentUserUID ?? "error")").setValue(userInfoDictionary, withCompletionBlock: { err, ref in
            if let error = err {
                print("userInfoDictionary was not saved: \(error.localizedDescription)")
            } else {
                print("userInfoDictionary saved successfully!")
                self.dataManager.setCurrentUser(user: tempUser)
                
                let nav = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! TabViewController
                nav.dataManager = self.dataManager
                self.present(nav, animated: true)
            }
        })
    }
}


// MARK: - Extentions 📚

extension SignUpController: ImagePickerDelegate, Delegate_Alert {
    func showAlert(myAlert: UIAlertController) {
        self.present(myAlert, animated: true, completion: nil)
    }

    func didSelect(image: UIImage?) {
        //self.signU_IMG_profile.image = image
        //-------- Upload Image
        uploadImagePic(img1: signU_IMG_profile.image!)
    }
}
