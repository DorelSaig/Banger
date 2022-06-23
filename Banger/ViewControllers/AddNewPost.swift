import UIKit
import YPImagePicker
import LocationPicker
import CoreLocation
//import LocationPickerViewController
import MapKit
import Lottie

class AddNewPost: UIViewController, CLLocationManagerDelegate{
    
    var uuid: String!
    var dataManager:DataManager?
    var tabar:TabViewController!
    var imagePicked = false
    var locationManager: CLLocationManager!
    let locationPicker = LocationPickerViewController()
    var cll2: CLLocationCoordinate2D?
    
    @IBOutlet weak var addpost_IMG_main: UIImageView!
    @IBOutlet weak var posts_TXT_title: UITextField!
    @IBOutlet weak var posts_LBL_location: UILabel!
    
    @IBOutlet weak var posts_BTN_add: UIButton!
    @IBOutlet weak var post_TXT_note: UITextView!
    
    @IBOutlet weak var posts_PRG_loading: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Post"
        
        tabar = navigationController?.floatingTabBarController as? TabViewController
        tabar.hide(bool: true)
        dataManager = tabar.dataManager
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddNewPost.imageTapped(gesture:)))
        addpost_IMG_main.addGestureRecognizer(tapGesture)
        
        //Get Location
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        
        if (gesture.view as? UIImageView) != nil {
            var config = YPImagePickerConfiguration()
            config.shouldSaveNewPicturesToAlbum = false
            config.startOnScreen = .library
            config.showsPhotoFilters = false
            config.showsCrop = .rectangle(ratio: (5/5))
            config.targetImageSize = .cappedTo(size: 1024)
            config.showsCropGridOverlay = true
            let picker = YPImagePicker(configuration: config)
            picker.didFinishPicking { [unowned picker] items, _ in
                if let photo = items.singlePhoto {
                    self.addpost_IMG_main.image = photo.image
                    self.imagePicked = true
                }
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        let placeMark = MKPlacemark(coordinate: locValue)
        let location = Location(name: "Current Location", location: nil, placemark: placeMark)
        locationPicker.location = location
        self.cll2 = locValue
        locationManager.stopUpdatingLocation()
        
    }
    
    
    // MARK: - Buttons Init
    
    @IBAction func locationPickerClicked(_ sender: Any) {
        
        locationPicker.mapType = .standard
        
        locationPicker.completion = {location in
            let coordinates = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
            self.cll2 = location?.coordinate
            CLGeocoder().reverseGeocodeLocation(coordinates, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    return
                } else if let country = placemarks?.first?.country, let city = placemarks?.first?.locality, let street = placemarks?.first?.thoroughfare,
                          let streetNumber = placemarks?.first?.subThoroughfare, let title = placemarks?.first?.name{
                    self.posts_LBL_location.text = "\(title) \(streetNumber) \(street) \(city), \(country)"
                    
                } else {
                    self.posts_LBL_location.text = "\(placemarks?.first?.name ?? "")"
                }
            })
        }
        navigationController?.pushViewController(locationPicker, animated: true)
        
    }
    
    @IBAction func addPostClicked(_ sender: Any) {
        
        guard let title = posts_TXT_title.text, !title.isEmpty else {
            dataManager?.displayMyAlertMessage(message: "Please Fill The Spot Title", delegate: self)
            return
        }
        
        guard let location = posts_LBL_location.text, !location.isEmpty else {
            dataManager?.displayMyAlertMessage(message: "Please Spicify The Spot Location", delegate: self)
            return
        }
        
        if !imagePicked{
            dataManager?.displayMyAlertMessage(message: "Please Choose The Spot Picture", delegate: self)
            return
        }
        
        uuid = NSUUID().uuidString
        
        //Add Progress Indicator
        startIndicator()
        
        dataManager?.uploadImagePic(img1: addpost_IMG_main.image!, uuid: uuid, file: "Posts", delegate: self)
    }
    
}



// MARK: - Extentions 📚

extension AddNewPost: Delegate_Image_Uploaded, Delegate_Stored_In_DB{
    
    func imageUploaded(imageUrl: String?) {
        if let url = imageUrl {
            //Stop Progress Indicator
            let post = Post(uuid: uuid, title: posts_TXT_title.text, imageUrl: url, creator: dataManager?.currentUser?.name, creatorUuid: dataManager?.currentUser?.uuid, coordinate: cll2!, note: post_TXT_note.text ?? "")
            
            dataManager?.addPostToDB(post: post, delegate: self)
        }
    }
    
    func storedSuccessfuly() {
        tabar.hide(bool: false)
        navigationController?.popViewController(animated: true)
    }
    
}

extension AddNewPost: Delegate_Alert{
    func showAlert(myAlert: UIAlertController) {
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func startIndicator(){
        posts_PRG_loading.isHidden = false
        
        posts_PRG_loading.contentMode = .scaleAspectFit
        
        posts_PRG_loading.animationSpeed = 1
        
        posts_PRG_loading.loopMode = .loop
        
        posts_PRG_loading.play()
    }
}
