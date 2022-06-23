import UIKit
import Kingfisher
import FirebaseDatabase
import MapKit
import SwiftFlags

class ShowPostController: UIViewController, Delegate_Stored_In_DB{
    
    func storedSuccessfuly() {
        print("User Saved Updated")
        checkSaved()
    }
    
    
    var dataManager:DataManager?
    var tabar:TabViewController!
    var currentPost:Post?
    var currentUserPosts:[String]?
    var saved:Bool?
    var authorUuid:String?
    var instaUrl:String?
    var authorImgUrl:String?
    var authorName:String?
    
    @IBOutlet weak var show_IMG_main: UIImageView!
    @IBOutlet weak var show_IMG_user: UIImageView!
    @IBOutlet weak var show_LBL_author: UILabel!
    @IBOutlet weak var show_LBL_country: UILabel!
    @IBOutlet weak var show_LBL_title: UILabel!
    @IBOutlet weak var show_TXT_description: UITextView!
    @IBOutlet weak var show_BTN_save: UIButton!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = currentPost?.title
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataManager = appDelegate.data
        
        tabar = navigationController?.floatingTabBarController as? TabViewController
        tabar.hide(bool: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ShowPostController.userImageTapped(gesture:)))
        show_IMG_user.addGestureRecognizer(tapGesture)
        show_IMG_user.isUserInteractionEnabled = true
        
        checkSaved()
        getAuthor()
        
    }
    
    
    
    func getAuthor(){
        
        let rootRef = Database.database().reference()
        let ref = rootRef.child("users")
        if let authorUuid = currentPost?.creatorUuid {
            ref.child(authorUuid).observeSingleEvent(of: .value, with: { snapshot in
                
                let value = snapshot.value as? NSDictionary
                self.authorImgUrl = value!["imageUrl"] as? String
                self.instaUrl = value!["instaUrl"] as? String
                self.authorName = value!["name"] as? String
                
                self.loadPost()
                
            }) { error in
                print(error.localizedDescription)
            }
        }
        
    }
    
    func loadPost(){
        
        KF.url(URL(string: (currentPost?.imageUrl)!))
            .fade(duration: 0.25)
            .cacheMemoryOnly()
            .set(to: show_IMG_main)
        
        KF.url(URL(string: (authorImgUrl!)))
            .fade(duration: 0.25)
            .cacheMemoryOnly()
            .set(to: self.show_IMG_user)
        
        show_IMG_user.layer.cornerRadius=50
        
        show_LBL_author.text = "Taken by: \(authorName ?? "Unknown")"
        
        show_LBL_title.text = currentPost?.title
        
        show_TXT_description.text = currentPost?.note
        
        
        let coordinates = CLLocation(latitude: (currentPost?.coordinate.latitude)!, longitude: (currentPost?.coordinate.longitude)!)
        CLGeocoder().reverseGeocodeLocation(coordinates, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                return
            }else if let country = placemarks?.first?.country,
                     let emoji = SwiftFlags.flag(for: country) {
                self.show_LBL_country.text = "\(emoji) \(country)"
            }
            else {
            }
        })
        
    }
    
    func checkSaved(){
        if let postUuid = currentPost?.uuid, let userSavedposts = dataManager?.currentUser?.savedPost{
            if(userSavedposts.contains(postUuid)){
                
                show_BTN_save.imageView?.image = #imageLiteral(resourceName: "bookmarkl")
                saved = true
            } else {
                
                show_BTN_save.imageView?.image = #imageLiteral(resourceName: "bookmarkUncheck")
                saved = false
            }
        }
    }
    
    @objc func userImageTapped(gesture: UIGestureRecognizer){
        if let instaUrl = instaUrl {
            dataManager?.goToInsta(instaUrl: instaUrl)
        }
    }
    
    @IBAction func savePost(_ sender: Any) {
        if let postUuid = currentPost?.uuid, let saved = saved{
            if(saved){
                dataManager?.updateUserSavedPosts(postUuid: postUuid, add: false, delegate: self)
            } else {
                dataManager?.updateUserSavedPosts(postUuid: postUuid, add: true, delegate: self)
            }
        }
    }
    
    @IBAction func directionClicked(_ sender: Any) {
        let regionDistance:CLLocationDistance = 10000
        if let coordinates = currentPost?.coordinate{
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = currentPost?.title
            mapItem.openInMaps(launchOptions: options)
        }
    }
 
}
