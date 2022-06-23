import UIKit
//import LocationPickerViewController

import LocationPicker
import CoreLocation
import MapKit
import YPImagePicker

class AddNewRegionController: UIViewController, CLLocationManagerDelegate{
    
    
    var uuid: String!
    var dataManager:DataManager?
    var tabar:TabViewController!
    var imagePicker: ImagePicker!
    var locationManager: CLLocationManager!
    let locationPicker = LocationPickerViewController()
    var imagePicked = false
    
    @IBOutlet weak var addregion_PRG_indicator: UIActivityIndicatorView!
    @IBOutlet weak var addregion_TF_city: UITextField!
    @IBOutlet weak var addregion_TF_country: UITextField!
    @IBOutlet weak var addregion_IMG_cover: UIImageView!
    @IBOutlet weak var addregion_BTN_add: UIButton!
    @IBOutlet weak var addregion_BTN_locate: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Create Region"
        
        tabar = navigationController?.floatingTabBarController as? TabViewController
        tabar.hide(bool: true)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        dataManager = tabar.dataManager
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddNewRegionController.imageTapped(gesture:)))
        addregion_IMG_cover.addGestureRecognizer(tapGesture)
        
        //Place Locate Button on Textfield's Right View
        addregion_TF_city.rightViewMode = UITextField.ViewMode.always
        addregion_TF_city.rightView = addregion_BTN_locate
        
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        let placeMark = MKPlacemark(coordinate: locValue)
        let location = Location(name: "Current Location", location: nil, placemark: placeMark)
        locationPicker.location = location
        locationManager.stopUpdatingLocation()
    }
    
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            //self.imagePicker.present(from: gesture.view!)
            //Here you can initiate your new ViewController
            var config = YPImagePickerConfiguration()
            config.shouldSaveNewPicturesToAlbum = false
            config.startOnScreen = .library
            config.showsPhotoFilters = false
            config.showsCrop = .rectangle(ratio: 16/9)
            let picker = YPImagePicker(configuration: config)
            picker.didFinishPicking { [unowned picker] items, _ in
                if let photo = items.singlePhoto {
                    self.addregion_IMG_cover.image = photo.image
                    self.imagePicked = true
                    
                }
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func locationPickerClicked(_ sender: Any) {
        locationPicker.mapType = .standard
        
        locationPicker.completion = { location in
            // do some awesome stuff with location
            let coordinates = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
            CLGeocoder().reverseGeocodeLocation(coordinates, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    return
                }else if let country = placemarks?.first?.country,
                         let city = placemarks?.first?.locality {
                    self.addregion_TF_city.text = city
                    self.addregion_TF_country.text = country
                }
                else {
                }
            })
        }
        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    @IBAction func addClicked(_ sender: Any) {
        guard let city = addregion_TF_city.text, !city.isEmpty else {
            dataManager?.displayMyAlertMessage(message: "Please Fill City", delegate: self)
            return
        }
        
        guard let country = addregion_TF_country.text, !country.isEmpty else {
            dataManager?.displayMyAlertMessage(message: "Please Spicify Country", delegate: self)
            return
        }
        
        if !imagePicked{
            dataManager?.displayMyAlertMessage(message: "Please Choose Cover For The Region", delegate: self)
            return
        }
        
        uuid = NSUUID().uuidString
        
        addregion_PRG_indicator.startAnimating()
        
        dataManager?.checkIfRegionExist(city: addregion_TF_city.text!, delegate: self)
        //dataManager?.uploadImagePic(img1: addregion_IMG_cover.image!, uuid: uuid, file: "Regions", delegate: self)
        
    }
    
}



// MARK: - Extentions 📚

extension AddNewRegionController: ImagePickerDelegate, Delegate_Image_Uploaded, Delegate_Stored_In_DB, Delegate_Region_Exist{
    func regionExist(bool: Bool) {
        if(bool){
            print("This Region Already Exist Look For it in The main ")
        } else {
            
            dataManager?.uploadImagePic(img1: addregion_IMG_cover.image!, uuid: uuid, file: "Regions", delegate: self)
        }
    }
    
    func storedSuccessfuly() {
        tabar.hide(bool: false)
        navigationController?.popViewController(animated: true)
    }
    
    func imageUploaded(imageUrl: String?) {
        if let url = imageUrl {
            addregion_PRG_indicator.stopAnimating()
            
            let region = Region(uuid: uuid, city: addregion_TF_city.text!, country: addregion_TF_country.text!)
            region.imgUrl = url
            
            dataManager?.addRegionToDB(region: region, delegate: self)
        }
    }
    
    
    func didSelect(image: UIImage?) {
        addregion_IMG_cover.image = image
        imagePicked = true
    }
}



// MARK: - Alert
extension AddNewRegionController: Delegate_Alert{
    func showAlert(myAlert: UIAlertController) {
        self.present(myAlert, animated: true, completion: nil)
    }
}
