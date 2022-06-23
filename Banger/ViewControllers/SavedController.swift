import UIKit
import FirebaseDatabase
import MapKit

class SavedController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var dataManager:DataManager?
    var posts: [Post]!
    let cellId = "postCell"
    
    @IBOutlet weak var savedPosts_collection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        let tabar = floatingTabBarController as! TabViewController
//        dataManager = tabar.dataManager
//        print("message from Saved: \(dataManager?.test)")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataManager = appDelegate.data
        
        self.title = "Saved Bangers"
        
        savedPosts_collection.delegate = self // Unless you have already defined the delegate in IB
        savedPosts_collection.dataSource = self
        
        posts = []
        fetchData()
        self.savedPosts_collection.register(UINib(nibName: "PostCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
    }
    
    func fetchData(){
        
        let rootRef = Database.database().reference()
        let ref = rootRef.child("Posts")
        
//        for post in dataManager!.currentUser!.savedPost {
//            
//            dataManager?.getPostFromDB(ref: ref, post: post, delegate: self)
//            
//        }
        
        let usersRef = rootRef.child("users")
        usersRef.child(dataManager!.currentUserUID!).child("savedPost").observe(DataEventType.childAdded, with: {snapshot in
            if snapshot.exists(){
//                self.posts.removeAll()
//                //self.fetchData()
//                self.savedPosts_collection.reloadData()
                
                self.dataManager!.getPostFromDB(ref: ref, post: snapshot.value as! String, delegate: self)

                print("somthing changed in users saved posts")
                
            }
        })
        
        
        usersRef.child(dataManager!.currentUserUID!).child("savedPost").observe(DataEventType.childRemoved, with: {snapshot in
            if snapshot.exists(){
                print("\(snapshot.key) --- \(snapshot.value)")
                self.posts.removeAll(where: {$0.uuid! == snapshot.value as! String})
                self.savedPosts_collection.reloadData()
                
            }
        })
        
        

    
    }
    
    
    // MARK: - CollectionView 📚
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = savedPosts_collection.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
               

        cell.configure(imgUrl: posts[indexPath.row].imageUrl ?? "https://cdn-icons.flaticon.com/png/512/2549/premium/2549859.png?token=exp=1653856114~hmac=72ea04d1898a25bdb1692899f4f0094d")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected")
        let showPost = self.storyboard?.instantiateViewController(withIdentifier: "Showpost") as! ShowPostController
        showPost.dataManager = self.dataManager
        showPost.currentPost = posts[indexPath.row]
        navigationController?.pushViewController(showPost, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {


           let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

           let numberofItem: CGFloat = 3

           let collectionViewWidth = self.savedPosts_collection.bounds.width

           let extraSpace = (numberofItem - 1) * flowLayout.minimumInteritemSpacing

           let inset = flowLayout.sectionInset.right + flowLayout.sectionInset.left

           let width = Int((collectionViewWidth - extraSpace - inset) / numberofItem)

           print(width)

           return CGSize(width: width, height: width)
       }
}


// MARK: - Extensions 📚

extension SavedController: Delegate_PostRecieved{
    func postRecieved(post: Post) {
        self.posts.append(post)
        self.savedPosts_collection.reloadData()
    }
    
    
}
