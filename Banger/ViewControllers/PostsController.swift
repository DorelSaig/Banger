import UIKit
import MapKit
import CoreLocation
import IGListKit
import Kingfisher

import FirebaseStorage
import FirebaseDatabase

class PostsController: UIViewController, MKMapViewDelegate {
    
    var dataManager:DataManager?
    var currentRegion:Region!
    var tabar:TabViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var clickCount = 0
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var posts_container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabar = navigationController?.floatingTabBarController as? TabViewController
        self.currentRegion = tabar.dataManager?.currentRegion
        self.title = currentRegion?.city
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataManager = appDelegate.data
        
        initMap()
                
        mapView.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        tabar.hide(bool: false)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? Get_Data_Protocol {
            destination.getData(data: appDelegate.data!)
        }
    }
    
    @IBAction func addPostClicked(_ sender: Any) {
        
        let addPost = self.storyboard?.instantiateViewController(withIdentifier: "Addpost") as! AddNewPost
        
        self.navigationController?.pushViewController(addPost, animated: true)
    }
    
}


// MARK: - Map 📚

extension PostsController{
    
    func initMap(){
        
        findInitialLocation()

    }
    
    func findInitialLocation(){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("\(currentRegion.city), \(currentRegion.country)") { placemarks, error in
            let placemark = placemarks?.first
            let lat = placemark?.location?.coordinate.latitude
            let lon = placemark?.location?.coordinate.longitude
            let initialLocation = CLLocation(latitude: lat!, longitude: lon!)
            self.mapView.centertoLocation(initialLocation)
        }
    }
    
}

private extension MKMapView {
    
    func centertoLocation ( _ location: CLLocation, regionRadius:CLLocationDistance = 10000) {
        let coordinateRegion = MKCoordinateRegion (
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
}


// MARK: - Extentions 📚

extension PostsController: Delegate_ItemSelected, Delegate_PostAdded{
    
    func itemDeselected(post: Post) {
        print("item Deselected")
        clickCount = 0
    }
    
    func postAdded(post: Post) {
        print("Post Added")
        //dataManager?.updateRegionPostsList(post: post)
        mapView.addAnnotation(post)
        
    }
    
    func itemSelected(post: Post) {
        print("item Selected")
        
        clickCount += 1
        
        self.mapView.centertoLocation(CLLocation(latitude: post.coordinate.latitude, longitude: post.coordinate.longitude), regionRadius: 1000)

        dataManager?.setCurrentPost(post: post)
        
        //Post Double Click
        if clickCount == 2 {
            let showPost = self.storyboard?.instantiateViewController(withIdentifier: "Showpost") as! ShowPostController
            showPost.dataManager = self.dataManager
            showPost.currentPost = post
            clickCount = 0
            self.navigationController?.pushViewController(showPost, animated: true)
            
        }
    }
    
}
