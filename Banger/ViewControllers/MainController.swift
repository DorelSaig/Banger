import UIKit
import FloatingTabBarController

import FirebaseStorage
import FirebaseDatabase

class MainController: UIViewController, UISearchBarDelegate{
    
    var dataManager:DataManager!
    var title1: String?
    var tabar: TabViewController!
    var regions: [Region]!
    var filteredData: [Region]!
    
    @IBOutlet weak var mytableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Explore"
        
        navigationController?.navigationItem.title = "Explore"
        
        tabar = navigationController?.floatingTabBarController as? TabViewController
        
        self.dataManager = tabar.dataManager
        tabar.dataManager?.setTestString(t: "Shit")
        
        navigationController?.navigationBar.layer.cornerRadius = 6
        navigationController?.navigationBar.clipsToBounds = true
        
        regions = []
        filteredData = []
        
        fetchData()
        
        setup()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tabar.hide(bool: false)
    }
    
    func fetchData(){
        
        let rootRef = Database.database().reference()
        let ref = rootRef.child("Regions")
        ref.observe(DataEventType.value, with: { snapshots in
            if snapshots.exists(){
                self.regions.removeAll()
                guard let snapshot = snapshots.children.allObjects as? [DataSnapshot] else {return}
                for eachSnap in snapshot{
                    guard let eachRegionDict = eachSnap.value as? Dictionary<String, AnyObject> else {return}
                    let r = Region(uuid: eachSnap.key, city: eachRegionDict["city"] as! String, country: eachRegionDict["country"] as! String)
                    r.imgUrl = eachRegionDict["imageUrl"] as! String
                    let arr = eachRegionDict["posts"] as! NSArray
                    r.posts = arr.compactMap({ $0 as? String })
                    self.regions.append(r)
                }
                self.filteredData = self.regions
                self.mytableView.reloadData()
            }else {
                self.regions.removeAll()
                self.filteredData.removeAll()
                self.mytableView.reloadData()
            }
        })
        
    }
    
    
    func setup() {
        
        mytableView.register(RegionCellTableViewCell.nib(), forCellReuseIdentifier: RegionCellTableViewCell.identifier)
        mytableView.delegate = self
        mytableView.dataSource = self
        searchBar.delegate = self
        
    }
    
    @IBAction func addRegionClicked(_ sender: Any) {
        let first = self.storyboard?.instantiateViewController(withIdentifier: "Add") as! AddNewRegionController
        
        self.navigationController?.pushViewController(first, animated: true)
    }
    
    @IBAction func clicked(_ sender: Any) {
        let first = UIViewController()
        
        navigationController?.pushViewController(first, animated: true)
    }
}



// MARK: - TableView 📚

extension MainController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
        //        return regions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mytableView.dequeueReusableCell(withIdentifier: RegionCellTableViewCell.identifier) as! RegionCellTableViewCell
        
        
        let region = filteredData[indexPath.row]
        
        //        let region = regions[indexPath.row]
        cell.configure(with: region.city, country: region.country, imgUrl: region.imgUrl)
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dataManager.setCurrentRegion(region: filteredData[indexPath.row])
        let regionPage = self.storyboard?.instantiateViewController(withIdentifier: "Posts") as! PostsController
        
        self.navigationController?.pushViewController(regionPage, animated: true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? regions : regions.filter{$0.city.lowercased().contains(searchText.lowercased())}
        
        self.mytableView.reloadData()
    }

}
